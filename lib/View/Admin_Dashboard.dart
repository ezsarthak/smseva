import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../Model/Issues.dart';
import '../widgets/issue_card.dart';
import '../widgets/filter_bar.dart';
import '../widgets/stats_overview.dart';
import '../widgets/loading_shimmer.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  List<Issue> issues = [];
  List<Issue> filteredIssues = [];
  List<String> categories = [];
  bool isLoading = true;
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

    loadData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    _refreshController.forward();

    await Future.delayed(const Duration(seconds: 1)); // simulate loading

    // 🟢 Dummy data (no API calls)
    issues = [
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

    categories = ['Water', 'Electricity', 'Roads', 'Waste Management'];

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      filteredIssues = List.from(issues);
      isLoading = false;
    });

    _applyFiltersAndSort();
    _refreshController.reset();
  }

  void _applyFiltersAndSort() {
    _filterController.forward().then((_) => _filterController.reset());

    setState(() {
      filteredIssues = issues.where((issue) {
        bool categoryMatch =
            selectedCategory.isEmpty || issue.category == selectedCategory;
        bool statusMatch =
            selectedStatus.isEmpty || issue.status == selectedStatus;
        bool criticalMatch = !showCriticalOnly || issue.issueCount >= 10;
        return categoryMatch && statusMatch && criticalMatch;
      }).toList();

      switch (sortBy) {
        case 'priority':
          filteredIssues.sort((a, b) => b.issueCount.compareTo(a.issueCount));
          break;
        case 'date':
          filteredIssues.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'category':
          filteredIssues.sort((a, b) => a.category.compareTo(b.category));
          break;
      }
    });
  }

  void _handleStatusFilter(String status) {
    HapticFeedback.mediumImpact();
    setState(() {
      selectedStatus = status;
      selectedCategory = '';
      showCriticalOnly = false;
    });
    _applyFiltersAndSort();
    _showFilterSnackBar(
      'Filtered by status: ${status.isEmpty ? 'All' : status}',
      const Color(0xFF667EEA),
    );
  }

  void _handleShowAll() {
    HapticFeedback.mediumImpact();
    setState(() {
      selectedStatus = '';
      selectedCategory = '';
      showCriticalOnly = false;
    });
    _applyFiltersAndSort();
    _showFilterSnackBar('Showing all issues', const Color(0xFF667EEA));
  }

  void _handleShowCritical() {
    HapticFeedback.mediumImpact();
    setState(() {
      selectedStatus = '';
      selectedCategory = '';
      showCriticalOnly = true;
    });
    _applyFiltersAndSort();
    _showFilterSnackBar(
      'Showing critical issues only',
      const Color(0xFFFF416C),
    );
  }

  Future<void> _updateIssueStatus(Issue issue, String newStatus) async {
    // 🟢 No API — just update locally
    setState(() {
      final index = issues.indexWhere((i) => i.ticketId == issue.ticketId);
      if (index != -1) {
        issues[index] = issue.copyWith(status: newStatus);
      }
    });
    _applyFiltersAndSort();
    _showSuccessSnackBar('Issue status updated locally');
  }

  void _showFilterSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF416C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF56AB2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: _buildAppBar(),
          ),
          Expanded(child: isLoading ? LoadingShimmer() : _buildBody()),
        ],
      ),
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
                image: AssetImage("assets/Suvidhalogo.png"),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 20),
          const Text(
            'SUVIDHA Admin Portal',
            style: TextStyle(
              letterSpacing: 1,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
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
                onPressed: isLoading ? null : loadData,
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
    return AnimatedBuilder(
      animation: _filterAnimation,
      builder: (context, child) {
        return Column(
          children: [
            const SizedBox(height: 20),
            FilterBar(
              categories: categories,
              selectedCategory: selectedCategory,
              selectedStatus: selectedStatus,
              sortBy: sortBy,
              showCriticalOnly: showCriticalOnly,
              onCategoryChanged: (category) {
                setState(() {
                  selectedCategory = category;
                  showCriticalOnly = false;
                });
                _applyFiltersAndSort();
              },
              onStatusChanged: (status) {
                setState(() {
                  selectedStatus = status;
                  showCriticalOnly = false;
                });
                _applyFiltersAndSort();
              },
              onSortChanged: (sort) {
                setState(() => sortBy = sort);
                _applyFiltersAndSort();
              },
            ),
            Expanded(
              child: filteredIssues.isEmpty
                  ? _buildEmptyState()
                  : _buildIssuesList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No issues found!',
        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildIssuesList() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: filteredIssues.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 100.0,
              child: FadeInAnimation(
                child: IssueCard(
                  issue: filteredIssues[index],
                  onStatusUpdate: _updateIssueStatus,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
