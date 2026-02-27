// lib/core/services/websocket_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:myapp/presentation/providers/auth/auth_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod/riverpod.dart';
import '../constants/api_constants.dart';

class WebSocketService {
  final FlutterSecureStorage storage;
  WebSocketChannel? _channel;

  final _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  WebSocketService(this.storage);

  Future<void> connectTeacher() async {
    debugPrint('🟡 [WS] Starting teacher WebSocket connection...');

    final token = await storage.read(key: ApiConstants.accessTokenKey);

    if (token == null || token.isEmpty) {
      debugPrint('🔴 [WS] No auth token found!');
      throw Exception('No authentication token');
    }

    debugPrint('🟢 [WS] Token loaded successfully');

    // تحويل https → ws
    final domain = ApiConstants.domain.trim();
    final wsBase = domain.replaceFirst(
      RegExp(r'^https?:\/\/'),
      domain.startsWith('https://') ? 'wss://' : 'ws://',
    );

    final url = '$wsBase/ws/pickup/teacher/';
    final uri = Uri.parse('$url?token=$token');

    debugPrint('🌐 [WS] Connecting to: $uri');

    try {
      _channel = WebSocketChannel.connect(uri);

      debugPrint('🟢 [WS] WebSocket connected successfully');

      _channel!.stream.listen(
        (message) {
          debugPrint('📩 [WS] Raw message received: $message');

          try {
            final decoded = jsonDecode(message);
            

            if (decoded is Map<String, dynamic>) {
              debugPrint('✅ [WS] JSON decoded successfully');
              debugPrint('🧩 [WS] Payload keys: ${decoded.keys}');
              _messageController.add(decoded);
            } else {
              debugPrint('⚠️ [WS] Message is not a Map<String, dynamic>');
            }
          } catch (e, stack) {
            debugPrint('❌ [WS] JSON decode error: $e');
            debugPrint('📚 [WS] Stack trace:\n$stack');
          }
        },
        onError: (error, stack) {
          debugPrint('❌ [WS] Stream error: $error');
          if (stack != null) {
            debugPrint('📚 [WS] Stack trace:\n$stack');
          }
        },
        onDone: () {
          final closeCode = _channel?.closeCode;
          debugPrint('🔌 [WS] Connection closed');
          debugPrint('ℹ️ [WS] Close code: $closeCode');

          switch (closeCode) {
            case 4003:
              debugPrint('🚫 [WS] Invalid token (4003)');
              break;
            case 1000:
              debugPrint('✅ [WS] Normal closure (1000)');
              break;
            default:
              debugPrint('⚠️ [WS] Unexpected close code');
          }
        },
      );
    } catch (e, stack) {
      debugPrint('🔥 [WS] Failed to connect WebSocket');
      debugPrint('❌ Error: $e');
      debugPrint('📚 Stack trace:\n$stack');
      rethrow;
    }
  }

  void disconnect() {
    debugPrint('🔌 [WS] Disconnecting WebSocket...');
    _channel?.sink.close();
  }

  void dispose() {
    debugPrint('🧹 [WS] Disposing WebSocketService');
    disconnect();
    _messageController.close();
  }
}

final websocketServiceProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  return WebSocketService(storage);
});