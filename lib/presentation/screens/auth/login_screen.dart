// lib/presentation/screens/auth/login_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/constants/storage_keys.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth/auth_provider.dart';

final errorMessageProvider = StateProvider<String?>((ref) => null);

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  static const Color primaryBlue = Color(0xFF0055A5);
  static const Color accentBlue = Color(0xFFE3F2FD);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final obscurePasswordProvider = StateProvider<bool>((ref) => true);

    final errorMessage = ref.watch(errorMessageProvider);

    ref.listen(authStateProvider, (previous, next) {
      next.when(
        data: (user) async {
          if (user == null) return;
          final tokenManager = ref.read(tokenManagerProvider);
          await tokenManager.storage.read(key: StorageKeys.accessToken);
          await tokenManager.storage.read(key: StorageKeys.refreshToken);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ تم تسجيل الدخول بنجاح\nالدور: ${user.role}',
                maxLines: 3,
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          if (user.role == 'TEACHER') {
            context.go('/teacher');
          } else if (user.role == 'PARENT') {
            context.go('/guardian');
          } else {
            context.go('/login');
          }
        },
        loading: () {},
        error: (error, _) {
          ref.read(errorMessageProvider.notifier).state = error as String;
          Timer(const Duration(seconds: 3), () {
            if (ref.exists(errorMessageProvider)) {
              ref.read(errorMessageProvider.notifier).state = null;
            }
          });
        },
      );
    });

    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _AnimatedBackground(accentBlue: accentBlue),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _AnimatedLogo(),
                    const SizedBox(height: 30),
                    _AnimatedText(
                      'الكيان الرقمي',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: primaryBlue,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          _AnimatedTextField(
                            controller: phoneController,
                            label: 'رقم الهاتف',
                            icon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                            validator: Validators.phone,
                            primaryColor: primaryBlue,
                          ),
                          const SizedBox(height: 20),
                          Consumer(
                            builder: (context, ref, _) {
                              final isObscured = ref.watch(
                                obscurePasswordProvider,
                              );
                              return _AnimatedTextField(
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
                                primaryColor: primaryBlue,
                              );
                            },
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _AnimatedTextButton(
                              onPressed: () {},
                              text: 'نسيت كلمة المرور؟',
                              primaryColor: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _AnimatedLoginButton(
                            isLoading: authState.isLoading,
                            onPressed: authState.maybeWhen(
                              loading: () => null,
                              orElse: () => () async {
                                if (!formKey.currentState!.validate()) return;

                                final isConnected = await ref
                                    .read(networkInfoProvider)
                                    .isConnected;

                                if (!isConnected) {
                                  ref
                                          .read(errorMessageProvider.notifier)
                                          .state =
                                      '❌ لا يوجد اتصال بالإنترنت\nيرجى التحقق من الشبكة وإعادة المحاولة';
                                  return;
                                }

                                ref
                                    .read(authStateProvider.notifier)
                                    .login(
                                      phoneController.text.trim(),
                                      passwordController.text,
                                    );
                              },
                            ),
                            primaryColor: primaryBlue,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    _AnimatedFooter(primaryColor: primaryBlue),
                  ],
                ),
              ),
            ),
          ),
          if (authState.isLoading) const _LoadingOverlay(),
          if (errorMessage != null) _ErrorOverlay(message: errorMessage),
        ],
      ),
    );
  }
}

// ==================== كلاسات مساعدة (بدون تغيير) ====================

class _AnimatedBackground extends StatefulWidget {
  final Color accentBlue;
  const _AnimatedBackground({required this.accentBlue});

  @override
  State<_AnimatedBackground> createState() => __AnimatedBackgroundState();
}

class __AnimatedBackgroundState extends State<_AnimatedBackground>
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
              color: widget.accentBlue.withOpacity(
                0.3 + _controller.value * 0.2,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedLogo extends StatefulWidget {
  const _AnimatedLogo();

  @override
  State<_AnimatedLogo> createState() => __AnimatedLogoState();
}

class __AnimatedLogoState extends State<_AnimatedLogo>
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
          child: Image.asset('assets/images/kyan.png', fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _AnimatedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  const _AnimatedText(this.text, {required this.style});

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
      child: Text(text, style: style),
    );
  }
}

class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Color primaryColor;

  const _AnimatedTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.keyboardType,
    this.validator,
    required this.primaryColor,
  });

  @override
  State<_AnimatedTextField> createState() => __AnimatedTextFieldState();
}

class __AnimatedTextFieldState extends State<_AnimatedTextField> {
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
                        color: widget.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              decoration: InputDecoration(
                labelText: widget.label,
                prefixIcon: Icon(widget.icon, color: widget.primaryColor),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          widget.obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: widget.onToggleVisibility,
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

class _AnimatedTextButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Color primaryColor;
  const _AnimatedTextButton({
    required this.onPressed,
    required this.text,
    required this.primaryColor,
  });

  @override
  State<_AnimatedTextButton> createState() => __AnimatedTextButtonState();
}

class __AnimatedTextButtonState extends State<_AnimatedTextButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: Transform.scale(
        scale: _scale,
        child: Text(
          widget.text,
          style: TextStyle(
            color: widget.primaryColor.withOpacity(0.8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AnimatedLoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final Color primaryColor;

  const _AnimatedLoginButton({
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
                'تسجيل الدخول',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

class _AnimatedFooter extends StatelessWidget {
  final Color primaryColor;
  const _AnimatedFooter({required this.primaryColor});

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
              color: primaryColor.withOpacity(0.2),
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
              color: primaryColor.withOpacity(0.6),
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

class _LoadingOverlay extends StatefulWidget {
  const _LoadingOverlay();

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
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
            color: Colors.black.withOpacity(0.3),
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
                          'جاري تسجيل الدخول...',
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

// ==================== Overlay الخطأ الجديد (بدون أنيميشن داخلي) ====================
class _ErrorOverlay extends StatelessWidget {
  final String message;
  const _ErrorOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: Container(
            color: Colors.black.withOpacity(0.3),
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
