import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message_model.dart';
import '../data/sample_data.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  // Users and messages loaded from sample data file
  late List<Map<String, String?>> _users;

  late String _currentUserId;

  late List<Message> _messages;

  @override
  void initState() {
    super.initState();
    // initialize from sample data (create mutable copies)
    _users = sampleUsers.map((u) => Map<String, String?>.from(u)).toList();
    _messages = sampleMessages.map((m) => m).toList();
    _currentUserId = _users.first['id']!;
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = _users.firstWhere((u) => u['id'] == _currentUserId);

    final message = Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: user['id']!,
      userName: user['name'] ?? 'Unknown',
      text: text,
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
      _controller.clear();
    });

    // Scroll handled by ListView reverse (if added)
  }

  Widget _buildMessageTile(Message msg) {
    final isMe = msg.userId == _currentUserId;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isMe ? Colors.blue[700] : Colors.grey[200];
    final textColor = isMe ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              child: Text(msg.userName.isNotEmpty ? msg.userName[0] : '?'),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: align,
              children: [
                Text(
                  msg.userName,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    msg.text,
                    style: TextStyle(color: textColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.Hm().format(msg.time),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe)
            CircleAvatar(
              backgroundColor: Colors.blue[700],
              child: Text(
                msg.userName.isNotEmpty ? msg.userName[0] : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: const Color(0xFF00589e),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // user selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Text('Act as:'),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _currentUserId,
                    items: _users
                        .map((u) => DropdownMenuItem(
                              value: u['id'],
                              child: Text(u['name'] ?? 'Unknown'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _currentUserId = v);
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageTile(msg);
                },
              ),
            ),

            // input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Écrire un message...',
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00589e),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
