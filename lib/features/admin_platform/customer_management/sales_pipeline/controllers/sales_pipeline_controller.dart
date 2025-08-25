// lib/features/admin_platform/customer_management/sales_pipeline/controllers/sales_pipeline_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../core/services/storage_service.dart';
import '../../../../../utils/app_logger.dart';
import '../models/deal_model.dart';
import '../models/pipeline_status_model.dart';
import '../../market_explorer/models/zaecdcenters_model.dart';

class SalesPipelineController extends GetxController {
  final ApiService _apiService = ApiService.to;
  final StorageService _storageService = StorageService.to;

  // Observable states
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // View state
  final RxString currentView = 'pipeline'.obs; // pipeline, list, forecast
  final RxBool showFilters = false.obs;
  final RxString selectedStageFilter = 'all'.obs;

  // Pipeline data
  final RxMap<String, PipelineStage> pipelineStages = <String, PipelineStage>{}.obs;
  final RxList<Deal> allDeals = <Deal>[].obs;
  final Rx<Deal?> selectedDeal = Rx<Deal?>(null);

  // Statistics
  final Rx<PipelineStatistics?> statistics = Rx<PipelineStatistics?>(null);
  final Rx<SalesVelocity?> salesVelocity = Rx<SalesVelocity?>(null);
  final Rx<Forecast?> forecast = Rx<Forecast?>(null);

  // Filters
  final RxString ownerFilter = 'all'.obs;
  final RxBool showHotDeals = false.obs;
  final RxBool showRottingDeals = false.obs;
  final RxList<String> selectedTags = <String>[].obs;
  final Rx<DateTimeRange?> dateRange = Rx<DateTimeRange?>(null);
  final RxString searchQuery = ''.obs;

  // Drag and drop
  final RxBool isDragging = false.obs;
  final Rx<String?> dragOverStage = Rx<String?>(null);

