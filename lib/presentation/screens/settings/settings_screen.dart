// lib/presentation/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/theme/text_styles.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: AppTextStyles.heading2.copyWith(fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildSectionHeader('الحساب'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.person_outline_rounded,
              title: 'تعديل الملف الشخصي',
              subtitle: 'الاسم، الصورة، ورقم الهاتف',
              onTap: () => context.push('/profile'),
            ),
            _buildSettingItem(
              icon: Icons.notifications_none_rounded,
              title: 'التنبيهات',
              subtitle: 'التحكم في إشعارات الاستلام والحضور',
              onTap: () {
                /* Navigate to notifications settings */
              },
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader('التطبيق'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.dark_mode_outlined,
              title: 'المظهر (قريباً)',
              subtitle: 'التبديل بين الوضع الفاتح والمظلم',
              trailing: Switch(
                value: false,
                onChanged: (val) {},
                activeColor: AppColors.primary,
              ),
            ),
            _buildSettingItem(
              icon: Icons.language_rounded,
              title: 'اللغة',
              subtitle: 'العربية',
              onTap: () {
                /* Change language logic */
              },
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader('الدعم'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.help_outline_rounded,
              title: 'مركز المساعدة',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.info_outline_rounded,
              title: 'عن التطبيق',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 32),
          // زر تسجيل الخروج
          _buildLogoutButton(ref, context),

          const SizedBox(height: 20),
          Center(
            child: Text(
              'الإصدار 1.0.0',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // مكوّن لعنوان القسم
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // مكوّن البطاقة التي تجمع العناصر
  Widget _buildSettingsCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  // مكوّن العنصر الواحد داخل القائمة
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.bodySmall)
          : null,
      trailing:
          trailing ??
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textHint,
          ),
      onTap: onTap,
    );
  }

  // مكوّن زر تسجيل الخروج
  Widget _buildLogoutButton(WidgetRef ref, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: () => _handleLogout(ref, context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.error.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'تسجيل الخروج',
              style: AppTextStyles.body.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(WidgetRef ref, BuildContext context) async {
    final bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('تسجيل الخروج'),
            content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
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

    if (confirm) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }
}
