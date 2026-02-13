// lib/data/datasources/auth_local_datasource.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/user.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage storage;

  AuthLocalDataSource(this.storage);

  Future<void> cacheAuthResponse({
    required String accessToken,
    required String refreshToken,
  }) async {
    await storage.write(
      key: ApiConstants.accessTokenKey,
      value: accessToken,
    );
    await storage.write(
      key: ApiConstants.refreshTokenKey,
      value: refreshToken,
    );
  }

  /// ✅ حفظ بيانات المستخدم
  Future<void> cacheUser(User user) async {
    await storage.write(
      key: ApiConstants.userDataKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<User?> getCachedUser() async {
    final userJson = await storage.read(key: ApiConstants.userDataKey);
    if (userJson == null) return null;

    try {
      return User.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    return storage.read(key: ApiConstants.accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return storage.read(key: ApiConstants.refreshTokenKey);
  }

  Future<void> clearAuthData() async {
    await storage.delete(key: ApiConstants.accessTokenKey);
    await storage.delete(key: ApiConstants.refreshTokenKey);
    await storage.delete(key: ApiConstants.userDataKey);
  }

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}