  // Pipeline stages configuration
  final List<PipelineStageConfig> stageConfigs = [
    PipelineStageConfig(
      name: 'Initial Contact',
      color: Colors.blue.shade300,
      icon: Icons.contact_phone,
      probability: 10,
      rottingDays: 14,
    ),
    PipelineStageConfig(
      name: 'Demo Scheduled',
      color: Colors.orange.shade300,
      icon: Icons.schedule,
      probability: 20,
      rottingDays: 7,
    ),
    PipelineStageConfig(
      name: 'Demo Completed',
      color: Colors.purple.shade300,
      icon: Icons.check_circle_outline,
      probability: 30,
      rottingDays: 10,
    ),
    PipelineStageConfig(
      name: 'Proposal Sent',
      color: Colors.indigo.shade300,
      icon: Icons.description,
      probability: 50,
      rottingDays: 14,
    ),
    PipelineStageConfig(
      name: 'Nurturing',
      color: Colors.amber.shade300,
      icon: Icons.favorite_outline,
      probability: 25,
      rottingDays: 30,
    ),
    PipelineStageConfig(
      name: 'Onboarding',
      color: Colors.green.shade300,
      icon: Icons.trending_up,
      probability: 90,
      rottingDays: 7,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
    AppLogger.d('SalesPipelineController initialized');
  }

  @override
  void onReady() {
    super.onReady();
    loadPipeline();
  }

  void _setupListeners() {
    // Debounce search
    debounce(searchQuery, (_) => loadPipeline(),
        time: const Duration(milliseconds: 500));

    // React to filter changes
    ever(ownerFilter, (_) => loadPipeline());
    ever(showHotDeals, (_) => loadPipeline());
    ever(showRottingDeals, (_) => loadPipeline());
    ever(selectedTags, (_) => loadPipeline());
    ever(dateRange, (_) => loadPipeline());
  }

  // Load pipeline data
  Future<void> loadPipeline() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final filters = _buildFilters();

      final response = await _apiService.get<Map<String, dynamic>>(
        '/sales-pipeline',
        queryParameters: filters,
      );

      if (response.success && response.data != null) {
        final data = response.data!['data'] ?? response.data!;

        // Parse pipeline stages
        _parsePipelineData(data['pipeline']);

        // Parse statistics
        if (data['stats'] != null) {
          statistics.value = PipelineStatistics.fromJson(data['stats']);
        }

        AppLogger.d('Pipeline loaded successfully');
      } else {
        errorMessage.value = response.message ?? 'Failed to load pipeline';
      }

    } catch (e) {
      AppLogger.e('Error loading pipeline', e);
      errorMessage.value = 'Error loading pipeline data';
    } finally {
      isLoading.value = false;
    }
  }

  // Parse pipeline data from API response
  void _parsePipelineData(Map<String, dynamic> pipelineData) {
    pipelineStages.clear();
    allDeals.clear();

    for (final stage in stageConfigs) {
      final stageData = pipelineData[stage.name];
      if (stageData != null) {
        final deals = (stageData['deals'] as List)
            .map((json) => Deal.fromJson(json))
            .toList();

        pipelineStages[stage.name] = PipelineStage(
          name: stage.name,
          deals: deals,
          totalValue: stageData['totalValue']?.toDouble() ?? 0,
          weightedValue: stageData['weightedValue']?.toDouble() ?? 0,
          count: stageData['count'] ?? 0,
        );

        allDeals.addAll(deals);
      } else {
        // Initialize empty stage
        pipelineStages[stage.name] = PipelineStage(
          name: stage.name,
          deals: [],
          totalValue: 0,
          weightedValue: 0,
          count: 0,
        );
      }
    }
  }

  // Create deal from ECD Center
  Future<bool> createDeal(ZAECDCenters center, {
    String? initialStage,
    DateTime? expectedCloseDate,
    List<String>? tags,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/sales-pipeline/deals',
        data: {
          'centerId': center.id,
          'title': '${center.ecdName} - Opportunity',
          'stage': initialStage ?? 'Initial Contact',
          'expectedCloseDate': expectedCloseDate?.toIso8601String() ??
              DateTime.now().add(const Duration(days: 60)).toIso8601String(),
          'tags': tags ?? [],
        },
      );

      if (response.success) {
        await loadPipeline();
        Get.snackbar(
          'Success',
          'Deal created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to create deal',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      AppLogger.e('Error creating deal', e);
      Get.snackbar(
        'Error',
        'Failed to create deal',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  // Update deal stage (drag and drop)
  Future<bool> updateDealStage(String dealId, String newStage) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/sales-pipeline/deals/$dealId/stage',
        data: {
          'stage': newStage,
        },
      );

      if (response.success) {
        // Update local data immediately for smooth UX
        final deal = allDeals.firstWhere((d) => d.id == dealId);
        final oldStage = deal.stage;

        // Remove from old stage
        pipelineStages[oldStage]?.deals.removeWhere((d) => d.id == dealId);
        pipelineStages[oldStage]?.count--;

        // Add to new stage
        deal.stage = newStage;
        deal.updateProbability();
        pipelineStages[newStage]?.deals.add(deal);
        pipelineStages[newStage]?.count++;

        // Refresh to get updated stats
        await loadPipeline();

        return true;
      }
    } catch (e) {
      AppLogger.e('Error updating deal stage', e);
      Get.snackbar(
        'Error',
        'Failed to update deal stage',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  // Update deal information
  Future<bool> updateDeal(String dealId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/sales-pipeline/deals/$dealId',
        data: updates,
      );

      if (response.success) {
        await loadPipeline();
        Get.snackbar(
          'Success',
          'Deal updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
    } catch (e) {
      AppLogger.e('Error updating deal', e);
      Get.snackbar(
        'Error',
        'Failed to update deal',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  // Add activity to deal
  Future<bool> addActivity(String dealId, ActivityData activity) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/sales-pipeline/deals/$dealId/activities',
        data: activity.toJson(),
      );

      if (response.success) {
        await loadPipeline();
        Get.snackbar(
          'Success',
          'Activity added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
    } catch (e) {
      AppLogger.e('Error adding activity', e);
      Get.snackbar(
        'Error',
        'Failed to add activity',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  // Close deal as won
  Future<bool> closeDealWon(String dealId, WonDetails details) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/sales-pipeline/deals/$dealId/close-won',
        data: details.toJson(),
      );

      if (response.success) {
        await loadPipeline();
        Get.snackbar(
          'Success',
          '🎉 Deal closed successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return true;
      }
    } catch (e) {
      AppLogger.e('Error closing deal', e);
      Get.snackbar(
        'Error',
        'Failed to close deal',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  // Close deal as lost
  Future<bool> closeDealLost(String dealId, LostReason reason) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/sales-pipeline/deals/$dealId/close-lost',
        data: reason.toJson(),
      );

      if (response.success) {
        await loadPipeline();
        return true;
      }
    } catch (e) {
      AppLogger.e('Error closing deal as lost', e);
      Get.snackbar(
        'Error',
        'Failed to close deal',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  // Load sales velocity metrics
  Future<void> loadSalesVelocity() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/sales-pipeline/velocity',
      );

      if (response.success && response.data != null) {
        salesVelocity.value = SalesVelocity.fromJson(response.data!);
      }
    } catch (e) {
      AppLogger.e('Error loading sales velocity', e);
    }
  }

  // Load forecast
  Future<void> loadForecast({String period = 'quarter'}) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/sales-pipeline/forecast',
        queryParameters: {'period': period},
      );

      if (response.success && response.data != null) {
        forecast.value = Forecast.fromJson(response.data!);
      }
    } catch (e) {
      AppLogger.e('Error loading forecast', e);
    }
  }

  // Get deal details
  Future<Deal?> getDealDetails(String dealId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/sales-pipeline/deals/$dealId',
      );

      if (response.success && response.data != null) {
        final data = response.data!['data'] ?? response.data!;
        return Deal.fromJson(data['deal'] ?? data);
      }
    } catch (e) {
      AppLogger.e('Error fetching deal details', e);
    }
    return null;
  }

  // Build filters for API calls
  Map<String, dynamic> _buildFilters() {
    final filters = <String, dynamic>{};

    if (ownerFilter.value != 'all') {
      filters['owner'] = ownerFilter.value;
    }

    if (selectedStageFilter.value != 'all') {
      filters['stage'] = selectedStageFilter.value;
    }

    if (showHotDeals.value) {
      filters['isHot'] = true;
    }

    if (showRottingDeals.value) {
      filters['isRotting'] = true;
    }

    if (selectedTags.isNotEmpty) {
      filters['tags'] = selectedTags.join(',');
    }

    if (dateRange.value != null) {
      filters['startDate'] = dateRange.value!.start.toIso8601String();
      filters['endDate'] = dateRange.value!.end.toIso8601String();
    }

    if (searchQuery.value.isNotEmpty) {
      filters['search'] = searchQuery.value;
    }

    return filters;
  }

  // UI Helper Methods
  void toggleView(String view) {
    currentView.value = view;
    if (view == 'forecast' && forecast.value == null) {
      loadForecast();
    }
  }

  void toggleFilters() {
    showFilters.value = !showFilters.value;
  }

  void selectDeal(Deal deal) {
    selectedDeal.value = deal;
  }

  void clearSelection() {
    selectedDeal.value = null;
  }

  // Drag and drop handlers
  void onDragStart(Deal deal) {
    isDragging.value = true;
    selectedDeal.value = deal;
  }

  void onDragEnd() {
    isDragging.value = false;
    dragOverStage.value = null;
  }

  void onDragEnterStage(String stage) {
    dragOverStage.value = stage;
  }

  void onDragLeaveStage() {
    dragOverStage.value = null;
  }

  Future<void> onDropDeal(String newStage) async {
    if (selectedDeal.value != null && selectedDeal.value!.stage != newStage) {
      await updateDealStage(selectedDeal.value!.id, newStage);
    }
    onDragEnd();
  }

  // Computed values
  double get totalPipelineValue {
    return pipelineStages.values.fold(0, (sum, stage) => sum + stage.totalValue);
  }

  double get weightedPipelineValue {
    return pipelineStages.values.fold(0, (sum, stage) => sum + stage.weightedValue);
  }

  int get totalDealsCount {
    return pipelineStages.values.fold(0, (sum, stage) => sum + stage.count);
  }

  int get rottingDealsCount {
    return allDeals.where((deal) => deal.status?.isRotting ?? false).length;
  }

  int get hotDealsCount {
    return allDeals.where((deal) => deal.status?.isHot ?? false).length;
  }

  PipelineStageConfig? getStageConfig(String stageName) {
    return stageConfigs.firstWhereOrNull((config) => config.name == stageName);
  }
}

// Supporting Models
class PipelineStage {
  final String name;
  final List<Deal> deals;
  final double totalValue;
  final double weightedValue;
  int count;

  PipelineStage({
    required this.name,
    required this.deals,
    required this.totalValue,
    required this.weightedValue,
    required this.count,
  });
}

class PipelineStageConfig {
  final String name;
  final Color color;
  final IconData icon;
  final int probability;
  final int rottingDays;

  PipelineStageConfig({
    required this.name,
    required this.color,
    required this.icon,
    required this.probability,
    required this.rottingDays,
  });
}

class PipelineStatistics {
  final Map<String, dynamic> pipeline;
  final Map<String, dynamic> forecast;
  final Map<String, dynamic> activities;
  final List<dynamic> funnel;

  PipelineStatistics({
    required this.pipeline,
    required this.forecast,
    required this.activities,
    required this.funnel,
  });

  factory PipelineStatistics.fromJson(Map<String, dynamic> json) {
    return PipelineStatistics(
      pipeline: json['pipeline'] ?? {},
      forecast: json['forecast'] ?? {},
      activities: json['activities'] ?? {},
      funnel: json['funnel'] ?? [],
    );
  }
}

class SalesVelocity {
  final int dealsWon;
  final double totalValue;
  final double avgDealSize;
  final double avgSalesCycle;
  final double velocityScore;

  SalesVelocity({
    required this.dealsWon,
    required this.totalValue,
    required this.avgDealSize,
    required this.avgSalesCycle,
    required this.velocityScore,
  });

  factory SalesVelocity.fromJson(Map<String, dynamic> json) {
    return SalesVelocity(
      dealsWon: json['dealsWon'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      avgDealSize: (json['avgDealSize'] ?? 0).toDouble(),
      avgSalesCycle: (json['avgSalesCycle'] ?? 0).toDouble(),
      velocityScore: (json['velocityScore'] ?? 0).toDouble(),
    );
  }
}

class Forecast {
  final double bestCase;
  final double realistic;
  final double worstCase;
  final int dealCount;
  final double avgProbability;

  Forecast({
    required this.bestCase,
    required this.realistic,
    required this.worstCase,
    required this.dealCount,
    required this.avgProbability,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      bestCase: (json['bestCase'] ?? 0).toDouble(),
      realistic: (json['realistic'] ?? 0).toDouble(),
      worstCase: (json['worstCase'] ?? 0).toDouble(),
      dealCount: json['dealCount'] ?? 0,
      avgProbability: (json['avgProbability'] ?? 0).toDouble(),
    );
  }
}