// lib/core/network/api_client.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  late final Dio _refreshDio;

  // StreamController لإعلام الـ UI بضرورة تسجيل الخروج
  final _logoutController = StreamController<void>.broadcast();
  Stream<void> get onLogoutRequired => _logoutController.stream;

  // للتحكم بعدم تكرار محاولات refresh في نفس الوقت
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshWaiters = [];

  ApiClient(this._dio, this._storage) {
    _init();
  }

  void _init() {
    // ضبط validateStatus ليقبل جميع الرموز حتى نتمكن من معالجة 401 يدويًا
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'ar',
      },
      validateStatus: (status) => true,
    );

    _refreshDio = Dio(
      BaseOptions(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isAuthFreeEndpoint =
              options.path.contains(ApiConstants.loginEndpoint) ||
              options.path.contains(ApiConstants.registerEndpoint) ||
              options.uri.path.contains(ApiConstants.refreshTokenEndpoint);
          if (!isAuthFreeEndpoint) {
            // التحقق الاستباقي من انتهاء التوكن
            await _preemptiveTokenRefresh();

            final token = await _storage.read(key: ApiConstants.accessTokenKey);
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          // التحقق من رمز الحالة غير الناجح
          if (response.statusCode != null &&
              (response.statusCode! < 200 || response.statusCode! >= 300)) {
            // إذا كان 401، نرمي UnauthorizedException
            if (response.statusCode == 401) {
              throw DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error: 'Unauthorized',
              );
            } else {
              throw DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error: 'Server error',
              );
            }
          }
          handler.next(response);
        },
        onError: (DioException error, handler) async {
          final res = error.response;
          final isAuthFreeEndpoint =
              error.requestOptions.path.contains(ApiConstants.loginEndpoint) ||
              error.requestOptions.path.contains(
                ApiConstants.refreshTokenEndpoint,
              );

          // إذا كان الخطأ 401 وليس من endpoints المفتوحة
          if (!isAuthFreeEndpoint && res?.statusCode == 401) {
            // نحاول refresh
            final success = await _refreshToken();

            if (success) {
              // إعادة إرسال الطلب الأصلي بالتوكن الجديد
              final newToken = await _storage.read(
                key: ApiConstants.accessTokenKey,
              );
              if (newToken != null) {
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newToken';
                try {
                  final response = await _dio.fetch(opts);
                  return handler.resolve(response);
                } catch (e) {
                  // إذا فشلت إعادة الإرسال، نمرر الخطأ الأصلي
                }
              }
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  /// التحقق الاستباقي: إذا كان التوكن على وشك الانتهاء، نقوم بتحديثه
  Future<void> _preemptiveTokenRefresh() async {
    final issuedAtStr = await _storage.read(key: ApiConstants.tokenIssuedAtKey);
    final token = await _storage.read(key: ApiConstants.accessTokenKey);

    if (token == null || issuedAtStr == null) return;

    final issuedAt = DateTime.fromMillisecondsSinceEpoch(
      int.parse(issuedAtStr),
    );
    final expiresAt = issuedAt.add(
      Duration(minutes: ApiConstants.tokenLifetimeMinutes),
    );
    final remaining = expiresAt.difference(DateTime.now());

    if (remaining <= const Duration(minutes: 2)) {
      await _refreshToken();
    }
  }

  /// محاولة تجديد التوكن باستخدام refresh token
  /// تعيد true إذا نجحت، false إذا فشلت
  Future<bool> _refreshToken() async {
    // منع التوازي
    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshWaiters.add(completer);
      try {
        await completer.future;
        return true; // إذا نجح الآخرون، نعتبر النجاح
      } catch (_) {
        return false;
      }
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _storage.read(
        key: ApiConstants.refreshTokenKey,
      );
      if (refreshToken == null) {
        await _storage.deleteAll();
        _logoutController.add(null);
        return false;
      }

      final response = await _refreshDio.post(
        ApiConstants.refUrl,
        data: {'refresh': refreshToken},
      );

     if (response.statusCode == 200) {
        final newAccess = response.data['access'];
        final newRefresh = response.data['refresh'];

        await _storage.write(
          key: ApiConstants.accessTokenKey,
          value: newAccess,
        );

        await _storage.write(
          key: ApiConstants.refreshTokenKey,
          value: newRefresh,   // ✅ الصحيح
        );

        await _storage.write(
          key: ApiConstants.tokenIssuedAtKey,
          value: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        for (final waiter in _refreshWaiters) {
          waiter.complete();
        }
        _refreshWaiters.clear();

        return true;
      } else {
        // أي استجابة أخرى تعني فشل التحديث (مثلاً 401)
        await _storage.deleteAll();
        _logoutController.add(null);
        for (final waiter in _refreshWaiters) {
          waiter.completeError('Refresh failed');
        }
        _refreshWaiters.clear();
        return false;
      }
    } catch (e) {
      await _storage.deleteAll();
      _logoutController.add(null);
      for (final waiter in _refreshWaiters) {
        waiter.completeError(e);
      }
      _refreshWaiters.clear();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  // ================= HTTP Helpers =================
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);

  void dispose() {
    _logoutController.close();
  }
}
