// lib/features/admin_platform/customer_management/sales_pipeline/widgets/pipeline_filters.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sales_pipeline_controller.dart';

class PipelineFilters extends StatelessWidget {
  const PipelineFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesPipelineController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Owner filter
          _buildFilterDropdown(
            label: 'Owner',
            value: controller.ownerFilter.value,
            items: const [
              {'value': 'all', 'label': 'All'},
              {'value': 'me', 'label': 'My Deals'},
              {'value': 'team', 'label': 'Team Deals'},
            ],
            onChanged: (value) => controller.ownerFilter.value = value!,
          ),
          const SizedBox(width: 16),

          // Hot deals toggle
          _buildToggleFilter(
            label: 'Hot Deals',
            icon: Icons.local_fire_department,
            value: controller.showHotDeals.value,
            activeColor: Colors.red,
            onChanged: (value) => controller.showHotDeals.value = value,
          ),
          const SizedBox(width: 16),

          // Rotting deals toggle
          _buildToggleFilter(
            label: 'Rotting',
            icon: Icons.warning,
            value: controller.showRottingDeals.value,
            activeColor: Colors.orange,
            onChanged: (value) => controller.showRottingDeals.value = value,
          ),
          const SizedBox(width: 16),

          // Date range picker
          _buildDateRangeFilter(controller),

          const Spacer(),

          // Clear filters button
          TextButton.icon(
            onPressed: () {
              controller.ownerFilter.value = 'all';
              controller.showHotDeals.value = false;
              controller.showRottingDeals.value = false;
              controller.selectedTags.clear();
              controller.dateRange.value = null;
              controller.searchQuery.value = '';
            },
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Clear Filters'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item['value'],
                  child: Text(
                    item['label']!,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1F2937),
              ),
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleFilter({
    required String label,
    required IconData icon,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Obx(() {
      final controller = Get.find<SalesPipelineController>();
      final isActive = label == 'Hot Deals'
          ? controller.showHotDeals.value
          : controller.showRottingDeals.value;

      return InkWell(
        onTap: () => onChanged(!isActive),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: isActive ? activeColor : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? activeColor : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isActive ? activeColor : Colors.grey.shade700,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDateRangeFilter(SalesPipelineController controller) {
    return Obx(() {
      final dateRange = controller.dateRange.value;
      final hasDateRange = dateRange != null;

      return InkWell(
        onTap: () async {
          final picked = await showDateRangePicker(
            context: Get.context!,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            initialDateRange: dateRange,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF875DEC),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            controller.dateRange.value = picked;
          }
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: hasDateRange
                  ? const Color(0xFF875DEC)
                  : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(6),
            color: hasDateRange
                ? const Color(0xFF875DEC).withOpacity(0.05)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                Icons.date_range,
                size: 16,
                color: hasDateRange
                    ? const Color(0xFF875DEC)
                    : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                hasDateRange
                    ? '${_formatDate(dateRange.start)} - ${_formatDate(dateRange.end)}'
                    : 'Date Range',
                style: TextStyle(
                  fontSize: 13,
                  color: hasDateRange
                      ? const Color(0xFF875DEC)
                      : Colors.grey.shade700,
                  fontWeight: hasDateRange ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (hasDateRange) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    controller.dateRange.value = null;
                  },
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
  }
}