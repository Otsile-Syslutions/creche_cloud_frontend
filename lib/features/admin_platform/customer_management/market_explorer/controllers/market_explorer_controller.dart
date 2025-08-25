// lib/features/admin_platform/customer_management/market_explorer/controllers/market_explorer_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../core/services/storage_service.dart';
import '../../../../../utils/app_logger.dart';
import '../models/zaecdcenters_model.dart';
import '../../../../auth/controllers/auth_controller.dart';
import '../../../../../routes/app_routes.dart';

class MarketExplorerController extends GetxController {
  final ApiService _apiService = ApiService.to;
  final StorageService _storageService = StorageService.to;

  // Get AuthController instance safely
  AuthController? get _authController =>
      Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isInitialized = false.obs;
  final RxBool isAuthVerified = false.obs;

  // View state
  final RxString selectedView = 'list'.obs;
  final RxBool showFilters = false.obs;

  // Data
  final RxList<ZAECDCenters> centers = <ZAECDCenters>[].obs;
  final RxList<ZAECDCenters> selectedCenters = <ZAECDCenters>[].obs;
  final Rx<ZAECDCenters?> selectedProspectForDetail = Rx<ZAECDCenters?>(null);
  final Rx<MarketAnalytics?> analytics = Rx<MarketAnalytics?>(null);

  // Market Statistics from Backend
  final Rx<MarketStatistics?> marketStats = Rx<MarketStatistics?>(null);

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

