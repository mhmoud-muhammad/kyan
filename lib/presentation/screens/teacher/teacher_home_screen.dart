// lib/presentation/screens/teacher/teacher_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/errors/error_handler.dart';
import 'package:myapp/core/network/connectivity_provider.dart';
// import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/theme/text_styles.dart';
import 'package:myapp/domain/entities/active_request.dart';
import 'package:myapp/domain/entities/student.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/presentation/providers/auth/auth_provider.dart';
import 'package:myapp/presentation/providers/teacher/teacher_provider.dart';
import 'package:myapp/presentation/widgets/app_error_view.dart';

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
      //ref.read(webSocketListenerProvider);
    });
  }

  Future<void> _connectWebSocket() async {
    if (_wsInitialized) return;

    // 1) تحقق من وجود مستخدم
    final auth = ref.read(authStateProvider);
    final user = auth.value;
    if (user == null) {
      debugPrint('⛔ [WS] user is null, skip connect');
      return;
    }

    // 2) تحقق من الإنترنت (من مزودك)
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) {
      debugPrint('🌐 [WS] No internet -> skip connect');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ لا يوجد اتصال بالإنترنت'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _wsInitialized = true;

    try {
      final service = ref.read(websocketConnectionProvider);

      // 3) اتصال WS
      await service.connectTeacher();

      // (اختياري) رسالة نجاح للمراجعة فقط
      debugPrint('🟢 [WS] connect ok');
    } catch (e) {
      debugPrint('❌ [WS] connect error: $e');

      // 4) حول الاستثناء إلى رسالة مناسبة واعرضها للمستخدم
      if (mounted) {
        final msg = failureMessage(e);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $msg'), backgroundColor: Colors.red),
        );

        // (اختياري) لو Unauthorized: وجهه للّوجن
        // if (failure is UnauthorizedFailure) {
        //   // مثال:
        //   context.go('/login');
        //   // أو اعرض Dialog
        // }
      }

      // 6) اسمح بمحاولة لاحقة
      _wsInitialized = false;
    }
  }

  Future<void> _refreshData(WidgetRef ref) async {
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(activeRequestsProvider);
  }

  @override
  void dispose() {
    //ref.read(teacherWebSocketServiceProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isOnlineProvider, (prev, next) {
      if (next == true) {
        // رجع الإنترنت -> وصل WS + حدّث REST
        ref.read(websocketConnectionProvider).connectTeacher(force: true);
        ref.invalidate(activeRequestsProvider);
        ref.invalidate(dashboardStatsProvider);
      }
    });
    ref.watch(webSocketListenerProvider); // ✅ يخلي الـ listener شغال
    ref.watch(webSocketStudentsProvider);
    final m = ref.watch(webSocketStudentsProvider);
    debugPrint(
      'WS map keys=${m.keys} requested=${m['requested']?.length ?? 0}',
    ); // ✅ أضف هذا السطر (يحافظ على state)

    final user = ref.watch(authStateProvider).value;
    final isOnline = ref.watch(isOnlineProvider);

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
              if (!isOnline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'لا يوجد اتصال بالإنترنت — سيتم المحاولة تلقائياً عند عودة الاتصال',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
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
            ref: ref,
            title: 'إجمالي الطلاب',
            value: stats.total.toString(),
            icon: Icons.groups_rounded,
            color: AppColors.primary,
            type: 'total',
          ),
          _buildStatCard(
            context,
            ref: ref,
            title: 'حاضر الآن',
            value: stats.present.toString(),
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
            type: 'present',
          ),
          _buildStatCard(
            context,
            ref: ref,
            title: 'قيد الطلب',
            value: stats.requested.toString(),
            icon: Icons.hourglass_top_rounded,
            color: const Color(0xFFFF8C42),
            type: 'requested',
          ),
          _buildStatCard(
            context,
            ref: ref,
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
    required WidgetRef ref, // ⬅️ أضف ref
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String type,
  }) {
    return InkWell(
      onTap: () {
        context.push(
          '/teacher/students-list/$type',
          // extra: {
          //   'title': title,
          //   'type': type,
          //   'color': color.withBlue(1),
          // },
        );
      },
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
    final requestsAsync = ref.watch(unifiedActiveRequestsProvider);
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
          error: (err, _) => AppErrorView(
            error: err,
            onRetry: () => ref.refresh(activeRequestsProvider),
          ),
        ),
      ],
    );
  }
}

class ActiveRequestCard extends ConsumerWidget {
  final ActiveRequest request;
  const ActiveRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveringIds = ref.watch(deliveringRequestIdsProvider);
    final isLoading = deliveringIds.contains(request.studentId);

    return Container(
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
          CircleAvatar(
            child: Text(
              request.studentName.isNotEmpty ? request.studentName[0] : '?',
            ),
          ),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.studentName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ✅ زر إتمام التسليم مباشرة
          ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 110, height: 38),
            child: ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () async => _deliverNow(context, ref, request),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline, size: 18),
              label: Text(isLoading ? '...' : 'تسليم'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deliverNow(
    BuildContext context,
    WidgetRef ref,
    ActiveRequest request,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    if (request.studentId <= 0) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('معرف الطالب غير صالح'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ منع الضغط المتكرر
    final delivering = ref.read(deliveringRequestIdsProvider);
    ref.read(deliveringRequestIdsProvider.notifier).state = {
      ...delivering,
      request.studentId,
    };

    // ✅ Optimistic UI: احذف الطلب فورًا
    ref
        .read(webSocketActiveRequestsProvider.notifier)
        .removeByStudentId(request.studentId);
    ref
        .read(webSocketStudentsProvider.notifier)
        .updateStudentStatusLocal(
          request.studentId,
          AttendanceStatus.delivered,
        );
    ref.invalidate(dashboardStatsProvider);

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
          // ❌ رجّع الطلب لو فشل
          ref.read(webSocketActiveRequestsProvider.notifier).upsert(request);
          ref
              .read(webSocketStudentsProvider.notifier)
              .updateStudentStatusLocal(
                request.studentId,
                AttendanceStatus.requested,
              );
          ref.invalidate(dashboardStatsProvider);

          messenger.showSnackBar(
            SnackBar(
              content: Text('❌ ${failureMessage(failure)}'),
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

          // fallback: لو REST هو المصدر
          ref.invalidate(activeRequestsProvider);
        },
      );
    } catch (e) {
      // ✅ حول أي Exception إلى رسالة مناسبة
      final msg = failureMessage(e);

      // ❌ رجّع الطلب لأن العملية فشلت
      ref.read(webSocketActiveRequestsProvider.notifier).upsert(request);
      ref
          .read(webSocketStudentsProvider.notifier)
          .updateStudentStatusLocal(
            request.studentId,
            AttendanceStatus.requested,
          );
      ref.invalidate(dashboardStatsProvider);

      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ $msg'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // ✅ فكّ اللودنج دائمًا
      final current = ref.read(deliveringRequestIdsProvider);
      final copy = {...current}..remove(request.studentId);
      ref.read(deliveringRequestIdsProvider.notifier).state = copy;
    }
  }
}

// =================== القائمة الجانبية ===================
class _AppDrawer extends ConsumerWidget {
  final User? user;
  const _AppDrawer({this.user});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authStateProvider);
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
// ===================  حقوق النشر ===================

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

        // ===== الأزرار في صف واحد بنفس الحجم =====
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('إلغاء'),
                ),
              ),
              const SizedBox(width: 8), // مسافة بين الزرين
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
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
