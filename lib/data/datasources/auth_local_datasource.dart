  // lib/data/datasources/auth_local_datasource.dart

  import 'dart:convert';
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  import 'package:myapp/core/constants/api_constants.dart';
  import '../../core/constants/storage_keys.dart';
  import '../../domain/entities/user.dart';

  abstract class AuthLocalDataSource {
    Future<void> cacheUser(User user);
    Future<User?> getCachedUser();

    Future<String?> getAccessToken();
    Future<String?> getRefreshToken();

    Future<void> cacheTokens(String accessToken, String refreshToken);
    Future<int?> getTokenIssuedAt();

    Future<bool> hasValidToken();
    Future<void> clearAuthData();

  Future<void> cacheRole(String role) async {}
  }

  class AuthLocalDataSourceImpl implements AuthLocalDataSource {
    final FlutterSecureStorage storage;

    AuthLocalDataSourceImpl(this.storage);

    // ================= USER =================

    @override
    Future<void> cacheUser(User user) async {
      await storage.write(
        key: StorageKeys.userData,
        value: jsonEncode(user.toJson()),
      );
    }

    @override
    Future<User?> getCachedUser() async {
      final userJson = await storage.read(key: StorageKeys.userData);
      if (userJson == null) return null;

      try {
        return User.fromJson(jsonDecode(userJson));
      } catch (_) {
        return null;
      }
    }

    // ================= TOKEN =================

    @override
    Future<String?> getAccessToken() {
      return storage.read(key: StorageKeys.accessToken);
    }

    @override
    Future<String?> getRefreshToken() {
      return storage.read(key: StorageKeys.refreshToken);
    }

    @override
    Future<void> cacheTokens(
      String accessToken,
      String refreshToken,
    ) async {
      await storage.write(
        key: StorageKeys.accessToken,
        value: accessToken,
      );

      await storage.write(
        key: StorageKeys.refreshToken,
        value: refreshToken,
      );

      await storage.write(
        key: StorageKeys.tokenIssuedAt,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    }

    @override
    Future<int?> getTokenIssuedAt() async {
      final value = await storage.read(key: StorageKeys.tokenIssuedAt);
      return value != null ? int.tryParse(value) : null;
    }

    @override
    Future<bool> hasValidToken() async {
      final accessToken = await getAccessToken();
      final issuedAtMillis = await getTokenIssuedAt();

      if (accessToken == null || issuedAtMillis == null) return false;

      final issuedAt =
          DateTime.fromMillisecondsSinceEpoch(issuedAtMillis);

      final expiresAt = issuedAt.add(
        Duration(minutes: ApiConstants.tokenLifetimeMinutes),
      );

      return DateTime.now().isBefore(expiresAt);
    }


@override
  Future<void> cacheRole(String role) async {
  await storage.write(key: StorageKeys.userRole, value: role);
}

Future<String?> getCachedRole() async {
  return await storage.read(key: StorageKeys.userRole);
}

// وفي clearAuthData
    @override
    Future<void> clearAuthData() async {
      await storage.delete(key: StorageKeys.accessToken);
      await storage.delete(key: StorageKeys.refreshToken);
      await storage.delete(key: StorageKeys.tokenIssuedAt);
      await storage.delete(key: StorageKeys.userData);
      await storage.delete(key: StorageKeys.userRole);
    }
  }