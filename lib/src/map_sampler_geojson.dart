import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

import 'cobe_models.dart';

class GeoJsonMapSampler {
  GeoJsonMapSampler._();

  static final GeoJsonMapSampler instance = GeoJsonMapSampler._();

  final Map<int, Future<List<GlobePoint>>> _cache =
      <int, Future<List<GlobePoint>>>{};
  List<_GeoPolygon>? _polygons;
  Future<List<_GeoPolygon>>? _polygonsFuture;

  Future<List<GlobePoint>> landPoints(int samples) {
    return _cache.putIfAbsent(samples, () async {
      final polygons = await _loadPolygons();
      final points = <GlobePoint>[];
      final dLong = math.pi * (3 - math.sqrt(5));

      for (var index = 0; index < samples; index++) {
        final y = 1 - ((index + 0.5) * 2 / samples);
        final radius = math.sqrt(math.max(0, 1 - (y * y)));
        final theta = dLong * index;
        final point = GlobePoint(
          math.cos(theta) * radius,
          y,
          math.sin(theta) * radius,
        );

        final geoPoint = _toGeoPoint(point);
        if (_isLand(geoPoint, polygons)) {
          points.add(point);
        }
      }

      return points;
    });
  }

  Future<List<_GeoPolygon>> _loadPolygons() {
    if (_polygons != null) {
      return Future<List<_GeoPolygon>>.value(_polygons);
    }
    _polygonsFuture ??= _decodePolygons();
    return _polygonsFuture!;
  }

  Future<List<_GeoPolygon>> _decodePolygons() async {
    final raw = await rootBundle.loadString(
      'packages/cobe_flutter/assets/countries.geojson',
    );
    final data = json.decode(raw) as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>;
    final polygons = <_GeoPolygon>[];

    for (final feature in features) {
      final featureMap = feature as Map<String, dynamic>;
      final geometry = featureMap['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List<dynamic>;
      final bbox = featureMap['bbox'] as List<dynamic>?;

      polygons.add(
        _GeoPolygon(
          rings: coordinates
              .map(
                (ring) => (ring as List<dynamic>)
                    .map((coord) {
                      final pair = coord as List<dynamic>;
                      return _GeoPoint(
                        lon: (pair[0] as num).toDouble(),
                        lat: (pair[1] as num).toDouble(),
                      );
                    })
                    .toList(growable: false),
              )
              .toList(growable: false),
          bounds: bbox == null
              ? null
              : _GeoBounds(
                  minLon: (bbox[0] as num).toDouble(),
                  minLat: (bbox[1] as num).toDouble(),
                  maxLon: (bbox[2] as num).toDouble(),
                  maxLat: (bbox[3] as num).toDouble(),
                ),
        ),
      );
    }

    _polygons = polygons;
    return polygons;
  }

  bool _isLand(_GeoPoint point, List<_GeoPolygon> polygons) {
    for (final polygon in polygons) {
      final bounds = polygon.bounds;
      if (bounds != null && !bounds.contains(point)) {
        continue;
      }
      if (polygon.contains(point)) {
        return true;
      }
    }
    return false;
  }

  _GeoPoint _toGeoPoint(GlobePoint point) {
    final lat = math.asin(point.y) * 180 / math.pi;
    final lon =
        (((math.atan2(point.z, -point.x) + math.pi) * 180 / math.pi) + 180) %
            360 -
        180;
    return _GeoPoint(lon: lon, lat: lat);
  }
}

class _GeoPolygon {
  const _GeoPolygon({required this.rings, required this.bounds});

  final List<List<_GeoPoint>> rings;
  final _GeoBounds? bounds;

  bool contains(_GeoPoint point) {
    if (rings.isEmpty) {
      return false;
    }
    if (!_insideRing(point, rings.first)) {
      return false;
    }
    for (final hole in rings.skip(1)) {
      if (_insideRing(point, hole)) {
        return false;
      }
    }
    return true;
  }

  bool _insideRing(_GeoPoint point, List<_GeoPoint> ring) {
    var inside = false;
    for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final xi = ring[i].lon;
      final yi = ring[i].lat;
      final xj = ring[j].lon;
      final yj = ring[j].lat;

      final intersects =
          ((yi > point.lat) != (yj > point.lat)) &&
          (point.lon <
              ((xj - xi) * (point.lat - yi) / ((yj - yi) + 1e-12)) + xi);
      if (intersects) {
        inside = !inside;
      }
    }
    return inside;
  }
}

class _GeoBounds {
  const _GeoBounds({
    required this.minLon,
    required this.minLat,
    required this.maxLon,
    required this.maxLat,
  });

  final double minLon;
  final double minLat;
  final double maxLon;
  final double maxLat;

  bool contains(_GeoPoint point) {
    return point.lon >= minLon &&
        point.lon <= maxLon &&
        point.lat >= minLat &&
        point.lat <= maxLat;
  }
}

class _GeoPoint {
  const _GeoPoint({required this.lon, required this.lat});

  final double lon;
  final double lat;
}
