part of '../main.dart';

class _IpData {
  const _IpData({
    required this.lat,
    required this.lon,
    this.city,
    this.country,
  });

  final double lat;
  final double lon;
  final String? city;
  final String? country;
}

class _Showcase {
  const _Showcase({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.overlays,
    this.darkCards = false,
  });

  final String title;
  final String subtitle;
  final CobeOptions options;
  final List<_OverlayCard> overlays;
  final bool darkCards;
}

class _OverlayCard {
  const _OverlayCard({
    required this.id,
    required this.title,
    required this.detail,
    required this.accent,
    required this.layout,
    this.useArc = false,
    this.emoji = false,
  });

  final String id;
  final String title;
  final String detail;
  final Color accent;
  final _CardLayout layout;
  final bool useArc;
  final bool emoji;
}

class _CardLayout {
  const _CardLayout({required this.dx, required this.dy});

  final double dx;
  final double dy;
}

class _Point3 {
  const _Point3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;
}

class _ProjectedPoint {
  const _ProjectedPoint({required this.offset, required this.z});

  final Offset offset;
  final double z;
}
