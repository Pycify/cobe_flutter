import 'package:cobe_flutter/cobe_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CobeOptions', () {
    test('copyWith only replaces supplied values', () {
      final marker = CobeMarker(
        id: 'lagos',
        location: const CobeLocation(6.5244, 3.3792),
        size: 0.08,
      );
      final options = _baseOptions().copyWith(markers: <CobeMarker>[marker]);

      final copy = options.copyWith(
        width: 640,
        phi: 1.2,
        opacity: 0.6,
      );

      expect(copy.width, 640);
      expect(copy.phi, 1.2);
      expect(copy.opacity, 0.6);
      expect(copy.height, options.height);
      expect(copy.markers, same(options.markers));
    });

    test('merge applies a patch across scalar and collection fields', () {
      final arc = CobeArc(
        id: 'route',
        from: const CobeLocation(51.5074, -0.1278),
        to: const CobeLocation(40.7128, -74.0060),
      );
      final options = _baseOptions();

      final merged = options.merge(
        CobeOptionsPatch(
          theta: -0.4,
          scale: 1.3,
          arcs: <CobeArc>[arc],
          markerColor: Colors.orange,
        ),
      );

      expect(merged.theta, -0.4);
      expect(merged.scale, 1.3);
      expect(merged.arcs, <CobeArc>[arc]);
      expect(merged.markerColor, Colors.orange);
      expect(merged.width, options.width);
      expect(merged.baseColor, options.baseColor);
    });
  });

  group('GlobePoint', () {
    test('supports vector arithmetic and scaling', () {
      const a = GlobePoint(1, 2, 3);
      const b = GlobePoint(-2, 4, 1);

      expect(a + b, _pointEquals(const GlobePoint(-1, 6, 4)));
      expect(a - b, _pointEquals(const GlobePoint(3, -2, 2)));
      expect(a * 2, _pointEquals(const GlobePoint(2, 4, 6)));
      expect(a.scale(0.5), _pointEquals(const GlobePoint(0.5, 1, 1.5)));
      expect(a.length, closeTo(3.7416573867, 1e-9));
    });

    test('normalized returns a unit vector and handles zero length', () {
      const point = GlobePoint(3, 0, 4);

      final normalized = point.normalized();

      expect(normalized.length, closeTo(1, 1e-9));
      expect(
        normalized,
        _pointEquals(const GlobePoint(0.6, 0, 0.8)),
      );
      expect(
        const GlobePoint(0, 0, 0).normalized(),
        _pointEquals(const GlobePoint(0, 0, 0)),
      );
    });
  });
}

Matcher _pointEquals(GlobePoint expected) {
  return isA<GlobePoint>()
      .having((point) => point.x, 'x', closeTo(expected.x, 1e-9))
      .having((point) => point.y, 'y', closeTo(expected.y, 1e-9))
      .having((point) => point.z, 'z', closeTo(expected.z, 1e-9));
}

CobeOptions _baseOptions() {
  return const CobeOptions(
    width: 320,
    height: 320,
    phi: 0.3,
    theta: 0.2,
    mapSamples: 1200,
    mapBrightness: 6,
    baseColor: Color(0xFFEAF1FF),
    markerColor: Color(0xFF2C6BFF),
    glowColor: Color(0xFF8CB6FF),
    diffuse: 1.2,
    dark: 0,
    arcColor: Color(0xFF446BFF),
  );
}
