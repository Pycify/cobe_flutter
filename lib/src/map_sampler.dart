import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import 'cobe_models.dart';

class MapSampler {
  MapSampler._();

  static final MapSampler instance = MapSampler._();

  _TextureData? _textureData;
  Future<_TextureData>? _textureFuture;
  final Map<int, Future<List<GlobePoint>>> _cache =
      <int, Future<List<GlobePoint>>>{};

  Future<List<GlobePoint>> landPoints(int samples) {
    return _cache.putIfAbsent(samples, () async {
      final texture = await _loadTexture();
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

        if (_sampleMap(texture, point) >= 0.5) {
          points.add(point);
        }
      }

      return points;
    });
  }

  Future<_TextureData> _loadTexture() {
    if (_textureData != null) {
      return Future<_TextureData>.value(_textureData);
    }
    _textureFuture ??= _decodeTexture();
    return _textureFuture!;
  }

  Future<_TextureData> _decodeTexture() async {
    final asset = await rootBundle.load(
      'packages/cobe_flutter/assets/texture.png',
    );
    final codec = await ui.instantiateImageCodec(asset.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final bytes = await frame.image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    final texture = _TextureData(
      width: frame.image.width,
      height: frame.image.height,
      bytes: bytes!.buffer.asUint8List(),
    );
    _textureData = texture;
    return texture;
  }

  double _sampleMap(_TextureData texture, GlobePoint point) {
    final phi = math.asin(point.y);
    final theta = math.atan2(point.z, -point.x);
    final u = (((theta * 0.5) / math.pi) % 1 + 1) % 1;
    final v = (((-((phi / math.pi) + 0.5)) % 1) + 1) % 1;

    final px = (u * (texture.width - 1)).round();
    final py = (v * (texture.height - 1)).round();
    final index = ((py * texture.width) + px) * 4;
    return texture.bytes[index] / 255;
  }
}

class _TextureData {
  const _TextureData({
    required this.width,
    required this.height,
    required this.bytes,
  });

  final int width;
  final int height;
  final Uint8List bytes;
}
