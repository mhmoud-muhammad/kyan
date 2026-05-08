// lib/core/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:myapp/core/constants/api_constants.dart';
import 'package:myapp/core/network/api_client.dart';

class WebSocketService {
  final ApiClient apiClient;

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _tokenRefreshTimer;
  Timer? _heartbeatTimer;

  String? _lastToken;

  bool _isConnecting = false;
  bool _disposed = false;

  int _connectAttempt = 0;
  int _connectionId = 0; // ✅ مهم: يميّز الاتصال الحالي
  bool _manualClose = false; // ✅ يمنع scheduleReconnect عند إغلاق مقصود

  DateTime? _connectedAt;
  int _msgCount = 0;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  WebSocketService(this.apiClient);

  // ===================== Helpers =====================

  bool get _isConnected => _channel != null && _channel!.closeCode == null;

  Uri _buildUri(String accessToken) {
    final domain = ApiConstants.domain.trim();
    final wsBase = domain.replaceFirst(
      RegExp(r'^https?:\/\/'),
      domain.startsWith('https://') ? 'wss://' : 'ws://',
    );
    return Uri.parse('$wsBase/ws/pickup/teacher/?token=$accessToken');
  }

  Map<String, dynamic> _buildHeaders(String accessToken) {
    final domain = ApiConstants.domain.trim();
    return <String, dynamic>{
      'Authorization': 'Bearer $accessToken',
      'Origin': domain,
    };
  }

  Future<String?> _ensureValidAccessToken() async {
    final token = await apiClient.getValidAccessToken();
    return (token == null || token.isEmpty) ? null : token;
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_disposed) return;

      final since = _connectedAt == null
          ? '-'
          : '${DateTime.now().difference(_connectedAt!).inSeconds}s';

