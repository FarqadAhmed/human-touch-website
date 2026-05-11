import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_settings_store.dart';

class HealthSupportChatPage extends StatefulWidget {
  const HealthSupportChatPage({super.key});

  @override
  State<HealthSupportChatPage> createState() => _HealthSupportChatPageState();
}

class _HealthSupportChatPageState extends State<HealthSupportChatPage> {
  final TextEditingController _messageController = TextEditingController();

  bool get isArabic => AppSettingsStore.instance.isArabic;

  String tr(String en, String ar) => isArabic ? ar : en;

  @override
  void initState() {
    super.initState();
    AppSettingsStore.instance.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppSettingsStore.instance.removeListener(_onLanguageChanged);
    _messageController.dispose();
    super.dispose();
  }

  String _formatNow() {
    final now = DateTime.now();
    final int hour =
        now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final String minute = now.minute.toString().padLeft(2, '0');
    final String suffix = now.hour >= 12 ? tr('PM', 'م') : tr('AM', 'ص');
    return '$hour:$minute $suffix';
  }

  String _generateSmartBotReply(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('emergency') ||
        message.contains('urgent') ||
        message.contains('danger') ||
        message.contains('help me') ||
        message.contains('sos') ||
        message.contains('طوارئ') ||
        message.contains('خطر') ||
        message.contains('ساعدني') ||
        message.contains('نجدة')) {
      return tr(
        'This sounds urgent. Please press the Emergency SOS button or contact your companion immediately.',
        'يبدو أن الأمر طارئ. يرجى الضغط على زر الطوارئ SOS أو التواصل مع المرافق فوراً.',
      );
    }

    if (message.contains('pain') ||
        message.contains('hurt') ||
        message.contains('sick') ||
        message.contains('fever') ||
        message.contains('headache') ||
        message.contains('dizzy') ||
        message.contains('ألم') ||
        message.contains('تعبان') ||
        message.contains('مريض') ||
        message.contains('حمى') ||
        message.contains('صداع') ||
        message.contains('دوخة')) {
      return tr(
        'I am sorry you are not feeling well. Try to rest, drink water, and tell your companion if the pain continues.',
        'آسف لأنك لا تشعر بحالة جيدة. حاول أن ترتاح وتشرب الماء، وأخبر المرافق إذا استمر الألم.',
      );
    }

    if (message.contains('sad') ||
        message.contains('cry') ||
        message.contains('lonely') ||
        message.contains('depressed') ||
        message.contains('upset') ||
        message.contains('حزين') ||
        message.contains('أبكي') ||
        message.contains('وحيد') ||
        message.contains('مكتئب') ||
        message.contains('متضايق')) {
      return tr(
        'I am sorry you feel this way. You are not alone. Try to talk to your companion or someone you trust.',
        'آسف لأنك تشعر بهذا الشعور. أنت لست وحدك. حاول التحدث مع المرافق أو شخص تثق به.',
      );
    }

    if (message.contains('tired') ||
        message.contains('sleep') ||
        message.contains('exhausted') ||
        message.contains('weak') ||
        message.contains('تعب') ||
        message.contains('نوم') ||
        message.contains('مرهق') ||
        message.contains('ضعيف')) {
      return tr(
        'It sounds like you need rest. Try to relax, drink water, and take a short break.',
        'يبدو أنك تحتاج إلى راحة. حاول أن تسترخي وتشرب الماء وتأخذ استراحة قصيرة.',
      );
    }

    if (message.contains('medicine') ||
        message.contains('medication') ||
        message.contains('pill') ||
        message.contains('dose') ||
        message.contains('دواء') ||
        message.contains('حبوب') ||
        message.contains('جرعة')) {
      return tr(
        'Please check your medication reminder. If you are unsure, ask your companion before taking anything.',
        'يرجى التحقق من تذكير الدواء. إذا لم تكن متأكداً، اسأل المرافق قبل أخذ أي شيء.',
      );
    }

    if (message.contains('food') ||
        message.contains('hungry') ||
        message.contains('eat') ||
        message.contains('meal') ||
        message.contains('طعام') ||
        message.contains('جوعان') ||
        message.contains('أكل') ||
        message.contains('وجبة')) {
      return tr(
        'Try to have a light healthy meal and drink enough water.',
        'حاول تناول وجبة صحية خفيفة واشرب كمية كافية من الماء.',
      );
    }

    if (message.contains('anxious') ||
        message.contains('stress') ||
        message.contains('worried') ||
        message.contains('scared') ||
        message.contains('قلق') ||
        message.contains('توتر') ||
        message.contains('خائف') ||
        message.contains('خايف')) {
      return tr(
        'Take a slow deep breath. You are safe. Try to relax and contact your companion if you need support.',
        'خذ نفساً عميقاً وببطء. أنت بأمان. حاول الاسترخاء وتواصل مع المرافق إذا كنت تحتاج دعماً.',
      );
    }

    return tr(
      'Thank you for sharing. I am here to support you. Tell me more about how you feel.',
      'شكراً لمشاركتك. أنا هنا لدعمك. أخبرني أكثر عن شعورك.',
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(tr('Please login first', 'يرجى تسجيل الدخول أولاً'))),
      );
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

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = !message.isFromBot;

    final alignment = message.isFromBot
        ? (isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start)
        : (isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.end);

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
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
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

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GestureDetector(
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
                        icon: Icon(
                          isArabic ? Icons.arrow_forward : Icons.arrow_back,
                        ),
                      ),
                      Text(
                        tr('Help Chat', 'محادثة المساعدة'),
                        style: const TextStyle(
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
                      ? Center(
                          child: Text(
                            tr(
                              'Please login to use chat',
                              'يرجى تسجيل الدخول لاستخدام المحادثة',
                            ),
                            style: const TextStyle(color: Colors.grey),
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
                              return Center(
                                child: Text(
                                  tr(
                                    'Error loading messages',
                                    'حدث خطأ أثناء تحميل الرسائل',
                                  ),
                                  style: const TextStyle(color: Colors.grey),
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
                                  text: tr(
                                    'Hello! How can I assist you today?',
                                    'مرحباً! كيف يمكنني مساعدتك اليوم؟',
                                  ),
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
                                    return Center(
                                      child: Text(
                                        tr('Today', 'اليوم'),
                                        style: const TextStyle(
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
                                  textAlign: isArabic
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  decoration: InputDecoration(
                                    hintText: tr(
                                      'Type a message',
                                      'اكتب رسالة',
                                    ),
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
