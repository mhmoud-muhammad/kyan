// lib/core/network/connectivity_provider.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final list = ref.watch(connectivityProvider).value;
  if (list == null) return true; // أو false حسب ما تفضل
  return !list.contains(ConnectivityResult.none);
});