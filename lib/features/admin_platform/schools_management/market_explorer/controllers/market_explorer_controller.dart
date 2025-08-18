// lib/features/admin_platform/schools_management/market_explorer/controllers/market_explorer_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../core/config/api_endpoints.dart';
import '../../../../../utils/app_logger.dart';
import '../models/zaecdcenters_model.dart';

class MarketExplorerController extends GetxController {
  final ApiService _apiService = ApiService.to;

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;

  // View state
  final RxString selectedView = 'list'.obs; // list, map, analytics
  final RxBool showFilters = false.obs;

  // Data
  final RxList<ZAECDCenters> centers = <ZAECDCenters>[].obs;
  final RxList<ZAECDCenters> selectedCenters = <ZAECDCenters>[].obs;
  final Rx<MarketAnalytics?> analytics = Rx<MarketAnalytics?>(null);

  // Filters
  final RxString searchQuery = ''.obs;
  final RxList<String> selectedProvinces = <String>[].obs;
  final RxList<String> selectedRegistrationStatus = <String>[].obs;
  final RxList<String> selectedLeadStatus = <String>[].obs;
  final RxString selectedPipelineStage = ''.obs;
  final RxInt minChildren = 0.obs;
  final RxInt maxChildren = 999.obs;
  final RxInt minLeadScore = 0.obs;
  final RxInt maxLeadScore = 100.obs;
  final RxBool hasPhone = false.obs;
  final RxBool hasEmail = false.obs;
  final RxString assignedRep = ''.obs;
  final RxString sortBy = 'leadScore'.obs;
  final RxString sortOrder = 'desc'.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 50.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;

  // Statistics
  final RxInt totalCenters = 0.obs;
  final RxInt totalChildren = 0.obs;
  final RxDouble totalPotentialMRR = 0.0.obs;
  final RxDouble avgLeadScore = 0.0.obs;
  final RxInt centersWithPhone = 0.obs;
  final RxInt centersWithEmail = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCenters();
    fetchAnalytics();

