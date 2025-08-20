// lib/features/admin_platform/schools_management/market_explorer/views/market_explorer_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../shared/layouts/desktop_app_layout.dart';
import '../../../config/sidebar/admin_menu_items.dart';
import '../controllers/market_explorer_controller.dart';
import '../models/zaecdcenters_model.dart';
import '../../../../auth/controllers/auth_controller.dart';
import 'market_analytics_view.dart';

class MarketExplorerPage extends GetView<MarketExplorerController> {
  const MarketExplorerPage({super.key});

  // Get AuthController for user information
  AuthController get authController => Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser.value;
    final userRoles = user?.roleNames ?? [];

    // Wrap in AdminDesktopLayout
    return AdminDesktopLayout(
      sidebarItems: AdminMenuItems.getMenuItems(userRoles),
      sidebarHeader: AdminMenuItems.buildHeader(),
      sidebarFooter: AdminMenuItems.buildFooter(),
      selectedIndex: 2, // Assuming Market Explorer is the 3rd item in Schools submenu
      body: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Custom header bar (replaces AppBar)
          _buildHeaderBar(),

          // Main content
          Expanded(
            child: Obx(() => Column(
              children: [
                _buildToolbar(),
                if (controller.showFilters.value) _buildFiltersPanel(),
                _buildMetricsRow(),
                Expanded(
                  child: _buildContentArea(),
                ),
              ],
            )),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActions(),
    );
  }

