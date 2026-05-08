// // lib/core/network/api_client.dart

// import 'dart:async';
// import 'package:flutter/foundation.dart'; // لإتاحة debugPrint
// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:myapp/core/errors/exceptions.dart';
// import '../constants/api_constants.dart';

// class ApiClient {
//   final Dio _dio;
//   final FlutterSecureStorage _storage;
//   late final Dio _refreshDio;

//   // StreamController لإعلام الـ UI بضرورة تسجيل الخروج
//   final _logoutController = StreamController<void>.broadcast();
//   Stream<void> get onLogoutRequired => _logoutController.stream;

//   // للتحكم بعدم تكرار محاولات refresh في نفس الوقت
//   bool _isRefreshing = false;
//   final List<Completer<void>> _refreshWaiters = [];

//   ApiClient(this._dio, this._storage) {
//     _init();
//   }

//   void _init() {
//     // ضبط validateStatus ليقبل جميع الرموز حتى نتمكن من معالجة 401 يدويًا
//     _dio.options = BaseOptions(
//       baseUrl: ApiConstants.baseUrl,
//       connectTimeout: const Duration(seconds: 30),
//       receiveTimeout: const Duration(seconds: 30),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Accept-Language': 'ar',
//       },
//       validateStatus: (status) => true,
//     );

//     _refreshDio = Dio(
//       BaseOptions(
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         validateStatus: (status) => true,
//       ),
//     );

//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           final isAuthFreeEndpoint =
//               options.path.contains(ApiConstants.loginEndpoint) ||
//               options.path.contains(ApiConstants.registerEndpoint) ||
//               options.uri.path.contains(ApiConstants.refreshTokenEndpoint);
//           if (!isAuthFreeEndpoint) {
//             // التحقق الاستباقي من انتهاء التوكن
//             await _preemptiveTokenRefresh();

//             final token = await _storage.read(key: ApiConstants.accessTokenKey);
//             if (token != null) {
//               options.headers['Authorization'] = 'Bearer $token';
//             }
//           }

//           handler.next(options);
//         },
//         onResponse: (response, handler) {
//           // التحقق من رمز الحالة غير الناجح
//           if (response.statusCode != null &&
//               (response.statusCode! < 200 || response.statusCode! >= 300)) {
//             // إذا كان 401، نرمي UnauthorizedException
//             if (response.statusCode == 401) {
//               return handler.reject(
//                 DioException(
//                   requestOptions: response.requestOptions,
//                   response: response,
//                   type: DioExceptionType.badResponse,
//                 ),
//               );
//             }
//           }
//           handler.next(response);
//         },
//         onError: (DioException error, handler) async {
//           final res = error.response;
//           final path = error.requestOptions.path;
//           final isAuthFreeEndpoint =
//               path.contains(ApiConstants.loginEndpoint) ||
//               path.contains(ApiConstants.refreshTokenEndpoint);

//           // 🔹 تحقق من انقطاع الإنترنت
//           if (error.type == DioExceptionType.connectionError ||
//               error.type == DioExceptionType.connectionTimeout) {
//             debugPrint('❌ Network error: ${error.message}');
//             return handler.reject(
//               DioException(
//                 requestOptions: error.requestOptions,
//                 type: DioExceptionType.unknown,
//                 error: NetworkException('لا يوجد اتصال بالإنترنت'),
//               ),
//             );
//           }

//           // 🔹 إذا كان الخطأ 401 وليس من endpoints المفتوحة
//           if (!isAuthFreeEndpoint && res?.statusCode == 401) {
//             final success = await _refreshToken();
//             if (success) {
//               final newToken = await _storage.read(
//                 key: ApiConstants.accessTokenKey,
//               );
//               if (newToken != null) {
//                 final opts = error.requestOptions;
//                 opts.headers['Authorization'] = 'Bearer $newToken';
//                 try {
//                   final response = await _dio.fetch(opts);
//                   return handler.resolve(response);
//                 } catch (e) {
//                   debugPrint('❌ Failed to resend request after refresh: $e');
//                 }
//               }
//             }
//             // فشل التجديد → إخطار بالخروج
//             _logoutController.add(null);
//             return handler.reject(
//               DioException(
//                 requestOptions: error.requestOptions,
//                 response: res,
//                 type: DioExceptionType.badResponse,
//                 error: UnauthorizedException('انتهت صلاحية الجلسة'),
//               ),
//             );
//           }

//           // 🔹 أخطاء أخرى
//           debugPrint(
//             '❌ Dio error: ${error.message}, status=${res?.statusCode}',
//           );
//           handler.next(error);
//         },
//       ),
//     );
//   }

//   /// التحقق الاستباقي: إذا كان التوكن على وشك الانتهاء، نقوم بتحديثه
//   Future<void> _preemptiveTokenRefresh() async {
//     final issuedAtStr = await _storage.read(key: ApiConstants.tokenIssuedAtKey);
//     final token = await _storage.read(key: ApiConstants.accessTokenKey);

