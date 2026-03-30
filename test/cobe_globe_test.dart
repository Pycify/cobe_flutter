import 'package:cobe_flutter/cobe_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CobeGlobe', () {
    testWidgets('overlay builder receives projected marker and arc ids', (
      tester,
    ) async {
      final controller = CobeController(
        _baseOptions().copyWith(
          markers: const <CobeMarker>[
            CobeMarker(
              id: 'lagos',
              location: CobeLocation(6.5244, 3.3792),
              size: 0.08,
            ),
            CobeMarker(location: CobeLocation(35.6762, 139.6503), size: 0.08),
          ],
          arcs: const <CobeArc>[
            CobeArc(
              id: 'atlantic',
              from: CobeLocation(51.5074, -0.1278),
              to: CobeLocation(40.7128, -74.0060),
            ),
            CobeArc(
              from: CobeLocation(-33.8688, 151.2093),
              to: CobeLocation(1.3521, 103.8198),
            ),
          ],
        ),
      );
      GlobeSceneData? capturedScene;

      await tester.pumpWidget(
        _testHost(
          CobeGlobe(
            controller: controller,
            autoRotate: false,
            overlayBuilder: (context, scene) {
              capturedScene = scene;
              return const SizedBox.expand();
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(capturedScene, isNotNull);
      expect(capturedScene!.size, const Size(300, 300));
      expect(capturedScene!.markerProjections.keys, contains('lagos'));
      expect(capturedScene!.markerProjections.length, 1);
      expect(capturedScene!.arcProjections.keys, contains('atlantic'));
      expect(capturedScene!.arcProjections.length, 1);
      expect(
        capturedScene!.markerProjections['lagos']!.offset.dx.isFinite,
        isTrue,
      );
      expect(
        capturedScene!.markerProjections['lagos']!.offset.dy.isFinite,
        isTrue,
      );
      expect(capturedScene!.markerProjections['lagos']!.depth.isFinite, isTrue);
    });

    testWidgets('auto rotate advances phi over time', (tester) async {
      final controller = CobeController(_baseOptions());

      await tester.pumpWidget(
        _testHost(
          CobeGlobe(
            controller: controller,
            autoRotate: true,
            autoRotateSpeed: 0.5,
          ),
        ),
      );

      final initialPhi = controller.options.phi;
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(controller.options.phi, greaterThan(initialPhi));
    });

    testWidgets('dragging updates phi and theta when draggable', (
      tester,
    ) async {
      final controller = CobeController(_baseOptions());

      await tester.pumpWidget(
        _testHost(
          CobeGlobe(controller: controller, autoRotate: false, draggable: true),
        ),
      );

      final initialPhi = controller.options.phi;
      final initialTheta = controller.options.theta;
      await tester.drag(find.byType(CobeGlobe), const Offset(40, -20));
      await tester.pump();

      expect(controller.options.phi, isNot(initialPhi));
      expect(controller.options.theta, isNot(initialTheta));
    });

    testWidgets('dragging is ignored when the widget is not draggable', (
      tester,
    ) async {
      final controller = CobeController(_baseOptions());

      await tester.pumpWidget(
        _testHost(
          CobeGlobe(
            controller: controller,
            autoRotate: false,
            draggable: false,
          ),
        ),
      );

      final initialPhi = controller.options.phi;
      final initialTheta = controller.options.theta;
      await tester.drag(find.byType(CobeGlobe), const Offset(40, -20));
      await tester.pump();

      expect(controller.options.phi, initialPhi);
      expect(controller.options.theta, initialTheta);
    });

    testWidgets('changing sampler type rebuilds successfully', (tester) async {
      final controller = CobeController(_baseOptions());

      await tester.pumpWidget(
        _testHost(
          CobeGlobe(
            controller: controller,
            autoRotate: false,
            mapSamplerType: MapSamplerType.imageMapSampler,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      await tester.pumpWidget(
        _testHost(
          CobeGlobe(
            controller: controller,
            autoRotate: false,
            mapSamplerType: MapSamplerType.geoJsonMapSampler,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CobeGlobe), findsOneWidget);
    });
  });
}

Widget _testHost(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: SizedBox(width: 300, height: 300, child: child)),
  );
}

CobeOptions _baseOptions() {
  return const CobeOptions(
    width: 300,
    height: 300,
    phi: 0,
    theta: 0.2,
    mapSamples: 600,
    mapBrightness: 6,
    baseColor: Color(0xFFEAF1FF),
    markerColor: Color(0xFF2C6BFF),
    glowColor: Color(0xFF8CB6FF),
    diffuse: 1.2,
    dark: 0,
    arcColor: Color(0xFF446BFF),
  );
}
