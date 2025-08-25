// lib/features/admin_platform/customer_management/market_explorer/views/market_explorer_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../shared/layouts/desktop_app_layout.dart';
import '../../../config/sidebar/admin_menu_items.dart';
import '../controllers/market_explorer_controller.dart';
import '../../../../auth/controllers/auth_controller.dart';
import '../tabs/analytics_tab/analytics_tab.dart';
import '../tabs/list_tab/list_tab.dart';
import '../tabs/map_tab/map_tab.dart';
import '../widgets/market_metrics.dart';
import '../tabs/list_tab/dialogs/list_tab_dialogs.dart';

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
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with title and divider
          _buildHeader(),

          // Metrics cards
          const MetricsSection(),

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
                onPressed: () => ListTabDialogs.showAddProspectDialog(),
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
                  return const MapTab();
                case 'analytics':
                  return const AnalyticsTab();
                case 'list':
                default:
                  return const ListTab();
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
                        onPressed: () => ListTabDialogs.showAssignRepDialog(controller),
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
                        onPressed: () => ListTabDialogs.showBulkUpdateDialog(controller),
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

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        ListTabDialogs.showExportDialog(controller);
        break;
      case 'import':
        ListTabDialogs.showImportDialog();
        break;
      case 'bulk_enrich':
        ListTabDialogs.showBulkEnrichDialog();
        break;
      case 'create_campaign':
        Get.toNamed('/campaigns/create');
        break;
      case 'territory_management':
        Get.toNamed('/territories');
        break;
    }
  }
}