// lib/presentation/widgets/app_error_view.dart
import 'package:flutter/material.dart';
import 'package:myapp/core/errors/error_handler.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/core/theme/app_colors.dart';

/// واجهة موحدة لعرض الأخطاء: أيقونة حسب نوع الخطأ + رسالة + زر إعادة المحاولة
class AppErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback? onRetry;
  final bool _compact;

  const AppErrorView({super.key, required this.error, this.onRetry})
    : _compact = false;

  /// نسخة مصغرة تُستخدم بدل الشاشة الحمراء عند فشل بناء جزء من الواجهة
  const AppErrorView.compact({super.key})
    : error = null,
      onRetry = null,
      _compact = true;

  IconData _iconFor(Failure f) {
    if (f is TimeoutFailure) return Icons.hourglass_empty_rounded;
    if (f is NetworkFailure) return Icons.wifi_off_rounded;
    if (f is UnauthorizedFailure || f is ForbiddenFailure) {
      return Icons.lock_outline_rounded;
    }
    if (f is LocationFailure || f is PermissionFailure) {
      return Icons.location_off_rounded;
    }
    if (f is NotFoundFailure) return Icons.search_off_rounded;
    if (f is ServerFailure) return Icons.cloud_off_rounded;
    return Icons.error_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (_compact) {
      return const Material(
        color: Colors.transparent,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'تعذر عرض هذا الجزء',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    final failure = asFailure(error);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha((0.08 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconFor(failure), color: AppColors.error, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              failureMessage(failure),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
