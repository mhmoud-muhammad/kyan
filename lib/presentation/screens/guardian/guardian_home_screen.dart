// lib/presentation/screens/guardian/guardian_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/services/location_service.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/theme/text_styles.dart';
import 'package:myapp/domain/entities/school.dart';
import 'package:myapp/domain/entities/student.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/presentation/providers/auth/auth_provider.dart';
import 'package:myapp/presentation/providers/guardian/guardian_provider.dart';

class GuardianHomeScreen extends ConsumerWidget {
  const GuardianHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final selectedSchool = ref.watch(selectedSchoolProvider);
    final user = authState.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          selectedSchool == null ? 'مدارسي' : selectedSchool.name,
          style: AppTextStyles.heading2.copyWith(
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        leading: selectedSchool != null
            ? Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => ref
                      .read(selectedSchoolProvider.notifier)
                      .clearSelection(),
                ),
              )
            : Builder(
                builder: (context) => Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.menu_rounded, size: 24),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
      ),
      drawer: _AppDrawer(user: user),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: selectedSchool == null
              ? const SchoolSelectionView(key: ValueKey('schools'))
              : const StudentListView(key: ValueKey('students')),
        ),
      ),
    );
  }
}

// ===================================================================
//                        القائمة الجانبية (Drawer)
// ===================================================================
class _AppDrawer extends ConsumerWidget {
  final User? user;
  const _AppDrawer({this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      width: MediaQuery.of(context).size.width * 0.7,
      child: Container(
        color: AppColors.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(context, user),
            const SizedBox(height: 10),
            _buildDrawerItem(
              icon: Icons.person_outline_rounded,
              title: 'الملف الشخصي',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: 'الإعدادات',
              color: AppColors.textSecondary,
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            _buildDrawerItem(
              icon: Icons.privacy_tip_outlined,
              title: 'سياسة الخصوصية',
              color: AppColors.primaryDark,
              onTap: () {
                Navigator.pop(context);
                _showPrivacyPolicyDialog(context);
              },
            ),
            const Divider(
              height: 30,
              thickness: 0.5,
              indent: 20,
              endIndent: 20,
            ),
            _buildDrawerItem(
              icon: Icons.logout_rounded,
              title: 'تسجيل الخروج',
              color: AppColors.error,
              onTap: () async {
                Navigator.pop(context);
                final shouldLogout = await _showLogoutConfirmationDialog(
                  context,
                );
                if (shouldLogout == true && context.mounted) {
                  await ref.read(authStateProvider.notifier).logout();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, User? user) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                user?.name ?? 'مستخدم',
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user?.phone ?? '',
                style: TextStyle(
                  color: AppColors.onPrimary.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: AppColors.textHint,
      ),
      onTap: onTap,
    );
  }

  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('سياسة الخصوصية'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'نحن نلتزم بحماية خصوصية معلوماتك الشخصية.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '• يتم جمع البيانات الضرورية فقط لتقديم الخدمة\n'
                '• لا يتم مشاركة بياناتك مع أطراف ثالثة دون موافقتك\n'
                '• يمكنك طلب حذف بياناتك في أي وقت\n'
                '• نستخدم إجراءات أمنية لحماية معلوماتك',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
//                        واجهة اختيار المدارس
// ===================================================================
class SchoolSelectionView extends ConsumerWidget {
  const SchoolSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolsAsync = ref.watch(mySchoolsProvider);

    return schoolsAsync.when(
      data: (schools) {
        if (schools.isEmpty) {
          return _buildEmptyState(
            icon: Icons.school_outlined,
            title: 'لا توجد مدارس',
            message: 'أنت غير مسجل في أي مدرسة بعد',
            actionLabel: 'تحديث',
            onRefresh: () => ref.refresh(mySchoolsProvider.future),
          );
        }
        print('Refreshing schools list...${schools.length} schools...');
        return RefreshIndicator(
          onRefresh: () => ref.refresh(mySchoolsProvider.future),
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          strokeWidth: 2.5,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildSchoolCard(context, ref, schools[index]),
                    childCount: schools.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      error: (err, _) => _buildErrorState(
        message: 'خطأ في تحميل المدارس',
        details: err.toString(),
        onRetry: () => ref.refresh(mySchoolsProvider.future),
      ),
      loading: () => _buildLoadingShimmer(),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Container(padding: const EdgeInsets.all(20)),
    );
  }

  Widget _buildSchoolCard(BuildContext context, WidgetRef ref, School school) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () =>
              ref.read(selectedSchoolProvider.notifier).selectSchool(school),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.name,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          school.publicCode ?? 'رمز المدرسة',
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary,
                    size: 16,
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================================================================
//                         واجهة عرض الطلاب
// ===================================================================
class StudentListView extends ConsumerWidget {
  const StudentListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsBySchoolProvider);

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return _buildEmptyState(
            icon: Icons.child_care_outlined,
            title: 'لا يوجد أبناء',
            message: 'لا يوجد أبناء مسجلين في هذه المدرسة',
            actionLabel: 'تحديث',
            onRefresh: () => ref.refresh(studentsBySchoolProvider.future),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(studentsBySchoolProvider.future),
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          strokeWidth: 2.5,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (_, index) =>
                StudentAttendanceCard(student: students[index], index: index),
          ),
        );
      },
      error: (err, _) => _buildErrorState(
        message: 'خطأ في جلب الأبناء',
        details: err.toString(),
        onRetry: () => ref.refresh(studentsBySchoolProvider.future),
      ),
      loading: () => _buildLoadingShimmer(),
    );
  }
}

// ===================================================================
//                          بطاقة عرض الطالب
// ===================================================================
class StudentAttendanceCard extends ConsumerWidget {
  final Student student;
  final int index;
  final locationService = LocationService();

  StudentAttendanceCard({super.key, required this.student, this.index = 0});

  Map<String, dynamic> _getStatusInfo(AttendanceStatus status) {
    print(
      'Determining status info for student ${student.name} with status: $status',
    );
    switch (status) {
      case AttendanceStatus.present:
        return {
          'color': AppColors.success,
          'icon': Icons.check_circle_rounded,
          'text': 'حاضر',
          'bg': AppColors.success.withOpacity(0.1),
        };
      case AttendanceStatus.absent:
        return {
          'color': AppColors.error,
          'icon': Icons.cancel_rounded,
          'text': 'غائب',
          'bg': AppColors.error.withOpacity(0.1),
        };
      case AttendanceStatus.late:
        return {
          'color': const Color(0xFFFF8C42),
          'icon': Icons.access_time_filled_rounded,
          'text': 'متأخر',
          'bg': const Color(0xFFFF8C42).withOpacity(0.1),
        };
      case AttendanceStatus.requested:
        return {
          'color': AppColors.primary,
          'icon': Icons.send_rounded,
          'text': 'تم الطلب',
          'bg': AppColors.primary.withOpacity(0.1),
        };
      case AttendanceStatus.at_gate:
        return {
          'color': AppColors.primaryDark,
          'icon': Icons.meeting_room_rounded,
          'text': 'عند البوابة',
          'bg': AppColors.primaryDark.withOpacity(0.1),
        };
      default:
        return {
          'color': AppColors.textHint,
          'icon': Icons.help_outline_rounded,
          'text': 'غير معروف',
          'bg': AppColors.textHint.withOpacity(0.1),
        };
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusInfo = _getStatusInfo(student.status);
    final bool canRequestPickup = student.status == AttendanceStatus.present;

    // استخدام provider خاص بكل طالب
    final pickupState = ref.watch(pickupRequestForStudentProvider(student.id));
    final isLoading = pickupState is AsyncLoading;

    // الاستماع للنتيجة
    ref.listen(pickupRequestForStudentProvider(student.id), (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${next.error}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else if (previous is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم إرسال طلب استلام لـ ${student.name}'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        ref.invalidate(studentsBySchoolProvider);
        Future.microtask(() => ref.refresh(studentsBySchoolProvider.future));
      }
    });
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutQuint,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Material(
          elevation: 2,
          shadowColor: AppColors.textHint.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // صورة الطالب
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: student.avatarUrl != null
                              ? NetworkImage(student.avatarUrl!)
                              : null,
                          backgroundColor: AppColors.primaryLight.withOpacity(
                            0.2,
                          ),
                          child: student.avatarUrl == null
                              ? Text(
                                  student.name[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: statusInfo['color'],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // معلومات الطالب
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusInfo['bg'],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  statusInfo['icon'],
                                  size: 14,
                                  color: statusInfo['color'],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  statusInfo['text'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: statusInfo['color'],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (canRequestPickup) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 0.5),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              // طلب الموقع
                              final position = await locationService
                                  .getCurrentLocation();
                              if (position == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '❌ لم نتمكن من الحصول على موقعك. تأكد من تفعيل GPS',
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }
                               ref
                                .read(pickupRequestForStudentProvider(student.id).notifier)
                                .sendRequest(
                                  lat: position.latitude,
                                  lng: position.longitude,
                                );
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        disabledBackgroundColor: AppColors.textHint.withOpacity(
                          0.3,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('جاري الإرسال...'),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('طلب استلام الآن'),
                              ],
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================================================================
//                      ويدجتس مساعدة (Helpers)
// ===================================================================

Widget _buildEmptyState({
  required IconData icon,
  required String title,
  required String message,
  required String actionLabel,
  required VoidCallback onRefresh,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(title, style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(actionLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildErrorState({
  required String message,
  required String details,
  required VoidCallback onRetry,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(message, style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            details,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildLoadingShimmer() {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 3,
    itemBuilder: (context, index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textHint.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
