import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:suvidha_admin/View/worker_assignment.dart';
import 'package:suvidha_admin/View/analytics_screen.dart';
import 'package:suvidha_admin/Widgets/filter_bar.dart';
import 'package:suvidha_admin/Widgets/issue_card.dart';
import 'package:suvidha_admin/Widgets/loading_shimmer.dart';
import '../Model/Issues.dart';
import '../Services/api_service.dart';



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

  late AnimationController _filterController;
  late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _filterAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _filterController, curve: Curves.easeOutBack),
    );

    loadData();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      final [issuesData, categoriesData] = await Future.wait([
        ApiService.getIssues(),
        ApiService.getCategories(),
      ]);

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        issues = issuesData as List<Issue>;
        categories = categoriesData as List<String>;
        filteredIssues = List.from(issues);
        isLoading = false;
      });

      _applyFiltersAndSort();
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Error loading data: $e');
    }
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
    try {
      final success = await ApiService.updateIssueStatus(
        issue.ticketId,
        newStatus,
      );

      if (success) {
        setState(() {
          final index = issues.indexWhere((i) => i.ticketId == issue.ticketId);
          if (index != -1) {
            // Update status and awaitingUserConfirmation based on new status
            bool? awaitingConfirmation;
            if (newStatus == 'admin_completed') {
              awaitingConfirmation = true;
            } else if (newStatus == 'in_progress' || newStatus == 'completed') {
              awaitingConfirmation = false;
            }

            issues[index] = issue.copyWith(
              status: newStatus,
              awaitingUserConfirmation: awaitingConfirmation,
            );
          }
        });
        _applyFiltersAndSort();
        _showSuccessSnackBar('Issue status updated successfully');
      } else {
        _showErrorSnackBar('Failed to update issue status');
      }
    } catch (e) {
      print('Error updating issue status: $e');
      _showErrorSnackBar('Error updating issue status: $e');
    }
  }

  void _showFilterSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.filter_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
        elevation: 8,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.error_outline, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
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
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle_outline, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
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
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          _buildGovHeader(),
          _buildBreadcrumb(),
          Expanded(child: isLoading ? LoadingShimmer() : _buildBody()),
        ],
      ),
    );
  }

  Widget _buildGovHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF1E3A8A), // Deep Blue
            const Color(0xFF1E40AF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top bar with national emblem style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance, color: Colors.white.withValues(alpha: 0.9), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Government of India',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Icon(Icons.language, color: Colors.white.withValues(alpha: 0.7), size: 18),
                const SizedBox(width: 8),
                Text(
                  'English',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Main header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Row(
              children: [
                // Logo
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    "assets/Suvidhalogo.png",
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 20),
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SUVIDHA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'जन सुविधा एवं शिकायत निवारण प्रणाली',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Public Grievance Redressal System',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Actions
                Row(
                  children: [
                    _buildHeaderButton(
                      icon: Icons.engineering_outlined,
                      label: 'Worker Assignment',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkerAssignmentScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildHeaderButton(
                      icon: Icons.bar_chart_rounded,
                      label: 'Analytics',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildHeaderButton(
                      icon: Icons.refresh_rounded,
                      label: isLoading ? 'Refreshing...' : 'Refresh',
                      onPressed: isLoading ? null : loadData,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: onPressed == null ? 0.05 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: onPressed == null ? 0.1 : 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: Colors.white.withValues(alpha: onPressed == null ? 0.5 : 1.0),
                    size: 20,
                  ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: onPressed == null ? 0.5 : 1.0),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.home_outlined, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            'Home',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
          ),
          Text(
            'Admin Dashboard',
            style: TextStyle(
              color: Colors.grey[900],
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF059669).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: const Color(0xFF059669)),
                const SizedBox(width: 6),
                Text(
                  'Online',
                  style: TextStyle(
                    color: const Color(0xFF059669),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBody() {
    return AnimatedBuilder(
      animation: _filterAnimation,
      builder: (context, child) {
        return Column(
          children: [
            // Compact Stats Summary
            _buildCompactStats(),
            const SizedBox(height: 16),
            // Compact Filter Bar
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
            const SizedBox(height: 16),
            // Main Content Area - Full Width
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

  Widget _buildCompactStats() {
    final newIssues = issues.where((i) => i.status == 'new').length;
    final inProgressIssues = issues.where((i) => i.status == 'in_progress').length;
    final awaitingIssues = issues.where((i) => i.status == 'admin_completed').length;
    final completedIssues = issues.where((i) => i.status == 'completed').length;
    final criticalIssues = issues.where((i) => i.issueCount >= 10).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Determine number of columns based on width
          int crossAxisCount = constraints.maxWidth > 1400 ? 6 :
                               constraints.maxWidth > 1000 ? 4 :
                               constraints.maxWidth > 600 ? 3 : 2;

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildCompactStatCard(
                'Total',
                issues.length.toString(),
                Icons.dashboard_rounded,
                const Color(0xFF1E3A8A),
                isSelected: selectedStatus.isEmpty && selectedCategory.isEmpty && !showCriticalOnly,
                onTap: _handleShowAll,
              ),
              _buildCompactStatCard(
                'New',
                newIssues.toString(),
                Icons.fiber_new_rounded,
                const Color(0xFFDC2626),
                isSelected: selectedStatus == 'new',
                onTap: () => _handleStatusFilter('new'),
              ),
              _buildCompactStatCard(
                'In Progress',
                inProgressIssues.toString(),
                Icons.work_outline_rounded,
                const Color(0xFF2563EB),
                isSelected: selectedStatus == 'in_progress',
                onTap: () => _handleStatusFilter('in_progress'),
              ),
              _buildCompactStatCard(
                'Awaiting',
                awaitingIssues.toString(),
                Icons.pending_outlined,
                const Color(0xFF7C3AED),
                isSelected: selectedStatus == 'admin_completed',
                onTap: () => _handleStatusFilter('admin_completed'),
              ),
              _buildCompactStatCard(
                'Completed',
                completedIssues.toString(),
                Icons.check_circle_outline_rounded,
                const Color(0xFF059669),
                isSelected: selectedStatus == 'completed',
                onTap: () => _handleStatusFilter('completed'),
              ),
              _buildCompactStatCard(
                'Critical',
                criticalIssues.toString(),
                Icons.warning_rounded,
                const Color(0xFFB91C1C),
                isSelected: showCriticalOnly,
                onTap: _handleShowCritical,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompactStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF64748B),
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : color,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white.withValues(alpha: 0.9) : color.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String emptyMessage = 'No issues found';
    String emptySubMessage = 'Try adjusting your filters to see more results';
    IconData emptyIcon = Icons.inbox_rounded;
    Color emptyColor = Colors.grey[400]!;

    if (showCriticalOnly) {
      emptyMessage = 'No critical issues! 🎉';
      emptySubMessage = 'Excellent! All issues are under control';
      emptyIcon = Icons.celebration_rounded;
      emptyColor = const Color(0xFF56AB2F);
    } else if (selectedStatus.isNotEmpty) {
      // Custom messages for each status
      switch (selectedStatus) {
        case 'new':
          emptyMessage = 'No new issues';
          emptySubMessage = 'All issues have been reviewed';
          emptyIcon = Icons.check_circle_outline;
          emptyColor = const Color(0xFF56AB2F);
          break;
        case 'in_progress':
          emptyMessage = 'No issues in progress';
          emptySubMessage = 'All work has been completed or not started';
          break;
        case 'admin_completed':
          emptyMessage = 'No issues awaiting confirmation';
          emptySubMessage = 'All completed issues have been confirmed by users';
          emptyIcon = Icons.verified_outlined;
          emptyColor = const Color(0xFF8B5CF6);
          break;
        case 'completed':
          emptyMessage = 'No completed issues';
          emptySubMessage = 'No issues have been fully resolved yet';
          break;
        default:
          emptyMessage = 'No ${selectedStatus} issues found';
          emptySubMessage = 'Try selecting a different status or clear filters';
      }
    }

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    emptyColor.withValues(alpha: 0.1),
                    emptyColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: emptyColor.withValues(alpha: 0.2), width: 2),
              ),
              child: Icon(emptyIcon, size: 80, color: emptyColor),
            ),
            const SizedBox(height: 32),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: emptyColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              emptySubMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (selectedStatus.isNotEmpty ||
                selectedCategory.isNotEmpty ||
                showCriticalOnly) ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _handleShowAll,
                  icon: const Icon(Icons.clear_all_rounded, color: Colors.white),
                  label: const Text(
                    'Clear All Filters',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
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
