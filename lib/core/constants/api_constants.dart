// lib/core/constants/api_constants.dart

enum Environment { dev, staging, prod }

class ApiConstants {
  // ================= ENVIRONMENT =================

  static const String _envString = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  static Environment get environment {
    switch (_envString) {
      case 'prod':
        return Environment.prod;
      case 'staging':
        return Environment.staging;
      default:
        return Environment.dev;
    }
  }

  // ================= API VERSION =================

  static const String apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: 'v1',
  );

  static const String updateStudentStatusEndpoint =
      '/teacher/student/'; // سيتم إضافة ID

  // ================= BASE DOMAINS =================

  static String get _baseDomain {
    switch (environment) {
      case Environment.prod:
        return 'https://successive-amandy-tech-code-3beec46e.koyeb.app';
      case Environment.staging:
        return 'https://successive-amandy-tech-code-3beec46e.koyeb.app';
      case Environment.dev:
        return 'https://successive-amandy-tech-code-3beec46e.koyeb.app';
    }
  }

//اختلاف في نقطه النهايخ بالنسبه للتحديث التوكن فقط
// لانو الباك اند بستخدم الريفريش توكن بدون الاصدار
  static String get refUrl => '$_baseDomain/api$refreshTokenEndpoint';
  static String get domain => _baseDomain;
  static String get baseUrl => '$_baseDomain/api/$apiVersion';
  // ================= AUTH ENDPOINTS =================

  static const String loginEndpoint = '/auth/login/';
  static const String registerEndpoint = '/auth/register/';
  static const String refreshTokenEndpoint = '/token/refresh/';
  static const String logoutEndpoint = '/auth/logout/';
  static const String forgotPasswordEndpoint = '/auth/forgot-password/';
  static const String resetPasswordEndpoint = '/auth/reset-password/';
  // (داخل كلاس ApiConstants)

  // ================= PARENT ENDPOINTS =================
  static const String parentSchoolsEndpoint = '/parent/schools/';
  static const String parentStudentsEndpoint =
      '/parent/students/'; // سيتم إضافة Query param لاحقًا

  // ================= TEACHER ENDPOINTS =================
  static const String teacherDashboardEndpoint = '/teacher/dashboard/';
  static const String teacherActiveRequestsEndpoint =
      '/teacher/requests/active/';
  static const String teacherPastRequestsEndpoint = '/teacher/requests/past/';
  static const String teacherRequestDetailsEndpoint =
      '/teacher/requests/'; // سيتم إضافة ID

  // ================= USER ENDPOINTS =================

  static const String userEndpoint = '/user/';
  static const String updateProfileEndpoint = '/user/profile/';
  static const String changePasswordEndpoint = '/user/change-password/';

  // ================= STORAGE KEYS =================

  static const String accessTokenKey = 'kyan_access_token';
  static const String refreshTokenKey = 'kyan_refresh_token';
  static const String userDataKey = 'kyan_user_data';
  static const String tokenIssuedAtKey = 'kyan_token_issued_at';

  // ================= TOKEN =================
  static const int tokenLifetimeMinutes = int.fromEnvironment(
    'TOKEN_LIFETIME',
    defaultValue: 10,
  );

  // (داخل كلاس ApiConstants)

  // ================= PARENT ENDPOINTS =================
  // ✅✅✅ الإضافة الجديدة ✅✅✅
  static const String createPickupRequestEndpoint = '/parent/pickup/create/';

  static const String updateStudentStatusBase =
      '/teacher/student/'; // ثم نضيف id والـ action
  // ================= DUMMY DATA =================
  static const bool useDummyData = bool.fromEnvironment(
    'USE_DUMMY_DATA',
    defaultValue: false,
  );
}

/*
 * flutter run                            <===== عشان اشتغل في dev invironment
 * flutter run --dart-define=ENV=staging  <===== عشان تحول البيئه الى Staging
 * flutter run --dart-define=ENV=prod     <===== عشان تشغل ال prodctive
 * flutter run --dart-define=API_VERSION=v2 <==== api version
 * flutter run --dart-define=USE_DUMMY_DATA=true <==== استعمال البيانات التجريبيه
 * عشان نسهل التحول الى بيئه الانتاج 
 */
