// lib/presentation/widgets/location_disclosure.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myapp/core/services/privacy_consent_service.dart';
import 'package:myapp/core/theme/app_colors.dart';

/// إفصاح واضح (Prominent Disclosure) قبل طلب إذن الموقع من النظام،
/// كما تشترط سياسة بيانات المستخدم في Google Play.
/// ترجع true إذا كان مسموحاً بالمتابعة لطلب الإذن.
Future<bool> ensureLocationDisclosure(
  BuildContext context,
  WidgetRef ref,
) async {
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse) {
    return true;
  }

  final consent = ref.read(privacyConsentServiceProvider);
  if (await consent.hasAcceptedLocationDisclosure()) return true;
  if (!context.mounted) return false;

  final accepted =
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(
            Icons.location_on_rounded,
            color: AppColors.primary,
            size: 40,
          ),
          title: const Text('استخدام موقعك'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'يجمع تطبيق كيان موقعك الجغرافي عند إرسال طلب استلام ابنك، '
                'وذلك للتحقق من وجودك بالقرب من المدرسة وإبلاغ المعلم بوصولك.',
              ),
              const SizedBox(height: 8),
              const Text(
                '• يُستخدم الموقع فقط أثناء فتح التطبيق.\n'
                '• لا يتم تتبع موقعك في الخلفية.\n'
                '• يُرسل الموقع لخوادم المدرسة مع طلب الاستلام فقط.',
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => openPrivacyPolicy(context),
                child: const Text(
                  'سياسة الخصوصية',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ليس الآن'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('موافق'),
            ),
          ],
        ),
      ) ??
      false;

  if (accepted) await consent.acceptLocationDisclosure();
  return accepted;
}
