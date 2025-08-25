// lib/features/admin_platform/customer_management/sales_pipeline/views/sales_pipeline_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../shared/layouts/desktop_app_layout.dart';
import '../../../config/sidebar/admin_menu_items.dart';
import '../controllers/sales_pipeline_controller.dart';
import '../../../../auth/controllers/auth_controller.dart';
import '../models/deal_model.dart';
import '../widgets/pipeline_column.dart';
import '../widgets/deal_detail_panel.dart';
import '../widgets/pipeline_filters.dart';
import '../widgets/pipeline_metrics_bar.dart';

class SalesPipelineView extends GetView<SalesPipelineController> {
  const SalesPipelineView({super.key});

  AuthController get authController => Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser.value;
    final userRoles = user?.roleNames ?? [];

    return AdminDesktopLayout(
      sidebarItems: AdminMenuItems.getMenuItems(userRoles),
      sidebarHeader: AdminMenuItems.buildHeader(),
      sidebarFooter: AdminMenuItems.buildFooter(),
      selectedIndex: 1, // Sales Pipeline in Customers submenu
      body: _buildMainContent(context),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Header with title and actions
          _buildHeader(),

          // Metrics bar
          const PipelineMetricsBar(),

          // Filters section
          Obx(() => controller.showFilters.value
              ? const PipelineFilters()
              : const SizedBox.shrink()),

          // Main pipeline view
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading pipeline',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: controller.loadPipeline,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF875DEC),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Stack(
                children: [
                  // Pipeline columns
                  _buildPipelineView(),

                  // Deal detail panel (slides from right)
                  Obx(() {
                    if (controller.selectedDeal.value != null) {
                      return Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: DealDetailPanel(
                          deal: controller.selectedDeal.value!,
                          onClose: controller.clearSelection,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Title and view switcher
          Row(
            children: [
              const Text(
                'Sales Pipeline',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 24),
              _buildViewSwitcher(),
            ],
          ),

          const Spacer(),

          // Actions
          Row(
            children: [
              // Search
              SizedBox(
                width: 250,
                height: 36,
                child: TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Search deals...',
                    hintStyle: const TextStyle(fontSize: 14),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Filter button
              IconButton(
                onPressed: controller.toggleFilters,
                icon: Obx(() => Icon(
                  Icons.filter_list,
                  color: controller.showFilters.value
                      ? const Color(0xFF875DEC)
                      : Colors.grey.shade600,
                )),
                tooltip: 'Toggle filters',
              ),

              const SizedBox(width: 12),

              // Add deal button
              ElevatedButton.icon(
                onPressed: _showAddDealDialog,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Deal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF875DEC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewSwitcher() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildViewOption('Pipeline', 'pipeline', Icons.view_column),
          _buildViewOption('List', 'list', Icons.view_list),
          _buildViewOption('Forecast', 'forecast', Icons.show_chart),
        ],
      ),
    ));
  }

  Widget _buildViewOption(String label, String value, IconData icon) {
    final isSelected = controller.currentView.value == value;

    return GestureDetector(
      onTap: () => controller.toggleView(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? const Color(0xFF875DEC)
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF875DEC)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineView() {
    return Obx(() {
      if (controller.currentView.value == 'pipeline') {
        return _buildKanbanView();
      } else if (controller.currentView.value == 'list') {
        return _buildListView();
      } else {
        return _buildForecastView();
      }
    });
  }

  Widget _buildKanbanView() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: controller.stageConfigs.map((config) {
                    final stage = controller.pipelineStages[config.name];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: PipelineColumn(
                        config: config,
                        stage: stage,
                        onDragStart: controller.onDragStart,
                        onDragEnd: controller.onDragEnd,
                        onDragEnter: () => controller.onDragEnterStage(config.name),
                        onDragLeave: controller.onDragLeaveStage,
                        onDrop: () => controller.onDropDeal(config.name),
                        onDealTap: controller.selectDeal,
                        isDragOver: controller.dragOverStage.value == config.name,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('Deal', style: _headerStyle())),
                  Expanded(flex: 2, child: Text('Company', style: _headerStyle())),
                  Expanded(flex: 2, child: Text('Stage', style: _headerStyle())),
                  Expanded(flex: 1, child: Text('Value', style: _headerStyle())),
                  Expanded(flex: 1, child: Text('Probability', style: _headerStyle())),
                  Expanded(flex: 2, child: Text('Expected Close', style: _headerStyle())),
                  Expanded(flex: 1, child: Text('Owner', style: _headerStyle())),
                  SizedBox(width: 48),
                ],
              ),
            ),

            // Table body
            Expanded(
              child: Obx(() => ListView.separated(
                itemCount: controller.allDeals.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final deal = controller.allDeals[index];
                  return _buildDealRow(deal);
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDealRow(Deal deal) {
    return InkWell(
      onTap: () => controller.selectDeal(deal),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  if (deal.isHot)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '🔥 HOT',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                deal.ecdCenter?.ecdName ?? '',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: deal.stageColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  deal.stage,
                  style: TextStyle(
                    fontSize: 12,
                    color: deal.stageColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'R${deal.value.annual.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${deal.probability.toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                deal.expectedCloseDate != null
                    ? '${deal.expectedCloseDate!.day}/${deal.expectedCloseDate!.month}/${deal.expectedCloseDate!.year}'
                    : '-',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                deal.owner?.fullName ?? '',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            SizedBox(
              width: 48,
              child: IconButton(
                icon: const Icon(Icons.more_horiz, size: 20),
                onPressed: () => _showDealActions(deal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastView() {
    controller.loadForecast();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Obx(() {
        final forecast = controller.forecast.value;
        if (forecast == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Forecast',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                _buildForecastCard(
                  'Best Case',
                  forecast.bestCase,
                  Colors.green.shade400,
                  Icons.trending_up,
                ),
                const SizedBox(width: 16),
                _buildForecastCard(
                  'Realistic',
                  forecast.realistic,
                  Colors.blue.shade400,
                  Icons.show_chart,
                ),
                const SizedBox(width: 16),
                _buildForecastCard(
                  'Worst Case',
                  forecast.worstCase,
                  Colors.orange.shade400,
                  Icons.trending_down,
                ),
              ],
            ),

            const SizedBox(height: 24),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Forecast Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetric('Deals in Pipeline', '${forecast.dealCount}'),
                        _buildMetric('Average Probability', '${forecast.avgProbability.toStringAsFixed(0)}%'),
                        _buildMetric('Expected Close (Realistic)', 'R${forecast.realistic.toStringAsFixed(0)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildForecastCard(String title, double value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'R${value.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  TextStyle _headerStyle() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF6B7280),
    );
  }

  void _showAddDealDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Add New Deal'),
        content: const Text('Select an ECD Center from Market Explorer to create a deal.'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/admin/customers/market-explorer');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF875DEC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Go to Market Explorer'),
          ),
        ],
      ),
    );
  }

  void _showDealActions(Deal deal) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Deal'),
              onTap: () {
                Get.back();
                controller.selectDeal(deal);
              },
            ),
            if (!deal.isClosed)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Mark as Won'),
                onTap: () {
                  Get.back();
                  _showWonDialog(deal);
                },
              ),
            if (!deal.isClosed)
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Mark as Lost'),
                onTap: () {
                  Get.back();
                  _showLostDialog(deal);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showWonDialog(Deal deal) {
    // Implementation for marking deal as won
    Get.dialog(
      AlertDialog(
        title: const Text('Mark Deal as Won'),
        content: const Text('Are you sure you want to mark this deal as won?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.closeDealWon(
                deal.id,
                WonDetails(
                  finalPrice: deal.value.annual,
                  keyFactors: ['Good fit', 'Budget approved'],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark as Won'),
          ),
        ],
      ),
    );
  }

  void _showLostDialog(Deal deal) {
    // Implementation for marking deal as lost
    Get.dialog(
      AlertDialog(
        title: const Text('Mark Deal as Lost'),
        content: const Text('Why was this deal lost?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.closeDealLost(
                deal.id,
                LostReason(
                  primary: 'Price',
                  details: 'Budget constraints',
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark as Lost'),
          ),
        ],
      ),
    );
  }
}