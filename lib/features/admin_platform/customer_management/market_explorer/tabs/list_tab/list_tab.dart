// lib/features/admin_platform/customer_management/market_explorer/tabs/list_tab.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../controllers/market_explorer_controller.dart';
import '../../models/zaecdcenters_model.dart';
import 'dialogs/list_tab_dialogs.dart';
import 'panels/list_detail_panel.dart';


class ListTab extends GetView<MarketExplorerController> {
  const ListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Check if we're in detail view
      if (controller.selectedProspectForDetail.value != null) {
        return _buildSplitView(context);
      }

      return Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by name, city, contact person...',
                      hintStyle: const TextStyle(fontFamily: 'Roboto'),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF875DEC)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) => controller.searchQuery.value = value,
                  ),
                ),
                const SizedBox(width: 16),

                // Filter button
                OutlinedButton.icon(
                  onPressed: () => controller.toggleFilters(),
                  icon: Icon(
                    controller.showFilters.value ? Icons.filter_list_off : Icons.filter_list,
                    size: 20,
                  ),
                  label: const Text('Filter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF875DEC),
                    side: const BorderSide(color: Color(0xFF875DEC)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // Filters panel if shown
          if (controller.showFilters.value) _buildFiltersPanel(),

          // Data table
          Expanded(
            child: _buildDataTable(),
          ),
        ],
      );
    });
  }

  Widget _buildSplitView(BuildContext context) {
    final prospect = controller.selectedProspectForDetail.value!;

    return Row(
      children: [
        // Left panel - Compressed list
        Container(
          width: 400,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Column(
            children: [
              // Search and filter bar (compressed)
              Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Search field
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search schools...',
                          hintStyle: const TextStyle(fontFamily: 'Roboto', fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280), size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF875DEC)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true,
                        ),
                        onChanged: (value) => controller.searchQuery.value = value,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Filter button
                    IconButton(
                      icon: Icon(
                        controller.showFilters.value ? Icons.filter_list_off : Icons.filter_list,
                        size: 20,
                      ),
                      onPressed: () => controller.toggleFilters(),
                      tooltip: 'Filter',
                      color: const Color(0xFF875DEC),
                    ),
                    // Close button
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        controller.selectedProspectForDetail.value = null;
                      },
                      tooltip: 'Close details',
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),

              // School list with custom scrollbar
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    scrollbarTheme: ScrollbarThemeData(
                      thumbVisibility: MaterialStateProperty.all(true),
                      trackVisibility: MaterialStateProperty.all(true),
                      thickness: MaterialStateProperty.all(3),
                      thumbColor: MaterialStateProperty.all(const Color(0xFF875DEC)),
                      trackColor: MaterialStateProperty.all(Colors.grey[200]),
                      trackBorderColor: MaterialStateProperty.all(Colors.grey[200]),
                      radius: const Radius.circular(2),
                    ),
                  ),
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: controller.centers.length,
                      itemBuilder: (context, index) {
                        final school = controller.centers[index];
                        final isSelected = school.id == prospect.id;

                        return InkWell(
                          onTap: () {
                            controller.selectedProspectForDetail.value = school;
                          },
                          onHover: (hovering) {
                            // Handle hover state if needed
                          },
                          child: Container(
                            height: 65,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF875DEC).withOpacity(0.05) : Colors.transparent,
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[200]!),
                                left: BorderSide(
                                  color: isSelected ? const Color(0xFF875DEC) : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _toCamelCase(school.ecdName),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? const Color(0xFF875DEC) : Colors.black,
                                    fontFamily: 'Roboto',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 2),
                                if (school.contactPerson != null && school.contactPerson!.isNotEmpty)
                                  Text(
                                    _toCamelCase(school.contactPerson!),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontFamily: 'Roboto',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Pagination at bottom
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.first_page, size: 20),
                      onPressed: controller.currentPage.value > 1
                          ? () => controller.currentPage.value = 1
                          : null,
                      color: const Color(0xFF875DEC),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      onPressed: controller.currentPage.value > 1
                          ? () => controller.currentPage.value--
                          : null,
                      color: const Color(0xFF875DEC),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text(
                        'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      onPressed: controller.hasMorePages
                          ? () => controller.loadNextPage()
                          : null,
                      color: const Color(0xFF875DEC),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.last_page, size: 20),
                      onPressed: controller.hasMorePages
                          ? () => controller.currentPage.value = controller.totalPages.value
                          : null,
                      color: const Color(0xFF875DEC),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Right panel - School details
        Expanded(
          child: ListDetailPanel(prospect: prospect),
        ),
      ],
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Province filters
          Text(
            'Province',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['GT', 'KZN', 'WC', 'EC', 'LIM', 'MP', 'NW', 'FS', 'NC']
                .map((province) => FilterChip(
              label: Text(province),
              selected: controller.selectedProvinces.contains(province),
              onSelected: (selected) => controller.toggleProvinceFilter(province),
              selectedColor: const Color(0xFF875DEC).withOpacity(0.2),
              checkmarkColor: const Color(0xFF875DEC),
              labelStyle: TextStyle(
                color: controller.selectedProvinces.contains(province)
                    ? const Color(0xFF875DEC)
                    : Colors.grey[700],
                fontFamily: 'Roboto',
              ),
            ))
                .toList(),
          )),

          const SizedBox(height: 16),

          // Registration status filters
          Text(
            'Registration Status',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Fully registered',
              'Conditionally registered',
              'In process',
              'Not registered'
            ].map((status) => FilterChip(
              label: Text(status),
              selected: controller.selectedRegistrationStatus.contains(status),
              onSelected: (selected) => controller.toggleRegistrationFilter(status),
              selectedColor: const Color(0xFF875DEC).withOpacity(0.2),
              checkmarkColor: const Color(0xFF875DEC),
              labelStyle: TextStyle(
                color: controller.selectedRegistrationStatus.contains(status)
                    ? const Color(0xFF875DEC)
                    : Colors.grey[700],
                fontFamily: 'Roboto',
              ),
            )).toList(),
          )),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              ElevatedButton(
                onPressed: controller.fetchCenters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF875DEC),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apply Filters'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: controller.clearFilters,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
                child: const Text('Clear All'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Obx(() {
      if (controller.isLoading.value && controller.centers.isEmpty) {
        return const Center(child: CircularProgressIndicator(
          color: Color(0xFF875DEC),
        ));
      }

      if (controller.centers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No ECD Centers found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: controller.clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF875DEC),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 24,
              minWidth: 1200,
              showCheckboxColumn: true,
              onSelectAll: (selected) {
                if (selected ?? false) {
                  controller.selectAllCenters();
                } else {
                  controller.clearSelection();
                }
              },
              columns: [
                DataColumn2(
                  label: const Text('School Name', style: TextStyle(fontFamily: 'Roboto')),
                  size: ColumnSize.L,
                  onSort: (columnIndex, ascending) =>
                      controller.setSorting('ecdName'),
                ),
                const DataColumn2(
                  label: Text('Province', style: TextStyle(fontFamily: 'Roboto')),
                  size: ColumnSize.S,
                ),
                const DataColumn2(
                  label: Text('City', style: TextStyle(fontFamily: 'Roboto')),
                  size: ColumnSize.M,
                ),
                const DataColumn2(
                  label: Text('Children', style: TextStyle(fontFamily: 'Roboto')),
                  size: ColumnSize.S,
                  numeric: true,
                ),
                const DataColumn2(
                  label: Text('Score', style: TextStyle(fontFamily: 'Roboto')),
                  size: ColumnSize.S,
                  numeric: true,
                ),
                const DataColumn2(
                  label: Text('Status', style: TextStyle(fontFamily: 'Roboto')),
                  size: ColumnSize.M,
                ),
                const DataColumn2(
                  label: Text('Actions', style: TextStyle(fontFamily: 'Roboto')),
                  size: ColumnSize.M,
                ),
              ],
              rows: controller.centers.map((center) =>
                  _buildProspectRow(center)
              ).toList(),
            ),
          ),

          // Pagination
          _buildPagination(),
        ],
      );
    });
  }

  DataRow2 _buildProspectRow(ZAECDCenters prospect) {
    return DataRow2(
      selected: controller.selectedCenters.contains(prospect),
      onSelectChanged: (selected) => controller.toggleCenterSelection(prospect),
      cells: [
        DataCell(
          InkWell(
            onTap: () {
              controller.selectedProspectForDetail.value = prospect;
            },
            onHover: (hovering) {
              // Handle hover state for color change
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(
                    _toCamelCase(prospect.ecdName),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (prospect.contactPerson != null && prospect.contactPerson!.isNotEmpty)
                  const SizedBox(height: 2),
                if (prospect.contactPerson != null && prospect.contactPerson!.isNotEmpty)
                  Text(
                    _toCamelCase(prospect.contactPerson!),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontFamily: 'Roboto',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
        DataCell(Text(prospect.province, style: const TextStyle(fontFamily: 'Roboto'))),
        DataCell(Text(_toCamelCase(prospect.townCity ?? ''), style: const TextStyle(fontFamily: 'Roboto'))),
        DataCell(Text(_formatNumber(prospect.numberOfChildren), style: const TextStyle(fontFamily: 'Roboto'))),
        DataCell(Text(
          prospect.leadScore.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getScoreColor(prospect.leadScore),
            fontFamily: 'Roboto',
          ),
        )),
        DataCell(_buildStatusChip(prospect.registrationStatus)),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined, size: 18),
              onPressed: () => controller.selectedProspectForDetail.value = prospect,
              tooltip: 'View Details',
              color: const Color(0xFF6B7280),
            ),
            if (prospect.telephone != null && prospect.telephone!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.phone_outlined, size: 18),
                onPressed: () => ListTabDialogs.callProspect(prospect),
                tooltip: 'Call',
                color: const Color(0xFF6B7280),
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF6B7280)),
              onSelected: (action) => ListTabDialogs.handleProspectAction(prospect, action, controller),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'add_to_campaign', child: Text('Add to Campaign')),
                const PopupMenuItem(value: 'schedule_demo', child: Text('Schedule Demo')),
                const PopupMenuItem(value: 'mark_contacted', child: Text('Mark as Contacted')),
              ],
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Fully registered':
        bgColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        break;
      case 'Conditionally registered':
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        break;
      case 'In process':
        bgColor = Colors.blue[50]!;
        textColor = Colors.blue[700]!;
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: controller.currentPage.value > 1
                ? () => controller.currentPage.value = 1
                : null,
            color: const Color(0xFF875DEC),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: controller.currentPage.value > 1
                ? () => controller.currentPage.value--
                : null,
            color: const Color(0xFF875DEC),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF875DEC).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: controller.hasMorePages
                ? () => controller.loadNextPage()
                : null,
            color: const Color(0xFF875DEC),
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: controller.hasMorePages
                ? () => controller.currentPage.value = controller.totalPages.value
                : null,
            color: const Color(0xFF875DEC),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.red;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.yellow[700]!;
    return Colors.grey;
  }

  String _toCamelCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }
}