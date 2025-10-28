import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final String selectedStatus;
  final String sortBy;
  final Function(String) onCategoryChanged;
  final Function(String) onStatusChanged;
  final Function(String) onSortChanged;

  const FilterBar({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.selectedStatus,
    required this.sortBy,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onSortChanged,
    required bool showCriticalOnly,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                Expanded(flex: 2, child: _buildCategoryDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _buildStatusDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _buildSortDropdown()),
              ],
            );
          } else {
            return Column(
              children: [
                _buildCategoryDropdown(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatusDropdown()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSortDropdown()),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return _buildDropdown(
      label: 'Category',
      value: selectedCategory.isEmpty ? null : selectedCategory,
      icon: Icons.account_tree_rounded,
      items: [
        const DropdownMenuItem(value: '', child: Text('All Categories')),
        ...categories.map(
          (category) =>
              DropdownMenuItem(value: category, child: Text(category)),
        ),
      ],
      onChanged: (value) => onCategoryChanged(value ?? ''),
    );
  }

  Widget _buildStatusDropdown() {
    return _buildDropdown(
      label: 'Status',
      value: selectedStatus.isEmpty ? null : selectedStatus,
      icon: Icons.flag_rounded,
      items: const [
        DropdownMenuItem(value: '', child: Text('All Status')),
        DropdownMenuItem(value: 'new', child: Text('New')),
        DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
        DropdownMenuItem(value: 'admin_completed', child: Text('Awaiting Confirmation')),
        DropdownMenuItem(value: 'completed', child: Text('Completed')),
      ],
      onChanged: (value) => onStatusChanged(value ?? ''),
    );
  }

  Widget _buildSortDropdown() {
    return _buildDropdown(
      label: 'Sort By',
      value: sortBy,
      icon: Icons.sort_rounded,
      items: const [
        DropdownMenuItem(value: 'priority', child: Text('Priority')),
        DropdownMenuItem(value: 'date', child: Text('Date')),
        DropdownMenuItem(value: 'category', child: Text('Category')),
      ],
      onChanged: (value) => onSortChanged(value ?? 'priority'),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E3A8A),
        ),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF475569)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      value: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: Colors.white,
      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
    );
  }
}
