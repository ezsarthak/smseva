import 'dart:ui';

import 'package:flutter/cupertino.dart';

class Location {
  final double longitude;
  final double latitude;

  Location({required this.longitude, required this.latitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
    );
  }
}
class StatData {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final String subtitle;

  StatData(
      this.title,
      this.value,
      this.color,
      this.icon, {
        required this.onTap,
        this.isActive = false,
        required this.subtitle,
      });
}