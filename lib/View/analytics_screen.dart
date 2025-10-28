import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:suvidha_admin/constants/AppConst.dart';

import '../Model/Issues.dart';
import '../Widgets/analytics_csv_export.dart';
import '../Widgets/analytics_map.dart';
import '../Widgets/analytics_pdf_upload.dart';
import '../Widgets/analytics_utils.dart';
import '../Widgets/analytics_widgets.dart';
import '../Widgets/empty_state.dart';
import '../Widgets/pie_chart.dart';
import '../Widgets/recent_card.dart';



class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // UI State
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isExporting = false;
  String _errorMessage = '';

  // Data
  List<Issue> _issues = [];
  List<Marker> _markers = [];
  final MapController _mapController = MapController();

  // Cached data
  Map<String, int> _cachedComplaintsBySector = {};
  Map<String, int> _cachedStatusData = {};
  List<Issue> _cachedRecentIssues = [];
  int _totalComplaints = 0;
  int _inProgressCount = 0;
  int _completedCount = 0;
  int _criticalCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchIssues();
  }

  // --- DATA HANDLING ---
  Future<void> _fetchIssues() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
       final String baseUrl = Appconst().serverUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/issues'),
        headers: {'Content-Type': 'application/json'},
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body);
          _issues = jsonData.map((json) => Issue.fromJson(json)).toList();
          _processAndCacheData();
          setState(() => _isLoading = false);
        } else {
          setState(() {
            _errorMessage = 'Failed to load issues. Status: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading issues: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _processAndCacheData() {
    _totalComplaints = _issues.length;
    _inProgressCount = _issues.where((i) => i.status.toLowerCase() == 'in progress').length;
    _completedCount = _issues.where((i) => i.status.toLowerCase() == 'completed').length;
    _criticalCount = _issues.where((i) => i.issueCount >= 10).length;

    final Map<String, int> sectorCounts = {};
    final Map<String, int> statusCounts = {};
    for (final issue in _issues) {
      final category = issue.category.isNotEmpty ? issue.category : 'Other';
      sectorCounts[category] = (sectorCounts[category] ?? 0) + 1;
      final status = getFormattedStatus(issue.status);
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }
    _cachedComplaintsBySector = sectorCounts;
    _cachedStatusData = statusCounts;

    final sortedIssues = List<Issue>.from(_issues);
    sortedIssues.sort((a, b) {
      final dateA = parseDate(a.createdAt);
      final dateB = parseDate(b.createdAt);
      if (dateA != null && dateB != null) return dateB.compareTo(dateA);
      if (dateB == null) return -1;
      if (dateA == null) return 1;
      return 0;
    });

    _cachedRecentIssues = sortedIssues.take(5).toList();
    _createMarkers();
  }

  // --- UI & WIDGETS ---
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analytics Overview')),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analytics Overview')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text('Error Loading Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red[700])),
              const SizedBox(height: 8),
              Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _fetchIssues, child: const Text('Retry')),
            ]),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text('Analytics Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF64748B)), onPressed: () => Navigator.pop(context)),
            actions: [
              IconButton(
                icon: _isRefreshing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh, color: Color(0xFF64748B)),
                onPressed: _isRefreshing ? null : _handleRefresh,
              ),
              IconButton(
                icon: const Icon(Icons.ios_share, color: Color(0xFF64748B)),
                onPressed: _isExporting ? null : _showExportOptions,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatsGrid(
                  totalComplaints: _totalComplaints,
                  inProgressCount: _inProgressCount,
                  completedCount: _completedCount,
                  criticalCount: _criticalCount,
                ),
                const SizedBox(height: 24),
                if (_issues.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildChartCard(
                          title: 'Issues by Category',
                          subtitle: 'Distribution across sectors',
                          child: AnalyticsBarChart(complaintsBySector: _cachedComplaintsBySector),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 1,
                        child: _buildChartCard(
                          title: 'Status Distribution',
                          subtitle: 'Current status overview',
                          child: AnalyticsPieChart(statusData: _cachedStatusData),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  IssueMapCard(markers: _markers, mapController: _mapController),
                  const SizedBox(height: 24),
                  RecentActivityCard(recentIssues: _cachedRecentIssues, onViewAll: _handleViewAllActivity),
                ] else
                  const EmptyState(),
              ],
            ),
          ),
        ),
        if (_isExporting)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Generating Report...', style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // A generic wrapper for chart containers
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  // --- HANDLERS & HELPERS ---
  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await _fetchIssues();
    setState(() => _isRefreshing = false);
    if (mounted && _errorMessage.isEmpty) {
      _showSnackBar('✅ Analytics data refreshed successfully');
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF8B5CF6)),
              title: const Text('Export PDF Report (Latest 20 SMS Reports)'),
              subtitle: const Text('Detailed summary of recent SMS grievances with analysis.'),
              onTap: () {
                Navigator.pop(context);
                _exportPdfReport();
              },
            ),
            const Divider(height: 20),
            ListTile(
              leading: const Icon(Icons.description_rounded, color: Color(0xFF3B82F6)),
              title: const Text('Export All SMS Reports as CSV'),
              subtitle: const Text('Complete SMS grievance data for spreadsheet analysis.'),
              onTap: () {
                Navigator.pop(context);
                _exportIssuesToCsv();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdfReport() async {
    setState(() => _isExporting = true);
    try {
      final service = ExportService(
        issues: _issues,
        complaintsBySector: _cachedComplaintsBySector,
        statusData: _cachedStatusData,
        totalComplaints: _totalComplaints,
        inProgressCount: _inProgressCount,
        completedCount: _completedCount,
        criticalCount: _criticalCount,
      );
      await service.exportPdfReport();
      if (mounted) _showSnackBar('✅ SMS grievance report exported as PDF successfully');
    } catch (e) {
      if (mounted) _showSnackBar('❌ Failed to export PDF: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportIssuesToCsv() async {
    setState(() => _isExporting = true);
    try {
      final service = ExportService(
        issues: _issues,
        complaintsBySector: _cachedComplaintsBySector,
        statusData: _cachedStatusData,
        totalComplaints: _totalComplaints,
        inProgressCount: _inProgressCount,
        completedCount: _completedCount,
        criticalCount: _criticalCount,
      );
      await service.exportIssuesToCsv();
      if (mounted) _showSnackBar('✅ SMS grievance data exported as CSV successfully');
    } catch (e) {
      if (mounted) _showSnackBar('❌ Failed to export CSV: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _handleViewAllActivity() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.only(top: 8), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const Padding(padding: EdgeInsets.all(20), child: Text('All Issues', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)))),
            Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _issues.length,
                    itemBuilder: (context, index) {
                      final sortedIssues = List<Issue>.from(_issues)
                        ..sort((a,b) {
                          final dateA = parseDate(a.createdAt);
                          final dateB = parseDate(b.createdAt);
                          if(dateA != null && dateB != null) return dateB.compareTo(dateA);
                          return 0;
                        });
                      return ActivityItem(issue: sortedIssues[index]);
                    })),
          ],
        ),
      ),
    );
  }

  void _createMarkers() {
    final List<Marker> newMarkers = [];
    for (final issue in _issues) {
      if (issue.location.latitude != 0.0 && issue.location.longitude != 0.0) {
        newMarkers.add(
          Marker(
            point: LatLng(issue.location.latitude, issue.location.longitude),
            width: 80,
            height: 80,
            child: Tooltip(
              message: "${issue.title}\nPriority: ${issue.priorityText}",
              child: Icon(
                Icons.location_pin,
                color: issue.priorityColor,
                size: 40,
              ),
            ),
          ),
        );
      }
    }
    setState(() {
      _markers = newMarkers;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}