// lib/presentation/screens/guardian/guardian_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/domain/entities/school.dart';
import 'package:myapp/domain/entities/student.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';
import 'package:myapp/presentation/providers/guardian_provider.dart';

// تعريف ألوان أساسية لتحسين التناسق
final _primaryColor = Colors.blue.shade800;
final _lightBackgroundColor = Colors.grey.shade100;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final selectedSchool = ref.watch(selectedSchoolProvider);
    final user = authState.value;

    return Scaffold(
      backgroundColor: _lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          selectedSchool == null ? 'مدارسي' : selectedSchool.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        // تغيير الأيقونة لتفتح القائمة الجانبية أو للرجوع
        leading: selectedSchool != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => ref.read(selectedSchoolProvider.notifier).clearSelection(),
              )
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded, size: 28),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
      ),
      // ✅ إضافة القائمة الجانبية
      drawer: _AppDrawer(user: user),
      body: SafeArea(
        child: authState.when(
          data: (userData) {
            if (userData == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
              return const SizedBox.shrink();
            }
            // ✅ استخدام AnimatedSwitcher لتجربة انتقال أفضل
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: selectedSchool == null
                  ? const SchoolSelectionView(key: ValueKey('schools'))
                  : const StudentListView(key: ValueKey('students')),
            );
          },
          error: (error, _) => _buildErrorWidget('خطأ في المصادقة: $error'),
          loading: () => const Center(child: CircularProgressIndicator()),
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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context, user),
          const SizedBox(height: 10),
          _buildDrawerItem(
            context: context,
            icon: Icons.person_outline,
            text: 'الملف الشخصي',
            onTap: () => context.push('/profile'),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.settings_outlined,
            text: 'الإعدادات',
            onTap: () => context.push('/settings'),
          ),
          const Divider(height: 20, indent: 20, endIndent: 20),
          _buildDrawerItem(
            context: context,
            icon: Icons.logout,
            text: 'تسجيل الخروج',
            color: Colors.red.shade700,
            onTap: () async {
              Navigator.pop(context); // إغلاق القائمة أولاً
              final shouldLogout = await _showLogoutConfirmationDialog(context);
              if (shouldLogout == true && context.mounted) {
                ref.read(authStateProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, User? user) {
    return UserAccountsDrawerHeader(
      accountName: Text(
        user?.name ?? 'مستخدم',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      accountEmail: Text(user?.phone ?? ''),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: user?.avatar != null ? NetworkImage(user!.avatar!) : null,
        child: user?.avatar == null
            ? Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 28, color: _primaryColor, fontWeight: FontWeight.bold),
              )
            : null,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? Theme.of(context).textTheme.bodyLarge?.color;
    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(text, style: TextStyle(color: itemColor, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تأكيد الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}


// ... (بقية الكود: SchoolSelectionView, StudentListView, StudentAttendanceCard, Helpers)
// يبقى كما هو من الرد السابق، فقد كان تصميمها جيدًا بالفعل.
// سأقوم بإدراجه هنا مرة أخرى للتأكد من اكتمال الملف.

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
            message: 'أنت غير مسجل في أي مدرسة بعد.',
            onRefresh: () => ref.refresh(mySchoolsProvider.future),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(mySchoolsProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'اختر المدرسة لعرض أبنائك',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ...schools.map((school) => _buildSchoolCard(context, ref, school)),
            ],
          ),
        );
      },
      error: (err, _) => _buildErrorWidget('خطأ في جلب المدارس: $err'),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildSchoolCard(BuildContext context, WidgetRef ref, School school) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: _primaryColor.withOpacity(0.1),
          child: Icon(Icons.school, color: _primaryColor),
        ),
        title: Text(school.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(school.publicCode ?? 'لا يوجد كود', style: TextStyle(color: Colors.grey.shade600)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 18),
        onTap: () => ref.read(selectedSchoolProvider.notifier).selectSchool(school),
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
            message: 'لا يوجد أبناء مسجلين في هذه المدرسة.',
            onRefresh: () => ref.refresh(studentsBySchoolProvider.future),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(studentsBySchoolProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (_, index) => StudentAttendanceCard(student: students[index]),
          ),
        );
      },
      error: (err, _) => _buildErrorWidget('خطأ في جلب الأبناء: $err'),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

// ===================================================================
//                          بطاقة عرض الطالب
// ===================================================================
class StudentAttendanceCard extends ConsumerWidget {
  final Student student;
  const StudentAttendanceCard({super.key, required this.student});

  Map<String, dynamic> _getStatusInfo(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return {'color': Colors.green.shade700, 'icon': Icons.check_circle, 'text': 'حاضر'};
      case AttendanceStatus.absent:
        return {'color': Colors.red.shade700, 'icon': Icons.cancel, 'text': 'غائب'};
      case AttendanceStatus.late:
        return {'color': Colors.orange.shade700, 'icon': Icons.access_time_filled, 'text': 'متأخر'};
      case AttendanceStatus.requested:
        return {'color': Colors.blue.shade700, 'icon': Icons.send_rounded, 'text': 'تم الطلب'};
      case AttendanceStatus.at_gate:
        return {'color': Colors.purple.shade700, 'icon': Icons.meeting_room, 'text': 'عند البوابة'};
      default:
        return {'color': Colors.grey.shade600, 'icon': Icons.help_outline, 'text': 'غير معروف'};
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusInfo = _getStatusInfo(student.status);
    final bool canRequestPickup = student.status == AttendanceStatus.present;

    ref.listen(pickupRequestProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال الطلب: ${next.error}')),
        );
      } else if (previous is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إرسال طلب استلام لـ ${student.name} بنجاح!')),
        );
        ref.invalidate(studentsBySchoolProvider);
      }
    });

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null,
                  child: student.avatarUrl == null ? const Icon(Icons.person, size: 30) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    student.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(statusInfo['icon'], color: statusInfo['color'], size: 30),
                    const SizedBox(height: 4),
                    Text(
                      statusInfo['text'],
                      style: TextStyle(color: statusInfo['color'], fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            if (canRequestPickup) ...[
              const Divider(height: 24, thickness: 0.5),
              SizedBox(
                width: double.infinity,
                child: Consumer(
                  builder: (context, ref, child) {
                    final pickupState = ref.watch(pickupRequestProvider);
                    final isLoading = pickupState is AsyncLoading;

                    return ElevatedButton.icon(
                      icon: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.directions_walk, size: 20),
                      label: Text(isLoading ? 'جاري الإرسال...' : 'طلب استلام الآن'),
                      onPressed: isLoading
                          ? null
                          : () {
                              ref.read(pickupRequestProvider.notifier).sendRequest(student.id);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    );
                  },
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

// ===================================================================
//                      ويدجتس مساعدة (Helpers)
// ===================================================================

Widget _buildEmptyState({required IconData icon, required String message, required VoidCallback onRefresh}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(message, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('إعادة المحاولة'),
          onPressed: onRefresh,
          style: ElevatedButton.styleFrom(
            foregroundColor: _primaryColor,
            backgroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}

Widget _buildErrorWidget(String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
        ],
      ),
    ),
  );
}
