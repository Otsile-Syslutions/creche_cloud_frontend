// lib/core/services/api_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../config/env.dart';
import '../config/api_endpoints.dart';
import 'storage_service.dart';
import '../../utils/app_logger.dart';

// =============================================================================
// API RESPONSE MODELS
// =============================================================================

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    required this.statusCode,
    this.errors,
  });

  factory ApiResponse.fromResponse(Response response) {
    final data = response.data;

    // Debug logging for response structure (safe version)
    try {
      AppLogger.d('=== API RESPONSE DEBUG ===');
      AppLogger.d('Response status: ${response.statusCode}');
      AppLogger.d('Response data type: ${data.runtimeType}');
      if (data is Map<String, dynamic>) {
        AppLogger.d('Has success field: ${data.containsKey('success')}');
        AppLogger.d('Has data field: ${data.containsKey('data')}');
        AppLogger.d('Data field type: ${data['data']?.runtimeType}');
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          final innerData = data['data'] as Map<String, dynamic>;
          AppLogger.d('Inner data keys: ${innerData.keys.toList()}');
        }
      }
      AppLogger.d('=========================');
    } catch (e) {
      AppLogger.w('Debug logging failed: $e');
    }

    return ApiResponse<T>(
      success: data['success'] ?? (response.statusCode! >= 200 && response.statusCode! < 300),
      message: data['message'],
      data: data['data'] ?? data,
      statusCode: response.statusCode!,
      errors: data['errors'],
    );
  }

  factory ApiResponse.error(String message, int statusCode, {Map<String, dynamic>? errors}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      data: null,
      statusCode: statusCode,
      errors: errors,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, message: $message, statusCode: $statusCode}';
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioException(DioException e) {
    String message = 'Network error occurred';
    int statusCode = 500;
    Map<String, dynamic>? errors;

    if (e.response != null) {
      statusCode = e.response!.statusCode!;
      final data = e.response!.data;

      if (data is Map<String, dynamic>) {
        message = data['message'] ?? 'Server error';
        errors = data['errors'];
      } else {
        message = 'Server returned invalid response';
      }
    } else {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          message = 'Connection timeout';
          break;
        case DioExceptionType.sendTimeout:
          message = 'Send timeout';
          break;
        case DioExceptionType.receiveTimeout:
          message = 'Receive timeout';
          break;
        case DioExceptionType.badCertificate:
          message = 'Certificate error';
          break;
        case DioExceptionType.connectionError:
          message = 'Connection error';
          break;
        case DioExceptionType.unknown:
          message = 'Network error: ${e.message}';
          break;
        default:
          message = 'Unknown error occurred';
      }
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  @override
  String toString() {
    return 'ApiException{message: $message, statusCode: $statusCode}';
  }
}

// =============================================================================
// API SERVICE
// =============================================================================

class ApiService extends getx.GetxService {
  static ApiService get to => getx.Get.find();

