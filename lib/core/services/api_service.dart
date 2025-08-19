// lib/core/services/api_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:get/get.dart' as getx;
import 'package:path_provider/path_provider.dart';
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

    // Debug logging for response structure
    try {
      AppLogger.d('=== API RESPONSE DEBUG ===');
      AppLogger.d('Response status: ${response.statusCode}');
      AppLogger.d('Response data type: ${data.runtimeType}');
      if (data is Map<String, dynamic>) {
        AppLogger.d('Has success field: ${data.containsKey('success')}');
        AppLogger.d('Has data field: ${data.containsKey('data')}');
        AppLogger.d('Data field type: ${data['data']?.runtimeType}');
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
// TOKEN STORAGE IMPLEMENTATION FOR FRESH_DIO
// =============================================================================

class SecureTokenStorage extends TokenStorage<OAuth2Token> {
  final StorageService _storage;
  OAuth2Token? _cachedToken;

  SecureTokenStorage(this._storage);

  @override
  Future<void> delete() async {
    _cachedToken = null;
    await _storage.remove('access_token');
    await _storage.remove('refresh_token');
    AppLogger.d('Tokens deleted from storage');
  }

  @override
  Future<OAuth2Token?> read() async {
    // Return cached token if available
    if (_cachedToken != null) {
      // Validate cached token is not expired
      try {
        if (!JwtDecoder.isExpired(_cachedToken!.accessToken)) {
          return _cachedToken;
        } else {
          AppLogger.d('Cached token is expired, checking storage');
        }
      } catch (e) {
        AppLogger.w('Error validating cached token', e);
      }
    }

    // Try to load from storage
    final accessToken = await _storage.getString('access_token');
    final refreshToken = await _storage.getString('refresh_token');

    if (accessToken != null && accessToken.isNotEmpty) {
      _cachedToken = OAuth2Token(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // Log token status
      try {
        final isExpired = JwtDecoder.isExpired(accessToken);
        if (isExpired) {
          AppLogger.w('Loaded token is expired');
        } else {
          final expDate = JwtDecoder.getExpirationDate(accessToken);
          AppLogger.d('Token loaded, expires: $expDate');
        }
      } catch (e) {
        AppLogger.w('Could not decode token expiry', e);
      }

      return _cachedToken;
    }

    return null;
  }

  @override
  Future<void> write(OAuth2Token token) async {
    _cachedToken = token;
    await _storage.setString('access_token', token.accessToken);
    if (token.refreshToken != null) {
      await _storage.setString('refresh_token', token.refreshToken!);
    }

    // Log token info
    try {
      final expDate = JwtDecoder.getExpirationDate(token.accessToken);
      AppLogger.d('Token stored, expires: $expDate');
    } catch (e) {
      AppLogger.d('Token stored (could not decode expiry)');
    }
  }

  // Helper method to check if token exists
  Future<bool> hasToken() async {
    final token = await read();
    return token != null;
  }

  // Helper to get access token directly
  Future<String?> getAccessToken() async {
    final token = await read();
    return token?.accessToken;
  }

  // Get cached token synchronously
  OAuth2Token? getCachedToken() => _cachedToken;
}

// =============================================================================
// API SERVICE WITH FRESH_DIO JWT HANDLING
// =============================================================================

class ApiService extends getx.GetxService {
  static ApiService get to => getx.Get.find();

  late Dio _dio;
  late Dio _tokenDio; // Separate Dio instance for token refresh
  late CookieJar _cookieJar;
  late Fresh<OAuth2Token> _fresh;
  late SecureTokenStorage _tokenStorage;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeCookieJar();
    await _initializeDio();
  }

  @override
  void onClose() {
    _dio.close();
    _tokenDio.close();
    super.onClose();
  }

  /// Initialize cookie jar for persistent cookies
  Future<void> _initializeCookieJar() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String cookiePath = '${appDocDir.path}/.cookies/';

      _cookieJar = PersistCookieJar(
        ignoreExpires: false,
        storage: FileStorage(cookiePath),
      );

      AppLogger.d('Cookie jar initialized at: $cookiePath');
    } catch (e) {
      AppLogger.w('Failed to initialize persistent cookie jar, using default', e);
      _cookieJar = CookieJar();
    }
  }

  /// Initialize Dio with Fresh JWT handling
  Future<void> _initializeDio() async {
    // Initialize token storage
    _tokenStorage = SecureTokenStorage(StorageService.to);

    // Create a separate Dio instance for token refresh (to avoid circular dependencies)
    _tokenDio = Dio(BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: Env.connectTimeout,
      receiveTimeout: Env.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add cookie manager to token dio
    _tokenDio.interceptors.add(CookieManager(_cookieJar));

    // Initialize Fresh with OAuth2
    _fresh = Fresh.oAuth2(
      tokenStorage: _tokenStorage,
      refreshToken: (token, client) async {
        try {
          AppLogger.d('Attempting token refresh...');

          // Use the separate tokenDio for refresh to avoid interceptor loops
          final response = await _tokenDio.post(
            ApiEndpoints.refreshToken,
            data: token?.refreshToken != null
                ? {'refreshToken': token!.refreshToken}
                : {},
          );

          if (response.statusCode == 200) {
            final data = response.data;
            String? newAccessToken;
            String? newRefreshToken;

            // Extract tokens from response - handle multiple possible structures
            if (data is Map<String, dynamic>) {
              // Check if tokens are in a 'data' field
              if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
                final innerData = data['data'] as Map<String, dynamic>;
                newAccessToken = innerData['access_token'] ?? innerData['accessToken'];
                newRefreshToken = innerData['refresh_token'] ?? innerData['refreshToken'];
              } else {
                // Tokens at root level
                newAccessToken = data['access_token'] ?? data['accessToken'];
                newRefreshToken = data['refresh_token'] ?? data['refreshToken'];
              }
            }

            if (newAccessToken != null) {
              AppLogger.d('✅ Token refreshed successfully');
              return OAuth2Token(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken ?? token?.refreshToken,
              );
            }
          }

          AppLogger.e('Token refresh failed - no new token in response');
          throw RevokeTokenException();
        } catch (e) {
          AppLogger.e('Token refresh error', e);
          throw RevokeTokenException();
        }
      },
      shouldRefresh: (response) {
        // Refresh on 401, but not for auth endpoints
        if (response?.statusCode == 401) {
          final path = response!.requestOptions.path;
          final shouldRefresh = !path.contains('/auth/login') &&
              !path.contains('/auth/register') &&
              !path.contains('/auth/refresh');
          if (shouldRefresh) {
            AppLogger.d('Got 401 on $path, will attempt refresh');
          }
          return shouldRefresh;
        }
        return false;
      },
      tokenHeader: (token) {
        return {'Authorization': 'Bearer ${token.accessToken}'};
      },
    );

    // Create main Dio instance
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
      validateStatus: (status) => status! < 500,
    ));

    // Add interceptors in correct order
    _dio.interceptors.add(CookieManager(_cookieJar)); // Cookie manager first
    _dio.interceptors.add(_fresh); // Fresh JWT handling second

    // Add logging interceptor in development
    if (Env.enableHttpLogging && Env.isDevelopment) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        error: true,
        logPrint: (obj) => AppLogger.d('DIO LOG: $obj'),
      ));
    }

    // Add custom interceptor for additional logging
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        AppLogger.d('Request: ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.d('Response: ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.e('Error: ${error.response?.statusCode} ${error.requestOptions.path}');
        handler.next(error);
      },
    ));

    AppLogger.d('Dio initialized with Fresh JWT handling');

    // Load any existing token
    final existingToken = await _tokenStorage.read();
    if (existingToken != null) {
      AppLogger.d('Found existing token in storage');
    }
  }

  // =============================================================================
  // AUTHENTICATION METHODS
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

    AppLogger.d('Attempting login for: $email');

    try {
      // Don't use Fresh for login endpoint
      final response = await _dio.post(
        ApiEndpoints.login,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        String? accessToken;
        String? refreshToken;

        AppLogger.d('Login response keys: ${responseData.keys}');

        // Extract tokens from response
        if (responseData is Map<String, dynamic>) {
          // Check multiple possible response structures

          // Structure 1: Tokens in 'data' field
          if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
            final innerData = responseData['data'] as Map<String, dynamic>;
            AppLogger.d('Found data field with keys: ${innerData.keys}');

            accessToken = innerData['access_token']?.toString() ?? innerData['accessToken']?.toString();
            refreshToken = innerData['refresh_token']?.toString() ?? innerData['refreshToken']?.toString();
          }
          // Structure 2: Tokens at root level
          else {
            accessToken = responseData['access_token']?.toString() ?? responseData['accessToken']?.toString();
            refreshToken = responseData['refresh_token']?.toString() ?? responseData['refreshToken']?.toString();
          }
        }

        if (accessToken != null && accessToken.isNotEmpty) {
          // Store tokens using Fresh
          await _fresh.setToken(OAuth2Token(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ));

          AppLogger.d('✅ Login successful, tokens stored');

          // Validate and log token info
          try {
            final decodedToken = JwtDecoder.decode(accessToken);
            final expDate = JwtDecoder.getExpirationDate(accessToken);
            AppLogger.d('Token payload: ${decodedToken.keys}');
            AppLogger.d('Token expires: $expDate');
          } catch (e) {
            AppLogger.w('Could not decode JWT', e);
          }

          // Log cookies received
          final cookies = await getCookies(Env.apiBaseUrl);
          if (cookies.isNotEmpty) {
            AppLogger.d('Cookies received: ${cookies.map((c) => c.name).toList()}');
          }
        } else {
          AppLogger.e('❌ No access token found in login response!');
          AppLogger.e('Response structure: $responseData');
          throw Exception('No access token in login response');
        }

        return ApiResponse.fromResponse(response);
      }

      throw ApiException(
        message: 'Login failed',
        statusCode: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
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

  /// Refresh access token manually
  Future<ApiResponse<Map<String, dynamic>>> refreshTokenRequest() async {
    try {
      // Get current token
      final currentToken = await _tokenStorage.read();

      if (currentToken?.refreshToken == null) {
        throw ApiException(
          message: 'No refresh token available',
          statusCode: 401,
        );
      }

      // Make refresh request directly
      final response = await _tokenDio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': currentToken!.refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        String? newAccessToken;
        String? newRefreshToken;

        // Extract tokens from response
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
            final innerData = data['data'] as Map<String, dynamic>;
            newAccessToken = innerData['access_token'] ?? innerData['accessToken'];
            newRefreshToken = innerData['refresh_token'] ?? innerData['refreshToken'];
          } else {
            newAccessToken = data['access_token'] ?? data['accessToken'];
            newRefreshToken = data['refresh_token'] ?? data['refreshToken'];
          }
        }

        if (newAccessToken != null) {
          // Store new tokens
          await _fresh.setToken(OAuth2Token(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? currentToken.refreshToken,
          ));

          return ApiResponse(
            success: true,
            message: 'Token refreshed successfully',
            data: {
              'access_token': newAccessToken,
              'refresh_token': newRefreshToken ?? currentToken.refreshToken,
            },
            statusCode: 200,
          );
        }
      }

      throw ApiException(
        message: 'Token refresh failed',
        statusCode: response.statusCode ?? 401,
      );
    } catch (e) {
      AppLogger.e('Token refresh failed', e);
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Token refresh failed: ${e.toString()}',
        statusCode: 401,
      );
    }
  }

  /// Logout user
  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    try {
      final response = await post<Map<String, dynamic>>(
        ApiEndpoints.logout,
      );

      // Clear tokens and cookies
      await clearTokens();

      return response;
    } catch (e) {
      // Clear tokens even if logout fails
      await clearTokens();

      return ApiResponse(
        success: true,
        message: 'Logged out locally',
        data: null,
        statusCode: 200,
      );
    }
  }

  /// Get current user profile
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    return await get<Map<String, dynamic>>(ApiEndpoints.getMe);
  }

  /// Get current tenant
  Future<ApiResponse<Map<String, dynamic>>> getCurrentTenant() async {
    return await get<Map<String, dynamic>>(ApiEndpoints.getCurrentTenant);
  }

  /// Debug user data and roles
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
  // USER MANAGEMENT METHODS
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
  // TENANT MANAGEMENT METHODS
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
  // TOKEN & SESSION MANAGEMENT
  // =============================================================================

  /// Clear all tokens and cookies
  Future<void> clearTokens() async {
    await _fresh.clearToken();
    await _tokenStorage.delete();
    await clearCookies();
    AppLogger.d('Tokens and cookies cleared');
  }

  /// Clear all cookies
  Future<void> clearCookies() async {
    try {
      await _cookieJar.deleteAll();
      AppLogger.d('All cookies cleared');
    } catch (e) {
      AppLogger.e('Error clearing cookies', e);
    }
  }

  /// Get cookies for a specific URI
  Future<List<Cookie>> getCookies(String url) async {
    try {
      final uri = Uri.parse(url);
      final cookies = await _cookieJar.loadForRequest(uri);
      return cookies;
    } catch (e) {
      AppLogger.e('Error getting cookies', e);
      return [];
    }
  }

  /// Set access token manually (for backward compatibility)
  Future<void> setAccessToken(String token) async {
    await _fresh.setToken(OAuth2Token(
      accessToken: token,
      refreshToken: null,
    ));
    AppLogger.d('Access token set manually');
  }

  /// Set refresh token manually (for backward compatibility)
  Future<void> setRefreshToken(String token) async {
    final currentToken = await _tokenStorage.read();
    await _fresh.setToken(OAuth2Token(
      accessToken: currentToken?.accessToken ?? '',
      refreshToken: token,
    ));
    AppLogger.d('Refresh token set manually');
  }

  // =============================================================================
  // UTILITY METHODS & GETTERS
  // =============================================================================

  /// Check if user is authenticated (synchronous but may be stale)
  bool get isAuthenticated {
    final cachedToken = _tokenStorage.getCachedToken();
    if (cachedToken == null) return false;

    try {
      return !JwtDecoder.isExpired(cachedToken.accessToken);
    } catch (e) {
      return false;
    }
  }

  /// Check if user is authenticated (async, always accurate)
  Future<bool> isAuthenticatedAsync() async {
    final token = await _tokenStorage.read();
    if (token == null) return false;

    try {
      return !JwtDecoder.isExpired(token.accessToken);
    } catch (e) {
      return false;
    }
  }

  /// Get current access token (synchronous, may be stale)
  String? get accessToken {
    return _tokenStorage.getCachedToken()?.accessToken;
  }

  /// Get current refresh token (synchronous, may be stale)
  String? get refreshTokenValue {
    return _tokenStorage.getCachedToken()?.refreshToken;
  }

  /// Get headers for authenticated requests
  Map<String, String> get authHeaders {
    final token = _tokenStorage.getCachedToken()?.accessToken;
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Get API base URL
  String get baseUrl => _dio.options.baseUrl;

  // =============================================================================
  // DEBUG METHODS
  // =============================================================================

  /// Debug current API state
  Future<void> debugApiState() async {
    AppLogger.d('=== API SERVICE STATE DEBUG ===');
    AppLogger.d('Base URL: $baseUrl');

    final token = await _tokenStorage.read();
    AppLogger.d('Has access token: ${token?.accessToken != null}');

    if (token?.accessToken != null) {
      AppLogger.d('Access token length: ${token!.accessToken.length}');
      AppLogger.d('Access token preview: ${token.accessToken.substring(0, token.accessToken.length.clamp(0, 30))}...');

      try {
        final isExpired = JwtDecoder.isExpired(token.accessToken);
        final expDate = JwtDecoder.getExpirationDate(token.accessToken);
        final remainingTime = expDate.difference(DateTime.now());

        AppLogger.d('Token expired: $isExpired');
        AppLogger.d('Token expires: $expDate');
        AppLogger.d('Time remaining: ${remainingTime.inMinutes} minutes');

        final decoded = JwtDecoder.decode(token.accessToken);
        AppLogger.d('Token claims: ${decoded.keys}');
      } catch (e) {
        AppLogger.w('Could not decode JWT', e);
      }
    }

    AppLogger.d('Has refresh token: ${token?.refreshToken != null}');

    // Check stored tokens
    try {
      final storedAccess = await StorageService.to.getString('access_token');
      final storedRefresh = await StorageService.to.getString('refresh_token');
      AppLogger.d('Stored access token: ${storedAccess != null ? 'Present' : 'Missing'}');
      AppLogger.d('Stored refresh token: ${storedRefresh != null ? 'Present' : 'Missing'}');
    } catch (e) {
      AppLogger.e('Error checking stored tokens: $e');
    }

    // Check cookies
    await debugCookieStatus();

    AppLogger.d('================================');
  }

  /// Debug cookie status
  Future<void> debugCookieStatus() async {
    try {
      AppLogger.d('=== COOKIE DEBUG INFO ===');

      final cookies = await getCookies(Env.apiBaseUrl);
      AppLogger.d('Cookies for ${Env.apiBaseUrl}: ${cookies.map((c) => '${c.name}=${c.value.substring(0, c.value.length.clamp(0, 20))}...').toList()}');

      AppLogger.d('========================');
    } catch (e) {
      AppLogger.e('Cookie debug error: $e');
    }
  }

  /// Test API authentication
  Future<void> testAuthentication() async {
    AppLogger.d('=== AUTHENTICATION TEST ===');

    // Check if authenticated
    final isAuth = await isAuthenticatedAsync();
    AppLogger.d('Is authenticated: $isAuth');

    if (isAuth) {
      // Try to make a test request
      try {
        AppLogger.d('Making test request to /api/auth/me...');
        final response = await get<Map<String, dynamic>>('/auth/me');
        AppLogger.d('Test request successful: ${response.success}');
        if (response.success) {
          AppLogger.d('User data: ${response.data}');
        }
      } catch (e) {
        AppLogger.e('Test request failed', e);
      }
    }

    AppLogger.d('==========================');
  }
}