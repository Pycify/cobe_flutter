import 'package:cobe_flutter/cobe_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CobeController', () {
    test('update merges patch and notifies listeners', () {
      final controller = CobeController(_baseOptions());
      var notifications = 0;
      controller.addListener(() {
        notifications += 1;
      });

      controller.update(
        const CobeOptionsPatch(
          phi: 1.25,
          theta: -0.5,
          mapSamples: 4096,
        ),
      );

      expect(notifications, 1);
      expect(controller.options.phi, 1.25);
      expect(controller.options.theta, -0.5);
      expect(controller.options.mapSamples, 4096);
      expect(controller.options.width, 320);
    });

    test('replace swaps options and notifies listeners', () {
      final controller = CobeController(_baseOptions());
      final replacement = _baseOptions().copyWith(
        width: 480,
        height: 240,
        phi: 0.75,
      );
      var notifications = 0;
      controller.addListener(() {
        notifications += 1;
      });

      controller.replace(replacement);

      expect(notifications, 1);
      expect(identical(controller.options, replacement), isTrue);
      expect(controller.options.width, 480);
      expect(controller.options.height, 240);
      expect(controller.options.phi, 0.75);
    });
  });
}

CobeOptions _baseOptions() {
  return const CobeOptions(
    width: 320,
    height: 320,
    phi: 0,
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
