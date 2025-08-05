// lib/core/services/api_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../config/env.dart';
import '../config/api_endpoints.dart';
import 'storage_service.dart';
import '../../utils/app_logger.dart';

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
      // These are now async calls - need await
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

  /// Handle token expiration by attempting refresh
  Future<bool> _handleTokenExpiration() async {
    if (_refreshToken == null || _refreshToken!.isEmpty) {
      await clearTokens();
      return false;
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': _refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];

        if (newAccessToken != null) {
          await setAccessToken(newAccessToken);
          if (newRefreshToken != null) {
            await setRefreshToken(newRefreshToken);
          }
          return true;
        }
      }
    } catch (e) {
      AppLogger.w('Token refresh failed', e);
    }

    // Refresh failed, clear tokens
    await clearTokens();
    return false;
  }

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

  /// Check if user is authenticated (has valid token)
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

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

  /// Upload file
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

  /// Login user
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
      final responseData = response.data!;
      if (responseData['accessToken'] != null) {
        await setAccessToken(responseData['accessToken']);
      }
      if (responseData['refreshToken'] != null) {
        await setRefreshToken(responseData['refreshToken']);
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

  /// Refresh access token
  Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    if (_refreshToken == null) {
      throw ApiException(message: 'No refresh token available');
    }

    final response = await post<Map<String, dynamic>>(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': _refreshToken},
    );

    // Update stored tokens if refresh successful
    if (response.success && response.data != null) {
      final responseData = response.data!;
      if (responseData['accessToken'] != null) {
        await setAccessToken(responseData['accessToken']);
      }
      if (responseData['refreshToken'] != null) {
        await setRefreshToken(responseData['refreshToken']);
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
    return await get<Map<String, dynamic>>(
      ApiEndpoints.getUsers,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (role != null) 'role': role,
        if (status != null) 'status': status,
        if (search != null) 'search': search,
      },
    );
  }

  /// Create new user
  Future<ApiResponse<Map<String, dynamic>>> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String roleId,
    String? phoneNumber,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'roleId': roleId,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      ...?additionalData,
    };

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

  /// Get user by ID
  Future<ApiResponse<Map<String, dynamic>>> getUserById(String userId) async {
    return await get<Map<String, dynamic>>(
      ApiEndpoints.getUserById(userId),
    );
  }

  // =============================================================================
  // TENANT MANAGEMENT METHODS
  // =============================================================================

  /// Get tenants (platform admin only)
  Future<ApiResponse<Map<String, dynamic>>> getTenants({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    return await get<Map<String, dynamic>>(
      ApiEndpoints.getTenants,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (search != null) 'search': search,
      },
    );
  }

  /// Create tenant (platform admin only)
  Future<ApiResponse<Map<String, dynamic>>> createTenant({
    required String name,
    required String slug,
    required String adminEmail,
    required String adminPassword,
    Map<String, dynamic>? settings,
  }) async {
    return await post<Map<String, dynamic>>(
      ApiEndpoints.createTenant,
      data: {
        'name': name,
        'slug': slug,
        'adminEmail': adminEmail,
        'adminPassword': adminPassword,
        if (settings != null) 'settings': settings,
      },
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
}

// =============================================================================
// RESPONSE MODELS (updated to match backend format)
// =============================================================================

/// API Response wrapper matching backend response structure
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final String? code;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.code,
    required this.statusCode,
  });

  factory ApiResponse.fromResponse(Response response) {
    final responseData = response.data;

    return ApiResponse<T>(
      success: responseData['success'] ?? false,
      message: responseData['message'],
      data: responseData['data'],
      errors: responseData['errors'],
      code: responseData['code'],
      statusCode: response.statusCode ?? 0,
    );
  }

  factory ApiResponse.success({
    String? message,
    T? data,
    int statusCode = 200,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    String? message,
    Map<String, dynamic>? errors,
    String? code,
    int statusCode = 500,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      code: code,
      statusCode: statusCode,
    );
  }
}

/// API Exception for handling errors (updated to match backend error format)
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.errors,
  });

  factory ApiException.fromDioException(DioException dioException) {
    String message = 'An unexpected error occurred';
    int? statusCode;
    String? code;
    Map<String, dynamic>? errors;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        code = 'TIMEOUT_ERROR';
        break;

      case DioExceptionType.badResponse:
        statusCode = dioException.response?.statusCode;
        final responseData = dioException.response?.data;

        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] ?? message;
          code = responseData['code'];
          errors = responseData['errors'];
        }
        break;

      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        code = 'REQUEST_CANCELLED';
        break;

      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        code = 'CONNECTION_ERROR';
        break;

      case DioExceptionType.badCertificate:
        message = 'Security certificate error';
        code = 'CERTIFICATE_ERROR';
        break;

      case DioExceptionType.unknown:
        message = dioException.message ?? message;
        code = 'UNKNOWN_ERROR';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      code: code,
      errors: errors,
    );
  }

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode, Code: $code)';
  }
}