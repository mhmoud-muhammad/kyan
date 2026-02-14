// lib/core/network/token_manager.dart
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';
import '../constants/api_constants.dart';

class TokenManager {
  final FlutterSecureStorage storage;

  final Duration tokenLifetime = Duration(
    minutes: ApiConstants.tokenLifetimeMinutes,
  );

  static const _refreshThreshold = Duration(minutes: 14);
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshWaiters = [];

  TokenManager(this.storage);

  /// ✅ هل يجب عمل refresh استباقي؟
  Future<bool> shouldRefresh() async {
    final issuedAtMillis = await storage.read(key: StorageKeys.tokenIssuedAt);
    if (issuedAtMillis == null) return false;

    final issuedAt =
        DateTime.fromMillisecondsSinceEpoch(int.parse(issuedAtMillis));
    final elapsed = DateTime.now().difference(issuedAt);
    return elapsed >= _refreshThreshold;
  }

  /// ✅ تمييز التوكن بأنه تم تحديثه
  Future<void> markTokenRefreshed() async {
    await storage.write(
      key: StorageKeys.tokenIssuedAt,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// ✅ تنفيذ refresh مع منع التكرار المتزامن
  Future<void> runRefresh(Future<void> Function() refreshAction) async {
    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshWaiters.add(completer);
      return completer.future;
    }

    _isRefreshing = true;
    try {
      await refreshAction();
      await markTokenRefreshed();

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

  /// ✅ الحصول على تاريخ إصدار التوكن
  Future<DateTime?> getTokenIssuedAt() async {
    final millis = await storage.read(key: StorageKeys.tokenIssuedAt);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(millis));
  }

  /// ✅ المدة المتبقية قبل refresh
  Future<Duration?> timeUntilRefresh() async {
    final issuedAt = await getTokenIssuedAt();
    if (issuedAt == null) return null;
    final elapsed = DateTime.now().difference(issuedAt);
    final remaining = _refreshThreshold - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// ✅ الحصول على refresh token
  Future<String?> getRefreshToken() async {
    return storage.read(key: StorageKeys.refreshToken);
  }

  /// ✅ تحديث access token
  Future<void> updateAccessToken(String newToken) async {
    await storage.write(key: StorageKeys.accessToken, value: newToken);
    await markTokenRefreshed();
  }
}
