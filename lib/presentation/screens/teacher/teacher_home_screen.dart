// lib/presentation/screens/teacher/teacher_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
// import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/core/services/websocket_service.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/theme/text_styles.dart';
import 'package:myapp/domain/entities/active_request.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/presentation/providers/auth/auth_provider.dart';
import 'package:myapp/presentation/providers/teacher/teacher_provider.dart';

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  bool _wsInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectWebSocket();
    });
  }

  Future<void> _connectWebSocket() async {
    if (_wsInitialized) return;
    _wsInitialized = true;
    try {
      // بدء اتصال WebSocket
      await ref.read(websocketServiceProvider).connectTeacher();
      // تفعيل مستمع الإشعارات
      ref.read(webSocketListenerProvider);
    } catch (e) {
      //print('❌ فشل الاتصال بـ WebSocket: $e');
    }
  }

  Future<void> _refreshData(WidgetRef ref) async {
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(activeRequestsProvider);
  }

  @override
  void dispose() {
    ref.read(websocketServiceProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          // أيقونة الإشعارات تعرض العدد
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, size: 28),
                onPressed: () => _showNotificationsPanel(context),
              ),
              // نقطة حمراء إذا كانت هناك إشعارات غير مقروءة
              Consumer(
                builder: (context, ref, child) {
                  final notifications = ref.watch(
                    webSocketNotificationsProvider,
                  );
                  if (notifications.isEmpty) return const SizedBox.shrink();
                  return Positioned(
                    left: 30,
                    bottom: 18,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.onPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
      ),
      drawer: _AppDrawer(user: user),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(ref),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(context, user),
              const SizedBox(height: 25),
              const StatsSection(),
              const SizedBox(height: 30),
              const ActiveRequestsSection(),
              const SizedBox(height: 30),
              const Center(child: _CopyrightFooter()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, User? user) {
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? ' المعلم ',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsPanel(BuildContext context) {
    final notifications = ref.read(webSocketNotificationsProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // شريط السحب
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'التنبيهات',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(webSocketNotificationsProvider.notifier)
                          .clearAll();
                    },
                    child: const Text('تحديد الكل كمقروء'),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(child: Text('لا توجد إشعارات'))
                  : ListView.separated(
                      itemCount: notifications.length,
                      padding: const EdgeInsets.all(15),
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _buildNotificationItem(notification, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    final message = notification['message'] ?? 'إشعار جديد';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: index == 0
            ? AppColors.primary.withAlpha((0.05 * 255).round())
            : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withAlpha((0.1 * 255).round()),
            child: Icon(
              Icons.notifications_active,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إشعار جديد',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            'الآن',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// =================== قسم الإحصائيات ===================
class StatsSection extends ConsumerWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    return statsAsync.when(
      data: (stats) => GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.2,
        children: [
          _buildStatCard(
            context,
            title: 'إجمالي الطلاب',
            value: stats.total.toString(),
            icon: Icons.groups_rounded,
            color: AppColors.primary,
            type: 'total',
          ),
          _buildStatCard(
            context,
            title: 'حاضر الآن',
            value: stats.present.toString(),
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
            type: 'present',
          ),
          _buildStatCard(
            context,
            title: 'قيد الطلب',
            value: stats.requested.toString(),
            icon: Icons.hourglass_top_rounded,
            color: const Color(0xFFFF8C42),
            type: 'requested',
          ),
          _buildStatCard(
            context,
            title: 'عند البوابة',
            value: stats.atGate.toString(),
            icon: Icons.meeting_room_rounded,
            color: AppColors.primaryDark,
            type: 'atGate',
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('خطأ في تحميل الإحصائيات: $err')),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String type,
  }) {
    return InkWell(
      onTap: null,
      /*type == 'total'
          ? null // غير قابلة للنقر حالياً
          : () => context.push(
              '/teacher/students-list/$type',
              extra: {'title': title},
            ),*/
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((0.3 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =================== قسم الطلبات النشطة ===================
class ActiveRequestsSection extends ConsumerWidget {
  const ActiveRequestsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(activeRequestsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الطلبات النشطة', style: AppTextStyles.heading2),
        const SizedBox(height: 15),
        requestsAsync.when(
          data: (requests) {
            if (requests.isEmpty) {
              return const Center(child: Text('لا توجد طلبات نشطة حالياً'));
            }
            return ListView.separated(
              itemCount: requests.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  ActiveRequestCard(request: requests[index]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 8),
                Text('فشل تحميل الطلبات: $err'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.refresh(activeRequestsProvider),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ActiveRequestCard extends StatelessWidget {
  final ActiveRequest request;
  const ActiveRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showRequestDetails(context, request),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColors.primary.withAlpha((0.1 * 255).round()),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(child: Text(request.studentName[0])),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.studentName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ولي الأمر: ${request.parentName}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  void _showRequestDetails(BuildContext context, ActiveRequest request) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'تفاصيل الاستلام',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
            ),
            const Divider(height: 40, thickness: 1),
            _detailRow(
              Icons.person_outline_rounded,
              'اسم الطالب',
              request.studentName,
            ),
            _detailRow(
              Icons.family_restroom_outlined,
              'ولي الأمر',
              request.parentName,
            ),
            _detailRow(
              Icons.access_time_rounded,
              'وقت الطلب',
              DateFormat('hh:mm a').format(request.requestedAt),
            ),
            _detailRow(
              Icons.info_outline_rounded,
              'الحالة',
              _getStatusText(request.status),
            ),
            const SizedBox(height: 35),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'إغلاق',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Consumer(
                    builder: (context, ref, child) {
                      return ElevatedButton(
                        onPressed: () async {
                          // الحصول على ScaffoldMessenger من الـ Navigator context (الذي يمثل الشاشة الرئيسية)
                          final messenger = ScaffoldMessenger.of(
                            Navigator.of(context).context,
                          );

                          // إغلاق الـ bottom sheet فوراً
                          Navigator.pop(context);

                          // التحقق من صحة الطالب بعد الإغلاق
                          if (request.studentId <= 0) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('معرف الطالب غير صالح'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          try {
                            final result = await ref.read(
                              updateStudentStatusProvider(
                                UpdateStatusParams(
                                  studentId: request.studentId,
                                  newStatus: 'DELIVERED',
                                ),
                              ).future,
                            );

                            result.fold(
                              (failure) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('❌ ${failure.message}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                              (_) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ تم إتمام التسليم بنجاح'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                ref.invalidate(activeRequestsProvider);
                              },
                            );
                          } catch (e) {
                            // في حالة حدوث استثناء غير متوقع
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('❌ حدث خطأ غير متوقع: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'إتمام التسليم',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'REQUESTED':
        return 'قيد الانتظار';
      case 'AT_GATE':
        return 'عند البوابة';
      case 'DELIVERED':
        return 'تم التسليم';
      default:
        return status;
    }
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// =================== القائمة الجانبية ===================
class _AppDrawer extends ConsumerWidget {
  final User? user;
  const _AppDrawer({this.user, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(25)),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(),
          const SizedBox(height: 20),
          _buildDrawerItem(
            Icons.person_outline_rounded,
            'الملف الشخصي',
            () => context.push('/profile'),
          ),
          _buildDrawerItem(
            Icons.settings_outlined,
            'الإعدادات',
            () => context.push('/settings'),
          ),
          _buildDrawerItem(Icons.privacy_tip_outlined, 'الخصوصية', () {}),
          const Spacer(),
          const Divider(),
          _buildDrawerItem(
            Icons.logout_rounded,
            'تسجيل الخروج',
            () => showLogoutConfirmation(context, ref),
            isExit: true,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white.withAlpha((0.2 * 255).round()),
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'المعلم',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.phone ?? '',
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.7 * 255).round()),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isExit = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isExit ? Colors.redAccent : AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isExit ? Colors.redAccent : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _CopyrightFooter extends StatelessWidget {
  const _CopyrightFooter();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'حقوق النشر © 2026 - نظام الكيان التعليمي',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      ),
    );
  }
}

Future<void> showLogoutConfirmation(BuildContext context, WidgetRef ref) async {
  final bool? confirm = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

        // ===== العنوان مع أيقونة =====
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text(
              'تسجيل الخروج',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),

        // ===== المحتوى =====
        content: const Text(
          'سيتم إنهاء جلستك الحالية ولن تصلك إشعارات حتى تقوم بتسجيل الدخول مرة أخرى.\n\nهل ترغب بالمتابعة؟',
          style: TextStyle(height: 1.4),
        ),

        // ===== الأزرار =====
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('إلغاء'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );

  // ===== تنفيذ الخروج =====
  if (confirm == true) {
    await ref.read(authStateProvider.notifier).logout();

    if (context.mounted) {
      context.go('/login');
    }
  }
}
