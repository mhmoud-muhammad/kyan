// lib/main.dart
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/kyan.dart';

// Provider للوصول إلى مثيل الإشعارات في أي مكان
final flutterLocalNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
      throw UnimplementedError('Must be overridden after initialization');
    });

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إعدادات الإشعارات
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
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

  // طلب أذونات iOS إذا لزم الأمر
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // تجاوز قيمة provider بالمثيل الذي أنشأناه
  final container = ProviderContainer(
    overrides: [
      flutterLocalNotificationsPluginProvider.overrideWithValue(
        flutterLocalNotificationsPlugin,
      ),
    ],
  );

  runApp(
    UncontrolledProviderScope(container: container, child: const KyanApp()),
  );
}

class KyanApp extends StatelessWidget {
  const KyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

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
