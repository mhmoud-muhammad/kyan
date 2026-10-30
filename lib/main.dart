// lib/main.dart
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/kyan.dart';
import 'core/errors/error_handler.dart';
import 'presentation/widgets/app_error_view.dart';
// إذا عندك apiClientProvider هنا (مثال)
import 'package:myapp/presentation/providers/auth/auth_provider.dart';

// طلب إذن الإشعارات (يُستدعى بعد الموافقة على سياسة الخصوصية)
Future<void> requestNotificationPermissions(
  FlutterLocalNotificationsPlugin plugin,
) async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }
}

// Provider للوصول إلى مثيل الإشعارات في أي مكان
final flutterLocalNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
      throw UnimplementedError('Must be overridden after initialization');
    });

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupGlobalErrorHandling();

  // إعدادات الإشعارات
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // إنشاء مثيل الإشعارات وتهيئته باستخدام المعامل المسمى settings
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    // يمكنك إضافة معالج للنقر على الإشعارات هنا إذا أردت
    // onDidReceiveNotificationResponse: (NotificationResponse response) {},
  );
  // ملاحظة: إذن الإشعارات يُطلب بعد موافقة المستخدم على سياسة الخصوصية
  // (انظر requestNotificationPermissions و SplashScreen)

  // تجاوز قيمة provider بالمثيل الذي أنشأناه
  final container = ProviderContainer(
    overrides: [
      flutterLocalNotificationsPluginProvider.overrideWithValue(
        flutterLocalNotificationsPlugin,
      ),
    ],
  );
  // بعد إنشاء container مباشرة:
  final apiClient = container.read(apiClientProvider);

  // ✅ عند فشل تجديد الجلسة: امسح بيانات الدخول وارجع لصفحة الدخول
  apiClient.onLogoutRequired.listen((_) async {
    await container.read(authStateProvider.notifier).sessionExpired();
    appRouter.go('/login');
    _showGlobalMessage('انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى');
  });

  runApp(
    UncontrolledProviderScope(container: container, child: const KyanApp()),
  );
}

/// مفتاح عام لعرض رسائل SnackBar من خارج الشاشات (مثل انتهاء الجلسة)
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void _showGlobalMessage(String message) {
  scaffoldMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}

/// التقاط أي خطأ غير معالج حتى لا يتوقف التطبيق أو تظهر شاشة حمراء/رمادية
void _setupGlobalErrorHandling() {
  // أخطاء إطار Flutter (أثناء البناء والرسم)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logError(details.exception, details.stack, tag: 'FlutterError');
  };

  // أخطاء async غير معالجة
  PlatformDispatcher.instance.onError = (error, stack) {
    logError(error, stack, tag: 'Uncaught');
    return true; // تم التعامل معه، لا تُغلق التطبيق
  };

  // بدل الشاشة الحمراء/الرمادية عند فشل بناء Widget في نسخة النشر
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const AppErrorView.compact();
  }
}

class KyanApp extends StatelessWidget {
  const KyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,

      // Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'AE'), // العربية
      ],
      locale: const Locale('ar', 'AE'),

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: null,
      themeMode: ThemeMode.light,

      // Router
      routerConfig: appRouter,
    );
  }
}
