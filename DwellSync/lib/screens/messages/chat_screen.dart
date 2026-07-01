import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dwell_sync/providers/payment_provider.dart';
import 'package:dwell_sync/providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  const ChatScreen({super.key, required this.currentUserId, required this.otherUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final matches = auth.allUsers.where((u) => u.id == widget.otherUserId).toList();
    final otherName = matches.isNotEmpty ? matches.first.name : 'Conversation';
    final otherPhotoUrl = matches.isNotEmpty ? matches.first.photoUrl : null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF155E63),
              backgroundImage: otherPhotoUrl != null && otherPhotoUrl.isNotEmpty
                  ? NetworkImage(otherPhotoUrl)
                  : null,
              child: (otherPhotoUrl == null || otherPhotoUrl.isEmpty)
                  ? Text(otherName.isNotEmpty ? otherName[0].toUpperCase() : '?')
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(otherName)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<PaymentProvider>(builder: (context, payment, child) {
              final messages = payment.getMessagesBetween(widget.currentUserId, widget.otherUserId);
              return ListView.builder(
                controller: _scrollController,
                reverse: false,
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final m = messages[index];
                  final isMe = m['senderId'] == widget.currentUserId;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF155E63) : Colors.grey[200],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 2),
                              bottomRight: Radius.circular(isMe ? 2 : 16),
                            ),
                          ),
                          child: Text(
                            m['text'] ?? '',
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Write a message...', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                      final payment = Provider.of<PaymentProvider>(context, listen: false);
                      payment.sendMessage(widget.currentUserId, widget.otherUserId, text);
                      _controller.clear();
                      // wait a short moment for the list to rebuild, then scroll
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                  },
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


