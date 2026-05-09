import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthSupportChatPage extends StatefulWidget {
  const HealthSupportChatPage({super.key});

  @override
  State<HealthSupportChatPage> createState() => _HealthSupportChatPageState();
}

class _HealthSupportChatPageState extends State<HealthSupportChatPage> {
  final TextEditingController _messageController = TextEditingController();

  String _formatNow() {
    final now = DateTime.now();
    final int hour =
        now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final String minute = now.minute.toString().padLeft(2, '0');
    final String suffix = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  String _generateSmartBotReply(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('emergency') ||
        message.contains('urgent') ||
        message.contains('danger') ||
        message.contains('help me') ||
        message.contains('sos')) {
      return 'This sounds urgent. Please press the Emergency SOS button or contact your companion immediately.';
    }

    if (message.contains('pain') ||
        message.contains('hurt') ||
        message.contains('sick') ||
        message.contains('fever') ||
        message.contains('headache') ||
        message.contains('dizzy')) {
      return 'I am sorry you are not feeling well. Try to rest, drink water, and tell your companion if the pain continues.';
    }

    if (message.contains('sad') ||
        message.contains('cry') ||
        message.contains('lonely') ||
        message.contains('depressed') ||
        message.contains('upset')) {
      return 'I am sorry you feel this way. You are not alone. Try to talk to your companion or someone you trust.';
    }

    if (message.contains('tired') ||
        message.contains('sleep') ||
        message.contains('exhausted') ||
        message.contains('weak')) {
      return 'It sounds like you need rest. Try to relax, drink water, and take a short break.';
    }

    if (message.contains('medicine') ||
        message.contains('medication') ||
        message.contains('pill') ||
        message.contains('dose')) {
      return 'Please check your medication reminder. If you are unsure, ask your companion before taking anything.';
    }

    if (message.contains('food') ||
        message.contains('hungry') ||
        message.contains('eat') ||
        message.contains('meal')) {
      return 'Try to have a light healthy meal and drink enough water.';
    }

    if (message.contains('anxious') ||
        message.contains('stress') ||
        message.contains('worried') ||
        message.contains('scared')) {
      return 'Take a slow deep breath. You are safe. Try to relax and contact your companion if you need support.';
    }

    return 'Thank you for sharing. I am here to support you. Tell me more about how you feel.';
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    _messageController.clear();

    await FirebaseFirestore.instance.collection('health_support_chats').add({
      'userId': user.uid,
      'text': text,
      'isFromBot': false,
      'senderRole': 'patient',
      'time': _formatNow(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final botReply = _generateSmartBotReply(text);

    await FirebaseFirestore.instance.collection('health_support_chats').add({
      'userId': user.uid,
      'text': botReply,
      'isFromBot': true,
      'senderRole': 'bot',
      'time': _formatNow(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final alignment =
        message.isFromBot ? CrossAxisAlignment.start : CrossAxisAlignment.end;

    final bubbleColor =
        message.isFromBot ? const Color(0xFF87CEEB) : Colors.white;

    final textColor = message.isFromBot ? Colors.white : Colors.black87;

    final borderRadius = message.isFromBot
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          );

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 240),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: borderRadius,
            border: message.isFromBot
                ? null
                : Border.all(color: const Color(0xFFE6E6E6)),
          ),
          child: Text(
            message.text,
            style: TextStyle(color: textColor, fontSize: 14),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          message.time,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _messagesStream() {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('health_support_chats')
        .where('userId', isEqualTo: user?.uid ?? '')
        .orderBy('createdAt')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Text(
                      'Help Chat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF87CEEB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: user == null
                    ? const Center(
                        child: Text(
                          'Please login to use chat',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _messagesStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF87CEEB),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                'Error loading messages',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          final docs = snapshot.data?.docs ?? [];

                          final messages = docs.map((doc) {
                            final data = doc.data();

                            return ChatMessage(
                              text: (data['text'] ?? '').toString(),
                              isFromBot: data['isFromBot'] ?? false,
                              time: (data['time'] ?? '').toString(),
                            );
                          }).toList();

                          if (messages.isEmpty) {
                            messages.add(
                              ChatMessage(
                                text: 'Hello! How can I assist you today?',
                                isFromBot: true,
                                time: _formatNow(),
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: ListView.separated(
                              itemCount: messages.length + 1,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return const Center(
                                    child: Text(
                                      'Today',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                }

                                final message = messages[index - 1];
                                return _buildMessageBubble(message);
                              },
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE6E6E6)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.emoji_emotions_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: const InputDecoration(
                                  hintText: 'Type a message',
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            const Icon(
                              Icons.attach_file,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.photo_camera_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFF87CEEB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isFromBot;
  final String time;

  ChatMessage({
    required this.text,
    required this.isFromBot,
    required this.time,
  });
}
