// lib/presentation/screens/auth/forgot_password_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart'; // تأكد من إضافة Dio في pubspec.yaml
import 'package:myapp/presentation/providers/auth/auth_provider.dart';
import '../../../core/network/api_client.dart'; // يجب أن يكون لديك ApiClient أو Dio محقون
import '../../../core/utils/validators.dart';

// Providers محلية
final isLoadingProvider = StateProvider<bool>((ref) => false);
final errorMessageProvider = StateProvider<String?>((ref) => null);
final successMessageProvider = StateProvider<String?>((ref) => null);

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  static const Color primaryBlue = Color(0xFF0055A5);
  static const Color accentBlue = Color(0xFFE3F2FD);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneController = TextEditingController();
    final nationalIdController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorMessageProvider);
    final successMessage = ref.watch(successMessageProvider);

    // دالة إعادة تعيين كلمة المرور
    Future<void> _handleResetPassword() async {
      // التحقق من صحة الحقول
      if (!formKey.currentState!.validate()) return;

      // التحقق من تطابق كلمتي السر
      if (newPasswordController.text != confirmPasswordController.text) {
        ref.read(errorMessageProvider.notifier).state = 'كلمتا السر غير متطابقتين';
        return;
      }

      ref.read(isLoadingProvider.notifier).state = true;
      ref.read(errorMessageProvider.notifier).state = null;
      ref.read(successMessageProvider.notifier).state = null;

      try {
        // استخدام ApiClient أو Dio مباشرة
        final dio = ref.read(apiClientProvider); // تأكد من وجود provider لـ Dio
        final response = await dio.post(
          '/api/v1/auth/reset-password/',
          data: {
            'phone': phoneController.text.trim(),
            'national_id': nationalIdController.text.trim(),
            'new_password': newPasswordController.text,
            'confirm_password': confirmPasswordController.text,
          },
        );

        if (response.statusCode == 200) {
          final message = response.data['detail'] ?? 'تم تغيير كلمة السر بنجاح';
          ref.read(successMessageProvider.notifier).state = message;

          // الانتقال إلى صفحة تسجيل الدخول بعد 2 ثانية
          Timer(const Duration(seconds: 2), () {
            if (context.mounted) {
              context.go('/login');
            }
          });
        }
      } on DioException catch (e) {
        // معالجة أخطاء API
        if (e.response?.statusCode == 400) {
          // errors من النوع { "field": ["message"] }
          final errors = e.response?.data;
          if (errors is Map) {
            // استخراج أول رسالة خطأ
            String firstError = '';
            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                firstError = value.first;
              } else if (value is String) {
                firstError = value;
              }
            });
            ref.read(errorMessageProvider.notifier).state = firstError.isNotEmpty ? firstError : 'بيانات غير صحيحة';
          } else {
            ref.read(errorMessageProvider.notifier).state = 'بيانات غير صحيحة';
          }
        } else {
          ref.read(errorMessageProvider.notifier).state = 'حدث خطأ في الاتصال';
        }
      } catch (e) {
        ref.read(errorMessageProvider.notifier).state = 'حدث خطأ غير متوقع';
      } finally {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _ForgotBackground(accentBlue: accentBlue),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ForgotLogo(),
                    const SizedBox(height: 30),
                    _ForgotText(
                      'إعادة تعيين كلمة المرور',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: primaryBlue,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ForgotText(
                      'أدخل بياناتك لتغيير كلمة المرور',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          _ForgotTextField(
                            controller: phoneController,
                            label: 'رقم الهاتف',
                            icon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                            validator: Validators.phone,
                            primaryColor: primaryBlue,
                          ),
                          const SizedBox(height: 20),
                          _ForgotTextField(
                            controller: nationalIdController,
                            label: 'رقم الهوية',
                            icon: Icons.badge,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'رقم الهوية مطلوب';
                              }
                              if (value.length < 10) {
                                return 'رقم الهوية يجب أن يكون 10 أرقام على الأقل';
                              }
                              return null;
                            },
                            primaryColor: primaryBlue,
                          ),
                          const SizedBox(height: 20),
                          _ForgotPasswordField(
                            controller: newPasswordController,
                            label: 'كلمة المرور الجديدة',
                            validator: Validators.password,
                            primaryColor: primaryBlue,
                          ),
                          const SizedBox(height: 20),
                          _ForgotPasswordField(
                            controller: confirmPasswordController,
                            label: 'تأكيد كلمة المرور',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'تأكيد كلمة المرور مطلوب';
                              }
                              return null;
                            },
                            primaryColor: primaryBlue,
                          ),
                          const SizedBox(height: 30),
                          _ForgotSubmitButton(
                            isLoading: isLoading,
                            onPressed: isLoading ? null : _handleResetPassword,
                            primaryColor: primaryBlue,
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              'العودة إلى تسجيل الدخول',
                              style: TextStyle(
                                color: primaryBlue.withAlpha((0.8 * 255).round()),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _ForgotFooter(primaryColor: primaryBlue),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading) const _ForgotLoadingOverlay(),
          if (errorMessage != null) _ForgotErrorOverlay(message: errorMessage),
          if (successMessage != null) _ForgotSuccessOverlay(message: successMessage),
        ],
      ),
    );
  }
}

