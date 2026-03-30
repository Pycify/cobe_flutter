import 'package:cobe_flutter/cobe_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'cobe_flutter example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C6BFF)),
        useMaterial3: true,
      ),
      home: const ExampleHome(),
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  late final CobeController _controller = CobeController(
    const CobeOptions(
      width: 420,
      height: 420,
      phi: 0,
      theta: 0.25,
      dark: 0.02,
      diffuse: 1.15,
      mapSamples: 10000,
      mapBrightness: 6,
      baseColor: Color(0xFFEAF1FF),
      markerColor: Color(0xFF2C6BFF),
      glowColor: Color(0xFF9ABEFF),
      arcColor: Color(0xFF446BFF),
      markers: <CobeMarker>[
        CobeMarker(
          id: 'lagos',
          location: CobeLocation(6.5244, 3.3792),
          size: 0.06,
          label: 'Lagos',
        ),
        CobeMarker(
          id: 'tokyo',
          location: CobeLocation(35.6764, 139.6500),
          size: 0.05,
          label: 'Tokyo',
        ),
      ],
      arcs: <CobeArc>[
        CobeArc(
          id: 'lagos-tokyo',
          from: CobeLocation(6.5244, 3.3792),
          to: CobeLocation(35.6764, 139.6500),
          label: 'Lagos to Tokyo',
        ),
      ],
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('cobe_flutter example'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SizedBox(
          width: 420,
          height: 420,
          child: CobeGlobe(
            controller: _controller,
            autoRotate: true,
            autoRotateSpeed: 0.18,
            draggable: true,
          ),
        ),
      ),
    );
  }
}
