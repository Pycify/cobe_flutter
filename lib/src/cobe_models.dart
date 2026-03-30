import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

@immutable
class CobeLocation {
  const CobeLocation(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

@immutable
class CobeMarker {
  const CobeMarker({
    required this.location,
    required this.size,
    this.color,
    this.id,
    this.label,
  });

  final CobeLocation location;
  final double size;
  final Color? color;
  final String? id;
  final String? label;
}

@immutable
class CobeArc {
  const CobeArc({
    required this.from,
    required this.to,
    this.color,
    this.id,
    this.label,
  });

  final CobeLocation from;
  final CobeLocation to;
  final Color? color;
  final String? id;
  final String? label;
}

@immutable
class CobeOptions {
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

  final double width;
  final double height;
  final double phi;
  final double theta;
  final int mapSamples;
  final double mapBrightness;
  final double mapBaseBrightness;
  final Color baseColor;
  final Color markerColor;
  final Color glowColor;
  final List<CobeMarker> markers;
  final double diffuse;
  final double devicePixelRatio;
  final double dark;
  final double opacity;
  final Offset offset;
  final double scale;
  final List<CobeArc> arcs;
  final Color arcColor;
  final double arcWidth;
  final double arcHeight;
  final double markerElevation;

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

@immutable
class CobeOptionsPatch {
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

  final double? width;
  final double? height;
  final double? phi;
  final double? theta;
  final int? mapSamples;
  final double? mapBrightness;
  final double? mapBaseBrightness;
  final Color? baseColor;
  final Color? markerColor;
  final Color? glowColor;
  final List<CobeMarker>? markers;
  final double? diffuse;
  final double? devicePixelRatio;
  final double? dark;
  final double? opacity;
  final Offset? offset;
  final double? scale;
  final List<CobeArc>? arcs;
  final Color? arcColor;
  final double? arcWidth;
  final double? arcHeight;
  final double? markerElevation;
}

@immutable
class GlobeProjection {
  const GlobeProjection({
    required this.offset,
    required this.visible,
    required this.depth,
  });

  final Offset offset;
  final bool visible;
  final double depth;
}

@immutable
class GlobeSceneData {
  const GlobeSceneData({
    required this.size,
    required this.markerProjections,
    required this.arcProjections,
  });

  final Size size;
  final Map<String, GlobeProjection> markerProjections;
  final Map<String, GlobeProjection> arcProjections;
}

@immutable
class GlobePoint {
  const GlobePoint(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  GlobePoint scale(double factor) =>
      GlobePoint(x * factor, y * factor, z * factor);

  GlobePoint operator +(GlobePoint other) =>
      GlobePoint(x + other.x, y + other.y, z + other.z);

  GlobePoint operator -(GlobePoint other) =>
      GlobePoint(x - other.x, y - other.y, z - other.z);

  GlobePoint operator *(double factor) => scale(factor);

  double get length => math.sqrt((x * x) + (y * y) + (z * z));

  GlobePoint normalized() {
    final currentLength = length;
    if (currentLength == 0) {
      return const GlobePoint(0, 0, 0);
    }
    return scale(1 / currentLength);
  }
}