      debugPrint(
        '💓 [WS] heartbeat connected=$_isConnected since=$since msgs=$_msgCount '
        'closeCode=${_channel?.closeCode} cid=$_connectionId',
      );
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _startTokenAutoRefresh() {
    _tokenRefreshTimer?.cancel();

    _tokenRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) async {
      if (_disposed) return;
      if (_channel == null) return;

      debugPrint(
        '🕐 [WS] token-check start (connected=$_isConnected closeCode=${_channel?.closeCode} cid=$_connectionId)',
      );

      final token = await apiClient.getValidAccessToken();
      debugPrint('🕐 [WS] token-check result token=${token == null ? "null" : "ok"}');

      if (token == null || token.isEmpty) return;

      if (_lastToken != null && token != _lastToken) {
        debugPrint('🟧 [WS] token changed -> reconnect');
        await connectTeacher(force: true);
      } else {
        debugPrint('🟦 [WS] token unchanged');
      }
    });
  }

  void _stopTokenAutoRefresh() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  void _scheduleReconnect(int callbackConnectionId, String reason) {
    if (_disposed) return;

    // ✅ لو callback ليس للاتصال الحالي -> تجاهل
    if (callbackConnectionId != _connectionId) {
      debugPrint('🟪 [WS] ignore reconnect from old cid=$callbackConnectionId (current=$_connectionId) reason=$reason');
      return;
    }

    // ✅ لو نحن أغلقنا يدويًا (reconnect/ disconnect) -> لا تعيد
    if (_manualClose) {
      debugPrint('🟪 [WS] manualClose=true -> skip scheduleReconnect reason=$reason');
      return;
    }

    // ✅ لو متصل فعلاً لا تعمل reconnect
    if (_isConnected) {
      debugPrint('🟩 [WS] already connected -> skip scheduleReconnect reason=$reason');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () async {
      if (_disposed) return;
      debugPrint('🔁 [WS] reconnect attempt... reason=$reason cid=$_connectionId');
      await connectTeacher(force: true);
    });
  }

  // ===================== Public API =====================

  Future<void> connectTeacher({bool force = false}) async {
    if (_disposed) return;
    if (_isConnecting) return;

    if (!force && _isConnected) {
      debugPrint('🟩 [WS] connectTeacher: already connected, skip');
      return;
    }

    _isConnecting = true;
    _reconnectTimer?.cancel();

    _connectAttempt++;
    _connectionId++; // ✅ اتصال جديد
    final myCid = _connectionId;

    debugPrint('🟡 [WS] connectTeacher(attempt=$_connectAttempt, force=$force, cid=$myCid)');

    try {
      // ✅ اقفل القناة السابقة لو force
      if (force && _channel != null) {
        debugPrint('🧹 [WS] force reconnect -> closing previous channel (oldCid=$myCid)');
        _manualClose = true;
        try {
          await _channel!.sink.close();
        } catch (_) {}
        _channel = null;
        _manualClose = false;
      }

      final accessToken = await _ensureValidAccessToken();
      if (accessToken == null) {
        debugPrint('🔴 [WS] No valid access token -> skip connect');
        return;
      }

      _lastToken = accessToken;

      final uri = _buildUri(accessToken);
      final headers = _buildHeaders(accessToken);

      debugPrint('🌐 [WS] Connecting to: $uri (cid=$myCid)');
      final newChannel = IOWebSocketChannel.connect(
        uri,
        headers: headers,
        pingInterval: const Duration(seconds: 20),
      );

      _channel = newChannel;
      _connectedAt = DateTime.now();
      _msgCount = 0;

      debugPrint('🟢 [WS] Connected (cid=$myCid)');
      _startHeartbeat();
      _startTokenAutoRefresh();

      newChannel.stream.listen(
        (message) async {
          // ✅ تجاهل الرسائل من قناة قديمة
          if (myCid != _connectionId) return;

          final now = DateTime.now().toIso8601String();
          debugPrint('🕒 [WS][$now][cid=$myCid] RAW => $message');

          try {
            final decoded = jsonDecode(message);
            if (decoded is! Map) return;

            final map = Map<String, dynamic>.from(decoded);
            _msgCount++;

            debugPrint('📩 [WS] msg#$_msgCount action=${map['action']} code=${map['code']} cid=$myCid');
            _messageController.add(map);

            final action = map['action']?.toString();
            final code = map['code']?.toString();
            if (action == 'ERROR' && code == 'AUTH_FAILED') {
              debugPrint('🚫 [WS] AUTH_FAILED -> force refresh + reconnect');
              await _refreshAndReconnect();
            }
          } catch (e) {
            debugPrint('❌ [WS] decode error: $e');
          }
        },
        onError: (error) async {
          debugPrint('❌ [WS] stream error: $error cid=$myCid');
          _scheduleReconnect(myCid, 'onError');
        },
        onDone: () async {
          final code = newChannel.closeCode;
          debugPrint('🔌 [WS] closed. code=$code cid=$myCid');

          // لو هذه ليست القناة الحالية -> تجاهل
          if (myCid != _connectionId) return;

          // 4003 = Invalid token غالباً
          if (code == 4003) {
            debugPrint('🟠 [WS] closeCode=4003 -> refresh + reconnect cid=$myCid');
            await _refreshAndReconnect();
            return;
          }

          _scheduleReconnect(myCid, 'onDone(code=$code)');
        },
        cancelOnError: true,
      );
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _refreshAndReconnect() async {
    if (_disposed) return;

    debugPrint('♻️ [WS] refreshing token (force)...');

    final newToken = await apiClient.forceRefreshAndGetToken();
    if (newToken == null || newToken.isEmpty) {
      debugPrint('🚫 [WS] refresh failed -> logout will happen via ApiClient');
      return;
    }

    _lastToken = newToken;
    debugPrint('✅ [WS] refresh success -> reconnecting...');
    await Future.delayed(const Duration(milliseconds: 300));
    await connectTeacher(force: true);
  }

  void disconnect() {
    debugPrint('🔌 [WS] Disconnect');
    _reconnectTimer?.cancel();
    _stopTokenAutoRefresh();
    _stopHeartbeat();

    _manualClose = true;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _manualClose = false;

    _channel = null;
    _connectedAt = null;
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _messageController.close();
  }
}