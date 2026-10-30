//lib/core/router/app_router.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/constants/api_constants.dart' show ApiConstants;
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/presentation/screens/auth/forgot_password_screen.dart';
import 'package:myapp/presentation/screens/auth/login_screen.dart';
import 'package:myapp/presentation/screens/teacher/students_list_screen.dart';
import 'package:myapp/presentation/screens/profile/profile_screen.dart';
import 'package:myapp/presentation/screens/settings/settings_screen.dart';
import 'package:myapp/presentation/screens/splash/splash_screen.dart';
import 'package:myapp/presentation/screens/privacy/privacy_consent_screen.dart';
import 'package:myapp/presentation/screens/guardian/guardian_home_screen.dart';
import 'package:myapp/presentation/screens/teacher/stats_details_screen.dart';
import 'package:myapp/presentation/screens/teacher/teacher_home_screen.dart';

class _StudentListMeta {
  final String title;
  final Color color;
  const _StudentListMeta(this.title, this.color);
}

_StudentListMeta _metaForType(String type) {
  switch (type) {
    case 'present':
      return _StudentListMeta('حاضر الآن', AppColors.success);
    case 'requested':
      return _StudentListMeta('قيد الطلب', const Color(0xFFFF8C42));
    case 'atGate':
      return _StudentListMeta('عند البوابة', AppColors.primaryDark);
    case 'delivered':
      return _StudentListMeta('تم التسليم', Colors.green);
    case 'total':
    default:
      return _StudentListMeta('إجمالي الطلاب', AppColors.primary);
  }
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
const _authenticatedRoutes = [
  '/guardian',
  '/teacher',
  '/manager',
  '/profile',
  '/settings',
];
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/privacy-consent',
      name: 'privacyConsent',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: PrivacyConsentScreen()),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeIn).animate(animation),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeIn).animate(animation),
            child: child,
          );
        },
      ),
    ),

    GoRoute(
      path: '/teacher/students-list/:type',
      name: 'studentsList',
      pageBuilder: (context, state) {
        final type = state.pathParameters['type'] ?? 'total';
        final meta = _metaForType(type);

        return CustomTransitionPage(
          key: state.pageKey,
          child: StudentsListScreen(
            type: type,
            title: meta.title,
            color: meta.color,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeIn).animate(animation),
            child: child,
          );
        },
      ),
    ),

    GoRoute(
      path: '/guardian',
      name: 'guardianHome',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: GuardianHomeScreen()),
    ),
    GoRoute(
      path: '/teacher',
      name: 'teacherHome',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: TeacherHomeScreen()),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'ForgotPasswordScreen',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ForgotPasswordScreen()),
    ),

    GoRoute(
      path: '/teacher/stats-details/:type',
      name: 'statsDetails',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: StatsDetailsScreen(), // هنا الـ extra ستأتي من context
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        );
      },
    ),
  ],
  redirect: (context, state) async {
    final isAuthenticated = await _checkAuthStatus();
    final isLoginRoute = state.matchedLocation == '/login';
    final isSplashRoute = state.matchedLocation == '/splash';

    if (isSplashRoute) {
      return null;
    }

    if (isAuthenticated && isLoginRoute) {
      return null;
    }

    if (!isAuthenticated &&
        _authenticatedRoutes.contains(state.matchedLocation)) {
      return '/login';
    }

    return null;
  },
);

Future<bool> _checkAuthStatus() async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: ApiConstants.accessTokenKey);
  return token != null && token.isNotEmpty;
}
