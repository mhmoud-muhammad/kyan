// lib/core/router/go_router_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_router.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return appRouter; // استخدم appRouter الموجود لديك
});