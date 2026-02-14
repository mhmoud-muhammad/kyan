// lib/data/datasources/auth_remote_datasource.dart
import 'package:myapp/core/errors/exceptions.dart';
import 'package:myapp/core/network/token_manager.dart';
import '../../core/network/api_client.dart';
import '../../core/network/dummy_data.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/auth_response.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;
final TokenManager tokenManager;

  AuthRemoteDataSource(this.apiClient, this.tokenManager);

  /// 🔹 تسجيل الدخول
  Future<AuthResponse> login(String email, String password) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(seconds: 1));
      final dummyResponse = DummyData.authenticate(email, password);
      if (dummyResponse != null) return AuthResponse.fromJson(dummyResponse);
      throw ServerException('Invalid email or password');
    }

    final response = await apiClient.post(
      ApiConstants.loginEndpoint,
      data: {'email': email, 'password': password},
    );

    return AuthResponse.fromJson(response.data);
  }

  /// 🔹 تسجيل مستخدم جديد
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(seconds: 1));
      final dummyResponse = DummyData.createDummyUser(
        email: email,
        name: name,
        phone: phone,
      );
      return AuthResponse.fromJson(dummyResponse);
    }

    final response = await apiClient.post(
      ApiConstants.registerEndpoint,
      data: {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
      },
    );

    return AuthResponse.fromJson(response.data);
  }

  /// 🔹 استرجاع بيانات المستخدم الحالي
  Future<Map<String, dynamic>> getCurrentUser() async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return DummyData.dummyUser;
    }

    final response = await apiClient.get(ApiConstants.userEndpoint);
    return response.data;
  }

  /// 🔹 دالة عامة لتحديث الـ token (Refresh)
  Future<String> refreshToken(String refreshToken) async {
    if (ApiConstants.useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.kyan_dummy_token_refreshed_2024';
    }

    final response = await apiClient.post(
      ApiConstants.refreshTokenEndpoint,
      data: {'refreshToken': refreshToken},
    );

    return response.data['accessToken'];
  }

  /// 🔹 تسجيل الخروج
  Future<void> logout() async {
    if (ApiConstants.useDummyData) return;

    await apiClient.post(ApiConstants.logoutEndpoint);
  }
}
