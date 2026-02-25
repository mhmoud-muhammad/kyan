// lib/core/services/websocket_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:myapp/presentation/providers/auth/auth_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod/riverpod.dart';
import '../constants/api_constants.dart';

class WebSocketService {
  final FlutterSecureStorage storage;
  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  WebSocketService(this.storage);

  Future<void> connectTeacher() async {
    final token = await storage.read(key: ApiConstants.accessTokenKey);
    if (token == null) throw Exception('No authentication token');

    // تحويل baseUrl من https إلى ws
    final wsBase = ApiConstants.domain.replaceFirst('https', 'ws');
    final url = '$wsBase/ws/pickup/teacher/?token=$token';

    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        _messageController.add(data);
      },
      onError: (error) {
        //print('WebSocket error: $error');
      },
      onDone: () {
        //print('WebSocket connection closed');
      },
    );
  }

  void disconnect() {
    _channel?.sink.close();
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}

final websocketServiceProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  return WebSocketService(storage);
});