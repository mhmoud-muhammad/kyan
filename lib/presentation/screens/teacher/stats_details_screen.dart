// lib/presentation/screens/teacher/stats_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/theme/text_styles.dart';
import 'package:myapp/domain/entities/student.dart';
import 'package:myapp/presentation/providers/teacher/teacher_provider.dart';

class StatsDetailsScreen extends ConsumerWidget {
  const StatsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>;
    final type = extra['type'] as String;
    final title = extra['title'] as String;
    final color = Color(extra['color'] as int);

    // ✅ جلب الطلاب حسب النوع (يتكامل مع DummyData أو API حسب البيئة)
    final studentsAsync = ref.watch(studentsByStatusProvider(type));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Header إحصائي (يبقى كما هو مع إضافة العدد)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getIconForType(type), color: Colors.white, size: 40),
                    // بدلاً من استخدام extra['count']
                    studentsAsync.when(
                      data: (students) {
                        final actualCount = students.length;
                        return Text(
                          '$actualCount', // الآن الرقم حقيقي
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (_, _) => Text('0'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ✅ قائمة الطلاب (تظهر تحت الهيدر)
          Expanded(
            child: studentsAsync.when(
              data: (students) {
                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا يوجد طلاب في هذه الفئة',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    return _buildStudentCard(students[index], color);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'خطأ في تحميل الطلاب',
                      style: TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      err.toString(),
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ بطاقة عرض الطالب
  Widget _buildStudentCard(Student student, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // صورة الطالب (أيقونة)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.child_care_rounded, color: color, size: 30),
          ),
          const SizedBox(width: 12),

          // معلومات الطالب
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (student.schoolName != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        student.schoolName!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
                // عرض حالة الطالب
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(student.status),
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ تحويل حالة الطالب إلى نص عربي
  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'حاضر';
      case AttendanceStatus.absent:
        return 'غائب';
      case AttendanceStatus.late:
        return 'متأخر';
      case AttendanceStatus.requested:
        return 'قيد الطلب';
      case AttendanceStatus.atGate:
        return 'عند البوابة';
      case AttendanceStatus.delivered:
        return 'تم التسليم';
      case AttendanceStatus.completed:
        return 'مكتمل';
      default:
        return 'غير معروف';
    }
  }

  // ✅ أيقونة حسب نوع الإحصائية
  IconData _getIconForType(String type) {
    switch (type) {
      case 'total':
        return Icons.groups_rounded;
      case 'present':
        return Icons.check_circle_rounded;
      case 'requested':
        return Icons.send_rounded;
      case 'atGate':
        return Icons.meeting_room_rounded;
      case 'delivered':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.bar_chart_rounded;
    }
  }
}
