import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/message_model.dart';
import '../core/storage/secure_storage.dart';
import '../core/network/api_client.dart';

class ChatProvider extends ChangeNotifier {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Lista de mensajes de la conversación activa
  List<MessageModel> _messages = [];
  List<MessageModel> get messages => _messages;

  // Contadores de no leídos por contacto
  final Map<int, int> _unreadCounts = {};
  int get totalUnread => _unreadCounts.values.fold(0, (a, b) => a + b);
  int unreadFor(int contactId) => _unreadCounts[contactId] ?? 0;

  // Estado de carga del historial
  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;
  bool _hasMoreHistory = true;
  bool get hasMoreHistory => _hasMoreHistory;

  // ID del contacto activo
  dynamic _activeContactId;

  // Reconexión
  int _retrySeconds = 1;
  Timer? _retryTimer;

  // Paginación
  static const int _pageSize = 20;

  // --- Compatibilidad con dashboard_header.dart ---
  int get unreadCount => totalUnread;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final token = await SecureStorage.getToken();
      if (token == null) return;

      final wsUrl = ApiClient.baseUrl
          .replaceFirst('http', 'ws')
          .replaceFirst('/api/v1', '/api/v1/chat/ws');
      final uri = Uri.parse('$wsUrl?token=$token');

      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;
      _retrySeconds = 1; // Reset backoff en conexión exitosa
      notifyListeners();

      _channel?.stream.listen(
        (data) {
          final decoded = jsonDecode(data);
          if (decoded.containsKey('error')) {
            debugPrint('Chat error: ${decoded['error']}');
            return;
          }

          final message = MessageModel.fromJson(decoded);

          if (_activeContactId == message.senderId ||
              _activeContactId == message.receiverId ||
              _activeContactId == 'admin') {
            // Reemplazar mensaje optimista si existe, o agregar el nuevo
            final optimisticIndex = _messages.indexWhere(
                (m) => m.id < 0 && m.content == message.content && m.senderId == message.senderId);
            
            if (optimisticIndex != -1) {
              final newMessages = List<MessageModel>.from(_messages);
              newMessages[optimisticIndex] = message;
              _messages = newMessages;
            } else if (!_messages.any((m) => m.id == message.id)) {
              _messages = [message, ..._messages];
            }

          } else {
            // Incrementar contador para el contacto específico
            _unreadCounts[message.senderId] =
                (_unreadCounts[message.senderId] ?? 0) + 1;
          }
          notifyListeners();
        },
        onDone: () {
          _isConnected = false;
          notifyListeners();
          _scheduleReconnect();
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _isConnected = false;
          notifyListeners();
          _scheduleReconnect();
        },
      );
    } catch (e) {
      debugPrint('Error connecting to WebSocket: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: _retrySeconds), () {
      _retrySeconds = (_retrySeconds * 2).clamp(1, 30);
      connect();
    });
  }



  void setActiveContact(dynamic contactId) {
    _activeContactId = contactId;
    if (contactId != null) {
      _unreadCounts.remove(contactId);
    }
    notifyListeners();
  }

  Future<void> loadHistory(dynamic contactId) async {
    _messages = [];
    _hasMoreHistory = true;
    _isLoadingHistory = true;
    _activeContactId = contactId;
    notifyListeners();

    try {
      final response = await apiClient.get(
        '/chat/history/$contactId',
        queryParameters: {'skip': 0, 'limit': _pageSize},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _messages = data.map((e) => MessageModel.fromJson(e)).toList();
        _hasMoreHistory = data.length >= _pageSize;
      }
    } catch (e) {
      debugPrint('Error fetching chat history: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreHistory(dynamic contactId) async {
    if (_isLoadingHistory || !_hasMoreHistory) return;
    _isLoadingHistory = true;
    notifyListeners();

    try {
      final response = await apiClient.get(
        '/chat/history/$contactId',
        queryParameters: {'skip': _messages.length, 'limit': _pageSize},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final older = data.map((e) => MessageModel.fromJson(e)).toList();
        _messages = [..._messages, ...older];
        _hasMoreHistory = data.length >= _pageSize;
      }
    } catch (e) {
      debugPrint('Error fetching more history: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  void sendMessage(dynamic receiverId, String content, {int? senderId}) {
    if (!_isConnected || _channel == null) return;
    if (content.length > 2000) return; // Límite de seguridad

    final payload = {
      'receiver_id': receiverId,
      'content': content,
    };

    // Inserción optimista para que el mensaje aparezca de inmediato en la UI
    if (senderId != null) {
      final tempMsg = MessageModel(
        id: -DateTime.now().millisecondsSinceEpoch, // ID temporal negativo
        senderId: senderId,
        receiverId: receiverId is int ? receiverId : 0,
        content: content,
        timestamp: DateTime.now().toIso8601String(),
        isRead: false,
      );
      _messages = [tempMsg, ..._messages];
      notifyListeners();
    }

    _channel!.sink.add(jsonEncode(payload));
  }

  void disconnect() {
    _retryTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _messages.clear();
    _unreadCounts.clear();
    _activeContactId = null;
    notifyListeners();
  }
}