  Widget _buildHeaderBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Title section
          const Icon(Icons.explore, size: 24),
          const SizedBox(width: 8),
          const Text(
            'Market Explorer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${controller.totalCenters.value} ECD Centers',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          )),

          const Spacer(),

          // Action buttons
          _buildViewToggle(),
          const SizedBox(width: 16),
          Obx(() => IconButton(
            icon: Icon(controller.showFilters.value ? Icons.filter_list_off : Icons.filter_list),
            onPressed: controller.toggleFilters,
            tooltip: 'Toggle Filters',
          )),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showExportDialog,
            tooltip: 'Export Data',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'bulk_enrich', child: Text('Bulk Enrich Contacts')),
              const PopupMenuItem(value: 'create_campaign', child: Text('Create Campaign')),
              const PopupMenuItem(value: 'territory_management', child: Text('Manage Territories')),
              const PopupMenuItem(value: 'import_data', child: Text('Import Additional Data')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Obx(() => SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'list',
          icon: Icon(Icons.list, size: 16),
          label: Text('List'),
        ),
        ButtonSegment(
          value: 'map',
          icon: Icon(Icons.map, size: 16),
          label: Text('Map'),
        ),
        ButtonSegment(
          value: 'analytics',
          icon: Icon(Icons.analytics, size: 16),
          label: Text('Analytics'),
        ),
      ],
      selected: {controller.selectedView.value},
      onSelectionChanged: (Set<String> selection) {
        controller.toggleView(selection.first);
      },
    ));
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          // Search bar
          Expanded(
            flex: 3,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, city, contact person...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => controller.searchQuery.value = '',
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              onChanged: (value) => controller.searchQuery.value = value,
            ),
          ),
          const SizedBox(width: 16),

          // Quick filters
          Expanded(
            flex: 2,
            child: _buildQuickFilters(),
          ),

          const SizedBox(width: 16),

          // Bulk actions
          Obx(() {
            if (controller.selectedCenters.isNotEmpty) {
              return _buildBulkActions();
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Obx(() => Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('Gauteng'),
          selected: controller.selectedProvinces.contains('GT'),
          onSelected: (selected) => controller.toggleProvinceFilter('GT'),
        ),
        FilterChip(
          label: const Text('Fully Registered'),
          selected: controller.selectedRegistrationStatus.contains('Fully registered'),
          onSelected: (selected) => controller.toggleRegistrationFilter('Fully registered'),
        ),
        FilterChip(
          label: const Text('50+ Children'),
          selected: controller.minChildren.value >= 50,
          onSelected: (selected) => controller.minChildren.value = selected ? 50 : 0,
        ),
        FilterChip(
          label: const Text('Has Phone'),
          selected: controller.hasPhone.value,
          onSelected: (selected) => controller.hasPhone.value = selected,
        ),
        FilterChip(
          label: const Text('Hot Prospects'),
          selected: controller.minLeadScore.value >= 80,
          onSelected: (selected) => controller.minLeadScore.value = selected ? 80 : 0,
        ),
      ],
    ));
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Advanced Filters',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // Geographic filters
              Expanded(
                child: _buildGeographicFilters(),
              ),
              const SizedBox(width: 24),

              // Business profile filters
              Expanded(
                child: _buildBusinessFilters(),
              ),
              const SizedBox(width: 24),

              // CRM status filters
              Expanded(
                child: _buildCRMFilters(),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: controller.fetchCenters,
                child: const Text('Apply Filters'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: controller.clearFilters,
                child: const Text('Clear All'),
              ),
              const Spacer(),
              Obx(() => Text(
                '${controller.centers.length} of ${controller.totalCenters.value} prospects match filters',
                style: TextStyle(color: Colors.grey[600]),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeographicFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Geographic', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Province selection
            Text('Province:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Obx(() => Wrap(
              spacing: 4,
              children: ['GT', 'KZN', 'WC', 'EC', 'LIM', 'MP', 'NW', 'FS', 'NC']
                  .map((province) => FilterChip(
                label: Text(province, style: const TextStyle(fontSize: 11)),
                selected: controller.selectedProvinces.contains(province),
                onSelected: (selected) => controller.toggleProvinceFilter(province),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ))
                  .toList(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Business Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Children count range
            Text('Children Count:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Min',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => controller.minChildren.value = int.tryParse(value) ?? 0,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Max',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => controller.maxChildren.value = int.tryParse(value) ?? 999,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Registration status
            Text('Registration Status:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Obx(() => Column(
              children: [
                'Fully registered',
                'Conditionally registered',
                'In process',
                'Not registered'
              ].map((status) => CheckboxListTile(
                title: Text(status, style: const TextStyle(fontSize: 12)),
                value: controller.selectedRegistrationStatus.contains(status),
                onChanged: (selected) => controller.toggleRegistrationFilter(status),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              )).toList(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCRMFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CRM Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Lead score range
            Text('Lead Score:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Obx(() => RangeSlider(
              values: RangeValues(
                controller.minLeadScore.value.toDouble(),
                controller.maxLeadScore.value.toDouble(),
              ),
              min: 0,
              max: 100,
              divisions: 10,
              labels: RangeLabels(
                controller.minLeadScore.value.toString(),
                controller.maxLeadScore.value.toString(),
              ),
              onChanged: (values) {
                controller.minLeadScore.value = values.start.round();
                controller.maxLeadScore.value = values.end.round();
              },
            )),

            // Contact data quality
            Obx(() => CheckboxListTile(
              title: const Text('Has Phone Number', style: TextStyle(fontSize: 12)),
              value: controller.hasPhone.value,
              onChanged: (value) => controller.hasPhone.value = value ?? false,
              dense: true,
            )),
            Obx(() => CheckboxListTile(
              title: const Text('Has Email Address', style: TextStyle(fontSize: 12)),
              value: controller.hasEmail.value,
              onChanged: (value) => controller.hasEmail.value = value ?? false,
              dense: true,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Obx(() => Row(
        children: [
          _buildMetricCard(
            'Total Prospects',
            '${controller.centers.length}',
            Icons.business,
          ),
          const SizedBox(width: 16),
          _buildMetricCard(
            'Total Children',
            '${controller.totalChildren.value}',
            Icons.child_care,
          ),
          const SizedBox(width: 16),
          _buildMetricCard(
            'Potential MRR',
            'R${controller.totalPotentialMRR.value.toStringAsFixed(0)}',
            Icons.attach_money,
          ),
          const SizedBox(width: 16),
          _buildMetricCard(
            'Avg Score',
            controller.avgLeadScore.value.toStringAsFixed(1),
            Icons.score,
          ),
          const Spacer(),
          if (controller.selectedCenters.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${controller.selectedCenters.length} selected',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ),
        ],
      )),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue[600]),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    return Obx(() {
      switch (controller.selectedView.value) {
        case 'map':
          return MarketExplorerMapView(
            prospects: controller.centers,
            onProspectSelected: _viewProspectDetails,
          );
        case 'analytics':
          return MarketExplorerAnalyticsView(
            prospects: controller.centers,
            analytics: controller.analytics.value,
            onRefresh: controller.fetchAnalytics,
          );
        case 'list':
        default:
          return _buildListView();
      }
    });
  }

  Widget _buildListView() {
    return Obx(() {
      if (controller.isLoading.value && controller.centers.isEmpty) {
        return const Center(child: CircularProgressIndicator());
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
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: controller.clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
              ),
            ],
          ),
        );
      }

      return Container(
        color: Colors.white,
        child: Column(
          children: [
            // Table with DataTable2 for better performance
            Expanded(
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
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
                    label: const Text('ECD Name'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) =>
                        controller.setSorting('ecdName'),
                  ),
                  const DataColumn2(
                    label: Text('Province'),
                    size: ColumnSize.S,
                  ),
                  const DataColumn2(
                    label: Text('City'),
                    size: ColumnSize.M,
                  ),
                  const DataColumn2(
                    label: Text('Children'),
                    size: ColumnSize.S,
                    numeric: true,
                  ),
                  const DataColumn2(
                    label: Text('Score'),
                    size: ColumnSize.S,
                    numeric: true,
                  ),
                  const DataColumn2(
                    label: Text('Status'),
                    size: ColumnSize.M,
                  ),
                  const DataColumn2(
                    label: Text('Actions'),
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
        ),
      );
    });
  }

  DataRow2 _buildProspectRow(ZAECDCenters prospect) {
    return DataRow2(
      selected: controller.selectedCenters.contains(prospect),
      onSelectChanged: (selected) => controller.toggleCenterSelection(prospect),
      cells: [
        DataCell(
          Row(
            children: [
              _buildLeadScoreIndicator(prospect.leadScore),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      prospect.ecdName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (prospect.contactPerson != null && prospect.contactPerson!.isNotEmpty)
                      Text(
                        prospect.contactPerson!,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(prospect.province)),
        DataCell(Text(prospect.townCity ?? '')),
        DataCell(Text(prospect.numberOfChildren.toString())),
        DataCell(Text(
          prospect.leadScore.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getScoreColor(prospect.leadScore),
          ),
        )),
        DataCell(Row(
          children: [
            _buildRegistrationStatusIndicator(prospect.registrationStatus),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                prospect.leadStatus,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        )),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, size: 16),
              onPressed: () => _viewProspectDetails(prospect),
              tooltip: 'View Details',
            ),
            if (prospect.telephone != null && prospect.telephone!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.phone, size: 16),
                onPressed: () => _callProspect(prospect),
                tooltip: 'Call',
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 16),
              onSelected: (action) => _handleProspectAction(prospect, action),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'add_to_campaign', child: Text('Add to Campaign')),
                const PopupMenuItem(value: 'schedule_demo', child: Text('Schedule Demo')),
                const PopupMenuItem(value: 'mark_contacted', child: Text('Mark as Contacted')),
                const PopupMenuItem(value: 'add_note', child: Text('Add Note')),
              ],
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildLeadScoreIndicator(int score) {
    Color color;
    if (score >= 80) {
      color = Colors.red;
    } else if (score >= 60) {
      color = Colors.orange;
    } else if (score >= 40) {
      color = Colors.yellow[700]!;
    } else {
      color = Colors.grey;
    }

    return Container(
      width: 8,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildRegistrationStatusIndicator(String status) {
    Color color;
    switch (status) {
      case 'Fully registered':
        color = Colors.green;
        break;
      case 'Conditionally registered':
        color = Colors.orange;
        break;
      case 'In process':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildPagination() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: controller.currentPage.value > 1
                ? () => controller.currentPage.value = 1
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: controller.currentPage.value > 1
                ? () => controller.currentPage.value--
                : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: controller.hasMorePages
                ? () => controller.loadNextPage()
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: controller.hasMorePages
                ? () => controller.currentPage.value = controller.totalPages.value
                : null,
          ),
        ],
      ),
    ));
  }

  Widget _buildBulkActions() {
    return Row(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.person_add, size: 16),
          label: const Text('Assign Rep'),
          onPressed: _showAssignRepDialog,
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.update, size: 16),
          label: const Text('Bulk Update'),
          onPressed: _showBulkUpdateDialog,
        ),
      ],
    );
  }

  Widget? _buildFloatingActions() {
    return Obx(() {
      if (controller.selectedView.value == 'list') {
        return FloatingActionButton.extended(
          onPressed: _showAddProspectDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add Prospect'),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.red;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.yellow[700]!;
    return Colors.grey;
  }

  // ... [Rest of the helper methods remain the same] ...

  void _viewProspectDetails(ZAECDCenters prospect) {
    Get.toNamed(
      AppRoutes.adminMarketExplorerDetail.replaceAll(':id', prospect.id),
      parameters: {'id': prospect.id},
    );
  }

  void _callProspect(ZAECDCenters prospect) {
    Get.snackbar(
      'Call',
      'Calling ${prospect.contactPerson ?? prospect.ecdName} at ${prospect.telephone}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _handleProspectAction(ZAECDCenters prospect, String action) async {
    switch (action) {
      case 'add_to_campaign':
        _showAddToCampaignDialog(prospect);
        break;
      case 'schedule_demo':
        _showScheduleDemoDialog(prospect);
        break;
      case 'mark_contacted':
        await controller.updateLeadStatus(
          prospect.id,
          'Contacted',
          prospect.pipelineStage,
        );
        break;
      case 'add_note':
        _showAddNoteDialog(prospect);
        break;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'bulk_enrich':
        _showBulkEnrichDialog();
        break;
      case 'create_campaign':
        Get.toNamed('/campaigns/create');
        break;
      case 'territory_management':
        Get.toNamed('/territories');
        break;
      case 'import_data':
        _showImportDialog();
        break;
    }
  }

  // ... [All dialog methods remain the same] ...

  void _showExportDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text('Export as CSV'),
              onTap: () {
                controller.exportData('csv');
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Export as JSON'),
              onTap: () {
                controller.exportData('json');
                Get.back();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAssignRepDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Assign Sales Representative'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select a sales rep for ${controller.selectedCenters.length} centers'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Sales Rep ID',
                hintText: 'Enter sales rep ID',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Sales rep assigned to ${controller.selectedCenters.length} centers',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _showBulkUpdateDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Bulk Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Update ${controller.selectedCenters.length} centers'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Lead Status',
                hintText: 'Select new lead status',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Updated ${controller.selectedCenters.length} centers',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddProspectDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Add New ECD Prospect'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              TextField(
                decoration: InputDecoration(
                  labelText: 'ECD Name',
                  hintText: 'Enter ECD center name',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Contact Person',
                  hintText: 'Enter contact person name',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'New prospect added successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddToCampaignDialog(ZAECDCenters prospect) {
    Get.dialog(
      AlertDialog(
        title: Text('Add ${prospect.ecdName} to Campaign'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Campaign',
                hintText: 'Select campaign',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                '${prospect.ecdName} added to campaign',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDemoDialog(ZAECDCenters prospect) {
    Get.dialog(
      AlertDialog(
        title: Text('Schedule Demo for ${prospect.ecdName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Date',
                hintText: 'Select date',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Time',
                hintText: 'Select time',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Demo scheduled for ${prospect.ecdName}',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(ZAECDCenters prospect) {
    final noteController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Add Note for ${prospect.ecdName}'),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter your note here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                controller.addNote(prospect.id, noteController.text, 'general');
                Get.back();
              }
            },
            child: const Text('Add Note'),
          ),
        ],
      ),
    );
  }

  void _showBulkEnrichDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Bulk Enrich Contact Data'),
        content: const Text('This feature will enrich contact information for selected centers.'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Processing',
                'Enriching contact data for selected centers...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Start Enrichment'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Import ECD Center Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a CSV file to import additional ECD center data.'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: null, // TODO: Implement file picker
              icon: const Icon(Icons.upload_file),
              label: const Text('Choose File'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Processing',
                'Importing ECD center data...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}