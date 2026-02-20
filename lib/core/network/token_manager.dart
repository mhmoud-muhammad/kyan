import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';
import '../constants/api_constants.dart';

class TokenManager {
  final FlutterSecureStorage storage;

  TokenManager(this.storage);

  /// ⏱️ عمر التوكن حسب السيرفر
  final Duration tokenLifetime = Duration(
    minutes: ApiConstants.tokenLifetimeMinutes,
  );

  /// ⏳ نعمل refresh قبل الانتهاء بقليل
  final Duration refreshThreshold = const Duration(minutes: 2);

  bool _isRefreshing = false;
  final List<Completer<void>> _refreshWaiters = [];

  // StreamController لإعلام الـ UI بضرورة تسجيل الخروج
  final _logoutController = StreamController<void>.broadcast();
  Stream<void> get onLogoutRequired => _logoutController.stream;

  /// ✅ هل يجب عمل refresh الآن؟
  Future<bool> shouldRefresh() async {
    final issuedAtMillis = await storage.read(key: StorageKeys.tokenIssuedAt);
    if (issuedAtMillis == null) return false;

    final issuedAt = DateTime.fromMillisecondsSinceEpoch(
      int.parse(issuedAtMillis),
    );

    final expiresAt = issuedAt.add(tokenLifetime);
    final remaining = expiresAt.difference(DateTime.now());

    return remaining <= refreshThreshold;
  }

  /// ✅ يتم استدعاؤها فقط عند:
  /// - login
  /// - refresh ناجح
  Future<void> markTokenIssuedNow() async {
    await storage.write(
      key: StorageKeys.tokenIssuedAt,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// ✅ منع refresh المتوازي
  Future<void> runRefresh(Future<void> Function() refreshAction) async {
    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshWaiters.add(completer);
      return completer.future;
    }

    _isRefreshing = true;
    try {
      await refreshAction();

      for (final waiter in _refreshWaiters) {
        waiter.complete();
      }
      _refreshWaiters.clear();
    } catch (e) {
      for (final waiter in _refreshWaiters) {
        waiter.completeError(e);
      }
      _refreshWaiters.clear();
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  /// ✅ محاولة تجديد التوكن باستخدام الـ refresh token المخزن
  Future<String?> refreshAccessToken() async {
    final refreshToken = await storage.read(key: StorageKeys.refreshToken);
    if (refreshToken == null) {
      await clearTokens();
      _logoutController.add(null);
      return null;
    }

    try {
      // هنا يجب أن نستخدم Dio منفصل بدون اعتراضيات لتجنب الحلقات اللانهائية
      final response = await Dio().post(
        '${ApiConstants.baseUrl}${ApiConstants.refreshTokenEndpoint}',
        data: {'refresh': refreshToken},
      );
      final newAccess = response.data['access'];
      await saveTokens(newAccess, refreshToken); // يحفظ access ويحدث issuedAt
      return newAccess;
    } catch (e) {
      // إذا فشل التحديث (مثلاً الـ refresh token منتهي)، نمسح كل شيء ونطلب تسجيل الخروج
      await clearTokens();
      _logoutController.add(null);
      return null;
    }
  }

  /// 🧪 معلومات مساعدة (اختياري)
  Future<Duration?> timeUntilExpiry() async {
    final issuedAtMillis = await storage.read(key: StorageKeys.tokenIssuedAt);
    if (issuedAtMillis == null) return null;

    final issuedAt = DateTime.fromMillisecondsSinceEpoch(
      int.parse(issuedAtMillis),
    );
    final expiresAt = issuedAt.add(tokenLifetime);

    return expiresAt.difference(DateTime.now());
  }

  /// حفظ التوكنات
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await storage.write(key: StorageKeys.accessToken, value: accessToken);
    await storage.write(key: StorageKeys.refreshToken, value: refreshToken);
    await markTokenIssuedNow();
  }

  /// مسح التوكنات
  Future<void> clearTokens() async {
    await storage.delete(key: StorageKeys.accessToken);
    await storage.delete(key: StorageKeys.refreshToken);
    await storage.delete(key: StorageKeys.tokenIssuedAt);
  }

  /// الحصول على التوكن الحالي (دون تحقق)
  Future<String?> getAccessToken() =>
      storage.read(key: StorageKeys.accessToken);

  /// الحصول على الـ refresh token الحالي
  Future<String?> getRefreshToken() =>
      storage.read(key: StorageKeys.refreshToken);

  void dispose() {
    _logoutController.close();
  }
}