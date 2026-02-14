// lib/core/network/api_client.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myapp/core/constants/api_constants.dart';
import 'package:myapp/core/errors/exceptions.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  late final Dio _refreshDio;

  bool _isRefreshing = false;
  final List<Completer<void>> _refreshCompleters = [];

  ApiClient(this._dio, this._storage) {
    _init();
  }

  Null get storage => null;

  void _init() {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'ar',
      },
    );

    // Dio خاص بالـ refresh (بدون interceptors)
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  // ================= REQUEST =================

  Future<void> _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token =
        await _storage.read(key: ApiConstants.accessTokenKey);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  // ================= ERROR =================

  Future<void> _onError(
      DioException error, ErrorInterceptorHandler handler) async {
    if (error.response?.statusCode == 401 &&
        !_isAuthEndpoint(error.requestOptions.path)) {
      try {
        await _handleTokenRefresh();
        final response = await _retry(error.requestOptions);
        return handler.resolve(response);
      } catch (_) {
        await _storage.deleteAll();
        return handler.reject(error);
      }
    }

    handler.next(error);
  }

  bool _isAuthEndpoint(String path) {
    return path.contains(ApiConstants.loginEndpoint) ||
        path.contains(ApiConstants.refreshTokenEndpoint);
  }

  // ================= REFRESH LOGIC =================

  Future<void> _handleTokenRefresh() async {
    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshCompleters.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      await _refreshToken();
      for (final completer in _refreshCompleters) {
        completer.complete();
      }
      _refreshCompleters.clear();
    } catch (e) {
      for (final completer in _refreshCompleters) {
        completer.completeError(e);
      }
      _refreshCompleters.clear();
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _refreshToken() async {
    final refreshToken =
        await _storage.read(key: ApiConstants.refreshTokenKey);

    if (refreshToken == null) {
      throw UnauthorizedException();
    }

    final response = await _refreshDio.post(
      ApiConstants.refreshTokenEndpoint,
      data: {'refreshToken': refreshToken},
    );

    final data = response.data;
    if (data is! Map || data['accessToken'] == null) {
      throw UnauthorizedException();
    }

    await _storage.write(
      key: ApiConstants.accessTokenKey,
      value: data['accessToken'].toString(),
    );
  }

  // ================= RETRY =================

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // ================= HTTP METHODS =================

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ================= ERROR HANDLER =================

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException('اتصال الإنترنت ضعيف');

      case DioExceptionType.connectionError:
        return NetworkException('لا يوجد اتصال بالإنترنت');

      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        final data = error.response?.data;

        String message = 'حدث خطأ في الخادم';

        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }

        if (code == 401) return UnauthorizedException(message);
        if (code == 403) return KyanException('غير مصرح لك');
        if (code == 404) return KyanException('المورد غير موجود');

        if (code == 422 && data is Map && data['errors'] is Map) {
          final errors = Map<String, String>.from(
            (data['errors'] as Map)
                .map((k, v) => MapEntry(k.toString(), v.toString())),
          );
          return ValidationException(errors);
        }

        if (code == 500) return ServerException('خطأ داخلي في الخادم');

        return ServerException(message, code: code);

      default:
        return ServerException('حدث خطأ غير متوقع');
    }
  }
}
