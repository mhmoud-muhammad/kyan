// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/kyan.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //final storage = const FlutterSecureStorage();

  runApp(const ProviderScope(child: KyanApp()));
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
      darkTheme: AppTheme.lightTheme, // Using light theme for both modes in this example
      themeMode: ThemeMode.light,

      // Router
      routerConfig: appRouter,
    );
  }
}
