
class ApiConstants {
  static const String baseUrl = 'https://api.kyan.com/v1';
  static const String dummyBaseUrl = 'https://dummyapi.kyan.com/v1';
  
  // Auth Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  // User Endpoints
  static const String userEndpoint = '/user';
  static const String updateProfileEndpoint = '/user/profile';
  static const String changePasswordEndpoint = '/user/change-password';
  
  // Token Keys
  static const String accessTokenKey = 'kyan_access_token';
  static const String refreshTokenKey = 'kyan_refresh_token';
  static const String userDataKey = 'kyan_user_data';
  
  // Dummy Data
  static const bool useDummyData = true; // للتبديل بين API الحقيقي والوهمي
}