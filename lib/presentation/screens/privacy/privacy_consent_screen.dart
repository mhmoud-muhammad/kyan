// lib/presentation/screens/privacy/privacy_consent_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/services/privacy_consent_service.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/theme/text_styles.dart';

/// تظهر عند أول تشغيل للتطبيق (وبعد أي تحديث لسياسة الخصوصية)
/// ولا يمكن استخدام التطبيق قبل الموافقة عليها.
class PrivacyConsentScreen extends ConsumerStatefulWidget {
  const PrivacyConsentScreen({super.key});

  @override
  ConsumerState<PrivacyConsentScreen> createState() =>
      _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends ConsumerState<PrivacyConsentScreen> {
  bool _agreed = false;
  bool _saving = false;
  late final TapGestureRecognizer _policyTap;

  @override
  void initState() {
    super.initState();
    _policyTap = TapGestureRecognizer()
      ..onTap = () => openPrivacyPolicy(context);
  }

  @override
  void dispose() {
    _policyTap.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    setState(() => _saving = true);
    await ref.read(privacyConsentServiceProvider).acceptPrivacyPolicy();
    if (!mounted) return;
    // نعود للـ splash ليكمل مسار الدخول الطبيعي
    context.go('/splash');
  }

  Future<void> _decline() async {
    final exit =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('لا يمكن المتابعة'),
            content: const Text(
              'استخدام تطبيق كيان يتطلب الموافقة على سياسة الخصوصية. '
              'هل تريد الخروج من التطبيق؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('رجوع'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('خروج'),
              ),
            ],
          ),
        ) ??
        false;
    if (exit) SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  children: [
                    Center(
                      child: Container(
                        height: 88,
                        width: 88,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(
                                (0.06 * 255).round(),
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Image.asset('assets/images/kyan3.png'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'الخصوصية وشروط الاستخدام',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'قبل البدء، يرجى قراءة كيفية تعامل تطبيق كيان مع بياناتك.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    _buildInfoCard(
                      icon: Icons.person_outline_rounded,
                      title: 'بيانات الحساب',
                      body:
                          'الاسم ورقم الهاتف وبيانات الدخول، وتُستخدم لتسجيل '
                          'دخولك وربطك بالمدرسة وأبنائك.',
                    ),
                    _buildInfoCard(
                      icon: Icons.school_outlined,
                      title: 'بيانات الطلاب',
                      body:
                          'أسماء الطلاب وحالة الحضور وطلبات الاستلام، وتُعرض '
                          'لولي الأمر والمعلم المعنيين فقط.',
                    ),
                    _buildInfoCard(
                      icon: Icons.location_on_outlined,
                      title: 'الموقع الجغرافي',
                      body:
                          'يُستخدم موقعك فقط أثناء استخدام التطبيق وعند إرسال '
                          'طلب استلام، للتحقق من قربك من المدرسة. لا يتم تتبع '
                          'موقعك في الخلفية.',
                    ),
                    _buildInfoCard(
                      icon: Icons.notifications_none_rounded,
                      title: 'الإشعارات',
                      body:
                          'نرسل إشعارات بطلبات الاستلام وتحديثات الحالة. يمكنك '
                          'إيقافها في أي وقت من إعدادات الجهاز.',
                    ),
                    _buildInfoCard(
                      icon: Icons.lock_outline_rounded,
                      title: 'حماية البيانات',
                      body:
                          'تُنقل البيانات عبر اتصال مشفّر (HTTPS) وتُخزّن بيانات '
                          'الدخول بشكل آمن على جهازك، ولا نبيع بياناتك لأي طرف.',
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => openPrivacyPolicy(context),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('قراءة سياسة الخصوصية كاملة'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryDark,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.03 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(body, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _agreed = !_agreed),
            child: Row(
              children: [
                Checkbox(
                  value: _agreed,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _agreed = v ?? false),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        const TextSpan(text: 'قرأت وأوافق على '),
                        TextSpan(
                          text: 'سياسة الخصوصية',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: _policyTap,
                        ),
                        const TextSpan(text: ' الخاصة بتطبيق كيان'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _saving ? null : _decline,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('رفض'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _agreed && !_saving ? _accept : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withAlpha(
                      (0.35 * 255).round(),
                    ),
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('موافق ومتابعة'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