  late Dio _dio;
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeDio();
    await _loadStoredTokens();
  }

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }

  /// Initialize Dio HTTP client with configuration
  Future<void> _initializeDio() async {
    _dio = Dio(BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: Env.connectTimeout,
      receiveTimeout: Env.receiveTimeout,
      sendTimeout: Env.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    ));

    // Add request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // Add logging interceptor in development
    if (Env.enableHttpLogging && Env.isDevelopment) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => AppLogger.d('API: $obj'),
      ));
    }
  }

  /// Load stored access and refresh tokens
  Future<void> _loadStoredTokens() async {
    try {
      final accessToken = await StorageService.to.getString('access_token');
      final refreshToken = await StorageService.to.getString('refresh_token');

      if (accessToken != null && accessToken.isNotEmpty) {
        _accessToken = accessToken;
      }

      if (refreshToken != null && refreshToken.isNotEmpty) {
        _refreshToken = refreshToken;
      }
    } catch (e) {
      AppLogger.e('Error loading stored tokens', e);
    }
  }

  /// Request interceptor
  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add authorization header if token exists
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }

    // Add tenant context header if available (for multi-tenant support)
    // This could be set from user's current tenant
    // options.headers['X-Tenant-ID'] = currentTenantId;

    handler.next(options);
  }

  /// Response interceptor
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    // Handle successful responses
    handler.next(response);
  }

  /// Error interceptor with backend-specific error handling
  void _onError(DioException error, ErrorInterceptorHandler handler) async {
    // Handle token expiration (401 from backend)
    if (error.response?.statusCode == 401) {
      // Try to refresh token
      final refreshed = await _handleTokenExpiration();
      if (refreshed) {
        // Retry original request with new token
        try {
          final originalRequest = error.requestOptions;
          originalRequest.headers['Authorization'] = 'Bearer $_accessToken';
          final response = await _dio.fetch(originalRequest);
          handler.resolve(response);
          return;
        } catch (e) {
          // If retry fails, continue with original error
        }
      }
    }

    handler.next(error);
  }

  /// Handle token expiration by refreshing
  Future<bool> _handleTokenExpiration() async {
    try {
      if (_refreshToken == null) return false;

      final response = await refreshTokenRequest();
      return response.success;
    } catch (e) {
      AppLogger.e('Token refresh failed', e);
      return false;
    }
  }

  // =============================================================================
  // TOKEN EXTRACTION HELPERS
  // =============================================================================

  /// Helper method to safely extract string values from any dynamic type
  String? _extractStringValue(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      return value.isNotEmpty ? value : null;
    }

    if (value is Map<String, dynamic>) {
      // If it's a nested object, try to extract common token field names
      final tokenValue = value['token'] ??
          value['value'] ??
          value['access_token'] ??
          value['accessToken'] ??
          value['refresh_token'] ??
          value['refreshToken'];

      if (tokenValue is String && tokenValue.isNotEmpty) {
        return tokenValue;
      }
    }

    // Convert to string as last resort, but only if it's not an empty object
    if (value is! Map || (value as Map).isNotEmpty) {
      final stringValue = value.toString();
      return stringValue.isNotEmpty && stringValue != 'null' ? stringValue : null;
    }

    return null;
  }

  /// Helper method to safely extract tokens from response data
  /// Handles the actual backend response structure: { success, message, data: { access_token, refresh_token, ... } }
  Map<String, String?> _extractTokens(Map<String, dynamic> responseData) {
    AppLogger.d('=== TOKEN EXTRACTION DEBUG ===');
    AppLogger.d('Response data keys: ${responseData.keys.toList()}');
    AppLogger.d('Response data structure: ${responseData.runtimeType}');

    String? accessToken;
    String? refreshToken;

    // The backend returns tokens in the responseData directly (which is the 'data' field from the API)
    // Try both field name variations that the backend provides

    // Extract access token - backend provides both access_token and accessToken
    final accessTokenRaw = responseData['access_token'] ?? responseData['accessToken'];
    accessToken = _extractStringValue(accessTokenRaw);

    // Extract refresh token - backend provides both refresh_token and refreshToken
    final refreshTokenRaw = responseData['refresh_token'] ?? responseData['refreshToken'];
    refreshToken = _extractStringValue(refreshTokenRaw);

    AppLogger.d('Raw access token type: ${accessTokenRaw?.runtimeType}');
    AppLogger.d('Raw refresh token type: ${refreshTokenRaw?.runtimeType}');
    AppLogger.d('Extracted access token: ${accessToken != null ? '[PRESENT]' : '[MISSING]'}');
    AppLogger.d('Extracted refresh token: ${refreshToken != null ? '[PRESENT]' : '[MISSING]'}');
    AppLogger.d('==============================');

    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  // =============================================================================
  // TOKEN MANAGEMENT
  // =============================================================================

  /// Set access token
  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    await StorageService.to.setString('access_token', token);
  }

  /// Set refresh token
  Future<void> setRefreshToken(String token) async {
    _refreshToken = token;
    await StorageService.to.setString('refresh_token', token);
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await StorageService.to.remove('access_token');
    await StorageService.to.remove('refresh_token');
  }

  /// Get current access token
  String? get accessToken => _accessToken;

  /// Get current refresh token
  String? get refreshTokenValue => _refreshToken;

  // =============================================================================
  // HTTP METHODS
  // =============================================================================

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );

      return ApiResponse<T>.fromResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Generic POST request
  Future<ApiResponse<T>> post<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );

      return ApiResponse<T>.fromResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );

      return ApiResponse<T>.fromResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );

      return ApiResponse<T>.fromResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Generic PATCH request
  Future<ApiResponse<T>> patch<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );

      return ApiResponse<T>.fromResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// File upload with progress
  Future<ApiResponse<T>> uploadFile<T>(
      String endpoint,
      File file, {
        String fieldName = 'file',
        Map<String, dynamic>? additionalData,
        ProgressCallback? onSendProgress,
        CancelToken? cancelToken,
      }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path, filename: fileName),
        ...?additionalData,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      return ApiResponse<T>.fromResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // =============================================================================
  // AUTHENTICATION METHODS (matching backend API)
  // =============================================================================

  /// Login user - UPDATED with improved token extraction
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
    bool rememberMe = false,
    String? tenantId,
  }) async {
    final data = {
      'email': email,
      'password': password,
      'rememberMe': rememberMe,
    };

    if (tenantId != null && tenantId.isNotEmpty) {
      data['tenantId'] = tenantId;
    }

    final response = await post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: data,
    );

    // Store tokens if login successful
    if (response.success && response.data != null) {
      try {
        final responseData = response.data!;

        // Extract tokens using the helper method
        final tokens = _extractTokens(responseData);

        final accessTokenValue = tokens['accessToken'];
        final refreshTokenValue = tokens['refreshToken'];

        if (accessTokenValue != null && accessTokenValue.isNotEmpty) {
          await setAccessToken(accessTokenValue);
          AppLogger.d('Access token stored successfully');
        } else {
          AppLogger.e('No valid access token found in response');
          AppLogger.e('Full response data: ${responseData.toString()}');
        }

        if (refreshTokenValue != null && refreshTokenValue.isNotEmpty) {
          await setRefreshToken(refreshTokenValue);
          AppLogger.d('Refresh token stored successfully');
        } else {
          AppLogger.w('No refresh token found in response');
        }
      } catch (e) {
        AppLogger.e('Error during token extraction: $e');
        // Don't throw here - login might still be successful even if token storage fails
      }
    }

    return response;
  }

  /// Register new user
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? role,
    String? tenantId,
  }) async {
    final data = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    };

    if (role != null) data['role'] = role;
    if (tenantId != null && tenantId.isNotEmpty) data['tenantId'] = tenantId;

    return await post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: data,
    );
  }

  /// Refresh access token - UPDATED with improved token extraction
  Future<ApiResponse<Map<String, dynamic>>> refreshTokenRequest() async {
    if (_refreshToken == null) {
      throw ApiException(message: 'No refresh token available', statusCode: 401);
    }

    final response = await post<Map<String, dynamic>>(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': _refreshToken},
    );

    // Update stored tokens if refresh successful
    if (response.success && response.data != null) {
      try {
        final responseData = response.data!;

        // Extract tokens using the helper method
        final tokens = _extractTokens(responseData);

        final accessTokenValue = tokens['accessToken'];
        final refreshTokenValue = tokens['refreshToken'];

        if (accessTokenValue != null && accessTokenValue.isNotEmpty) {
          await setAccessToken(accessTokenValue);
          AppLogger.d('Access token refreshed and stored successfully');
        } else {
          AppLogger.e('No valid access token found in refresh response');
          AppLogger.e('Full response data: ${responseData.toString()}');
        }

        if (refreshTokenValue != null && refreshTokenValue.isNotEmpty) {
          await setRefreshToken(refreshTokenValue);
          AppLogger.d('Refresh token updated and stored successfully');
        }
      } catch (e) {
        AppLogger.e('Error during token refresh extraction: $e');
        // Don't throw here - the refresh might still be successful
      }
    }

    return response;
  }

  /// Logout user
  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    final response = await post<Map<String, dynamic>>(
      ApiEndpoints.logout,
    );

    // Clear tokens regardless of response
    await clearTokens();

    return response;
  }

  /// Get current user profile
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    return await get<Map<String, dynamic>>(ApiEndpoints.getMe);
  }

  /// Get current tenant
  Future<ApiResponse<Map<String, dynamic>>> getCurrentTenant() async {
    return await get<Map<String, dynamic>>(ApiEndpoints.getCurrentTenant);
  }

  /// Debug user data and roles (development only)
  Future<ApiResponse<Map<String, dynamic>>> debugUser() async {
    return await get<Map<String, dynamic>>(ApiEndpoints.debugUser);
  }

  /// Forgot password
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    return await post<Map<String, dynamic>>(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  /// Reset password
  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String token,
    required String password,
  }) async {
    return await post<Map<String, dynamic>>(
      ApiEndpoints.resetPassword(token),
      data: {'password': password},
    );
  }

  /// Verify email
  Future<ApiResponse<Map<String, dynamic>>> verifyEmail({
    required String token,
  }) async {
    return await get<Map<String, dynamic>>(
      ApiEndpoints.verifyEmail(token),
    );
  }

  /// Resend verification email
  Future<ApiResponse<Map<String, dynamic>>> resendVerification({
    required String email,
  }) async {
    return await post<Map<String, dynamic>>(
      ApiEndpoints.resendVerification,
      data: {'email': email},
    );
  }

  /// Check API health
  Future<bool> checkHealth() async {
    try {
      final response = await get<Map<String, dynamic>>('/health');
      return response.success;
    } catch (e) {
      return false;
    }
  }

  // =============================================================================
  // USER MANAGEMENT METHODS (matching backend)
  // =============================================================================

  /// Get users in tenant
  Future<ApiResponse<Map<String, dynamic>>> getUsers({
    int page = 1,
    int limit = 10,
    String? role,
    String? status,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (role != null) queryParams['role'] = role;
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;

    return await get<Map<String, dynamic>>(
      ApiEndpoints.getUsers,
      queryParameters: queryParams,
    );
  }

  /// Create new user
  Future<ApiResponse<Map<String, dynamic>>> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
    Map<String, dynamic>? address,
  }) async {
    // FIXED: Explicitly declare as Map<String, dynamic>
    final Map<String, dynamic> data = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'role': role,
    };

    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (address != null) data['address'] = address;

    return await post<Map<String, dynamic>>(
      ApiEndpoints.createUser,
      data: data,
    );
  }

  /// Update user
  Future<ApiResponse<Map<String, dynamic>>> updateUser(
      String userId,
      Map<String, dynamic> updateData,
      ) async {
    return await put<Map<String, dynamic>>(
      ApiEndpoints.updateUser(userId),
      data: updateData,
    );
  }

  /// Delete user
  Future<ApiResponse<Map<String, dynamic>>> deleteUser(String userId) async {
    return await delete<Map<String, dynamic>>(
      ApiEndpoints.deleteUser(userId),
    );
  }

  // =============================================================================
  // TENANT MANAGEMENT METHODS (matching backend)
  // =============================================================================

  /// Get tenants (platform admin only)
  Future<ApiResponse<Map<String, dynamic>>> getTenants({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;

    return await get<Map<String, dynamic>>(
      ApiEndpoints.getTenants,
      queryParameters: queryParams,
    );
  }

  /// Create new tenant
  Future<ApiResponse<Map<String, dynamic>>> createTenant({
    required String name,
    required String slug,
    String? displayName,
    String? description,
    Map<String, dynamic>? settings,
  }) async {
    // FIXED: Explicitly declare as Map<String, dynamic>
    final Map<String, dynamic> data = {
      'name': name,
      'slug': slug,
    };

    if (displayName != null) data['displayName'] = displayName;
    if (description != null) data['description'] = description;
    if (settings != null) data['settings'] = settings;

    return await post<Map<String, dynamic>>(
      ApiEndpoints.createTenant,
      data: data,
    );
  }

  /// Update tenant
  Future<ApiResponse<Map<String, dynamic>>> updateTenant(
      String tenantId,
      Map<String, dynamic> updateData,
      ) async {
    return await put<Map<String, dynamic>>(
      ApiEndpoints.updateTenant(tenantId),
      data: updateData,
    );
  }

  /// Delete tenant
  Future<ApiResponse<Map<String, dynamic>>> deleteTenant(String tenantId) async {
    return await delete<Map<String, dynamic>>(
      ApiEndpoints.deleteTenant(tenantId),
    );
  }

  // =============================================================================
  // DEBUG METHODS
  // =============================================================================

  /// Debug login response structure
  Future<void> debugLoginResponse() async {
    try {
      final response = await post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {
          'email': 'test@example.com',
          'password': 'testpassword'
        },
      );

      AppLogger.d('=== FULL LOGIN RESPONSE DEBUG ===');
      AppLogger.d('Success: ${response.success}');
      AppLogger.d('Status Code: ${response.statusCode}');
      AppLogger.d('Message: ${response.message}');
      AppLogger.d('Data Type: ${response.data.runtimeType}');
      AppLogger.d('Full Data: ${response.data}');

      if (response.data != null) {
        response.data!.forEach((key, value) {
          AppLogger.d('Key: $key, Type: ${value.runtimeType}, Value: $value');
        });
      }
    } catch (e) {
      AppLogger.e('Debug login error: $e');
    }
  }

  /// Debug user endpoint
  Future<void> debugUserEndpoint() async {
    try {
      final response = await get<Map<String, dynamic>>(ApiEndpoints.debugUser);
      AppLogger.d('Debug user response: ${response.data}');
    } catch (e) {
      AppLogger.e('Debug user error: $e');
    }
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Get headers for authenticated requests
  Map<String, String> get authHeaders => {
    'Authorization': 'Bearer $_accessToken',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Check if user is authenticated
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  /// Get API base URL
  String get baseUrl => _dio.options.baseUrl;
}