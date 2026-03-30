import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// A geographic coordinate in degrees.
@immutable
class CobeLocation {
  /// Creates a location from [latitude] and [longitude] in degrees.
  const CobeLocation(this.latitude, this.longitude);

  /// Latitude in degrees.
  final double latitude;

  /// Longitude in degrees.
  final double longitude;
}

/// A marker projected on top of the globe.
@immutable
class CobeMarker {
  /// Creates a marker at [location] with a normalized [size].
  const CobeMarker({
    required this.location,
    required this.size,
    this.color,
    this.id,
    this.label,
  });

  /// Geographic position of the marker.
  final CobeLocation location;

  /// Marker radius relative to the globe size.
  final double size;

  /// Optional per-marker color override.
  final Color? color;

  /// Stable identifier used by overlays to look up this marker projection.
  final String? id;

  /// Optional human-readable label for downstream UI.
  final String? label;
}

/// A curved connection rendered between two globe locations.
@immutable
class CobeArc {
  /// Creates an arc from [from] to [to].
  const CobeArc({
    required this.from,
    required this.to,
    this.color,
    this.id,
    this.label,
  });

  /// Arc start location.
  final CobeLocation from;

  /// Arc end location.
  final CobeLocation to;

  /// Optional per-arc color override.
  final Color? color;

  /// Stable identifier used by overlays to look up this arc projection.
  final String? id;

  /// Optional human-readable label for downstream UI.
  final String? label;
}

/// Immutable configuration for a rendered globe.
@immutable
class CobeOptions {
  /// Creates a complete set of globe rendering options.
  const CobeOptions({
    required this.width,
    required this.height,
    required this.phi,
    required this.theta,
    required this.mapSamples,
    required this.mapBrightness,
    required this.baseColor,
    required this.markerColor,
    required this.glowColor,
    required this.diffuse,
    required this.dark,
    required this.arcColor,
    this.mapBaseBrightness = 0,
    this.markers = const <CobeMarker>[],
    this.devicePixelRatio = 1,
    this.opacity = 1,
    this.offset = Offset.zero,
    this.scale = 1,
    this.arcs = const <CobeArc>[],
    this.arcWidth = 0.5,
    this.arcHeight = 0.3,
    this.markerElevation = 0.02,
  });

  /// Fallback logical width used when the parent does not constrain the widget.
  final double width;

  /// Fallback logical height used when the parent does not constrain the widget.
  final double height;

  /// Horizontal rotation in radians.
  final double phi;

  /// Vertical tilt in radians.
  final double theta;

  /// Number of land sample points to generate on the sphere.
  final int mapSamples;

  /// Brightness multiplier for visible land samples.
  final double mapBrightness;

  /// Base brightness applied before the land sample multiplier.
  final double mapBaseBrightness;

  /// Color used to paint the globe body.
  final Color baseColor;

  /// Default color used for markers.
  final Color markerColor;

  /// Color used for the globe glow.
  final Color glowColor;

  /// Markers rendered on top of the globe.
  final List<CobeMarker> markers;

  /// Diffuse lighting strength for the globe shading.
  final double diffuse;

  /// Device pixel ratio used by the painter when rasterizing.
  final double devicePixelRatio;

  /// Darkness contribution used in the globe shading model.
  final double dark;

  /// Overall globe opacity.
  final double opacity;

  /// Additional translation applied to the globe center.
  final Offset offset;

  /// Additional scale multiplier applied to the globe radius.
  final double scale;

  /// Arcs rendered across the globe surface.
  final List<CobeArc> arcs;

  /// Default color used for arcs.
  final Color arcColor;

  /// Stroke width used when drawing arcs.
  final double arcWidth;

  /// Height of the arc curve above the globe surface.
  final double arcHeight;

  /// Elevation added to markers above the globe surface.
  final double markerElevation;

  /// Returns a copy with any provided fields replaced.
  CobeOptions copyWith({
    double? width,
    double? height,
    double? phi,
    double? theta,
    int? mapSamples,
    double? mapBrightness,
    double? mapBaseBrightness,
    Color? baseColor,
    Color? markerColor,
    Color? glowColor,
    List<CobeMarker>? markers,
    double? diffuse,
    double? devicePixelRatio,
    double? dark,
    double? opacity,
    Offset? offset,
    double? scale,
    List<CobeArc>? arcs,
    Color? arcColor,
    double? arcWidth,
    double? arcHeight,
    double? markerElevation,
  }) {
    return CobeOptions(
      width: width ?? this.width,
      height: height ?? this.height,
      phi: phi ?? this.phi,
      theta: theta ?? this.theta,
      mapSamples: mapSamples ?? this.mapSamples,
      mapBrightness: mapBrightness ?? this.mapBrightness,
      mapBaseBrightness: mapBaseBrightness ?? this.mapBaseBrightness,
      baseColor: baseColor ?? this.baseColor,
      markerColor: markerColor ?? this.markerColor,
      glowColor: glowColor ?? this.glowColor,
      markers: markers ?? this.markers,
      diffuse: diffuse ?? this.diffuse,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
      dark: dark ?? this.dark,
      opacity: opacity ?? this.opacity,
      offset: offset ?? this.offset,
      scale: scale ?? this.scale,
      arcs: arcs ?? this.arcs,
      arcColor: arcColor ?? this.arcColor,
      arcWidth: arcWidth ?? this.arcWidth,
      arcHeight: arcHeight ?? this.arcHeight,
      markerElevation: markerElevation ?? this.markerElevation,
    );
  }

