import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  // تحديد هوية الألوان من اللوجو
  static const Color primaryBlue = Color(0xFF0055A5);
  static const Color accentBlue = Color(0xFFE3F2FD);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final obscurePasswordProvider = StateProvider<bool>((ref) => true);

    // الاستماع لحالة المصادقة (Logic)
    ref.listen(authStateProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('دور المستخدم ($role) غير مدعوم.')),
                );
            }
          }
        },
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.redAccent,
          ),
        ),
      );
    });

    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // لمسة جمالية خلفية تعكس خطوط اللوجو
          Positioned(
            top: -50,
            right: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: accentBlue.withOpacity(0.5),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- منطقة اللوجو ---
                    Hero(
                      tag: 'logo',
                      child: Container(
                        height: 120,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/kyan.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'الكيان الرقمي',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: primaryBlue,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'مستقبل التعليم بين يديك',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                    const SizedBox(height: 50),

                    // --- نموذج تسجيل الدخول ---
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: phoneController,
                            label: 'رقم الهاتف',
                            icon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                            validator: Validators.phone,
                          ),
                          const SizedBox(height: 20),
                          Consumer(
                            builder: (context, ref, _) {
                              final isObscured = ref.watch(
                                obscurePasswordProvider,
                              );
                              return _buildTextField(
                                controller: passwordController,
                                label: 'كلمة المرور',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                obscureText: isObscured,
                                onToggleVisibility: () =>
                                    ref
                                            .read(
                                              obscurePasswordProvider.notifier,
                                            )
                                            .state =
                                        !isObscured,
                                validator: Validators.password,
                              );
                            },
                          ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                'نسيت كلمة المرور؟',
                                style: TextStyle(
                                  color: primaryBlue.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // --- زر الدخول الذكي ---
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: authState.maybeWhen(
                                loading: () => null,
                                orElse: () => () {
                                  if (formKey.currentState!.validate()) {
                                    ref
                                        .read(authStateProvider.notifier)
                                        .login(
                                          phoneController.text.trim(),
                                          passwordController.text,
                                        );
                                  }
                                },
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 2,
                              ),
                              child: authState.maybeWhen(
                                loading: () => const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                orElse: () => const Text(
                                  'تسجيل الدخول',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget مساعد لبناء الحقول بتصميم عصري
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryBlue),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ... (داخل قائمة children الخاصة بـ Column)
        const SizedBox(height: 50), // مسافة قبل الحقوق
        // قسم حقوق الملكية
        Column(
          children: [
            Container(
              width: 40,
              height: 2,
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.copyright, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 5),
                Text(
                  'جميع الحقوق محفوظة لعام ${DateTime.now().year}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'الكيان الرقمي - Digital Entity',
              style: TextStyle(
                color: primaryBlue.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'sans-serif', // أو نوع الخط المستخدم في تطبيقك
              ),
            ),
            const SizedBox(height: 20), // مسافة أمان أخيرة
          ],
        ),
      ],
    );
  }
}
