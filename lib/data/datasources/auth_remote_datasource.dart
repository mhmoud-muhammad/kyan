// lib/data/datasources/auth_remote_datasource.dart
import 'package:myapp/core/errors/exceptions.dart';
import 'package:myapp/core/network/token_manager.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/auth_response.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;
  final TokenManager tokenManager;

  AuthRemoteDataSource(this.apiClient, this.tokenManager);

  /// 🔹 تسجيل الدخول
  Future<AuthResponse> login(String phone, String password) async {
    final response = await apiClient.post(
      ApiConstants.loginEndpoint,
      data: {'phone': phone, 'password': password},
    );

    // التحقق من رمز الحالة
    if (response.statusCode != 200 && response.statusCode != 201) {
      // محاولة استخراج رسالة الخطأ من الاستجابة
      String message = 'فشل تسجيل الدخول';
      if (response.data is Map && response.data['message'] != null) {
        message = response.data['message'];
      } else if (response.data is String) {
        message = response.data;
      }
    
      // رمي استثناء مناسب حسب رمز الحالة
      if (response.statusCode == 401) {
        throw UnauthorizedException(message);
      } else {
        throw ServerException(message, code: response.statusCode);
      }
    }

    // إذا كان الرد ناجحًا، نقوم بتحويل البيانات
    final authResponse = AuthResponse.fromJson(response.data);

    // حفظ التوكنات
    await tokenManager.saveTokens(
      authResponse.accessToken,
      authResponse.refreshToken,
    );

    return authResponse;
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await apiClient.post(
      ApiConstants.refreshTokenEndpoint,
      data: {'refresh': refreshToken},
    );

    final authResponse = AuthResponse.fromJson(response.data);

    // حفظ التوكنات الجديدة وتحديث وقت الإصدار
    await tokenManager.saveTokens(
      authResponse.accessToken,
      authResponse.refreshToken,
    );
    await tokenManager.markTokenIssuedNow();

    return authResponse;
  }

  /// 🔹 المستخدم الحالي
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await apiClient.get(ApiConstants.userEndpoint);
    return response.data;
  }

  /// 🔹 تسجيل الخروج
  Future<void> logout(String refreshToken) async {
    await apiClient.post(
      ApiConstants.logoutEndpoint,
      data: {'refresh': refreshToken},
    );

    await tokenManager.clearTokens();
  }
}