  /// Returns a copy with the non-null values from [patch] applied.
  CobeOptions merge(CobeOptionsPatch patch) {
    return copyWith(
      width: patch.width,
      height: patch.height,
      phi: patch.phi,
      theta: patch.theta,
      mapSamples: patch.mapSamples,
      mapBrightness: patch.mapBrightness,
      mapBaseBrightness: patch.mapBaseBrightness,
      baseColor: patch.baseColor,
      markerColor: patch.markerColor,
      glowColor: patch.glowColor,
      markers: patch.markers,
      diffuse: patch.diffuse,
      devicePixelRatio: patch.devicePixelRatio,
      dark: patch.dark,
      opacity: patch.opacity,
      offset: patch.offset,
      scale: patch.scale,
      arcs: patch.arcs,
      arcColor: patch.arcColor,
      arcWidth: patch.arcWidth,
      arcHeight: patch.arcHeight,
      markerElevation: patch.markerElevation,
    );
  }
}

/// Partial update payload for [CobeOptions].
@immutable
class CobeOptionsPatch {
  /// Creates a patch with any subset of [CobeOptions] fields.
  const CobeOptionsPatch({
    this.width,
    this.height,
    this.phi,
    this.theta,
    this.mapSamples,
    this.mapBrightness,
    this.mapBaseBrightness,
    this.baseColor,
    this.markerColor,
    this.glowColor,
    this.markers,
    this.diffuse,
    this.devicePixelRatio,
    this.dark,
    this.opacity,
    this.offset,
    this.scale,
    this.arcs,
    this.arcColor,
    this.arcWidth,
    this.arcHeight,
    this.markerElevation,
  });

  /// Replacement for [CobeOptions.width].
  final double? width;

  /// Replacement for [CobeOptions.height].
  final double? height;

  /// Replacement for [CobeOptions.phi].
  final double? phi;

  /// Replacement for [CobeOptions.theta].
  final double? theta;

  /// Replacement for [CobeOptions.mapSamples].
  final int? mapSamples;

  /// Replacement for [CobeOptions.mapBrightness].
  final double? mapBrightness;

  /// Replacement for [CobeOptions.mapBaseBrightness].
  final double? mapBaseBrightness;

  /// Replacement for [CobeOptions.baseColor].
  final Color? baseColor;

  /// Replacement for [CobeOptions.markerColor].
  final Color? markerColor;

  /// Replacement for [CobeOptions.glowColor].
  final Color? glowColor;

  /// Replacement for [CobeOptions.markers].
  final List<CobeMarker>? markers;

  /// Replacement for [CobeOptions.diffuse].
  final double? diffuse;

  /// Replacement for [CobeOptions.devicePixelRatio].
  final double? devicePixelRatio;

  /// Replacement for [CobeOptions.dark].
  final double? dark;

  /// Replacement for [CobeOptions.opacity].
  final double? opacity;

  /// Replacement for [CobeOptions.offset].
  final Offset? offset;

  /// Replacement for [CobeOptions.scale].
  final double? scale;

  /// Replacement for [CobeOptions.arcs].
  final List<CobeArc>? arcs;

  /// Replacement for [CobeOptions.arcColor].
  final Color? arcColor;

  /// Replacement for [CobeOptions.arcWidth].
  final double? arcWidth;

  /// Replacement for [CobeOptions.arcHeight].
  final double? arcHeight;

  /// Replacement for [CobeOptions.markerElevation].
  final double? markerElevation;
}

/// The projected screen-space result for a globe point.
@immutable
class GlobeProjection {
  /// Creates a projected point with visibility and depth metadata.
  const GlobeProjection({
    required this.offset,
    required this.visible,
    required this.depth,
  });

  /// Screen position in logical pixels.
  final Offset offset;

  /// Whether the projected point should be considered visible.
  final bool visible;

  /// Depth after rotation where larger values are closer to the viewer.
  final double depth;
}

/// Overlay data derived from the current rendered globe scene.
@immutable
class GlobeSceneData {
  /// Creates a scene snapshot for overlay builders.
  const GlobeSceneData({
    required this.size,
    required this.markerProjections,
    required this.arcProjections,
  });

  /// The logical size of the rendered globe widget.
  final Size size;

  /// Marker projections keyed by marker id.
  final Map<String, GlobeProjection> markerProjections;

  /// Arc midpoint projections keyed by arc id.
  final Map<String, GlobeProjection> arcProjections;
}

/// A simple 3D vector used by the globe renderer.
@immutable
class GlobePoint {
  /// Creates a 3D point from cartesian coordinates.
  const GlobePoint(this.x, this.y, this.z);

  /// X coordinate.
  final double x;

  /// Y coordinate.
  final double y;

  /// Z coordinate.
  final double z;

  /// Returns this point scaled by [factor].
  GlobePoint scale(double factor) =>
      GlobePoint(x * factor, y * factor, z * factor);

  /// Returns the vector sum of this point and [other].
  GlobePoint operator +(GlobePoint other) =>
      GlobePoint(x + other.x, y + other.y, z + other.z);

  /// Returns the vector difference between this point and [other].
  GlobePoint operator -(GlobePoint other) =>
      GlobePoint(x - other.x, y - other.y, z - other.z);

  /// Returns this point scaled by [factor].
  GlobePoint operator *(double factor) => scale(factor);

  /// Euclidean vector length.
  double get length => math.sqrt((x * x) + (y * y) + (z * z));

  /// Returns a unit-length version of this point.
  GlobePoint normalized() {
    final currentLength = length;
    if (currentLength == 0) {
      return const GlobePoint(0, 0, 0);
    }
    return scale(1 / currentLength);
  }
}
