// lib/features/admin_platform/customer_management/sales_pipeline/controllers/sales_pipeline_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../core/services/storage_service.dart';
import '../../../../../core/config/api_endpoints.dart';
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
  final RxString currentView = 'pipeline'.obs;
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
    _initializeStages();
    _setupListeners();
    AppLogger.d('SalesPipelineController initialized');
  }

  @override
  void onReady() {
    super.onReady();
    loadPipeline();
  }

  void _initializeStages() {
    for (final config in stageConfigs) {
      pipelineStages[config.name] = PipelineStage(
        name: config.name,
        deals: [],
        totalValue: 0,
        weightedValue: 0,
        count: 0,
      );
    }
  }

  void _setupListeners() {
    debounce(searchQuery, (_) => loadPipeline(),
        time: const Duration(milliseconds: 500));
    ever(ownerFilter, (_) => loadPipeline());
    ever(showHotDeals, (_) => loadPipeline());
    ever(showRottingDeals, (_) => loadPipeline());
    ever(selectedTags, (_) => loadPipeline());
    ever(dateRange, (_) => loadPipeline());
  }

  Future<void> loadPipeline() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final filters = _buildFilters();
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiEndpoints.getSalesPipeline,
        queryParameters: filters,
      );

      AppLogger.d('Pipeline API Response: ${response.data}');

      if (response.success && response.data != null) {
        // Clear and reinitialize stages
        _initializeStages();
        allDeals.clear();

        // The API returns data in response.data.data structure
        final responseData = response.data!;
        final data = responseData['data'] ?? responseData;

        // Parse deals - handle both array and object structures
        if (data['deals'] != null) {
          if (data['deals'] is List) {
            _parseDealsArray(data['deals'] as List);
          } else if (data['deals'] is Map) {
            // If deals come as a map, convert to list
            final dealsMap = data['deals'] as Map;
            final dealsList = dealsMap.values.toList();
            _parseDealsArray(dealsList);
          }
        } else if (data['pipeline'] != null) {
          _parsePipelineStructure(data['pipeline']);
        } else if (data is List) {
          // Sometimes the API might return just an array of deals
          _parseDealsArray(data);
        }

        // Parse statistics if available
        if (data['stats'] != null) {
          statistics.value = PipelineStatistics.fromJson(data['stats']);
        }

        // Force UI update
        pipelineStages.refresh();
        allDeals.refresh();

        AppLogger.d('Pipeline loaded: ${allDeals.length} deals');
        AppLogger.d('Stages: ${pipelineStages.keys.join(', ')}');
        pipelineStages.forEach((stageName, stage) {
          AppLogger.d('Stage $stageName: ${stage.count} deals, value: ${stage.totalValue}');
        });
      } else {
        errorMessage.value = response.message ?? 'Failed to load pipeline';
        _initializeStages();
      }
    } catch (e) {
      AppLogger.e('Error loading pipeline', e);
      errorMessage.value = 'Error loading pipeline data';
      _initializeStages();
    } finally {
      isLoading.value = false;
    }
  }

  void _parseDealsArray(List dealsData) {
    AppLogger.d('Parsing ${dealsData.length} deals');

    for (final dealJson in dealsData) {
      try {
        final deal = Deal.fromJson(dealJson);
        allDeals.add(deal);

        // Find the stage and add the deal
        final stage = pipelineStages[deal.stage];
        if (stage != null) {
          stage.deals.add(deal);
          stage.count++;
          stage.totalValue += deal.value.annual;
          stage.weightedValue += deal.value.weighted;

          AppLogger.d('Added deal ${deal.id} to stage ${deal.stage}');
        } else {
          AppLogger.w('Stage ${deal.stage} not found for deal ${deal.id}');
        }
      } catch (e) {
        AppLogger.e('Error parsing deal: $e', e);
      }
    }
  }

  void _parsePipelineStructure(Map<String, dynamic> pipelineData) {
    AppLogger.d('Parsing pipeline structure');

    for (final config in stageConfigs) {
      final stageData = pipelineData[config.name];
      if (stageData != null && stageData['deals'] != null) {
        final deals = (stageData['deals'] as List)
            .map((json) => Deal.fromJson(json))
            .toList();

        final stage = pipelineStages[config.name]!;
        stage.deals.addAll(deals);
        stage.count = deals.length;
        stage.totalValue = (stageData['totalValue'] ?? 0).toDouble();
        stage.weightedValue = (stageData['weightedValue'] ?? 0).toDouble();

        allDeals.addAll(deals);

        AppLogger.d('Stage ${config.name}: ${deals.length} deals');
      }
    }
  }

  Future<bool> createDeal(ZAECDCenters center, {
    String? initialStage,
    DateTime? expectedCloseDate,
    List<String>? tags,
  }) async {
    try {
      AppLogger.d('Creating deal for center: ${center.id}');

      final dealData = {
        'centerId': center.id,
        'title': '${center.ecdName} - Opportunity',
        'stage': initialStage ?? 'Initial Contact',
        'expectedCloseDate': expectedCloseDate?.toIso8601String() ??
            DateTime.now().add(const Duration(days: 60)).toIso8601String(),
        'tags': tags ?? [],
        'value': {
          'monthly': center.numberOfChildren * 9.20,
          'annual': center.numberOfChildren * 9.20 * 12,
        },
        'notes': 'Deal created from Market Explorer',
        'probability': 10,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        ApiEndpoints.createDeal,
        data: dealData,
      );

      AppLogger.d('Create deal response: ${response.data}');

      if (response.success) {
        // Reload the pipeline to show the new deal
        await loadPipeline();

        Get.snackbar(
          'Success',
          'Deal created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
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

  Future<bool> updateDealStage(String dealId, String newStage) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        ApiEndpoints.updateDealStage(dealId),
        data: {'stage': newStage},
      );

      if (response.success) {
        // Update local state immediately for smooth UX
        final dealIndex = allDeals.indexWhere((d) => d.id == dealId);
        if (dealIndex != -1) {
          final deal = allDeals[dealIndex];
          final oldStage = deal.stage;

          // Remove from old stage
          final oldStageData = pipelineStages[oldStage];
          if (oldStageData != null) {
            oldStageData.deals.removeWhere((d) => d.id == dealId);
            oldStageData.count--;
            oldStageData.totalValue -= deal.value.annual;
            oldStageData.weightedValue -= deal.value.weighted;
          }

          // Update deal
          deal.stage = newStage;
          deal.updateProbability();

          // Add to new stage
          final newStageData = pipelineStages[newStage];
          if (newStageData != null) {
            newStageData.deals.add(deal);
            newStageData.count++;
            newStageData.totalValue += deal.value.annual;
            newStageData.weightedValue += deal.value.weighted;
          }

          // Force UI update
          pipelineStages.refresh();
        }

        // Refresh from server
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

  Future<bool> addActivity(String dealId, ActivityData activity) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiEndpoints.addDealActivity(dealId),
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
    }
    return false;
  }

  Future<bool> closeDealWon(String dealId, WonDetails details) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiEndpoints.closeDealWon(dealId),
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
    }
    return false;
  }

  Future<bool> closeDealLost(String dealId, LostReason reason) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiEndpoints.closeDealLost(dealId),
        data: reason.toJson(),
      );

      if (response.success) {
        await loadPipeline();
        return true;
      }
    } catch (e) {
      AppLogger.e('Error closing deal as lost', e);
    }
    return false;
  }

  Future<void> loadSalesVelocity() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiEndpoints.getSalesVelocity,
      );

      if (response.success && response.data != null) {
        salesVelocity.value = SalesVelocity.fromJson(response.data!);
      }
    } catch (e) {
      AppLogger.e('Error loading sales velocity', e);
    }
  }

  Future<void> loadForecast({String period = 'quarter'}) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiEndpoints.getSalesForecast,
        queryParameters: {'period': period},
      );

      if (response.success && response.data != null) {
        forecast.value = Forecast.fromJson(response.data!);
      }
    } catch (e) {
      AppLogger.e('Error loading forecast', e);
    }
  }

  Map<String, dynamic> _buildFilters() {
    final filters = <String, dynamic>{};

    if (ownerFilter.value != 'all') {
      filters['owner'] = ownerFilter.value;
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
    return allDeals.where((deal) => deal.isRotting).length;
  }

  int get hotDealsCount {
    return allDeals.where((deal) => deal.isHot).length;
  }
}

// Supporting Models
class PipelineStage {
  final String name;
  final List<Deal> deals;
  double totalValue;
  double weightedValue;
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