//     if (token == null || issuedAtStr == null) return;

//     final issuedAt = DateTime.fromMillisecondsSinceEpoch(
//       int.parse(issuedAtStr),
//     );
//     final expiresAt = issuedAt.add(
//       Duration(minutes: ApiConstants.tokenLifetimeMinutes),
//     );
//     final remaining = expiresAt.difference(DateTime.now());

//     if (remaining <= const Duration(minutes: 2)) {
//       await _refreshToken();
//     }
//   }

//   /// محاولة تجديد التوكن باستخدام refresh token
//   /// تعيد true إذا نجحت، false إذا فشلت
//   Future<bool> _refreshToken() async {
//     // منع التوازي
//     if (_isRefreshing) {
//       final completer = Completer<void>();
//       _refreshWaiters.add(completer);
//       try {
//         await completer.future;
//         return true; // إذا نجح الآخرون، نعتبر النجاح
//       } catch (_) {
//         return false;
//       }
//     }

//     _isRefreshing = true;
//     try {
//       final refreshToken = await _storage.read(
//         key: ApiConstants.refreshTokenKey,
//       );
//       if (refreshToken == null) {
//         await _storage.deleteAll();
//         _logoutController.add(null);
//         return false;
//       }

//       final response = await _refreshDio.post(
//         ApiConstants.refUrl,
//         data: {'refresh': refreshToken},
//       );

//       if (response.statusCode == 200) {
//         final newAccess = response.data['access'];
//         final newRefresh = response.data['refresh'];

//         await _storage.write(
//           key: ApiConstants.accessTokenKey,
//           value: newAccess,
//         );

//         await _storage.write(
//           key: ApiConstants.refreshTokenKey,
//           value: newRefresh, // ✅ الصحيح
//         );

//         await _storage.write(
//           key: ApiConstants.tokenIssuedAtKey,
//           value: DateTime.now().millisecondsSinceEpoch.toString(),
//         );

//         for (final waiter in _refreshWaiters) {
//           waiter.complete();
//         }
//         _refreshWaiters.clear();

//         return true;
//       } else {
//         // أي استجابة أخرى تعني فشل التحديث (مثلاً 401)
//         await _storage.deleteAll();
//         _logoutController.add(null);
//         for (final waiter in _refreshWaiters) {
//           waiter.completeError('Refresh failed');
//         }
//         _refreshWaiters.clear();
//         return false;
//       }
//     } catch (e) {
//       await _storage.deleteAll();
//       _logoutController.add(null);
//       for (final waiter in _refreshWaiters) {
//         waiter.completeError(e);
//       }
//       _refreshWaiters.clear();
//       return false;
//     } finally {
//       _isRefreshing = false;
//     }
//   }

//   // ================= HTTP Helpers =================
//   Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
//       _dio.get(path, queryParameters: queryParameters);

//   Future<Response> post(String path, {dynamic data}) =>
//       _dio.post(path, data: data);

//   Future<Response> put(String path, {dynamic data}) =>
//       _dio.put(path, data: data);
//   Future<Response> patch(String path, {dynamic data}) =>
//       _dio.patch(path, data: data);

//   Future<Response> delete(String path) => _dio.delete(path);

