// lib/presentation/screens/teacher/stats_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/theme/text_styles.dart';
import 'package:myapp/domain/entities/student.dart';
import 'package:myapp/presentation/providers/teacher/teacher_provider.dart';

class StatsDetailsScreen extends ConsumerStatefulWidget {
  const StatsDetailsScreen({super.key});

  @override
  ConsumerState<StatsDetailsScreen> createState() => _StatsDetailsScreenState();
}

class _StatsDetailsScreenState extends ConsumerState<StatsDetailsScreen> {
  late final String type;
  late final String title;
  late final Color color;

  @override
  void initState() {
    super.initState();
    // استخراج البيانات من extra بأمان بعد التأكد من أن context لا يزال صالحاً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final extra = GoRouterState.of(context).extra as Map<String, dynamic>;
        type = extra['type'] as String;
        title = extra['title'] as String;
        final colorValue = extra['color'];
        color = colorValue is int ? Color(colorValue) : Colors.blue;
        setState(() {}); // إعادة بناء الشاشة بعد تحميل البيانات
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;

    final type = (extra?['type'] as String?) ?? 'total';
    final title = (extra?['title'] as String?) ?? '';
    final colorValue = extra?['color'];
    final color = colorValue is int
        ? Color(colorValue)
        : (colorValue as Color? ?? Colors.blue);

    final studentsMap = ref.watch(webSocketStudentsProvider);
    final students = studentsFromMapByType(studentsMap, type);

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
          // الهيدر الإحصائي
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
                    const SizedBox(width: 10),
                    Text(
                      '${students.length}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

          // قائمة الطلاب
          Expanded(
            child: students.isEmpty
                ? Center(
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
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      return _buildStudentCard(students[index], color);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool get _isDataLoaded =>
      type != null &&
      title != null &&
      color != null; // بسيط: نتحقق من أن المتغيرات مُنشأة

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
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      student.status,
                      color,
                    ).withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(student.status),
                        size: 12,
                        color: _getStatusColor(student.status, color),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(student.status),
                        style: TextStyle(
                          fontSize: 11,
                          color: _getStatusColor(student.status, color),
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
      case AttendanceStatus.unknown:
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

// الدوال المساعدة خارج الكلاس (أو يمكن وضعها داخل الكلاس)
Color _getStatusColor(AttendanceStatus status, Color defaultColor) {
  switch (status) {
    case AttendanceStatus.present:
      return Colors.green;
    case AttendanceStatus.absent:
      return Colors.red;
    case AttendanceStatus.late:
      return Colors.orange;
    case AttendanceStatus.requested:
      return Colors.blue;
    case AttendanceStatus.atGate:
      return Colors.purple;
    case AttendanceStatus.delivered:
      return defaultColor;
    case AttendanceStatus.completed:
      return Colors.teal;
    case AttendanceStatus.unknown:
    default:
      return Colors.grey;
  }
}

IconData _getStatusIcon(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return Icons.check_circle;
    case AttendanceStatus.absent:
      return Icons.cancel;
    case AttendanceStatus.late:
      return Icons.access_time;
    case AttendanceStatus.requested:
      return Icons.send;
    case AttendanceStatus.atGate:
      return Icons.meeting_room;
    case AttendanceStatus.delivered:
      return Icons.local_shipping;
    case AttendanceStatus.completed:
      return Icons.verified;
    case AttendanceStatus.unknown:
    default:
      return Icons.help_outline;
  }
}
