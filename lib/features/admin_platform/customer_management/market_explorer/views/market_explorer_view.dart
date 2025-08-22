// lib/features/admin_platform/customer_management/market_explorer/views/market_explorer_view.dart

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

  // Market totals - these would typically come from your backend
  static const int TOTAL_MARKET_SCHOOLS = 41538;
  static const int TOTAL_MARKET_CHILDREN = 1561957;
  static const double TOTAL_MARKET_MRR = 14370004.40;

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
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with title and divider
          _buildHeader(),

          // Metrics cards
          _buildMetricsSection(),

          // Main content panel
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _buildContentPanel(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              const Text(
                'Market Explorer',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: Color(0xFF1F2937),
                ),
              ),

              // Add Prospect button
              ElevatedButton.icon(
                onPressed: _showAddProspectDialog,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Prospect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF875DEC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFF875DEC)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Divider with purple underline
          Stack(
            children: [
              Container(
                height: 1,
                color: Colors.grey[300],
              ),
              Container(
                height: 3,
                width: 140, // Width to cover "Market E"
                decoration: const BoxDecoration(
                  color: Color(0xFF875DEC),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(2),
                    bottomRight: Radius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper function to format numbers with thousand separators
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  // Helper function to format currency with thousand separators
  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(2);
    final parts = formatted.split('.');
    final wholePart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
    return '$wholePart.${parts[1]}';
  }

  Widget _buildMetricsSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Obx(() {
        // Calculate current onboarded values (assuming 0 for now, but would come from actual data)
        const int currentOnboardedSchools = 0; // This would come from your actual data
        const int currentOnboardedChildren = 0; // This would come from your actual data
        const double currentMRR = 0.0; // This would come from your actual data

        // Calculate market share percentage
        final double marketSharePercentage = (currentOnboardedSchools / TOTAL_MARKET_SCHOOLS) * 100;

        // Check if there are selected centers
        final bool hasSelection = controller.selectedCenters.isNotEmpty;

        return Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Prospects',
                hasSelection
                    ? '${_formatNumber(controller.selectedCenters.length)} selected'
                    : '${_formatNumber(currentOnboardedSchools)} of ${_formatNumber(TOTAL_MARKET_SCHOOLS)}',
                Icons.business_outlined,
                subtitle: hasSelection ? 'Schools selected' : 'Schools onboarded',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Total Children',
                hasSelection
                    ? _formatNumber(controller.totalSelectedChildren)
                    : '${_formatNumber(currentOnboardedChildren)} of ${_formatNumber(TOTAL_MARKET_CHILDREN)}',
                Icons.child_care_outlined,
                subtitle: hasSelection ? 'Children in selection' : 'Children reached',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Potential MRR',
                hasSelection
                    ? 'R${_formatCurrency(controller.totalSelectedMRR.toDouble())}'
                    : 'R${_formatCurrency(currentMRR)} of R${_formatCurrency(TOTAL_MARKET_MRR)}',
                Icons.payments_outlined,
                subtitle: hasSelection ? 'Selected value' : 'Current vs potential',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                hasSelection ? 'Avg. Score' : 'Market Share',
                hasSelection
                    ? _calculateAverageScore().toStringAsFixed(1)
                    : '${marketSharePercentage.toStringAsFixed(2)}%',
                hasSelection ? Icons.analytics_outlined : Icons.pie_chart_outline_outlined,
                subtitle: hasSelection ? 'Lead score average' : 'Market penetration',
                isPercentage: !hasSelection,
              ),
            ),
          ],
        );
      }),
    );
  }

  // Helper method to calculate average score of selected prospects
  double _calculateAverageScore() {
    if (controller.selectedCenters.isEmpty) return 0.0;
    final totalScore = controller.selectedCenters.fold(
        0,
            (sum, center) => sum + center.leadScore
    );
    return totalScore / controller.selectedCenters.length;
  }

  Widget _buildMetricCard(String label, String value, IconData icon, {String? subtitle, bool isPercentage = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF875DEC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 24,
              color: const Color(0xFF875DEC),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isPercentage ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: isPercentage ? const Color(0xFF875DEC) : null,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tabs header
          _buildTabsHeader(),

          // Content area
          Expanded(
            child: Obx(() {
              switch (controller.selectedView.value) {
                case 'map':
                  return MarketExplorerMapView(
                    prospects: controller.centers,
                    onProspectSelected: (prospect) {
                      controller.selectedProspectForDetail.value = prospect;
                    },
                  );
                case 'analytics':
                  return MarketExplorerAnalyticsView(
                    prospects: controller.centers,
                    analytics: controller.analytics.value,
                    onRefresh: controller.fetchAnalytics,
                  );
                case 'list':
                default:
                  return _buildListContent();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            children: [
              // Tabs
              Obx(() => Row(
                children: [
                  _buildTab('List', 'list', controller.selectedView.value == 'list'),
                  const SizedBox(width: 24),
                  _buildTab('Map', 'map', controller.selectedView.value == 'map'),
                  const SizedBox(width: 24),
                  _buildTab('Analytics', 'analytics', controller.selectedView.value == 'analytics'),
                ],
              )),

              const Spacer(),

              // Action buttons
              Obx(() {
                if (controller.selectedCenters.isNotEmpty && controller.selectedView.value == 'list') {
                  return Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _showAssignRepDialog,
                        icon: const Icon(Icons.person_add_outlined, size: 18),
                        label: const Text('Assign Rep'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF875DEC),
                          side: const BorderSide(color: Color(0xFF875DEC)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _showBulkUpdateDialog,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Bulk Update'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF875DEC),
                          side: const BorderSide(color: Color(0xFF875DEC)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              // More menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, color: Color(0xFF6B7280)),
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'export', child: Text('Export Data')),
                  const PopupMenuItem(value: 'import', child: Text('Import Data')),
                  const PopupMenuItem(value: 'bulk_enrich', child: Text('Bulk Enrich Contacts')),
                  const PopupMenuItem(value: 'create_campaign', child: Text('Create Campaign')),
                  const PopupMenuItem(value: 'territory_management', child: Text('Manage Territories')),
                ],
              ),
            ],
          ),
        ),
        // Divider positioned to align with active tab indicator
        Stack(
          children: [
            Container(
              height: 1,
              margin: EdgeInsets.only(
                left: controller.selectedView.value == 'list'
                    ? 79  // Start 5px before "List" tab indicator end (84-5)
                    : controller.selectedView.value == 'map'
                    ? 163 // Start 5px before "Map" tab indicator end (168-5)
                    : 263, // Start 5px before "Analytics" tab indicator end (268-5)
                right: 5, // Stop 5px from right edge
              ),
              color: Colors.grey[200],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTab(String label, String value, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.toggleView(value),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFF875DEC) : Colors.grey[600],
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF875DEC) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    // Check if we're in detail view
    if (controller.selectedProspectForDetail.value != null) {
      return Builder(
        builder: (context) => _buildSplitView(context),
      );
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
          child: _buildDetailPanel(prospect),
        ),
      ],
    );
  }

  String _toCamelCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildMiniStatusChip(String status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.split(' ').first,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildDetailPanel(ZAECDCenters prospect) {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // School header
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _toCamelCase(prospect.ecdName),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildStatusChip(prospect.registrationStatus),
                                const SizedBox(width: 12),
                                Text(
                                  'Score: ${prospect.leadScore}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _getScoreColor(prospect.leadScore),
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Schedule Demo button
                      ElevatedButton.icon(
                        onPressed: () => _scheduleDemo(prospect),
                        icon: const Icon(Icons.calendar_today_outlined, size: 18),
                        label: const Text('Schedule Demo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF875DEC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // CRM Actions bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.white,
              child: Row(
                children: [
                  _buildCRMActionButton(Icons.email_outlined, 'Email', () => _emailProspect(prospect)),
                  const SizedBox(width: 16),
                  _buildCRMActionButton(Icons.phone_outlined, 'Call', () => _callProspect(prospect)),
                  const SizedBox(width: 16),
                  _buildCRMActionButton(Icons.note_add_outlined, 'Note', () => _addNote(prospect)),
                  const SizedBox(width: 16),
                  _buildCRMActionButton(Icons.task_outlined, 'Task', () => _createTask(prospect)),
                  const SizedBox(width: 16),
                  _buildCRMActionButton(Icons.event_outlined, 'Meeting', () => _scheduleMeeting(prospect)),
                  const SizedBox(width: 16),
                  // More menu for additional actions
                  PopupMenuButton<String>(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.more_horiz, size: 18, color: Color(0xFF6B7280)),
                          const SizedBox(width: 6),
                          const Text(
                            'More',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                    onSelected: (value) => _handleCRMAction(prospect, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'log_sms', child: Text('Log SMS')),
                      const PopupMenuItem(value: 'log_whatsapp', child: Text('Log WhatsApp')),
                      const PopupMenuItem(value: 'log_linkedin', child: Text('Log LinkedIn Message')),
                      const PopupMenuItem(value: 'log_activity', child: Text('Log Activity')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Content sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column - Activities
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Recent Activities'),
                        _buildActivityTimeline(prospect),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Upcoming Tasks'),
                        _buildUpcomingTasks(prospect),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right column - School info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('About this School'),
                        _buildSchoolInfo(prospect),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Contacts'),
                        _buildContactsSection(prospect),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                onPressed: () => _callProspect(prospect),
                tooltip: 'Call',
                color: const Color(0xFF6B7280),
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF6B7280)),
              onSelected: (action) => _handleProspectAction(prospect, action),
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

  Widget _buildMasterDetailView() {
    final prospect = controller.selectedProspectForDetail.value!;

    return Row(
      children: [
        // Left panel - School list (compressed)
        Container(
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Column(
            children: [
              // Header with back button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        controller.selectedProspectForDetail.value = null;
                      },
                      color: const Color(0xFF875DEC),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Schools',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable list of schools
              Expanded(
                child: ListView.builder(
                  itemCount: controller.centers.length,
                  itemBuilder: (context, index) {
                    final school = controller.centers[index];
                    final isSelected = school.id == prospect.id;

                    return InkWell(
                      onTap: () {
                        controller.selectedProspectForDetail.value = school;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF875DEC).withOpacity(0.1) : Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              school.ecdName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? const Color(0xFF875DEC) : Colors.black87,
                                fontFamily: 'Roboto',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${school.townCity ?? ''} • ${school.numberOfChildren} children',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Right panel - School details (HubSpot-style)
        Expanded(
          child: Container(
            color: const Color(0xFFFAFAFA),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // School header
                  Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prospect.ecdName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildStatusChip(prospect.registrationStatus),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Score: ${prospect.leadScore}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _getScoreColor(prospect.leadScore),
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Action buttons
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _scheduleDemo(prospect),
                                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                                  label: const Text('Schedule Demo'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF875DEC),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _addNote(prospect),
                                  icon: const Icon(Icons.note_add_outlined, size: 18),
                                  label: const Text('Add Note'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF875DEC),
                                    side: const BorderSide(color: Color(0xFF875DEC)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // CRM Actions bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    color: Colors.white,
                    child: Row(
                      children: [
                        _buildCRMActionButton(Icons.email_outlined, 'Email', () => _emailProspect(prospect)),
                        const SizedBox(width: 16),
                        _buildCRMActionButton(Icons.phone_outlined, 'Call', () => _callProspect(prospect)),
                        const SizedBox(width: 16),
                        _buildCRMActionButton(Icons.task_outlined, 'Task', () => _createTask(prospect)),
                        const SizedBox(width: 16),
                        _buildCRMActionButton(Icons.event_outlined, 'Meeting', () => _scheduleMeeting(prospect)),
                        const SizedBox(width: 16),
                        // More menu for additional actions
                        PopupMenuButton<String>(
                          child: Row(
                            children: [
                              const Icon(Icons.more_horiz, size: 20, color: Color(0xFF6B7280)),
                              const SizedBox(width: 4),
                              const Text('More', style: TextStyle(color: Color(0xFF6B7280))),
                            ],
                          ),
                          onSelected: (value) => _handleCRMAction(prospect, value),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'log_sms', child: Text('Log SMS')),
                            const PopupMenuItem(value: 'log_whatsapp', child: Text('Log WhatsApp')),
                            const PopupMenuItem(value: 'log_linkedin', child: Text('Log LinkedIn Message')),
                            const PopupMenuItem(value: 'log_activity', child: Text('Log Activity')),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content sections
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Activities
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Recent Activities'),
                              _buildActivityTimeline(prospect),
                              const SizedBox(height: 24),
                              _buildSectionHeader('Upcoming Tasks'),
                              _buildUpcomingTasks(prospect),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right column - School info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('About this School'),
                              _buildSchoolInfo(prospect),
                              const SizedBox(height: 24),
                              _buildSectionHeader('Contacts'),
                              _buildContactsSection(prospect),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCRMActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildActivityTimeline(ZAECDCenters prospect) {
    // This would be populated with actual activity data
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Text(
        'No recent activities',
        style: TextStyle(
          color: Colors.grey,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildUpcomingTasks(ZAECDCenters prospect) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Text(
        'No upcoming tasks',
        style: TextStyle(
          color: Colors.grey,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildSchoolInfo(ZAECDCenters prospect) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Province', prospect.province),
          _buildInfoRow('City', prospect.townCity ?? 'N/A'),
          _buildInfoRow('Children', prospect.numberOfChildren.toString()),
          _buildInfoRow('Registration', prospect.registrationStatus),
          _buildInfoRow('Lead Status', prospect.leadStatus),
          if (prospect.streetAddress != null)
            _buildInfoRow('Address', prospect.streetAddress!),
        ],
      ),
    );
  }

  Widget _buildContactsSection(ZAECDCenters prospect) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prospect.contactPerson != null && prospect.contactPerson!.isNotEmpty)
            _buildContactCard(prospect.contactPerson!, prospect.telephone, prospect.email),
          if (prospect.contactPerson == null || prospect.contactPerson!.isEmpty)
            const Text(
              'No contacts available',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Roboto',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactCard(String name, String? phone, String? email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 4),
        if (phone != null && phone.isNotEmpty)
          Text(
            phone,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontFamily: 'Roboto',
            ),
          ),
        if (email != null && email.isNotEmpty)
          Text(
            email,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontFamily: 'Roboto',
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontFamily: 'Roboto',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
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
      width: 4,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
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

  // Helper methods for actions
  void _callProspect(ZAECDCenters prospect) {
    Get.snackbar(
      'Call',
      'Calling ${prospect.contactPerson ?? prospect.ecdName} at ${prospect.telephone}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF875DEC),
      colorText: Colors.white,
    );
  }

  void _emailProspect(ZAECDCenters prospect) {
    Get.snackbar(
      'Email',
      'Opening email composer for ${prospect.ecdName}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF875DEC),
      colorText: Colors.white,
    );
  }

  void _createTask(ZAECDCenters prospect) {
    _showTaskDialog(prospect);
  }

  void _scheduleMeeting(ZAECDCenters prospect) {
    _showMeetingDialog(prospect);
  }

  void _scheduleDemo(ZAECDCenters prospect) {
    _showScheduleDemoDialog(prospect);
  }

  void _addNote(ZAECDCenters prospect) {
    _showAddNoteDialog(prospect);
  }

  void _handleCRMAction(ZAECDCenters prospect, String action) {
    switch (action) {
      case 'log_sms':
        _showLogActivityDialog(prospect, 'SMS');
        break;
      case 'log_whatsapp':
        _showLogActivityDialog(prospect, 'WhatsApp');
        break;
      case 'log_linkedin':
        _showLogActivityDialog(prospect, 'LinkedIn');
        break;
      case 'log_activity':
        _showLogActivityDialog(prospect, 'Activity');
        break;
    }
  }

  void _showQuickActionsMenu(BuildContext context, ZAECDCenters prospect) {
    showMenu(
      context: context,
      position: RelativeRect.fill,
      items: [
        const PopupMenuItem(value: 'add_to_campaign', child: Text('Add to Campaign')),
        const PopupMenuItem(value: 'schedule_demo', child: Text('Schedule Demo')),
        const PopupMenuItem(value: 'mark_contacted', child: Text('Mark as Contacted')),
      ],
    ).then((value) {
      if (value != null) {
        _handleProspectAction(prospect, value);
      }
    });
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
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _showExportDialog();
        break;
      case 'import':
        _showImportDialog();
        break;
      case 'bulk_enrich':
        _showBulkEnrichDialog();
        break;
      case 'create_campaign':
        Get.toNamed('/campaigns/create');
        break;
      case 'territory_management':
        Get.toNamed('/territories');
        break;
    }
  }

  // Dialog methods remain the same but with updated styling
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
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

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
                labelText: 'Sales Rep',
                hintText: 'Select sales representative',
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
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
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
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
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
              onPressed: null,
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
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Import'),
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
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Enrichment'),
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
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
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
          children: const [
            TextField(
              decoration: InputDecoration(
                labelText: 'Date',
                hintText: 'Select date',
              ),
            ),
            SizedBox(height: 16),
            TextField(
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
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
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
                Get.snackbar(
                  'Success',
                  'Note added successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF875DEC),
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Note'),
          ),
        ],
      ),
    );
  }

  void _showTaskDialog(ZAECDCenters prospect) {
    Get.dialog(
      AlertDialog(
        title: Text('Create Task for ${prospect.ecdName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(
              decoration: InputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter task title',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Due Date',
                hintText: 'Select due date',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description',
                border: OutlineInputBorder(),
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
                'Task created successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Create Task'),
          ),
        ],
      ),
    );
  }

  void _showMeetingDialog(ZAECDCenters prospect) {
    Get.dialog(
      AlertDialog(
        title: Text('Schedule Meeting with ${prospect.ecdName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(
              decoration: InputDecoration(
                labelText: 'Meeting Title',
                hintText: 'Enter meeting title',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Date & Time',
                hintText: 'Select date and time',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Location/Link',
                hintText: 'Enter location or meeting link',
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
                'Meeting scheduled successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _showLogActivityDialog(ZAECDCenters prospect, String activityType) {
    Get.dialog(
      AlertDialog(
        title: Text('Log $activityType for ${prospect.ecdName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '$activityType Details',
                hintText: 'Enter details about the $activityType',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Date & Time',
                hintText: 'When did this occur?',
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
                '$activityType logged successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF875DEC),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Activity'),
          ),
        ],
      ),
    );
  }
}