  // Statistics (from backend)
  final RxInt totalCenters = 0.obs;
  final RxInt totalChildren = 0.obs;
  final RxDouble totalPotentialMRR = 0.0.obs;
  final RxDouble avgLeadScore = 0.0.obs;
  final RxInt centersWithPhone = 0.obs;
  final RxInt centersWithEmail = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupFilterListeners();
    AppLogger.d('MarketExplorerController initialized');
  }

  @override
  void onReady() {
    super.onReady();
    // Small delay to ensure everything is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!isInitialized.value) {
        _loadInitialData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    if (isInitialized.value) return;

    try {
      AppLogger.d('Loading initial Market Explorer data...');
      isInitialized.value = true;

      // Ensure authentication is set up
      await _ensureAuthentication();

      // Load data
      await fetchCenters();

      // Load analytics in background (don't await, and ignore errors)
      fetchAnalytics().catchError((e) {
        AppLogger.w('Analytics fetch failed (non-critical): $e');
        // Don't show error to user as analytics is not critical
      });

    } catch (e) {
      AppLogger.e('Error loading initial data', e);

      // Only show error if it's not authentication related (already handled)
      if (!e.toString().contains('Authentication')) {
        errorMessage.value = 'Failed to load data. Please try refreshing.';
      }

      // Mark as not initialized so we can retry
      if (e.toString().contains('Authentication')) {
        isInitialized.value = false;
      }
    }
  }

  /// Ensure authentication token is properly set in ApiService
  Future<void> _ensureAuthentication() async {
    try {
      // Skip if already verified in this session
      if (isAuthVerified.value) {
        AppLogger.d('Authentication already verified in this session');
        return;
      }

      // Ensure AuthController exists
      if (_authController == null) {
        AppLogger.d('AuthController not found, creating...');
        if (!Get.isRegistered<AuthController>()) {
          Get.put(AuthController());
        }
      }

      // Wait a bit for AuthController to initialize
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if user is authenticated
      final isAuthenticated = _authController?.isAuthenticated.value ?? false;

      if (!isAuthenticated) {
        AppLogger.w('User not authenticated, checking for stored token...');

        // Check for stored token
        final storedToken = await _storageService.getString('access_token');

        if (storedToken != null && storedToken.isNotEmpty) {
          AppLogger.d('Found stored token, setting in API service');
          await _apiService.setAccessToken(storedToken);
          isAuthVerified.value = true;
          return;
        }

        // Try to refresh token
        final refreshToken = await _storageService.getString('refresh_token');
        if (refreshToken != null && refreshToken.isNotEmpty) {
          AppLogger.d('Attempting to refresh access token...');

          try {
            final response = await _apiService.refreshTokenRequest();
            if (response.success && response.data != null) {
              AppLogger.d('Token refreshed successfully');
              isAuthVerified.value = true;
              return;
            }
          } catch (e) {
            AppLogger.e('Failed to refresh token', e);
          }
        }

        // If we get here, authentication failed
        AppLogger.w('No valid authentication found, redirecting to login');
        await _authController?.clearSession();
        Get.offAllNamed(AppRoutes.login);
        throw Exception('Authentication required');
      }

      // Ensure the token is loaded in the API service
      final storedToken = await _storageService.getString('access_token');

      if (storedToken != null && storedToken.isNotEmpty) {
        if (_apiService.accessToken != storedToken) {
          AppLogger.d('Setting access token in API service');
          await _apiService.setAccessToken(storedToken);
        }
        isAuthVerified.value = true;
      } else {
        AppLogger.w('No access token found despite being authenticated');
        // Try to get token from AuthController
        final authToken = _authController?.accessToken;
        if (authToken != null && authToken.isNotEmpty) {
          AppLogger.d('Using token from AuthController');
          await _apiService.setAccessToken(authToken);
          await _storageService.setString('access_token', authToken);
          isAuthVerified.value = true;
        } else {
          throw Exception('No valid access token available');
        }
      }

      AppLogger.d('Authentication verified successfully');

    } catch (e) {
      AppLogger.e('Authentication verification failed', e);
      errorMessage.value = 'Authentication error. Please log in again.';
      isAuthVerified.value = false;
      rethrow;
    }
  }

  void _setupFilterListeners() {
    // Debounce search
    debounce(searchQuery, (_) {
      if (isInitialized.value) fetchCenters();
    }, time: const Duration(milliseconds: 500));

    // React to filter changes
    ever(selectedProvinces, (_) {
      if (isInitialized.value) fetchCenters();
    });
    ever(selectedRegistrationStatus, (_) {
      if (isInitialized.value) fetchCenters();
    });
    ever(selectedLeadStatus, (_) {
      if (isInitialized.value) fetchCenters();
    });
    ever(selectedPipelineStage, (_) {
      if (isInitialized.value) fetchCenters();
    });
    ever(hasPhone, (_) {
      if (isInitialized.value) fetchCenters();
    });
    ever(hasEmail, (_) {
      if (isInitialized.value) fetchCenters();
    });
    ever(sortBy, (_) {
      if (isInitialized.value) fetchCenters();
    });
    ever(sortOrder, (_) {
      if (isInitialized.value) fetchCenters();
    });
  }

  // Fetch ECD Centers
  Future<void> fetchCenters({bool loadMore = false}) async {
    // Prevent multiple simultaneous loads
    if (isLoading.value || isLoadingMore.value) return;

    if (loadMore) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      currentPage.value = 1;
    }

    try {
      // Ensure token is still valid
      await _ensureAuthentication();

      final queryParams = _buildQueryParams();
      if (loadMore) {
        queryParams['page'] = (currentPage.value + 1).toString();
      }

      AppLogger.d('Fetching centers from /market-explorer with params: $queryParams');

      // Make API call with direct path
      final response = await _apiService.get<Map<String, dynamic>>(
        '/market-explorer',
        queryParameters: queryParams,
      );

      AppLogger.d('Response received: success=${response.success}, statusCode=${response.statusCode}');

      if (response.success) {
        // Get the response data
        final responseData = response.data ?? {};

        // Handle nested data structure
        final data = responseData['data'] ?? responseData;

        AppLogger.d('Processing response data structure');

        // Parse centers array
        final List<dynamic> centersJson = data['centers'] ?? [];
        AppLogger.d('Found ${centersJson.length} centers in response');

        final List<ZAECDCenters> fetchedCenters = [];

        for (var json in centersJson) {
          try {
            final center = ZAECDCenters.fromJson(json);
            fetchedCenters.add(center);
          } catch (e) {
            AppLogger.w('Error parsing center: $e');
            // Continue parsing other centers
          }
        }

        if (loadMore) {
          centers.addAll(fetchedCenters);
          currentPage.value++;
        } else {
          centers.value = fetchedCenters;
        }

        // Update pagination
        if (data['pagination'] != null) {
          totalItems.value = data['pagination']['total'] ?? data['pagination']['totalItems'] ?? 0;
          totalPages.value = data['pagination']['totalPages'] ?? data['pagination']['total'] ?? 0;
        }

        // Update market statistics from backend
        if (data['stats'] != null) {
          _updateMarketStatistics(data['stats']);
        }

        errorMessage.value = '';
        AppLogger.d('Successfully loaded ${fetchedCenters.length} centers');

      } else {
        // Handle non-success response
        errorMessage.value = response.message ?? 'Failed to fetch centers';
        AppLogger.w('API returned non-success: ${response.message}');

        // Don't clear existing data on error
        if (!loadMore && centers.isEmpty) {
          centers.value = [];
        }
      }

    } catch (e) {
      AppLogger.e('Error fetching centers', e);

      // Handle specific error types
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        // Session expired, try to refresh token
        AppLogger.w('Auth error detected, attempting token refresh');
        isAuthVerified.value = false;

        try {
          await _ensureAuthentication();
          // Retry the fetch after successful authentication
          await fetchCenters(loadMore: loadMore);
          return;
        } catch (authError) {
          errorMessage.value = 'Session expired. Please log in again.';
          AppLogger.e('Failed to refresh authentication', authError);
        }
      } else if (e.toString().contains('404')) {
        errorMessage.value = 'Market Explorer endpoint not found. Please contact support.';
      } else if (e.toString().contains('NetworkException') || e.toString().contains('SocketException')) {
        errorMessage.value = 'Network error. Please check your connection.';
      } else if (e.toString().contains('Authentication')) {
        // Authentication errors are already handled in _ensureAuthentication
        return;
      } else {
        errorMessage.value = 'Error loading data. Please try again.';
      }

      // Set empty data on first load error
      if (!loadMore && centers.isEmpty) {
        centers.value = [];
        totalCenters.value = 0;
      }

    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Update market statistics from backend response
  void _updateMarketStatistics(Map<String, dynamic> stats) {
    try {
      // Parse market statistics
      marketStats.value = MarketStatistics.fromJson(stats);

      // Update local observable values for backward compatibility
      if (stats['filtered'] != null) {
        totalCenters.value = stats['filtered']['totalCenters'] ?? 0;
        totalChildren.value = stats['filtered']['totalChildren'] ?? 0;
        totalPotentialMRR.value = (stats['filtered']['totalPotentialMRR'] ?? 0).toDouble();
        avgLeadScore.value = (stats['filtered']['avgLeadScore'] ?? 0).toDouble();
        centersWithPhone.value = stats['filtered']['withPhone'] ?? 0;
        centersWithEmail.value = stats['filtered']['withEmail'] ?? 0;
      }

      AppLogger.d('Market statistics updated: ${marketStats.value?.toJson()}');
    } catch (e) {
      AppLogger.e('Error updating market statistics', e);
    }
  }

  // Fetch analytics - with better error handling
  Future<void> fetchAnalytics() async {
    try {
      // Don't ensure authentication if it's already failing
      if (!isAuthVerified.value) {
        AppLogger.w('Skipping analytics fetch - not authenticated');
        return;
      }

      AppLogger.d('Fetching market analytics...');

      final response = await _apiService.get<Map<String, dynamic>>(
        '/market-explorer/analytics',
      );

      if (response.success && response.data != null) {
        final responseData = response.data!;
        final data = responseData['data'] ?? responseData;

        // Update both analytics and market stats if available
        analytics.value = MarketAnalytics.fromJson(data);

        // If the analytics endpoint also returns market stats, update them
        if (data['marketTotals'] != null || data['onboarded'] != null) {
          marketStats.value = MarketStatistics.fromJson(data);
        }

        AppLogger.d('Analytics loaded successfully');
      } else {
        AppLogger.w('Failed to fetch analytics: ${response.message}');
      }
    } catch (e) {
      // Don't show error for analytics, it's not critical
      AppLogger.w('Error fetching analytics (non-critical): $e');
    }
  }

  // Get single center details
  Future<ZAECDCenters?> getCenterDetails(String centerId) async {
    try {
      // Ensure authentication before making API call
      await _ensureAuthentication();

      final response = await _apiService.get<Map<String, dynamic>>(
        '/market-explorer/$centerId',
      );

      if (response.success && response.data != null) {
        final data = response.data!['data'] ?? response.data!;
        return ZAECDCenters.fromJson(data['center'] ?? data);
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
      await _ensureAuthentication();

      final response = await _apiService.put<Map<String, dynamic>>(
        '/market-explorer/$centerId',
        data: updates,
      );

      if (response.success) {
        // Update local data
        final index = centers.indexWhere((c) => c.id == centerId);
        if (index != -1 && response.data != null) {
          final data = response.data!['data'] ?? response.data!;
          centers[index] = ZAECDCenters.fromJson(data['center'] ?? data);
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
      await _ensureAuthentication();

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
          final data = response.data!['data'] ?? response.data!;
          centers[index] = ZAECDCenters.fromJson(data['center'] ?? data);
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
      await _ensureAuthentication();

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
          final responseData = response.data!['data'] ?? response.data!;
          centers[index] = ZAECDCenters.fromJson(responseData['center'] ?? responseData);
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
      await _ensureAuthentication();

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
      await _ensureAuthentication();

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
          duration: const Duration(seconds: 5),
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
      await _ensureAuthentication();

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
      await _ensureAuthentication();

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

  // Manual refresh
  Future<void> refreshData() async {
    errorMessage.value = '';
    await fetchCenters();
    // Try to fetch analytics but don't await
    fetchAnalytics().catchError((e) {
      AppLogger.w('Analytics refresh failed (non-critical): $e');
    });
  }

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

  // UI helper methods
  void toggleView(String view) {
    selectedView.value = view;
    if (view == 'analytics' && analytics.value == null) {
      fetchAnalytics().catchError((e) {
        AppLogger.w('Analytics fetch failed: $e');
      });
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

  // Computed values with backend data
  int get totalSelectedMRR {
    return selectedCenters.fold(0, (sum, center) => sum + center.potentialMRR.toInt());
  }

  int get totalSelectedChildren {
    return selectedCenters.fold(0, (sum, center) => sum + center.numberOfChildren);
  }

  // Get market totals from backend stats
  int get totalMarketSchools => marketStats.value?.marketTotals?.schools ?? 0;
  int get totalMarketChildren => marketStats.value?.marketTotals?.children ?? 0;
  double get totalMarketMRR => marketStats.value?.marketTotals?.mrr ?? 0.0;

  // Get onboarded totals from backend stats
  int get onboardedSchools => marketStats.value?.onboarded?.schools ?? 0;
  int get onboardedChildren => marketStats.value?.onboarded?.children ?? 0;
  double get currentMRR => marketStats.value?.onboarded?.mrr ?? 0.0;

  // Calculate market share percentage
  double get marketSharePercentage => marketStats.value?.marketShare?.percentage ?? 0.0;

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

// Market Statistics Model
class MarketStatistics {
  final MarketTotals? marketTotals;
  final OnboardedStats? onboarded;
  final FilteredStats? filtered;
  final MarketShare? marketShare;
  final List<PipelineStage>? pipeline;
  final List<LeadStatusStat>? leadStatus;
  final CompetitorStats? competitors;

  MarketStatistics({
    this.marketTotals,
    this.onboarded,
    this.filtered,
    this.marketShare,
    this.pipeline,
    this.leadStatus,
    this.competitors,
  });

  factory MarketStatistics.fromJson(Map<String, dynamic> json) {
    return MarketStatistics(
      marketTotals: json['marketTotals'] != null
          ? MarketTotals.fromJson(json['marketTotals'])
          : null,
      onboarded: json['onboarded'] != null
          ? OnboardedStats.fromJson(json['onboarded'])
          : null,
      filtered: json['filtered'] != null
          ? FilteredStats.fromJson(json['filtered'])
          : null,
      marketShare: json['marketShare'] != null
          ? MarketShare.fromJson(json['marketShare'])
          : null,
      pipeline: json['pipeline'] != null
          ? (json['pipeline'] as List)
          .map((e) => PipelineStage.fromJson(e))
          .toList()
          : null,
      leadStatus: json['leadStatus'] != null
          ? (json['leadStatus'] as List)
          .map((e) => LeadStatusStat.fromJson(e))
          .toList()
          : null,
      competitors: json['competitors'] != null
          ? CompetitorStats.fromJson(json['competitors'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'marketTotals': marketTotals?.toJson(),
      'onboarded': onboarded?.toJson(),
      'filtered': filtered?.toJson(),
      'marketShare': marketShare?.toJson(),
      'pipeline': pipeline?.map((e) => e.toJson()).toList(),
      'leadStatus': leadStatus?.map((e) => e.toJson()).toList(),
      'competitors': competitors?.toJson(),
    };
  }
}

class MarketTotals {
  final int schools;
  final int children;
  final double mrr;

  MarketTotals({
    required this.schools,
    required this.children,
    required this.mrr,
  });

  factory MarketTotals.fromJson(Map<String, dynamic> json) {
    return MarketTotals(
      schools: json['schools'] ?? 0,
      children: json['children'] ?? 0,
      mrr: (json['mrr'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schools': schools,
      'children': children,
      'mrr': mrr,
    };
  }
}

class OnboardedStats {
  final int schools;
  final int children;
  final double mrr;

  OnboardedStats({
    required this.schools,
    required this.children,
    required this.mrr,
  });

  factory OnboardedStats.fromJson(Map<String, dynamic> json) {
    return OnboardedStats(
      schools: json['schools'] ?? 0,
      children: json['children'] ?? 0,
      mrr: (json['mrr'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schools': schools,
      'children': children,
      'mrr': mrr,
    };
  }
}

class FilteredStats {
  final int totalCenters;
  final int totalChildren;
  final double totalPotentialMRR;
  final double avgLeadScore;
  final int withPhone;
  final int withEmail;

  FilteredStats({
    required this.totalCenters,
    required this.totalChildren,
    required this.totalPotentialMRR,
    required this.avgLeadScore,
    required this.withPhone,
    required this.withEmail,
  });

  factory FilteredStats.fromJson(Map<String, dynamic> json) {
    return FilteredStats(
      totalCenters: json['totalCenters'] ?? 0,
      totalChildren: json['totalChildren'] ?? 0,
      totalPotentialMRR: (json['totalPotentialMRR'] ?? 0).toDouble(),
      avgLeadScore: (json['avgLeadScore'] ?? 0).toDouble(),
      withPhone: json['withPhone'] ?? 0,
      withEmail: json['withEmail'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCenters': totalCenters,
      'totalChildren': totalChildren,
      'totalPotentialMRR': totalPotentialMRR,
      'avgLeadScore': avgLeadScore,
      'withPhone': withPhone,
      'withEmail': withEmail,
    };
  }
}

class MarketShare {
  final double percentage;
  final int schoolsRemaining;
  final double potentialRemaining;

  MarketShare({
    required this.percentage,
    required this.schoolsRemaining,
    required this.potentialRemaining,
  });

  factory MarketShare.fromJson(Map<String, dynamic> json) {
    return MarketShare(
      percentage: (json['percentage'] ?? 0).toDouble(),
      schoolsRemaining: json['schoolsRemaining'] ?? 0,
      potentialRemaining: (json['potentialRemaining'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage,
      'schoolsRemaining': schoolsRemaining,
      'potentialRemaining': potentialRemaining,
    };
  }
}

class PipelineStage {
  final String id;
  final int count;
  final double totalMRR;

  PipelineStage({
    required this.id,
    required this.count,
    required this.totalMRR,
  });

  factory PipelineStage.fromJson(Map<String, dynamic> json) {
    return PipelineStage(
      id: json['_id'] ?? '',
      count: json['count'] ?? 0,
      totalMRR: (json['totalMRR'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'count': count,
      'totalMRR': totalMRR,
    };
  }
}

class LeadStatusStat {
  final String id;
  final int count;

  LeadStatusStat({
    required this.id,
    required this.count,
  });

  factory LeadStatusStat.fromJson(Map<String, dynamic> json) {
    return LeadStatusStat(
      id: json['_id'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'count': count,
    };
  }
}

class CompetitorStats {
  final int usingCompetitors;
  final int wonFromCompetitors;

  CompetitorStats({
    required this.usingCompetitors,
    required this.wonFromCompetitors,
  });

  factory CompetitorStats.fromJson(Map<String, dynamic> json) {
    return CompetitorStats(
      usingCompetitors: json['usingCompetitors'] ?? 0,
      wonFromCompetitors: json['wonFromCompetitors'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usingCompetitors': usingCompetitors,
      'wonFromCompetitors': wonFromCompetitors,
    };
  }
}