    // Set up listeners for filter changes
    _setupFilterListeners();
  }

  void _setupFilterListeners() {
    // Debounce search query
    debounce(searchQuery, (_) => fetchCenters(), time: Duration(milliseconds: 500));

    // React to filter changes
    ever(selectedProvinces, (_) => fetchCenters());
    ever(selectedRegistrationStatus, (_) => fetchCenters());
    ever(selectedLeadStatus, (_) => fetchCenters());
    ever(selectedPipelineStage, (_) => fetchCenters());
    ever(hasPhone, (_) => fetchCenters());
    ever(hasEmail, (_) => fetchCenters());
    ever(sortBy, (_) => fetchCenters());
    ever(sortOrder, (_) => fetchCenters());
  }

  // Fetch ECD Centers with filters
  Future<void> fetchCenters({bool loadMore = false}) async {
    if (loadMore) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      currentPage.value = 1;
    }

    try {
      // Build query parameters
      final queryParams = _buildQueryParams();

      if (loadMore) {
        queryParams['page'] = (currentPage.value + 1).toString();
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        '/market-explorer',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;

        // Parse centers
        final List<dynamic> centersJson = data['centers'] ?? [];
        final List<ZAECDCenters> fetchedCenters = centersJson
            .map((json) => ZAECDCenters.fromJson(json))
            .toList();

        if (loadMore) {
          centers.addAll(fetchedCenters);
          currentPage.value++;
        } else {
          centers.value = fetchedCenters;
        }

        // Update pagination info
        if (data['pagination'] != null) {
          totalItems.value = data['pagination']['total'] ?? 0;
          totalPages.value = data['pagination']['totalPages'] ?? 0;
        }

        // Update statistics
        if (data['stats'] != null) {
          _updateStatistics(data['stats']);
        }

        errorMessage.value = '';
      } else {
        errorMessage.value = response.message ?? 'Failed to fetch centers';
      }
    } catch (e) {
      AppLogger.e('Error fetching centers', e);
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Fetch market analytics
  Future<void> fetchAnalytics() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/market-explorer/analytics',
      );

      if (response.success && response.data != null) {
        analytics.value = MarketAnalytics.fromJson(response.data!);
      }
    } catch (e) {
      AppLogger.e('Error fetching analytics', e);
    }
  }

  // Get single center details
  Future<ZAECDCenters?> getCenterDetails(String centerId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/market-explorer/$centerId',
      );

      if (response.success && response.data != null) {
        return ZAECDCenters.fromJson(response.data!['center']);
      }
    } catch (e) {
      AppLogger.e('Error fetching center details', e);
      Get.snackbar(
        'Error',
        'Failed to fetch center details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return null;
  }

  // Update center
  Future<bool> updateCenter(String centerId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/market-explorer/$centerId',
        data: updates,
      );

      if (response.success) {
        // Update local data
        final index = centers.indexWhere((c) => c.id == centerId);
        if (index != -1 && response.data != null) {
          centers[index] = ZAECDCenters.fromJson(response.data!['center']);
        }

        Get.snackbar(
          'Success',
          'Center updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to update center',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      AppLogger.e('Error updating center', e);
      Get.snackbar(
        'Error',
        'Failed to update center',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  // Add note to center
  Future<bool> addNote(String centerId, String content, String type) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/market-explorer/$centerId/notes',
        data: {
          'content': content,
          'type': type,
        },
      );

      if (response.success) {
        // Update local data
        final index = centers.indexWhere((c) => c.id == centerId);
        if (index != -1 && response.data != null) {
          centers[index] = ZAECDCenters.fromJson(response.data!['center']);
        }

        Get.snackbar(
          'Success',
          'Note added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
    } catch (e) {
      AppLogger.e('Error adding note', e);
      Get.snackbar(
        'Error',
        'Failed to add note',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  // Update lead status
  Future<bool> updateLeadStatus(
      String centerId,
      String leadStatus,
      String pipelineStage, {
        String? reasonWon,
        String? reasonLost,
      }) async {
    try {
      final data = {
        'leadStatus': leadStatus,
        'pipelineStage': pipelineStage,
      };

      if (reasonWon != null) data['reasonWon'] = reasonWon;
      if (reasonLost != null) data['reasonLost'] = reasonLost;

      final response = await _apiService.put<Map<String, dynamic>>(
        '/market-explorer/$centerId/status',
        data: data,
      );

      if (response.success) {
        // Update local data
        final index = centers.indexWhere((c) => c.id == centerId);
        if (index != -1 && response.data != null) {
          centers[index] = ZAECDCenters.fromJson(response.data!['center']);
        }

        Get.snackbar(
          'Success',
          'Lead status updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
    } catch (e) {
      AppLogger.e('Error updating lead status', e);
      Get.snackbar(
        'Error',
        'Failed to update lead status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  // Assign sales rep
  Future<bool> assignSalesRep(List<String> centerIds, String salesRepId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/market-explorer/assign',
        data: {
          'centerIds': centerIds,
          'salesRepId': salesRepId,
        },
      );

      if (response.success) {
        // Refresh data
        await fetchCenters();

        Get.snackbar(
          'Success',
          response.message ?? 'Sales rep assigned successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
    } catch (e) {
      AppLogger.e('Error assigning sales rep', e);
      Get.snackbar(
        'Error',
        'Failed to assign sales rep',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  // Convert to tenant
  Future<bool> convertToTenant(String centerId, Map<String, dynamic> tenantData) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/market-explorer/$centerId/convert',
        data: tenantData,
      );

      if (response.success) {
        // Remove from centers list
        centers.removeWhere((c) => c.id == centerId);

        Get.snackbar(
          'Success',
          'Successfully converted to tenant!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
        return true;
      }
    } catch (e) {
      AppLogger.e('Error converting to tenant', e);
      Get.snackbar(
        'Error',
        'Failed to convert to tenant',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  // Bulk update
  Future<bool> bulkUpdate(List<String> centerIds, Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/market-explorer/bulk',
        data: {
          'centerIds': centerIds,
          'updates': updates,
        },
      );

      if (response.success) {
        // Refresh data
        await fetchCenters();

        Get.snackbar(
          'Success',
          response.message ?? 'Centers updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
    } catch (e) {
      AppLogger.e('Error in bulk update', e);
      Get.snackbar(
        'Error',
        'Failed to update centers',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  // Export data
  Future<void> exportData(String format) async {
    try {
      final queryParams = _buildQueryParams();
      queryParams['format'] = format;

      final response = await _apiService.get<dynamic>(
        '/market-explorer/export',
        queryParameters: queryParams,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Export completed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Handle file download based on format
        // Implementation depends on your file handling approach
      }
    } catch (e) {
      AppLogger.e('Error exporting data', e);
      Get.snackbar(
        'Error',
        'Failed to export data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Helper methods

  Map<String, dynamic> _buildQueryParams() {
    final params = <String, dynamic>{
      'page': currentPage.value.toString(),
      'limit': itemsPerPage.value.toString(),
      'sortBy': sortBy.value,
      'sortOrder': sortOrder.value,
    };

    if (searchQuery.value.isNotEmpty) {
      params['search'] = searchQuery.value;
    }

    if (selectedProvinces.isNotEmpty) {
      params['provinces'] = selectedProvinces.join(',');
    }

    if (selectedRegistrationStatus.isNotEmpty) {
      params['registrationStatus'] = selectedRegistrationStatus.join(',');
    }

    if (selectedLeadStatus.isNotEmpty) {
      params['leadStatus'] = selectedLeadStatus.join(',');
    }

    if (selectedPipelineStage.value.isNotEmpty && selectedPipelineStage.value != 'All') {
      params['pipelineStage'] = selectedPipelineStage.value;
    }

    if (minChildren.value > 0) {
      params['minChildren'] = minChildren.value.toString();
    }

    if (maxChildren.value < 999) {
      params['maxChildren'] = maxChildren.value.toString();
    }

    if (minLeadScore.value > 0) {
      params['minLeadScore'] = minLeadScore.value.toString();
    }

    if (maxLeadScore.value < 100) {
      params['maxLeadScore'] = maxLeadScore.value.toString();
    }

    if (hasPhone.value) {
      params['hasPhone'] = 'true';
    }

    if (hasEmail.value) {
      params['hasEmail'] = 'true';
    }

    if (assignedRep.value.isNotEmpty && assignedRep.value != 'All') {
      params['assignedRep'] = assignedRep.value;
    }

    return params;
  }

  void _updateStatistics(Map<String, dynamic> stats) {
    totalCenters.value = stats['totalCenters'] ?? 0;
    totalChildren.value = stats['totalChildren'] ?? 0;
    totalPotentialMRR.value = (stats['totalPotentialMRR'] ?? 0).toDouble();
    avgLeadScore.value = (stats['avgLeadScore'] ?? 0).toDouble();
    centersWithPhone.value = stats['withPhone'] ?? 0;
    centersWithEmail.value = stats['withEmail'] ?? 0;
  }

  // UI Helper methods

  void toggleView(String view) {
    selectedView.value = view;
    if (view == 'analytics' && analytics.value == null) {
      fetchAnalytics();
    }
  }

  void toggleFilters() {
    showFilters.value = !showFilters.value;
  }

  void toggleCenterSelection(ZAECDCenters center) {
    if (selectedCenters.contains(center)) {
      selectedCenters.remove(center);
    } else {
      selectedCenters.add(center);
    }
  }

  void selectAllCenters() {
    selectedCenters.value = List.from(centers);
  }

  void clearSelection() {
    selectedCenters.clear();
  }

  void toggleProvinceFilter(String province) {
    if (selectedProvinces.contains(province)) {
      selectedProvinces.remove(province);
    } else {
      selectedProvinces.add(province);
    }
  }

  void toggleRegistrationFilter(String status) {
    if (selectedRegistrationStatus.contains(status)) {
      selectedRegistrationStatus.remove(status);
    } else {
      selectedRegistrationStatus.add(status);
    }
  }

  void toggleLeadStatusFilter(String status) {
    if (selectedLeadStatus.contains(status)) {
      selectedLeadStatus.remove(status);
    } else {
      selectedLeadStatus.add(status);
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedProvinces.clear();
    selectedRegistrationStatus.clear();
    selectedLeadStatus.clear();
    selectedPipelineStage.value = '';
    minChildren.value = 0;
    maxChildren.value = 999;
    minLeadScore.value = 0;
    maxLeadScore.value = 100;
    hasPhone.value = false;
    hasEmail.value = false;
    assignedRep.value = '';
    sortBy.value = 'leadScore';
    sortOrder.value = 'desc';
  }

  void loadNextPage() {
    if (!isLoadingMore.value && currentPage.value < totalPages.value) {
      fetchCenters(loadMore: true);
    }
  }

  void setSorting(String field) {
    if (sortBy.value == field) {
      sortOrder.value = sortOrder.value == 'asc' ? 'desc' : 'asc';
    } else {
      sortBy.value = field;
      sortOrder.value = 'desc';
    }
  }

  // Computed values

  int get totalSelectedMRR {
    return selectedCenters.fold(0, (sum, center) => sum + center.potentialMRR.toInt());
  }

  int get totalSelectedChildren {
    return selectedCenters.fold(0, (sum, center) => sum + center.numberOfChildren);
  }

  double get marketPenetration {
    if (totalCenters.value == 0) return 0;
    // Assuming we have some customers already
    return (127 / totalCenters.value) * 100; // Example: 127 customers
  }

  bool get hasMorePages => currentPage.value < totalPages.value;

  bool get hasFiltersApplied {
    return searchQuery.value.isNotEmpty ||
        selectedProvinces.isNotEmpty ||
        selectedRegistrationStatus.isNotEmpty ||
        selectedLeadStatus.isNotEmpty ||
        selectedPipelineStage.value.isNotEmpty ||
        minChildren.value > 0 ||
        maxChildren.value < 999 ||
        minLeadScore.value > 0 ||
        maxLeadScore.value < 100 ||
        hasPhone.value ||
        hasEmail.value ||
        assignedRep.value.isNotEmpty;
  }
}