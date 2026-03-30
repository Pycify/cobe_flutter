import 'package:cobe_flutter/src/cobe_models.dart';
import 'package:cobe_flutter/src/map_sampler.dart';
import 'package:cobe_flutter/src/map_sampler_geojson.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapSampler', () {
    test('image sampler returns cached land points for a sample size', () async {
      final first = await MapSampler.instance.landPoints(512);
      final second = await MapSampler.instance.landPoints(512);

      expect(first, isNotEmpty);
      expect(first.length, lessThan(512));
      expect(identical(first, second), isTrue);
    });

    test('geojson sampler returns cached land points for a sample size', () async {
      final first = await GeoJsonMapSampler.instance.landPoints(512);
      final second = await GeoJsonMapSampler.instance.landPoints(512);

      expect(first, isNotEmpty);
      expect(first.length, lessThan(512));
      expect(identical(first, second), isTrue);
    });

    test('image and geojson samplers produce comparable land coverage', () async {
      const samples = 2000;
      final imagePoints = await MapSampler.instance.landPoints(samples);
      final geoJsonPoints = await GeoJsonMapSampler.instance.landPoints(samples);

      final imageKeys = imagePoints.map(_pointKey).toSet();
      final geoJsonKeys = geoJsonPoints.map(_pointKey).toSet();
      final countDelta = (imageKeys.length - geoJsonKeys.length).abs();

      expect(imageKeys, isNotEmpty);
      expect(geoJsonKeys, isNotEmpty);
      expect(imageKeys.length, inInclusiveRange(550, 700));
      expect(geoJsonKeys.length, inInclusiveRange(500, 700));
      expect(countDelta, lessThan(100));
      expect(
        imagePoints.every((point) => point.length > 0.999 && point.length < 1.001),
        isTrue,
      );
      expect(
        geoJsonPoints.every((point) => point.length > 0.999 && point.length < 1.001),
        isTrue,
      );
    });
  });
}

String _pointKey(GlobePoint point) {
  return [
    point.x.toStringAsFixed(6),
    point.y.toStringAsFixed(6),
    point.z.toStringAsFixed(6),
  ].join(',');
}
