// lib/core/services/privacy_consent_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myapp/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

/// يحفظ موافقة المستخدم على سياسة الخصوصية وإفصاح الموقع.
/// لا يتم مسحها عند تسجيل الخروج (تخص الجهاز وليس الحساب).
class PrivacyConsentService {
  final FlutterSecureStorage storage;
  const PrivacyConsentService(this.storage);

  Future<bool> hasAcceptedPrivacyPolicy() async {
    try {
      final version = await storage.read(key: AppConstants.privacyAcceptedKey);
      return version == AppConstants.privacyPolicyVersion;
    } catch (_) {
      return false;
    }
  }

  Future<void> acceptPrivacyPolicy() {
    return storage.write(
      key: AppConstants.privacyAcceptedKey,
      value: AppConstants.privacyPolicyVersion,
    );
  }

  Future<bool> hasAcceptedLocationDisclosure() async {
    try {
      return await storage.read(key: AppConstants.locationDisclosureKey) ==
          'true';
    } catch (_) {
      return false;
    }
  }

  Future<void> acceptLocationDisclosure() {
    return storage.write(
      key: AppConstants.locationDisclosureKey,
      value: 'true',
    );
  }
}

final privacyConsentServiceProvider = Provider<PrivacyConsentService>((ref) {
  return const PrivacyConsentService(FlutterSecureStorage());
});

/// يفتح صفحة سياسة الخصوصية في المتصفح
Future<void> openPrivacyPolicy(BuildContext context) async {
  final uri = Uri.parse(AppConstants.privacyPolicyUrl);
  bool opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('❌ openPrivacyPolicy error: $e');
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تعذر فتح الرابط: ${AppConstants.privacyPolicyUrl}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
