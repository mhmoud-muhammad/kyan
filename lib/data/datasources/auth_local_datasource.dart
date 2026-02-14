// auth_local_datasource.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/storage_keys.dart';
import '../../domain/entities/user.dart';
abstract class AuthLocalDataSource {
  Future<void> cacheUser(User user);
  Future<User?> getCachedUser();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearAuthData();
  Future<bool> hasValidToken();

  Future<void> cacheTokens(String accessToken, String refreshToken);
  Future<int?> getTokenIssuedAt();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  AuthLocalDataSourceImpl(this.storage);

  // ---------------- User ----------------
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

  // ---------------- Token ----------------
  @override
  Future<String?> getAccessToken() =>
      storage.read(key: StorageKeys.accessToken);

  @override
  Future<String?> getRefreshToken() =>
      storage.read(key: StorageKeys.refreshToken);

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

  // ---------------- Utilities ----------------
  @override
  Future<void> clearAuthData() async {
    await storage.delete(key: StorageKeys.accessToken);
    await storage.delete(key: StorageKeys.refreshToken);
    await storage.delete(key: StorageKeys.userData);
    await storage.delete(key: StorageKeys.tokenIssuedAt);
  }

  @override
  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

