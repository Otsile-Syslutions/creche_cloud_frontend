// lib/core/services/api_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:get/get.dart' as getx;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/env.dart';
import '../config/api_endpoints.dart';
import 'storage_service.dart';
import '../../utils/app_logger.dart';

// [Keep all the existing response models and exceptions as they are]
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

// Token Storage Implementation
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
    if (_cachedToken != null) {
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

    final accessToken = await _storage.getString('access_token');
    final refreshToken = await _storage.getString('refresh_token');

    if (accessToken != null && accessToken.isNotEmpty) {
      _cachedToken = OAuth2Token(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

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

    try {
      final expDate = JwtDecoder.getExpirationDate(token.accessToken);
      AppLogger.d('Token stored, expires: $expDate');
    } catch (e) {
      AppLogger.d('Token stored (could not decode expiry)');
    }
  }

  Future<bool> hasToken() async {
    final token = await read();
    return token != null;
  }

  Future<String?> getAccessToken() async {
    final token = await read();
    return token?.accessToken;
  }

  OAuth2Token? getCachedToken() => _cachedToken;
}

// =============================================================================
// API SERVICE WITH EARLY INITIALIZATION
// =============================================================================

class ApiService extends getx.GetxService {
  static ApiService get to => getx.Get.find();

  // Make these nullable and check before use
  Dio? _dio;
  Dio? _tokenDio;
  CookieJar? _cookieJar;
  Fresh<OAuth2Token>? _fresh;
  SecureTokenStorage? _tokenStorage;

  // Add initialization flag
  bool _isInitialized = false;
  final _initCompleter = <Function>[];

  @override
  Future<void> onInit() async {
    super.onInit();
    // Initialize immediately when service is created
    await _initialize();
  }

  /// Initialize the service (can be called multiple times safely)
  Future<void> _initialize() async {
    if (_isInitialized) {
      AppLogger.d('ApiService already initialized');
      return;
    }

    try {
      AppLogger.d('Initializing ApiService...');
      AppLogger.d('Platform: ${kIsWeb ? "Web" : "Native"}');

      await _initializeCookieJar();
      await _initializeDio();
      _isInitialized = true;

      // Call any pending operations
      for (var completer in _initCompleter) {
        completer();
      }
      _initCompleter.clear();

      AppLogger.d('ApiService initialization complete');
    } catch (e) {
      AppLogger.e('Failed to initialize ApiService', e);
      rethrow;
    }
  }

  /// Ensure the service is initialized before use
  Future<void> ensureInitialized() async {
    if (_isInitialized) return;

    // Wait for initialization if it's in progress
    if (_dio == null || _tokenDio == null) {
      AppLogger.d('Waiting for ApiService initialization...');
      await _initialize();
    }
  }

  @override
  void onClose() {
    _dio?.close();
    _tokenDio?.close();
    super.onClose();
  }

  /// Initialize cookie jar for persistent cookies
  Future<void> _initializeCookieJar() async {
    try {
      if (kIsWeb) {
        // On web, browsers handle cookies automatically
        AppLogger.d('Running on web - browser handles cookies automatically');
        // Use a memory-only cookie jar for web to avoid issues
        _cookieJar = CookieJar();
      } else {
        // On mobile/desktop, use persistent cookie storage
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String cookiePath = '${appDocDir.path}/.cookies/';

        _cookieJar = PersistCookieJar(
          ignoreExpires: false,
          storage: FileStorage(cookiePath),
        );

        AppLogger.d('Cookie jar initialized at: $cookiePath');
      }
    } catch (e) {
      AppLogger.w('Failed to initialize persistent cookie jar, using default', e);
      _cookieJar = CookieJar();
    }
  }

  /// Initialize Dio with Fresh JWT handling
  Future<void> _initializeDio() async {
    // Initialize token storage
    _tokenStorage = SecureTokenStorage(StorageService.to);

    // Create a separate Dio instance for token refresh
    _tokenDio = Dio(BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: Env.connectTimeout,
      receiveTimeout: Env.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add cookie manager to token dio (only for non-web platforms)
    if (!kIsWeb && _cookieJar != null) {
      _tokenDio!.interceptors.add(CookieManager(_cookieJar!));
    }

    // Initialize Fresh with OAuth2
    _fresh = Fresh.oAuth2(
      tokenStorage: _tokenStorage!,
      refreshToken: (token, client) async {
        try {
          AppLogger.d('Attempting token refresh...');

          final response = await _tokenDio!.post(
            ApiEndpoints.refreshToken,
            data: token?.refreshToken != null
                ? {'refreshToken': token!.refreshToken}
                : {},
          );

          if (response.statusCode == 200) {
            final data = response.data;
            String? newAccessToken;
            String? newRefreshToken;

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

    // Add interceptors
    // Only add cookie manager for non-web platforms
    if (!kIsWeb && _cookieJar != null) {
      _dio!.interceptors.add(CookieManager(_cookieJar!));
    }
    _dio!.interceptors.add(_fresh!);

    // Add logging interceptor in development
    if (Env.enableHttpLogging && Env.isDevelopment) {
      _dio!.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        error: true,
        logPrint: (obj) => AppLogger.d('DIO LOG: $obj'),
      ));
    }

    // Add custom interceptor
    _dio!.interceptors.add(InterceptorsWrapper(
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
    final existingToken = await _tokenStorage!.read();
    if (existingToken != null) {
      AppLogger.d('Found existing token in storage');
    }
  }

  // =============================================================================
  // AUTHENTICATION METHODS WITH INITIALIZATION CHECK
  // =============================================================================

  /// Login user
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
    bool rememberMe = false,
    String? tenantId,
  }) async {
    // Ensure service is initialized
    await ensureInitialized();

    if (_dio == null) {
      throw Exception('ApiService not properly initialized');
    }

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
      final response = await _dio!.post(
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

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
            final innerData = responseData['data'] as Map<String, dynamic>;
            AppLogger.d('Found data field with keys: ${innerData.keys}');

            accessToken = innerData['access_token']?.toString() ?? innerData['accessToken']?.toString();
            refreshToken = innerData['refresh_token']?.toString() ?? innerData['refreshToken']?.toString();
          } else {
            accessToken = responseData['access_token']?.toString() ?? responseData['accessToken']?.toString();
            refreshToken = responseData['refresh_token']?.toString() ?? responseData['refreshToken']?.toString();
          }
        }

        if (accessToken != null && accessToken.isNotEmpty) {
          await _fresh!.setToken(OAuth2Token(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ));

          AppLogger.d('✅ Login successful, tokens stored');

          try {
            final decodedToken = JwtDecoder.decode(accessToken);
            final expDate = JwtDecoder.getExpirationDate(accessToken);
            AppLogger.d('Token payload: ${decodedToken.keys}');
            AppLogger.d('Token expires: $expDate');
          } catch (e) {
            AppLogger.w('Could not decode JWT', e);
          }

          // Log cookies only on non-web platforms
          if (!kIsWeb) {
            final cookies = await getCookies(Env.apiBaseUrl);
            if (cookies.isNotEmpty) {
              AppLogger.d('Cookies received: ${cookies.map((c) => c.name).toList()}');
            }
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
    await ensureInitialized();

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
    await ensureInitialized();

    try {
      final currentToken = await _tokenStorage!.read();

      if (currentToken?.refreshToken == null) {
        throw ApiException(
          message: 'No refresh token available',
          statusCode: 401,
        );
      }

      final response = await _tokenDio!.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': currentToken!.refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        String? newAccessToken;
        String? newRefreshToken;

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
          await _fresh!.setToken(OAuth2Token(
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
    await ensureInitialized();

    try {
      final response = await post<Map<String, dynamic>>(
        ApiEndpoints.logout,
      );

      await clearTokens();

      return response;
    } catch (e) {
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
    await ensureInitialized();
    return await get<Map<String, dynamic>>(ApiEndpoints.getMe);
  }

  /// Get current tenant
  Future<ApiResponse<Map<String, dynamic>>> getCurrentTenant() async {
    await ensureInitialized();
    return await get<Map<String, dynamic>>(ApiEndpoints.getCurrentTenant);
  }

  /// Debug user data and roles
  Future<ApiResponse<Map<String, dynamic>>> debugUser() async {
    await ensureInitialized();
    return await get<Map<String, dynamic>>(ApiEndpoints.debugUser);
  }

  /// Forgot password
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    await ensureInitialized();
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
    await ensureInitialized();
    return await post<Map<String, dynamic>>(
      ApiEndpoints.resetPassword(token),
      data: {'password': password},
    );
  }

  /// Verify email
  Future<ApiResponse<Map<String, dynamic>>> verifyEmail({
    required String token,
  }) async {
    await ensureInitialized();
    return await get<Map<String, dynamic>>(
      ApiEndpoints.verifyEmail(token),
    );
  }

  /// Resend verification email
  Future<ApiResponse<Map<String, dynamic>>> resendVerification({
    required String email,
  }) async {
    await ensureInitialized();
    return await post<Map<String, dynamic>>(
      ApiEndpoints.resendVerification,
      data: {'email': email},
    );
  }

  /// Check API health
  Future<bool> checkHealth() async {
    await ensureInitialized();
    try {
      final response = await get<Map<String, dynamic>>('/health');
      return response.success;
    } catch (e) {
      return false;
    }
  }

  // =============================================================================
  // HTTP METHODS WITH INITIALIZATION CHECK
  // =============================================================================

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
      }) async {
    await ensureInitialized();

    if (_dio == null) {
      throw Exception('ApiService not properly initialized');
    }

    try {
      final response = await _dio!.get(
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
    await ensureInitialized();

    if (_dio == null) {
      throw Exception('ApiService not properly initialized');
    }

    try {
      final response = await _dio!.post(
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
    await ensureInitialized();

    if (_dio == null) {
      throw Exception('ApiService not properly initialized');
    }

    try {
      final response = await _dio!.put(
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
    await ensureInitialized();

    if (_dio == null) {
      throw Exception('ApiService not properly initialized');
    }

    try {
      final response = await _dio!.delete(
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
    await ensureInitialized();

    if (_dio == null) {
      throw Exception('ApiService not properly initialized');
    }

    try {
      final response = await _dio!.patch(
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
  /// Note: On web, File handling is different. Consider using MultipartFile.fromBytes for web
  Future<ApiResponse<T>> uploadFile<T>(
      String endpoint,
      File file, {
        String fieldName = 'file',
        Map<String, dynamic>? additionalData,
        ProgressCallback? onSendProgress,
        CancelToken? cancelToken,
      }) async {
    await ensureInitialized();

    if (_dio == null) {
      throw Exception('ApiService not properly initialized');
    }

    try {
      final fileName = file.path.split('/').last;

      // Create multipart file
      // Note: On web, you might need to use MultipartFile.fromBytes instead
      final multipartFile = kIsWeb
          ? throw Exception('File upload on web requires different implementation')
          : await MultipartFile.fromFile(file.path, filename: fileName);

      final formData = FormData.fromMap({
        fieldName: multipartFile,
        ...?additionalData,
      });

      final response = await _dio!.post(
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

  // [Keep all the remaining methods as they are, just add ensureInitialized() at the start of each]

  // USER MANAGEMENT METHODS
  Future<ApiResponse<Map<String, dynamic>>> getUsers({
    int page = 1,
    int limit = 10,
    String? role,
    String? status,
    String? search,
  }) async {
    await ensureInitialized();

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

  Future<ApiResponse<Map<String, dynamic>>> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
    Map<String, dynamic>? address,
  }) async {
    await ensureInitialized();

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

  Future<ApiResponse<Map<String, dynamic>>> updateUser(
      String userId,
      Map<String, dynamic> updateData,
      ) async {
    await ensureInitialized();
    return await put<Map<String, dynamic>>(
      ApiEndpoints.updateUser(userId),
      data: updateData,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteUser(String userId) async {
    await ensureInitialized();
    return await delete<Map<String, dynamic>>(
      ApiEndpoints.deleteUser(userId),
    );
  }

  // TENANT MANAGEMENT METHODS
  Future<ApiResponse<Map<String, dynamic>>> getTenants({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    await ensureInitialized();

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

  Future<ApiResponse<Map<String, dynamic>>> createTenant({
    required String name,
    required String slug,
    String? displayName,
    String? description,
    Map<String, dynamic>? settings,
  }) async {
    await ensureInitialized();

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

  Future<ApiResponse<Map<String, dynamic>>> updateTenant(
      String tenantId,
      Map<String, dynamic> updateData,
      ) async {
    await ensureInitialized();
    return await put<Map<String, dynamic>>(
      ApiEndpoints.updateTenant(tenantId),
      data: updateData,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteTenant(String tenantId) async {
    await ensureInitialized();
    return await delete<Map<String, dynamic>>(
      ApiEndpoints.deleteTenant(tenantId),
    );
  }

  // TOKEN & SESSION MANAGEMENT
  Future<void> clearTokens() async {
    if (_fresh != null) {
      await _fresh!.clearToken();
    }
    if (_tokenStorage != null) {
      await _tokenStorage!.delete();
    }
    await clearCookies();
    AppLogger.d('Tokens and cookies cleared');
  }

  Future<void> clearCookies() async {
    try {
      if (!kIsWeb && _cookieJar != null) {
        await _cookieJar!.deleteAll();
        AppLogger.d('All cookies cleared');
      } else if (kIsWeb) {
        AppLogger.d('Running on web - cookies handled by browser');
      }
    } catch (e) {
      AppLogger.e('Error clearing cookies', e);
    }
  }

  Future<List<Cookie>> getCookies(String url) async {
    try {
      if (kIsWeb) {
        // On web, we can't directly access cookies this way
        AppLogger.d('Running on web - cookies managed by browser');
        return [];
      }
      if (_cookieJar == null) return [];
      final uri = Uri.parse(url);
      final cookies = await _cookieJar!.loadForRequest(uri);
      return cookies;
    } catch (e) {
      AppLogger.e('Error getting cookies', e);
      return [];
    }
  }

  Future<void> setAccessToken(String token) async {
    await ensureInitialized();
    if (_fresh != null) {
      await _fresh!.setToken(OAuth2Token(
        accessToken: token,
        refreshToken: null,
      ));
      AppLogger.d('Access token set manually');
    }
  }

  Future<void> setRefreshToken(String token) async {
    await ensureInitialized();
    if (_tokenStorage != null) {
      final currentToken = await _tokenStorage!.read();
      if (_fresh != null) {
        await _fresh!.setToken(OAuth2Token(
          accessToken: currentToken?.accessToken ?? '',
          refreshToken: token,
        ));
        AppLogger.d('Refresh token set manually');
      }
    }
  }

  // UTILITY METHODS & GETTERS
  bool get isAuthenticated {
    final cachedToken = _tokenStorage?.getCachedToken();
    if (cachedToken == null) return false;

    try {
      return !JwtDecoder.isExpired(cachedToken.accessToken);
    } catch (e) {
      return false;
    }
  }

  Future<bool> isAuthenticatedAsync() async {
    try {
      await ensureInitialized();

      if (_tokenStorage == null) return false;

      final token = await _tokenStorage!.read().timeout(const Duration(seconds: 3));

      if (token == null) {
        AppLogger.d('No token found in storage');
        return false;
      }

      try {
        final isExpired = JwtDecoder.isExpired(token.accessToken);
        if (!isExpired) {
          AppLogger.d('Access token is valid');
          return true;
        }
        AppLogger.d('Access token is expired');
      } catch (e) {
        AppLogger.w('Failed to decode access token', e);
        return false;
      }

      if (token.refreshToken != null) {
        try {
          final refreshExpired = JwtDecoder.isExpired(token.refreshToken!);
          if (!refreshExpired) {
            AppLogger.d('Refresh token is valid, user is authenticated');
            return true;
          }
          AppLogger.d('Refresh token is also expired');
        } catch (e) {
          AppLogger.w('Failed to decode refresh token', e);
        }
      }

      return false;
    } catch (e) {
      AppLogger.e('Error checking authentication status', e);
      return false;
    }
  }

  String? get accessToken {
    return _tokenStorage?.getCachedToken()?.accessToken;
  }

  String? get refreshTokenValue {
    return _tokenStorage?.getCachedToken()?.refreshToken;
  }

  Map<String, String> get authHeaders {
    final token = _tokenStorage?.getCachedToken()?.accessToken;
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  String get baseUrl => _dio?.options.baseUrl ?? Env.apiBaseUrl;

  // DEBUG METHODS
  Future<void> debugApiState() async {
    AppLogger.d('=== API SERVICE STATE DEBUG ===');
    AppLogger.d('Platform: ${kIsWeb ? "Web" : "Native"}');
    AppLogger.d('Is initialized: $_isInitialized');
    AppLogger.d('Base URL: $baseUrl');

    if (_tokenStorage != null) {
      final token = await _tokenStorage!.read();
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
    }

    try {
      final storedAccess = await StorageService.to.getString('access_token');
      final storedRefresh = await StorageService.to.getString('refresh_token');
      AppLogger.d('Stored access token: ${storedAccess != null ? 'Present' : 'Missing'}');
      AppLogger.d('Stored refresh token: ${storedRefresh != null ? 'Present' : 'Missing'}');
    } catch (e) {
      AppLogger.e('Error checking stored tokens: $e');
    }

    await debugCookieStatus();

    AppLogger.d('================================');
  }

  Future<void> debugCookieStatus() async {
    try {
      AppLogger.d('=== COOKIE DEBUG INFO ===');

      if (kIsWeb) {
        AppLogger.d('Running on web - cookies managed by browser');
      } else if (_cookieJar != null) {
        final cookies = await getCookies(Env.apiBaseUrl);
        AppLogger.d('Cookies for ${Env.apiBaseUrl}: ${cookies.map((c) => '${c.name}=${c.value.substring(0, c.value.length.clamp(0, 20))}...').toList()}');
      }

      AppLogger.d('========================');
    } catch (e) {
      AppLogger.e('Cookie debug error: $e');
    }
  }

  Future<void> testAuthentication() async {
    AppLogger.d('=== AUTHENTICATION TEST ===');

    final isAuth = await isAuthenticatedAsync();
    AppLogger.d('Is authenticated: $isAuth');

    if (isAuth) {
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