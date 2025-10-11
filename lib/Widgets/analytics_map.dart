import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../Model/Issues.dart';

class IssueMap extends StatelessWidget {
  final List<Issue> issues;
  final MapController mapController = MapController();

  IssueMap({super.key, required this.issues});

  @override
  Widget build(BuildContext context) {
    final markers = issues
        .where((i) => i.location.latitude != 0 && i.location.longitude != 0)
        .map(
          (i) => Marker(
        point: LatLng(i.location.latitude, i.location.longitude),
        width: 40,
        height: 40,
        child: const Icon(Icons.location_pin, color: Colors.red, size: 30),
      ),
    )
        .toList();

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: LatLng(23.2599, 77.4126),
        zoom: 11.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