// ==================== مكونات مساعدة ====================

class _ForgotBackground extends StatefulWidget {
  final Color accentBlue;
  const _ForgotBackground({required this.accentBlue});

  @override
  State<_ForgotBackground> createState() => __ForgotBackgroundState();
}

class __ForgotBackgroundState extends State<_ForgotBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: -50 + _controller.value * 30,
          right: -50 + _controller.value * 20,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.accentBlue.withAlpha(
                (0.8 * 255 + _controller.value * 0.2).round(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ForgotLogo extends StatefulWidget {
  const _ForgotLogo();

  @override
  State<_ForgotLogo> createState() => __ForgotLogoState();
}

class __ForgotLogoState extends State<_ForgotLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Hero(
        tag: 'logo',
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset('assets/images/kyan3.png', fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _ForgotText extends StatelessWidget {
  final String text;
  final TextStyle style;
  const _ForgotText(this.text, {required this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Text(text, style: style, textAlign: TextAlign.center),
    );
  }
}

class _ForgotTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Color primaryColor;

  const _ForgotTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    required this.primaryColor,
  });

  @override
  State<_ForgotTextField> createState() => __ForgotTextFieldState();
}

class __ForgotTextFieldState extends State<_ForgotTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 1.02),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        child: Transform.scale(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: widget.primaryColor.withAlpha((0.3 * 255).round()),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              decoration: InputDecoration(
                labelText: widget.label,
                prefixIcon: Icon(widget.icon, color: widget.primaryColor),
                filled: true,
                fillColor: Colors.grey[50],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: widget.primaryColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final Color primaryColor;

  const _ForgotPasswordField({
    required this.controller,
    required this.label,
    this.validator,
    required this.primaryColor,
  });

  @override
  State<_ForgotPasswordField> createState() => __ForgotPasswordFieldState();
}

class __ForgotPasswordFieldState extends State<_ForgotPasswordField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _obscureText = true;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 1.02),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        child: Transform.scale(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: widget.primaryColor.withAlpha((0.3 * 255).round()),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: _obscureText,
              validator: widget.validator,
              decoration: InputDecoration(
                labelText: widget.label,
                prefixIcon: Icon(Icons.lock_outline_rounded, color: widget.primaryColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: widget.primaryColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final Color primaryColor;

  const _ForgotSubmitButton({
    required this.isLoading,
    required this.onPressed,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'تغيير كلمة المرور',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

class _ForgotFooter extends StatelessWidget {
  final Color primaryColor;
  const _ForgotFooter({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: primaryColor.withAlpha((0.2 * 255).round()),
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
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'الكيان الرقمي - Digital Entity',
            style: TextStyle(
              color: primaryColor.withAlpha((0.6 * 255).round()),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ForgotLoadingOverlay extends StatefulWidget {
  const _ForgotLoadingOverlay();

  @override
  State<_ForgotLoadingOverlay> createState() => _ForgotLoadingOverlayState();
}

class _ForgotLoadingOverlayState extends State<_ForgotLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fadeAnimation = Tween<double>(
      begin: 0.5,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 300),
          child: Container(
            color: Colors.black.withAlpha((0.3 * 255).round()),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF0055A5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'جاري تغيير كلمة المرور...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotErrorOverlay extends StatelessWidget {
  final String message;
  const _ForgotErrorOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: Container(
            color: Colors.black.withAlpha((0.3 * 255).round()),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('حسناً'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotSuccessOverlay extends StatelessWidget {
  final String message;
  const _ForgotSuccessOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: Container(
            color: Colors.black.withAlpha((0.3 * 255).round()),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 50,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}