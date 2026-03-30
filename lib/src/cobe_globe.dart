import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'cobe_controller.dart';
import 'cobe_models.dart';
import 'map_sampler.dart';
import 'map_sampler_geojson.dart';
import 'enum.dart';

typedef GlobeOverlayBuilder =
    Widget Function(BuildContext context, GlobeSceneData scene);

class CobeGlobe extends StatefulWidget {
  const CobeGlobe({
    super.key,
    required this.controller,
    this.overlayBuilder,
    this.draggable = true,
    this.autoRotate = true,
    this.autoRotateSpeed = 0.22,
    this.dragSensitivity = 0.01,
    this.tiltSensitivity = 0.005,
    this.mapSamplerType = MapSamplerType.geoJsonMapSampler,
  });

  final CobeController controller;
  final MapSamplerType mapSamplerType;
  final GlobeOverlayBuilder? overlayBuilder;
  final bool draggable;
  final bool autoRotate;
  final double autoRotateSpeed;
  final double dragSensitivity;
  final double tiltSensitivity;

  @override
  State<CobeGlobe> createState() => _CobeGlobeState();
}

class _CobeGlobeState extends State<CobeGlobe>
    with SingleTickerProviderStateMixin {
  static const double _globeRadius = 0.8;

  Ticker? _ticker;
  Duration? _lastTick;
  int _loadRevision = 0;
  int? _loadedSamples;
  List<GlobePoint> _landPoints = const <GlobePoint>[];
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _ensureMapData();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(CobeGlobe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
    if (oldWidget.controller != widget.controller ||
        oldWidget.mapSamplerType != widget.mapSamplerType) {
      _loadedSamples = null;
      _ensureMapData();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    _ensureMapData();
    if (mounted) {
      setState(() {});
    }
  }

  void _onTick(Duration elapsed) {
    final lastTick = _lastTick;
    _lastTick = elapsed;
    if (!widget.autoRotate || _dragging || lastTick == null) {
      return;
    }

    final deltaSeconds =
        (elapsed - lastTick).inMicroseconds / Duration.microsecondsPerSecond;
    if (deltaSeconds <= 0) {
      return;
    }

    widget.controller.update(
      CobeOptionsPatch(
        phi:
            widget.controller.options.phi +
            (widget.autoRotateSpeed * deltaSeconds),
      ),
    );
  }

  void _ensureMapData() {
    final targetSamples = widget.controller.options.mapSamples;
    if (_loadedSamples == targetSamples) {
      return;
    }

    final revision = ++_loadRevision;
    _loadMapData(targetSamples).then((points) {
      if (!mounted || revision != _loadRevision) {
        return;
      }
      setState(() {
        _loadedSamples = targetSamples;
        _landPoints = points;
      });
    });
  }

  Future<List<GlobePoint>> _loadMapData(int samples) {
    switch (widget.mapSamplerType) {
      case MapSamplerType.imageMapSampler:
        return MapSampler.instance.landPoints(samples);
      case MapSamplerType.geoJsonMapSampler:
        return GeoJsonMapSampler.instance.landPoints(samples);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.controller.options;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : options.width;
        final height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : options.height;
        final size = Size(width, height);
        final scene = _buildScene(size, options);

        return MouseRegion(
          cursor: widget.draggable
              ? (_dragging
                    ? SystemMouseCursors.grabbing
                    : SystemMouseCursors.grab)
              : MouseCursor.defer,
          child: GestureDetector(
            onPanStart: widget.draggable
                ? (_) {
                    setState(() {
                      _dragging = true;
                    });
                  }
                : null,
            onPanEnd: widget.draggable
                ? (_) {
                    setState(() {
                      _dragging = false;
                    });
                  }
                : null,
            onPanCancel: widget.draggable
                ? () {
                    setState(() {
                      _dragging = false;
                    });
                  }
                : null,
            onPanUpdate: widget.draggable
                ? (details) {
                    final current = widget.controller.options;
                    final nextTheta =
                        (current.theta +
                                (details.delta.dy * widget.tiltSensitivity))
                            .clamp(-math.pi / 2, math.pi / 2)
                            .toDouble();
                    widget.controller.update(
                      CobeOptionsPatch(
                        phi:
                            current.phi +
                            (details.delta.dx * widget.dragSensitivity),
                        theta: nextTheta,
                      ),
                    );
                  }
                : null,
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _CobeGlobePainter(
                          options: options,
                          landPoints: _landPoints,
                          globeRadius: _globeRadius,
                        ),
                      ),
                    ),
                  ),
                  if (widget.overlayBuilder != null)
                    Positioned.fill(
                      child: widget.overlayBuilder!(context, scene),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  GlobeSceneData _buildScene(Size size, CobeOptions options) {
    final markerProjections = <String, GlobeProjection>{};
    final arcProjections = <String, GlobeProjection>{};

    for (final marker in options.markers) {
      final id = marker.id;
      if (id == null) {
        continue;
      }
      markerProjections[id] = _projectLocation(
        size: size,
        options: options,
        location: marker.location,
        worldRadius: _globeRadius + options.markerElevation,
      );
    }

    for (final arc in options.arcs) {
      final id = arc.id;
      if (id == null) {
        continue;
      }
      final projection = _projectArcMidpoint(
        size: size,
        options: options,
        arc: arc,
      );
      if (projection != null) {
        arcProjections[id] = projection;
      }
    }

    return GlobeSceneData(
      size: size,
      markerProjections: markerProjections,
      arcProjections: arcProjections,
    );
  }

  GlobeProjection _projectLocation({
    required Size size,
    required CobeOptions options,
    required CobeLocation location,
    required double worldRadius,
  }) {
    final point = _latLonTo3D(location).scale(worldRadius);
    final rotated = _applyRotation(point, options);
    final center = Offset(size.width / 2, size.height / 2) + options.offset;
    final radiusPx = math.min(size.width, size.height) * 0.5 * options.scale;
    final scaleFactor = radiusPx / _globeRadius;

    return GlobeProjection(
      offset: Offset(
        center.dx + (rotated.x * scaleFactor),
        center.dy - (rotated.y * scaleFactor),
      ),
      visible:
          rotated.z >= 0 ||
          ((rotated.x * rotated.x) + (rotated.y * rotated.y) >=
              (_globeRadius * _globeRadius)),
      depth: rotated.z,
    );
  }

  GlobeProjection? _projectArcMidpoint({
    required Size size,
    required CobeOptions options,
    required CobeArc arc,
  }) {
    final from = _latLonTo3D(arc.from);
    final to = _latLonTo3D(arc.to);
    final sum = from + to;
    final sumLength = sum.length;
    if (sumLength < 0.001) {
      return null;
    }

    final scalar =
        (0.25 * (_globeRadius + options.markerElevation)) +
        ((0.5 * (_globeRadius + options.arcHeight + options.markerElevation)) /
            sumLength);
    final rotated = _applyRotation(sum.scale(scalar), options);
    final center = Offset(size.width / 2, size.height / 2) + options.offset;
    final radiusPx = math.min(size.width, size.height) * 0.5 * options.scale;
    final scaleFactor = radiusPx / _globeRadius;

    return GlobeProjection(
      offset: Offset(
        center.dx + (rotated.x * scaleFactor),
        center.dy - (rotated.y * scaleFactor),
      ),
      visible:
          rotated.z >= 0 ||
          ((rotated.x * rotated.x) + (rotated.y * rotated.y) >=
              (_globeRadius * _globeRadius)),
      depth: rotated.z,
    );
  }

  GlobePoint _latLonTo3D(CobeLocation location) {
    final latRad = location.latitude * math.pi / 180;
    final lonRad = (location.longitude * math.pi / 180) - math.pi;
    final cosLat = math.cos(latRad);
    return GlobePoint(
      -cosLat * math.cos(lonRad),
      math.sin(latRad),
      cosLat * math.sin(lonRad),
    );
  }

  GlobePoint _applyRotation(GlobePoint point, CobeOptions options) {
    final cx = math.cos(options.theta);
    final cy = math.cos(options.phi);
    final sx = math.sin(options.theta);
    final sy = math.sin(options.phi);

    return GlobePoint(
      (cy * point.x) + (sy * point.z),
      (sy * sx * point.x) + (cx * point.y) - (cy * sx * point.z),
      (-sy * cx * point.x) + (sx * point.y) + (cy * cx * point.z),
    );
  }
}

class _CobeGlobePainter extends CustomPainter {
  const _CobeGlobePainter({
    required this.options,
    required this.landPoints,
    required this.globeRadius,
  });

  final CobeOptions options;
  final List<GlobePoint> landPoints;
  final double globeRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2) + options.offset;
    final radiusPx = math.min(size.width, size.height) * 0.5 * options.scale;
    final unitScale = radiusPx / globeRadius;
    final sphereRect = Rect.fromCircle(center: center, radius: radiusPx);

    _paintGlow(canvas, center, radiusPx);
    _paintOcean(canvas, sphereRect);
    _paintLand(canvas, center, unitScale);
    _paintArcs(canvas, center, unitScale, radiusPx);
    _paintMarkers(canvas, center, unitScale, radiusPx);
  }

  void _paintGlow(Canvas canvas, Offset center, double radiusPx) {
    final outer = radiusPx * 1.22;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          _withOpacity(
            _mix(options.glowColor, Colors.white, 0.15),
            0.2 * options.opacity,
          ),
          _withOpacity(options.glowColor, 0.08 * options.opacity),
          Colors.transparent,
        ],
        stops: const <double>[0.0, 0.62, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: outer));
    canvas.drawCircle(center, outer, paint);
  }

  void _paintOcean(Canvas canvas, Rect rect) {
    final darkMix = (0.2 + (options.dark * 0.45)).clamp(0.0, 0.8).toDouble();
    final shadow = _mix(options.baseColor, Colors.black, darkMix);
    final highlight = _mix(
      options.baseColor,
      Colors.white,
      0.32 - (options.dark * 0.12),
    );
    final waterLow = _mix(
      shadow,
      options.glowColor,
      0.12 + (options.mapBaseBrightness * 0.3),
    );
    final center = Offset(
      rect.center.dx - (rect.width * 0.12),
      rect.center.dy - (rect.height * 0.16),
    );

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          ((center.dx - rect.center.dx) / rect.width) * 2,
          ((center.dy - rect.center.dy) / rect.height) * 2,
        ),
        radius: 0.95,
        colors: <Color>[
          _withOpacity(highlight, options.opacity),
          _withOpacity(
            _mix(options.baseColor, highlight, 0.35),
            options.opacity,
          ),
          _withOpacity(waterLow, options.opacity),
        ],
        stops: const <double>[0.0, 0.56, 1.0],
      ).createShader(rect);
    canvas.drawOval(rect, paint);

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, rect.width * 0.003).toDouble()
      ..color = _withOpacity(
        _mix(options.glowColor, Colors.white, 0.25),
        0.45 * options.opacity,
      );
    canvas.drawOval(rect.deflate(rect.width * 0.01), rim);
  }

  void _paintLand(Canvas canvas, Offset center, double unitScale) {
    if (landPoints.isEmpty) {
      return;
    }

    final lightMode =
        options.baseColor.computeLuminance() > 0.65 && options.dark < 0.5;
    final darknessBoost = options.dark.clamp(0.0, 1.0).toDouble();
    final baseLand = lightMode
        ? _mix(options.baseColor, const Color(0xFF202020), 0.86)
        : _mix(options.baseColor, Colors.white, 0.68 + (darknessBoost * 0.18));
    final landTint = lightMode
        ? _mix(baseLand, Colors.black, 0.12)
        : _mix(baseLand, Colors.white, 0.18 + (darknessBoost * 0.12));
    final minBrightness = lightMode ? 0.18 : 0.18 + (darknessBoost * 0.1);
    final dotRadius = math.max(0.9, unitScale * 0.0039).toDouble();
    final paint = Paint()..style = PaintingStyle.fill;

    for (final point in landPoints) {
      final rotated = _rotate(point.scale(globeRadius));
      if (rotated.z <= 0) {
        continue;
      }

      final strength = math
          .pow(rotated.z.clamp(0.0, 1.0).toDouble(), options.diffuse)
          .toDouble();
      final brightness = ((0.22 + (options.mapBrightness * 0.1)) * strength)
          .clamp(minBrightness, 1.0)
          .toDouble();
      paint.color = _withOpacity(
        landTint,
        (brightness * options.opacity).clamp(0.0, 1.0).toDouble(),
      );

      canvas.drawCircle(
        Offset(
          center.dx + (rotated.x * unitScale),
          center.dy - (rotated.y * unitScale),
        ),
        dotRadius,
        paint,
      );
    }
  }

  void _paintMarkers(
    Canvas canvas,
    Offset center,
    double unitScale,
    double radiusPx,
  ) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, radiusPx * 0.003).toDouble()
      ..color = _withOpacity(Colors.white, 0.65 * options.opacity);
    final fill = Paint()..style = PaintingStyle.fill;

    for (final marker in options.markers) {
      final projected = _rotate(
        _latLonTo3D(
          marker.location,
        ).scale(globeRadius + options.markerElevation),
      );

      final hiddenByGlobe =
          projected.z < 0 &&
          ((projected.x * projected.x) + (projected.y * projected.y) <
              (globeRadius * globeRadius));
      if (hiddenByGlobe) {
        continue;
      }

      final position = Offset(
        center.dx + (projected.x * unitScale),
        center.dy - (projected.y * unitScale),
      );
      final markerRadius = (marker.size * radiusPx * 0.52)
          .clamp(2.5, 18.0)
          .toDouble();
      fill.color = _withOpacity(
        marker.color ?? options.markerColor,
        options.opacity,
      );

      canvas.drawCircle(position, markerRadius, fill);
      canvas.drawCircle(position, markerRadius + 0.5, stroke);
    }
  }

  void _paintArcs(
    Canvas canvas,
    Offset center,
    double unitScale,
    double radiusPx,
  ) {
    for (final arc in options.arcs) {
      final color = arc.color ?? options.arcColor;
      final path = Path();
      GlobePoint? previousPoint;
      GlobePoint? previousRotated;

      final from = _latLonTo3D(
        arc.from,
      ).scale(globeRadius + options.markerElevation);
      final to = _latLonTo3D(
        arc.to,
      ).scale(globeRadius + options.markerElevation);
      final midSum = _latLonTo3D(arc.from) + _latLonTo3D(arc.to);
      final midDirection = midSum.length < 0.001
          ? const GlobePoint(0, 1, 0)
          : midSum.normalized();
      final mid = midDirection.scale(
        globeRadius + options.arcHeight + options.markerElevation,
      );

      for (var i = 0; i <= 48; i++) {
        final t = i / 48;
        final point = _bezier(from, mid, to, t);
        final rotated = _rotate(point);
        final hidden =
            rotated.z < 0 &&
            ((rotated.x * rotated.x) + (rotated.y * rotated.y) <
                (globeRadius * globeRadius));
        if (hidden) {
          previousPoint = null;
          previousRotated = null;
          continue;
        }

        final offset = Offset(
          center.dx + (rotated.x * unitScale),
          center.dy - (rotated.y * unitScale),
        );
        if (previousPoint == null || previousRotated == null) {
          path.moveTo(offset.dx, offset.dy);
        } else {
          path.lineTo(offset.dx, offset.dy);
        }
        previousPoint = point;
        previousRotated = rotated;
      }

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = (options.arcWidth * radiusPx * 0.01)
            .clamp(1.2, 5.0)
            .toDouble()
        ..color = _withOpacity(color, options.opacity);
      canvas.drawPath(path, paint);
    }
  }

  GlobePoint _latLonTo3D(CobeLocation location) {
    final latRad = location.latitude * math.pi / 180;
    final lonRad = (location.longitude * math.pi / 180) - math.pi;
    final cosLat = math.cos(latRad);
    return GlobePoint(
      -cosLat * math.cos(lonRad),
      math.sin(latRad),
      cosLat * math.sin(lonRad),
    );
  }

  GlobePoint _rotate(GlobePoint point) {
    final cx = math.cos(options.theta);
    final cy = math.cos(options.phi);
    final sx = math.sin(options.theta);
    final sy = math.sin(options.phi);
    return GlobePoint(
      (cy * point.x) + (sy * point.z),
      (sy * sx * point.x) + (cx * point.y) - (cy * sx * point.z),
      (-sy * cx * point.x) + (sx * point.y) + (cy * cx * point.z),
    );
  }

  GlobePoint _bezier(GlobePoint a, GlobePoint b, GlobePoint c, double t) {
    final u = 1 - t;
    return GlobePoint(
      (u * u * a.x) + (2 * u * t * b.x) + (t * t * c.x),
      (u * u * a.y) + (2 * u * t * b.y) + (t * t * c.y),
      (u * u * a.z) + (2 * u * t * b.z) + (t * t * c.z),
    );
  }

  Color _mix(Color a, Color b, double t) =>
      Color.lerp(a, b, t.clamp(0.0, 1.0).toDouble())!;

  Color _withOpacity(Color color, double opacity) =>
      color.withValues(alpha: opacity.clamp(0.0, 1.0).toDouble());

  @override
  bool shouldRepaint(covariant _CobeGlobePainter oldDelegate) {
    return oldDelegate.options != options ||
        oldDelegate.landPoints != landPoints;
  }
}
