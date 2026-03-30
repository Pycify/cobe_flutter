part of '../main.dart';

class _ShowcaseOverlay extends StatelessWidget {
  const _ShowcaseOverlay({
    required this.scene,
    required this.items,
    this.darkCards = false,
  });

  final GlobeSceneData scene;
  final List<_OverlayCard> items;
  final bool darkCards;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (final item in items) {
      final projection = item.useArc
          ? scene.arcProjections[item.id]
          : scene.markerProjections[item.id];
      if (projection == null || !projection.visible) continue;

      const cardBg = Color(0xFF1E1E2A);

      children.add(
        Positioned(
          left: projection.offset.dx + item.layout.dx,
          top: projection.offset.dy + item.layout.dy,
          child: IgnorePointer(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: item.emoji ? 10 : 14,
                vertical: item.emoji ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: item.accent.withValues(alpha: 0.25),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: item.accent.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.accent,
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: item.accent.withValues(alpha: 0.7),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: item.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 1,
                    height: 16,
                    color: const Color(0xFF5C5C5C),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item.detail,
                    style: const TextStyle(
                      color: Color(0xFFE7E7E7),
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Stack(children: children);
  }
}

class _IpOverlay extends StatelessWidget {
  const _IpOverlay({
    required this.scene,
    required this.loading,
    required this.error,
    required this.data,
  });

  final GlobeSceneData scene;
  final bool loading;
  final bool error;
  final _IpData? data;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: Text(
          'LOCATING...',
          style: TextStyle(
            color: const Color(0xFF2E43FF).withValues(alpha: 0.5),
            fontSize: 11,
            letterSpacing: 3,
          ),
        ),
      );
    }

    if (error || data == null) {
      return Center(
        child: Text(
          error ? 'LOCATION UNAVAILABLE' : '',
          style: const TextStyle(
            color: Color(0xFFB0AAA3),
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
      );
    }

    final projection = scene.markerProjections['you'];
    if (projection == null || !projection.visible) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: <Widget>[
        Positioned(
          left: projection.offset.dx - 64,
          top: projection.offset.dy - 56,
          child: IgnorePointer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF2E43FF).withValues(alpha: 0.4),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xFF2E43FF).withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E43FF),
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: const Color(0xFF2E43FF).withValues(
                                alpha: 0.8,
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'YOU ARE HERE',
                        style: TextStyle(
                          color: Color(0xFF7B9FFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 10,
                  color: const Color(0xFF2E43FF).withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF838383),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          side: const BorderSide(color: Color(0xFFD5D2CD)),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _IntroOverlay extends StatelessWidget {
  const _IntroOverlay({required this.options});

  static const String _orbital =
      'BY GABRIEL  *  USING FLUTTER  *  POWERED BY DART  *  '
      'MADE WITH FLUTTER  *  BUILT FOR THE WEB  *  FLUTTER IS AMAZING  *  '
      'OPEN SOURCE  *  CROSS PLATFORM  *  DART IS FAST  *  GLOBE IN FLUTTER  *  ';

  final CobeOptions options;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _OrbitalTextPainter(
                text: _orbital,
                color: const Color(0xAA2E43FF),
                fontSize: 15,
                orbitScale: 1.15,
                options: options,
              ),
            ),
          ),
        ),
        Center(
          child: IgnorePointer(
            child: SizedBox(
              width: 260,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Text(
                    'GabbyGreat',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Courier New',
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      color: Color(0xCC2E43FF),
                      letterSpacing: 4,
                      height: 1.45,
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ScanlinePainter(
                        lineColor: const Color(0x44F3F3F3),
                        spacing: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  const _ScanlinePainter({required this.lineColor, required this.spacing});

  final Color lineColor;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter old) => false;
}

class _OrbitalTextPainter extends CustomPainter {
  static const double _ringTilt = 0.4;

  const _OrbitalTextPainter({
    required this.text,
    required this.color,
    required this.fontSize,
    required this.orbitScale,
    required this.options,
  });

  final String text;
  final Color color;
  final double fontSize;
  final double orbitScale;
  final CobeOptions options;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final globeRadius = math.min(size.width, size.height) * 0.5 * options.scale;
    final radius = globeRadius * orbitScale;

    final style = TextStyle(
      fontSize: fontSize,
      color: color,
      letterSpacing: 0.8,
      fontWeight: FontWeight.w500,
    );

    final measured = <String, double>{};
    for (final ch in text.characters) {
      if (!measured.containsKey(ch)) {
        final tp = TextPainter(
          text: TextSpan(text: ch, style: style),
          textDirection: TextDirection.ltr,
        )..layout();
        measured[ch] = tp.width;
      }
    }

    final circumference = 2 * math.pi * radius;
    final textWidth = text.characters.fold<double>(
      0,
      (sum, ch) => sum + (measured[ch] ?? fontSize * 0.6),
    );
    if (textWidth <= 0) return;
    final repeats = (circumference / textWidth).ceil() + 1;
    final fullText = text * repeats;
    final glyphs = fullText.characters.toList(growable: false);

    final points = <_ProjectedPoint>[];
    final tangents = <Offset>[];
    const steps = 720;
    for (var i = 0; i <= steps; i++) {
      final lambda = (i / steps) * math.pi * 2;
      points.add(_projectEquatorialPoint(lambda, radius, center));
    }
    for (var i = 0; i < steps; i++) {
      tangents.add(points[i + 1].offset - points[i].offset);
    }

    double distance = 0;
    for (final ch in glyphs.reversed) {
      final cw = measured[ch] ?? fontSize * 0.6;
      final sample = ((distance / circumference) * steps).floor() % steps;
      final position = points[sample];
      final tangent = tangents[sample];
      final rotation = math.atan2(tangent.dy, tangent.dx) + math.pi;
      final offsetFromCenter = position.offset - center;
      final hiddenByGlobe = position.z < 0 &&
          (offsetFromCenter.dx * offsetFromCenter.dx) +
                  (offsetFromCenter.dy * offsetFromCenter.dy) <
              (globeRadius * globeRadius);

      if (hiddenByGlobe) {
        distance += cw;
        continue;
      }

      canvas.save();
      canvas.translate(position.offset.dx, position.offset.dy);
      canvas.rotate(rotation);

      final tp = TextPainter(
        text: TextSpan(text: ch, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();

      distance += cw;
      if (distance > circumference) break;
    }
  }

  _ProjectedPoint _projectEquatorialPoint(
    double lambda,
    double radius,
    Offset center,
  ) {
    final point = _rotate(
      _Point3(
        radius * math.cos(lambda),
        0,
        radius * math.sin(lambda),
      ),
    );
    return _ProjectedPoint(
      offset: Offset(center.dx + point.x, center.dy - point.y),
      z: point.z,
    );
  }

  _Point3 _rotate(_Point3 point) {
    final cx = math.cos(_ringTilt);
    final cy = math.cos(options.phi);
    final sx = math.sin(_ringTilt);
    final sy = math.sin(options.phi);
    return _Point3(
      (cy * point.x) + (sy * point.z),
      (sy * sx * point.x) + (cx * point.y) - (cy * sx * point.z),
      (-sy * cx * point.x) + (sx * point.y) + (cy * cx * point.z),
    );
  }

  @override
  bool shouldRepaint(_OrbitalTextPainter old) =>
      old.text != text ||
      old.color != color ||
      old.fontSize != fontSize ||
      old.orbitScale != orbitScale ||
      old.options != options;
}
