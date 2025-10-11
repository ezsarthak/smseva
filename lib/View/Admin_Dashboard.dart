import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../Model/Issues.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  List<Issue> issues = [
    Issue(
      ticketId: 'T001',
      category: 'Plumbing',
      address: 'Sector 7, MG Road',
      location: Location(longitude: 77.69, latitude: 28.98),
      description: 'Broken water pipe causing leakage.',
      title: 'Water Leakage',
      status: 'new',
      createdAt: '2025-10-01',
      inProgressAt: '',
      completedAt: '',
      photo: null,
      users: ['user1'],
      issueCount: 4,
      updatedBy: 'admin@suvidha.com',
      originalText: 'Pipe broken at MG Road.',
      admin_completed_at: '',
      user_completed_at: '',
      admin_completed_by: '',
      user_completed_by: '',
    ),
    Issue(
      ticketId: 'T002',
      category: 'Electrical',
      address: 'Sector 3, Indira Nagar',
      location: Location(longitude: 77.71, latitude: 28.97),
      description: 'Street lights not working.',
      title: 'Street Light Fault',
      status: 'in_progress',
      createdAt: '2025-09-29',
      inProgressAt: '',
      completedAt: '',
      photo: null,
      users: ['user2'],
      issueCount: 9,
      updatedBy: 'worker@suvidha.com',
      originalText: 'Electric pole 13 lights off.',
      admin_completed_at: '',
      user_completed_at: '',
      admin_completed_by: '',
      user_completed_by: '',
    ),
    Issue(
      ticketId: 'T003',
      category: 'Cleaning',
      address: 'Rajiv Chowk, Delhi',
      location: Location(longitude: 77.21, latitude: 28.63),
      description: 'Garbage not collected for two days.',
      title: 'Garbage Overflow',
      status: 'completed',
      createdAt: '2025-09-25',
      inProgressAt: '',
      completedAt: '',
      photo: null,
      users: ['user3'],
      issueCount: 12,
      updatedBy: 'admin@suvidha.com',
      originalText: 'Overflowing garbage near metro.',
      admin_completed_at: '',
      user_completed_at: '',
      admin_completed_by: '',
      user_completed_by: '',
    ),
  ];

  List<Issue> filteredIssues = [];
  List<String> categories = ['Plumbing', 'Electrical', 'Cleaning'];
  String selectedCategory = '';
  String selectedStatus = '';
  String sortBy = 'priority';
  bool showCriticalOnly = false;

  late AnimationController _refreshController;
  late AnimationController _filterController;
  late Animation<double> _refreshAnimation;
  late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();
    filteredIssues = List.from(issues);

    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _refreshAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );
    _filterAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _filterController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              image: const DecorationImage(
                  image: AssetImage("assets/Suvidhalogo.png")),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 20),
          const Text(
            'SUVIDHA Admin Portal',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
      actions: [
        AnimatedBuilder(
          animation: _refreshAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _refreshAnimation.value * 2 * 3.14159,
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _refreshController.forward(from: 0);
                  setState(() => filteredIssues = List.from(issues));
                },
                tooltip: 'Refresh Data',
                color: const Color(0xFF667EEA),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        const SizedBox(height: 20),
        FilterBar(
          categories: categories,
          selectedCategory: selectedCategory,
          selectedStatus: selectedStatus,
          showCriticalOnly: showCriticalOnly,
          onCategoryChanged: (category) {
            setState(() {
              selectedCategory = category;
              filteredIssues = issues
                  .where((i) => i.category == category)
                  .toList();
            });
          },
          onStatusChanged: (status) {
            setState(() {
              selectedStatus = status;
              filteredIssues = issues
                  .where((i) => i.status == status)
                  .toList();
            });
          },
          onShowCriticalChanged: (val) {
            setState(() {
              showCriticalOnly = val;
              filteredIssues = val
                  ? issues.where((i) => i.issueCount >= 10).toList()
                  : List.from(issues);
            });
          },
        ),
        Expanded(
          child: filteredIssues.isEmpty
              ? _buildEmptyState()
              : _buildIssuesList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inbox_rounded, size: 80, color: Colors.grey),
          SizedBox(height: 24),
          Text(
            'No issues found',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text('Try changing filters or refresh.'),
        ],
      ),
    );
  }

  Widget _buildIssuesList() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: filteredIssues.length,
        itemBuilder: (context, index) {
          final issue = filteredIssues[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 80,
              child: FadeInAnimation(
                child: IssueCard(issue: issue),
              ),
            ),
          );
        },
      ),
    );
  }
}

class IssueCard extends StatelessWidget {
  final Issue issue;
  const IssueCard({Key? key, required this.issue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: issue.priorityBackgroundColor,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: issue.statusBackgroundColor,
          child: Icon(issue.statusIcon, color: issue.statusColor),
        ),
        title: Text(
          issue.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${issue.category} • ${issue.address}\nPriority: ${issue.priorityText}',
          style: const TextStyle(height: 1.4),
        ),
        trailing: Text(
          issue.status.toUpperCase(),
          style: TextStyle(
              color: issue.statusColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final String selectedStatus;
  final bool showCriticalOnly;
  final Function(String) onCategoryChanged;
  final Function(String) onStatusChanged;
  final Function(bool) onShowCriticalChanged;

  const FilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.selectedStatus,
    required this.showCriticalOnly,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onShowCriticalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          DropdownButton<String>(
            value: selectedCategory.isEmpty ? null : selectedCategory,
            hint: const Text('Filter by Category'),
            items: categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) => onCategoryChanged(value ?? ''),
          ),
          DropdownButton<String>(
            value: selectedStatus.isEmpty ? null : selectedStatus,
            hint: const Text('Filter by Status'),
            items: const [
              DropdownMenuItem(value: 'new', child: Text('New')),
              DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
            ],
            onChanged: (value) => onStatusChanged(value ?? ''),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: showCriticalOnly,
                onChanged: (val) => onShowCriticalChanged(val ?? false),
              ),
              const Text('Show Critical Only'),
            ],
          ),
        ],
      ),
    );
  }
}
