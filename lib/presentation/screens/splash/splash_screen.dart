//lib/presentation/screens/splash/splash_screen.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    _checkAuth();
  }

// (داخل _SplashScreenState)

  Future<void> _checkAuth() async {
    // الانتظار قليلاً لعرض الشعار
    await Future.delayed(const Duration(seconds: 2));

    // الوصول إلى localDataSource لجلب بيانات المستخدم المخزنة
    final localDataSource = ref.read(authLocalDataSourceProvider);
    final isAuthenticated = await localDataSource.hasValidToken();

    if (!mounted) return;

    if (isAuthenticated) {
      final user = await localDataSource.getCachedUser();
      if (user != null) {
        // --- نفس المنطق الذكي للتوجيه ---
        final role = user.role.toUpperCase();
        switch (role) {
          case 'PARENT':
          case 'GUARDIAN':
            context.go('/guardian');
            break;
          case 'TEACHER':
            context.go('/teacher');
            break;
          case 'MANAGER':
            context.go('/manager');
            break;
          default:
            context.go('/login'); // إذا كان الدور غير معروف، اذهب للدخول
        }
      } else {
        // يوجد توكن ولكن لا توجد بيانات مستخدم، اذهب للدخول لتحديثها
        context.go('/login');
      }
    } else {
      // لا يوجد توكن، اذهب للدخول
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                    child: Center(
                    child: Image.asset(
                      'assets/images/kyan.png',
                      height: 80,
                      width: 80,
                      fit: BoxFit.scaleDown,
                    ),
                    ),
                ) ,
                const Text(
                  'Kyan',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
