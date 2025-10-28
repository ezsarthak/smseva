import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class IssueMapCard extends StatelessWidget {
  final List<Marker> markers;
  final MapController mapController;

  const IssueMapCard({
    super.key,
    required this.markers,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    return _buildChartCard(
      title: 'Issue Locations',
      subtitle: 'Geographic distribution of issues',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildMapLegendItem('Critical', Colors.red),
              const SizedBox(width: 12),
              _buildMapLegendItem('High', Colors.orange),
              const SizedBox(width: 12),
              _buildMapLegendItem('Medium', Colors.amber),
              const SizedBox(width: 12),
              _buildMapLegendItem('Low', Colors.green),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(18.9582,72.8321), // Bhopal, India
                initialZoom: 11.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app', // Replace with your app's package name
                ),
                MarkerLayer(
                  markers: markers,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Generic card wrapper
  Widget _buildChartCard({required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                  Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                ],
              ),
              
            ],
          ),
          child,
        ],
      ),
    );
  }
}