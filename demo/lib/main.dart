import 'dart:convert';
import 'dart:math' as math;

import 'package:cobe_flutter/cobe_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

part 'src/demo_models.dart';
part 'src/demo_showcases.dart';
part 'src/demo_overlays.dart';

void main() {
  runApp(const CobeDemoApp());
}

class CobeDemoApp extends StatelessWidget {
  const CobeDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'COBE Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F7F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E43FF),
          brightness: Brightness.light,
          primary: const Color(0xFF2E43FF),
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const DemoHome(),
    );
  }
}

class DemoHome extends StatefulWidget {
  const DemoHome({super.key});

  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  late final CobeController _controller;
  int _activeIndex = 0;
  final Set<MapSamplerType> _visibleGlobes = <MapSamplerType>{
    ...MapSamplerType.values,
  };

  _IpData? _ipData;
  bool _ipLoading = false;
  bool _ipError = false;

  CobeOptions _buildIpOptions(_IpData data) {
    final phi = -(math.pi / 2) - (data.lon * math.pi / 180);
    final theta = (data.lat * math.pi / 180).clamp(-math.pi / 2, math.pi / 2);
    return CobeOptions(
      width: 680,
      height: 680,
      phi: phi,
      theta: theta,
      dark: 0.02,
      diffuse: 1.16,
      mapSamples: 11000,
      mapBrightness: 6.2,
      mapBaseBrightness: 0.1,
      baseColor: const Color(0xFFF3F3F3),
      markerColor: const Color(0xFF2E43FF),
      glowColor: const Color(0xFFF0F0F0),
      arcColor: const Color(0xFF2E43FF),
      markerElevation: 0.02,
      markers: <CobeMarker>[
        CobeMarker(
          id: 'you',
          location: CobeLocation(data.lat, data.lon),
          size: 0.022,
        ),
      ],
    );
  }

  Future<void> _fetchIpLocation() async {
    if (_ipData != null || _ipLoading) return;
    setState(() {
      _ipLoading = true;
      _ipError = false;
    });
    try {
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = _IpData(
          lat: (json['latitude'] as num).toDouble(),
          lon: (json['longitude'] as num).toDouble(),
          city: json['city'] as String?,
          country: json['country_name'] as String?,
        );
        setState(() {
          _ipData = data;
          _ipLoading = false;
        });
        if (_activeIndex == _ipShowcaseIndex) {
          _controller.replace(_buildIpOptions(data));
        }
      } else {
        setState(() {
          _ipLoading = false;
          _ipError = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _ipLoading = false;
          _ipError = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = CobeController(_showcases.first.options);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setShowcase(int index) {
    setState(() => _activeIndex = index);
    if (index == _ipShowcaseIndex) {
      if (_ipData != null) {
        _controller.replace(_buildIpOptions(_ipData!));
      } else {
        _controller.replace(_ipPlaceholderOptions);
        _fetchIpLocation();
      }
    } else {
      _controller.replace(_showcases[index].options);
    }
  }

  void _toggleGlobe(MapSamplerType type, bool enabled) {
    if (!enabled && _visibleGlobes.length == 1 && _visibleGlobes.contains(type)) {
      return;
    }

    setState(() {
      if (enabled) {
        _visibleGlobes.add(type);
      } else {
        _visibleGlobes.remove(type);
      }
    });
  }

  String _globeLabel(MapSamplerType type) {
    switch (type) {
      case MapSamplerType.imageMapSampler:
        return 'Image Map Sampler';
      case MapSamplerType.geoJsonMapSampler:
        return 'GeoJSON Map Sampler';
    }
  }

  @override
  Widget build(BuildContext context) {
    final showcase = _showcases[_activeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              children: <Widget>[
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: MapSamplerType.values.map((type) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                          value: _visibleGlobes.contains(type),
                          onChanged: (value) =>
                              _toggleGlobe(type, value ?? false),
                        ),
                        Text(
                          _globeLabel(type),
                          style: const TextStyle(
                            color: Color(0xFF5A5651),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Row(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ...MapSamplerType.values
                        .where(_visibleGlobes.contains)
                        .map(
                      (type) => CobeGlobe(
                        controller: _controller,
                        autoRotate: _activeIndex != _ipShowcaseIndex,
                        autoRotateSpeed: 0.16,
                        mapSamplerType: type,
                        overlayBuilder: (context, scene) {
                          if (_activeIndex == _ipShowcaseIndex) {
                            return _IpOverlay(
                              scene: scene,
                              loading: _ipLoading,
                              error: _ipError,
                              data: _ipData,
                            );
                          }
                          if (_activeIndex == _introShowcaseIndex) {
                            return _IntroOverlay(options: _controller.options);
                          }
                          return _ShowcaseOverlay(
                            scene: scene,
                            items: showcase.overlays,
                            darkCards: showcase.darkCards,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  showcase.title,
                  style: const TextStyle(
                    color: Color(0xFF2E43FF),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3.4,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    _showcases.length,
                    (index) => Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: index == _activeIndex
                            ? const Color(0xFF2E43FF)
                            : const Color(0xFFD8D6D3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: 200,
                  height: 2,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned.fill(
                        child: Container(color: const Color(0xFFD6D3CF)),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOut,
                        left:
                            (_activeIndex / (_showcases.length - 1)) *
                            (200 - 80),
                        top: 0,
                        child: Container(
                          width: 80,
                          height: 2,
                          color: const Color(0xFF2E43FF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _NavButton(
                      icon: Icons.arrow_back,
                      onPressed: _activeIndex > 0
                          ? () => _setShowcase(_activeIndex - 1)
                          : null,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        _activeIndex == _ipShowcaseIndex && _ipData != null
                            ? '${_ipData!.city ?? '—'}, ${_ipData!.country ?? '—'}'
                            : showcase.subtitle,
                        style: TextStyle(
                          color: const Color(0xFF96918B),
                          fontSize:
                              _activeIndex == _ipShowcaseIndex &&
                                  _ipData != null
                              ? 13
                              : 18,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    _NavButton(
                      icon: Icons.arrow_forward,
                      onPressed: _activeIndex < _showcases.length - 1
                          ? () => _setShowcase(_activeIndex + 1)
                          : null,
                    ),
                  ],
                ),
                if (_activeIndex == _ipShowcaseIndex &&
                    _ipData != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    '${_ipData!.lat.abs().toStringAsFixed(4)}°'
                    '${_ipData!.lat >= 0 ? 'N' : 'S'}  '
                    '${_ipData!.lon.abs().toStringAsFixed(4)}°'
                    '${_ipData!.lon >= 0 ? 'E' : 'W'}',
                    style: const TextStyle(
                      color: Color(0xFFB0AAA3),
                      fontSize: 11,
                      letterSpacing: 1.8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
