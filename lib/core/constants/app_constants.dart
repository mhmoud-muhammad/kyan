//lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'Kyan';
  static const String appVersion = '1.0.0';
  
  // Shared Preferences Keys
  static const String themeModeKey = 'kyan_theme_mode';
  static const String languageKey = 'kyan_language';
  static const String onboardingCompleted = 'kyan_onboarding_completed';
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Validation
  static const int passwordMinLength = 8;
  static const int nameMinLength = 3;
  static const int nameMaxLength = 50;
}