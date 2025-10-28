import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Model/Issues.dart';


class IssueCard extends StatefulWidget {
  final Issue issue;
  final Function(Issue, String) onStatusUpdate;

  const IssueCard({Key? key, required this.issue, required this.onStatusUpdate})
    : super(key: key);

  @override
  State<IssueCard> createState() => _IssueCardState();
}

class _IssueCardState extends State<IssueCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.01,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) {
              setState(() => _isHovered = true);
              _controller.forward();
            },
            onExit: (_) {
              setState(() => _isHovered = false);
              _controller.reverse();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isHovered
                      ? widget.issue.statusColor.withValues(alpha: 0.4)
                      : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isHovered ? 0.06 : 0.03),
                    blurRadius: _isHovered ? 12 : 4,
                    offset: Offset(0, _isHovered ? 4 : 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildHeader(), _buildContent(), _buildActions()],
                  ),
                  if (_isUpdating)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.issue.priorityColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Updating status...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: widget.issue.priorityColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Status Indicator (Left border accent)
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: widget.issue.statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Ticket ID
                    Text(
                      widget.issue.ticketId,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status Badge
                    _buildCompactStatusBadge(),
                    const Spacer(),
                    // Report Count
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.issue.priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_rounded,
                            size: 12,
                            color: widget.issue.priorityColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.issue.issueCount}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: widget.issue.priorityColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Title
                Text(
                  widget.issue.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: widget.issue.statusBackgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: widget.issue.statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        widget.issue.status.toUpperCase(),
        style: TextStyle(
          color: widget.issue.statusColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meta information - simplified
          Row(
            children: [
              Icon(Icons.category_rounded, size: 16, color: const Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                widget.issue.category,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on_rounded, size: 16, color: const Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.issue.address,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Description - compact
          Text(
            widget.issue.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive layout based on available width
        if (constraints.maxWidth > 400) {
          return Row(
            children: [
              Expanded(
                child: _buildMetaItem(
                  Icons.category_rounded,
                  widget.issue.category,
                  const Color(0xFF8B5CF6),
                  true,
                ),
              ),
              Expanded(
                child: _buildMetaItem(
                  Icons.location_on_rounded,
                  _truncateText(widget.issue.address, 25),
                  const Color(0xFF06B6D4),
                  true,
                ),
              ),
              Expanded(
                child: _buildMetaItem(
                  Icons.calendar_month,
                  _formatDate(widget.issue.createdAt),
                  const Color(0xFF84CC16),
                  false,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMetaItem(
                      Icons.category_rounded,
                      widget.issue.category,
                      const Color(0xFF8B5CF6),
                      true,
                    ),
                  ),
                  Expanded(
                    child: _buildMetaItem(
                      Icons.calendar_month,
                      _formatDate(widget.issue.createdAt),
                      const Color(0xFF84CC16),
                      false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildMetaItem(
                Icons.location_on_rounded,
                widget.issue.address,
                const Color(0xFF06B6D4),
                true,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildMetaItem(IconData icon, String text, Color color, bool have) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: have
          ? const EdgeInsets.only(right: 8)
          : const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.issue.priorityColor.withValues(alpha: 0.08),
            widget.issue.priorityColor.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: widget.issue.priorityColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people_rounded,
            size: 18,
            color: widget.issue.priorityColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Reported by ${widget.issue.users.length} user${widget.issue.users.length > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.issue.priorityColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${widget.issue.issueCount} reports',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isUpdating ? null : () => _showIssueDetails(),
              icon: Icon(
                Icons.visibility_rounded,
                size: 16,
                color: _isUpdating ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              ),
              label: Text(
                'View Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isUpdating ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                side: BorderSide(
                  color: _isUpdating ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (widget.issue.status == 'new') ...[
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : () => _showStatusUpdateDialog('in_progress'),
                icon: _isUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.play_arrow_rounded, size: 16),
                label: Text(
                  _isUpdating ? 'Updating...' : 'Start',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ] else if (widget.issue.status == 'in_progress') ...[
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : () => _showStatusUpdateDialog('admin_completed'),
                icon: _isUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 16),
                label: Text(
                  _isUpdating ? 'Updating...' : 'Complete',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ] else if (widget.issue.status == 'admin_completed') ...[
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pending_outlined,
                      size: 16,
                      color: Color(0xFF7C3AED),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Awaiting Confirmation',
                      style: TextStyle(
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (widget.issue.status == 'completed') ...[
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF059669).withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: Color(0xFF059669),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Completed',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriorityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: widget.issue.priorityColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: widget.issue.priorityColor.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getPriorityIcon(), color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            widget.issue.priorityText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.issue.statusBackgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: widget.issue.statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: widget.issue.statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            widget.issue.status.toUpperCase(),
            style: TextStyle(
              color: widget.issue.statusColor,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  String _formatDate(String dateStr) {
    // Simple date formatting - you can enhance this
    try {
      final parts = dateStr.split(' ');
      if (parts.isNotEmpty) {
        return parts[0]; // Return just the date part
      }
    } catch (e) {
      // Fallback
    }
    return dateStr.length > 10 ? dateStr.substring(0, 10) : dateStr;
  }

  IconData _getPriorityIcon() {
    switch (widget.issue.priorityText) {
      case 'Critical':
        return Icons.warning_rounded;
      case 'High':
        return Icons.priority_high_rounded;
      case 'Medium':
        return Icons.remove_rounded;
      default:
        return Icons.low_priority_rounded;
    }
  }

  void _showIssueDetails() {
    Uint8List? decodedBytes;
    if (widget.issue.photo != null)
      decodedBytes = base64Decode(widget.issue.photo!);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.issue.statusColor.withValues(alpha: 0.3), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with colored background
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.issue.statusColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: widget.issue.statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.issue.statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        color: widget.issue.statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Issue Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: widget.issue.statusColor,
                            ),
                          ),
                          Text(
                            widget.issue.ticketId,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: widget.issue.statusColor.withValues(alpha: 0.7),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, color: widget.issue.statusColor),
                      style: IconButton.styleFrom(
                        backgroundColor: widget.issue.statusColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
              // Content area
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Basic Information', [
                        if (widget.issue.photo != null)
                          Image.memory(decodedBytes!, fit: BoxFit.scaleDown),
                        _buildDetailRow('Ticket ID', widget.issue.ticketId),
                        _buildDetailRow('Title', widget.issue.title),
                        _buildDetailRow('Category', widget.issue.category),
                        _buildDetailRow('Status', widget.issue.status),
                        _buildDetailRow('Priority', widget.issue.priorityText),
                        if (widget.issue.awaitingUserConfirmation == true)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.pending_outlined,
                                  size: 18,
                                  color: const Color(0xFF8B5CF6),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Awaiting user confirmation via SMS',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF8B5CF6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('Location & Time', [
                        _buildDetailRow('Address', widget.issue.address),
                        _buildDetailRow('Created At', widget.issue.createdAt),
                        _buildDetailRow(
                          'Total Reports',
                          widget.issue.issueCount.toString(),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('Description', [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: widget.issue.statusColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: widget.issue.statusColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            widget.issue.description,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('Reporters', [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.issue.users
                              .map(
                                (user) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.issue.statusColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: widget.issue.statusColor
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.person_rounded,
                                        size: 14,
                                        color: widget.issue.statusColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        user,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: widget.issue.statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.issue.statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border(
              left: BorderSide(
                color: widget.issue.statusColor,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: widget.issue.statusColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(String newStatus) {
    String displayStatus = newStatus;
    String message = 'Are you sure you want to mark this issue as "$displayStatus"?';

    if (newStatus == 'admin_completed') {
      displayStatus = 'completed';
      message = 'Mark this issue as completed?\n\n'
          'Note: An SMS will be sent to the user(s) to confirm if the issue is actually resolved. '
          'The issue will be fully marked as completed only after user confirmation.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.update_rounded, color: widget.issue.priorityColor),
            const SizedBox(width: 12),
            const Text('Update Status'),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Set loading state
              setState(() {
                _isUpdating = true;
              });

              // Call the status update callback
              await widget.onStatusUpdate(widget.issue, newStatus);

              // Clear loading state after a brief delay to show the loading animation
              if (mounted) {
                setState(() {
                  _isUpdating = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.issue.priorityColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
