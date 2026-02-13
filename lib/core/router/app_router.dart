import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/constants/api_constants.dart' show ApiConstants;
import 'package:myapp/presentation/screens/auth/login_screen.dart';
import 'package:myapp/presentation/screens/home/home_screen.dart';
import 'package:myapp/presentation/screens/splash/splash_screen.dart'; 
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

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
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: HomeScreen(),
      ),
    ),
  ],
  redirect: (context, state) async {
    final isAuthenticated = await _checkAuthStatus();
    final isLoginRoute = state.matchedLocation == '/login';
    final isRegisterRoute = state.matchedLocation == '/register';
    final isSplashRoute = state.matchedLocation == '/splash';
    
    if (isSplashRoute) {
      return null; // Stay in splash
    }
    
    if (isAuthenticated) {
      if (isLoginRoute || isRegisterRoute) {
        return '/home';
      }
    } else {
      if (!isLoginRoute && !isRegisterRoute) {
        return '/login';
      }
    }
    
    return null;
  },
);

Future<bool> _checkAuthStatus() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: ApiConstants.accessTokenKey);
  return token != null && token.isNotEmpty;
}