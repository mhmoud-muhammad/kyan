import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myapp/core/theme/text_styles.dart';
import 'package:myapp/domain/entities/active_request.dart';
import 'package:myapp/domain/entities/teacher_dashboard_stats.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';
import 'package:myapp/presentation/providers/teacher_provider.dart';
import 'package:myapp/core/theme/app_colors.dart';

class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key});

  Future<void> _refreshData(WidgetRef ref) async {
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(activeRequestsProvider);
  }

  void _showNotificationsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // للسماح للقائمة بأخذ مساحة أكبر إذا زادت الإشعارات
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height:
            MediaQuery.of(context).size.height *
            0.75, // عرض القائمة بنسبة 75% من الشاشة
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // شريط السحب العلوي للتجميل
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
                    onPressed: () {}, // دالة مسح الكل مثلاً
                    child: const Text('تحديد الكل كمقروء'),
                  ),
                ],
              ),
            ),
            const Divider(),
            // قائمة الإشعارات
            Expanded(
              child: ListView.separated(
                itemCount: 5, // استبدلها بعدد الإشعارات الحقيقي من الـ Provider
                padding: const EdgeInsets.all(15),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _buildNotificationItem(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت فرعي لتصميم شكل الإشعار الواحد
  Widget _buildNotificationItem(int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: index == 0
            ? AppColors.primary.withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              Icons.notifications_active,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلب استلام جديد',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'ولي أمر الطالب أحمد محمد وصل الآن عند البوابة',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            'منذ ٢د',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          // إرجاع أيقونة التنبيهات وجعلها قابلة للنقل
          // داخل AppBar -> actions:
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 28),
            onPressed: () => _showNotificationsPanel(
              context,
            ), // استدعاء اللوحة بدلاً من التنقل
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
              // قسم الترحيب وصورة المستخدم (قابلة للنقل)
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
      onTap: () => context.push('/profile'), // قابلة للنقل للملف الشخصي
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: user?.avatar != null
                  ? NetworkImage(user!.avatar!)
                  : null,
              child: user?.avatar == null
                  ? Icon(Icons.person, color: AppColors.primary, size: 30)
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'أستاذ كمال',
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
}

// =================== قسم الإحصائيات (تفعيل النقر) ===================
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
        childAspectRatio: 1.2, // تم تحسين النسبة لتناسب التصميم الجديد
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
      error: (err, _) => Text('خطأ في البيانات'),
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
      onTap: () =>
          context.push('/teacher/students-list/$type', extra: {'title': title}),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
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

// =================== قسم الطلبات النشطة (تفعيل تفاصيل الطلب) ===================
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
          data: (requests) => requests.isEmpty
              ? const Text('لا توجد طلبات حالياً')
              : ListView.separated(
                  itemCount: requests.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      ActiveRequestCard(request: requests[index]),
                ),
          loading: () => const CircularProgressIndicator(),
          error: (err, _) => const Text('خطأ في تحميل الطلبات'),
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
      onTap: () => _showRequestDetails(context, request), // تفعيل عرض التفاصيل
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'تفاصيل الاستلام',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 30),
            _detailRow(Icons.person, 'اسم الطالب', request.studentName),
            _detailRow(Icons.family_restroom, 'ولي الأمر', request.parentName),
            _detailRow(
              Icons.access_time,
              'وقت الطلب',
              DateFormat('hh:mm a').format(request.requestedAt),
            ),
            _detailRow(
              Icons.info_outline,
              'الحالة',
              request.status == 'REQUESTED' ? 'قيد الانتظار' : 'عند البوابة',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ... كود _AppDrawer و _CopyrightFooter كما هو في الكود السابق لديك
// --- القائمة الجانبية المحدثة ---
class _AppDrawer extends StatelessWidget {
  final User? user;
  const _AppDrawer({this.user});

  @override
  Widget build(BuildContext context) {
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
            () {},
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
            backgroundColor: Colors.white.withOpacity(0.2),
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
                    color: Colors.white.withOpacity(0.7),
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
        'حقوق النشر © ٢٠٢٤ - نظام الكيان التعليمي',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      ),
    );
  }
}
