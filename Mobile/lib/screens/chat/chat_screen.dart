import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final dynamic contactId;
  final String contactName;

  const ChatScreen({
    super.key,
    required this.contactId,
    required this.contactName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatProvider _chatProvider;
  late final int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
    _currentUserId = context.read<AuthProvider>().userId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatProvider.connect();
      _chatProvider.setActiveContact(widget.contactId);
      _chatProvider.loadHistory(widget.contactId);
    });

    // Paginación: cargar más al llegar al tope (scroll inverso = "final" de la lista)
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        _chatProvider.loadMoreHistory(widget.contactId);
      }
    });
  }

  @override
  void dispose() {
    _chatProvider.setActiveContact(null);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (!_chatProvider.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sin conexión. Reintentando...')),
      );
      return;
    }

    _chatProvider.sendMessage(widget.contactId, text, senderId: _currentUserId);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contactName),
      ),
      body: Column(
        children: [
          // Banner de desconexión
          if (!chatProvider.isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: Colors.orange[800],
              child: const Text(
                'Reconectando...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          Expanded(
            child: chatProvider.isLoadingHistory && chatProvider.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: chatProvider.messages.length +
                        (chatProvider.hasMoreHistory ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Loader de paginación al final
                      if (index == chatProvider.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }

                      final message = chatProvider.messages[index];
                      final isMe = message.senderId == _currentUserId;

                      return Align(
                        key: ValueKey(message.id),
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Theme.of(context).primaryColor
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(16).copyWith(
                              bottomRight:
                                  isMe ? const Radius.circular(0) : null,
                              bottomLeft:
                                  !isMe ? const Radius.circular(0) : null,
                            ),
                          ),
                          child: Text(
                            message.content,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLength: 2000,
                      maxLengthEnforcement:
                          MaxLengthEnforcement.enforced,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        counterText: '', // Oculta el contador "0/2000"
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