//   void dispose() {
//     _logoutController.close();
//   }
// }
// lib/core/network/api_client.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myapp/core/errors/exceptions.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  late final Dio _refreshDio;

  final _logoutController = StreamController<void>.broadcast();
  Stream<void> get onLogoutRequired => _logoutController.stream;

  bool _isRefreshing = false;
  final List<Completer<void>> _refreshWaiters = [];

  ApiClient(this._dio, this._storage) {
    _init();
  }

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
      validateStatus: (status) => true,
    );

    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.refUrl, // ✅ مهم لو refUrl نسبي
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
          final isAuthFreeEndpoint = _isAuthFreeEndpoint(options);
          debugPrint('➡️ REQUEST: ${options.method} ${options.uri}');

          if (!isAuthFreeEndpoint) {
            debugPrint('🔐 Auth required → checking token expiry');

            // ✅ لو قريب ينتهي، جرّب refresh قبل ما نرسل الطلب
            await _preemptiveTokenRefresh();

            final token = await _storage.read(key: ApiConstants.accessTokenKey);
            if (token != null && token.isNotEmpty) {
              debugPrint('✅ Access token attached');
              options.headers['Authorization'] = 'Bearer $token';
            } else {
              debugPrint('⚠️ No access token found');
            }
          } else {
            debugPrint('🆓 Auth-free endpoint');
          }

          handler.next(options);
        },

        // ✅ خليه يمرر الاستجابات حتى لو 401/400... ونعالجها في onError
        onResponse: (response, handler) {
          final code = response.statusCode ?? 0;
          if (code >= 200 && code < 300) {
            return handler.next(response);
          }

          // ✅ حوّل أي non-2xx إلى DioException حتى يدخل onError
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
            ),
          );
        },

        onError: (DioException error, handler) async {
          final res = error.response;
          final status = res?.statusCode;
          final opts = error.requestOptions;

          // ✅ لا نحاول refresh على endpoints الخاصة بالـ auth
          final isAuthFreeEndpoint = _isAuthFreeEndpoint(opts);

          // ✅ Network down
          if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            return handler.reject(
              DioException(
                requestOptions: opts,
                type: DioExceptionType.unknown,
                error: NetworkException('لا يوجد اتصال بالإنترنت'),
                response: res,
              ),
            );
          }

          // ✅ 401 => جرّب refresh مرة واحدة فقط لنفس الطلب
          final alreadyRetried = opts.extra['retried'] == true;

          if (!isAuthFreeEndpoint && status == 401 && !alreadyRetried) {
            opts.extra['retried'] = true;

            final success = await _refreshToken();
            if (success) {
              final newToken = await _storage.read(
                key: ApiConstants.accessTokenKey,
              );

              if (newToken != null && newToken.isNotEmpty) {
                opts.headers['Authorization'] = 'Bearer $newToken';

                try {
                  final clonedResponse = await _dio.fetch(opts);
                  return handler.resolve(clonedResponse);
                } catch (e) {
                  // لو فشل إعادة الإرسال، رجّع الخطأ الطبيعي
                  return handler.reject(
                    DioException(
                      requestOptions: opts,
                      response: res,
                      type: DioExceptionType.unknown,
                      error: e,
                    ),
                  );
                }
              }
            }

            // ❌ refresh فشل => logout + UI ينتقل للـ login
            await _storage.deleteAll();
            _logoutController.add(null);

            // لا نعرض "انتهت الجلسة" - فقط نمرر UnauthorizedException لو احتجت mapper
            return handler.reject(
              DioException(
                requestOptions: opts,
                response: res,
                type: DioExceptionType.badResponse,
                error: UnauthorizedException('SESSION_EXPIRED'),
              ),
            );
          }

          // أي أخطاء أخرى
          handler.next(error);
        },
      ),
    );
  }

  bool _isAuthFreeEndpoint(RequestOptions options) {
    final p = options.path;
    // لو تستخدم URLs كاملة أحياناً:
    final uriPath = options.uri.path;

    return p.contains(ApiConstants.loginEndpoint) ||
        p.contains(ApiConstants.registerEndpoint) ||
        p.contains(ApiConstants.refreshTokenEndpoint) ||
        uriPath.contains(ApiConstants.refreshTokenEndpoint);
  }

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
    debugPrint('⏳ Token remaining: ${remaining.inSeconds} seconds');

    if (remaining <= const Duration(minutes: 3)) {
      debugPrint("referesh token ends time#$remaining");
      await _refreshToken();
    }
  }

  Future<bool> _refreshToken() async {
    // ✅ منع refresh بالتوازي
    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshWaiters.add(completer);
      try {
        await completer.future;
        debugPrint("نجح الريفريش توكن");
        return true;
      } catch (_) {
        debugPrint("فشل الرفريش تتوكن");
        return false;
      }
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storage.read(
        key: ApiConstants.refreshTokenKey,
      );

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _refreshDio.post(
        ApiConstants
            .refreshTokenEndpoint, // ✅ الأفضل endpoint وليس refUrl لو متاح
        data: {'refresh': refreshToken},
      );
      debugPrint("الريفريش$response");

      if (response.statusCode == 200) {
        final newAccess = response.data['access'];
        final newRefresh = response.data['refresh'];

        if (newAccess == null || newAccess.toString().isEmpty) return false;

        await _storage.write(
          key: ApiConstants.accessTokenKey,
          value: newAccess.toString(),
        );

        if (newRefresh != null && newRefresh.toString().isNotEmpty) {
          await _storage.write(
            key: ApiConstants.refreshTokenKey,
            value: newRefresh.toString(),
          );
        }

        await _storage.write(
          key: ApiConstants.tokenIssuedAtKey,
          value: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        for (final w in _refreshWaiters) {
          w.complete();
        }
        _refreshWaiters.clear();

        return true;
      }

      // 401/400 من refresh => refresh token انتهى
      for (final w in _refreshWaiters) {
        w.completeError('Refresh failed');
      }
      _refreshWaiters.clear();
      return false;
    } catch (e) {
      for (final w in _refreshWaiters) {
        w.completeError(e);
      }
      _refreshWaiters.clear();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  // داخل ApiClient
  Future<String?> getValidAccessToken() async {
    await _preemptiveTokenRefresh(); // يجرّب refresh لو قرب ينتهي
    return _storage.read(key: ApiConstants.accessTokenKey);
  }

  // (اختياري لكن مفيد للـ WS لو السيرفر قفل بسبب توكن)
  Future<String?> forceRefreshAndGetToken() async {
    final ok = await _refreshToken();
    if (!ok) return null;
    return _storage.read(key: ApiConstants.accessTokenKey);
  }

  // ================= HTTP Helpers =================
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);

  void dispose() {
    _logoutController.close();
  }
}
