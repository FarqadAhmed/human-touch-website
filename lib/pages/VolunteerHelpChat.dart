import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import 'package:humantouch/pages/app_settings_store.dart';

class VolunteerHelpChatPage extends StatefulWidget {
  final String volunteerId;
  final String volunteerName;

  const VolunteerHelpChatPage({
    super.key,
    required this.volunteerId,
    required this.volunteerName,
  });

  @override
  State<VolunteerHelpChatPage> createState() => _VolunteerHelpChatPageState();
}

class _VolunteerHelpChatPageState extends State<VolunteerHelpChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isSendingVoice = false;
  String? _playingUrl;

  bool get isArabic => AppSettingsStore.instance.isArabic;

  String tr(String en, String ar) => isArabic ? ar : en;

  String get _currentUserId => _auth.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    AppSettingsStore.instance.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  String _buildChatId(String userA, String userB) {
    final ids = [userA, userB]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _ensureChatExists({
    required String chatId,
    required Map<String, dynamic> volunteerData,
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final currentUser = _auth.currentUser;

    if (currentUser == null) return;

    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'chatId': chatId,
        'participants': [_currentUserId, widget.volunteerId],
        'participantIds': [_currentUserId, widget.volunteerId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': '',
        'patientId': _currentUserId,
        'volunteerId': widget.volunteerId,
        'patientName': currentUser.displayName ?? 'Patient',
        'patientPhoto': currentUser.photoURL ?? '',
        'volunteerName': widget.volunteerName,
        'volunteerPhoto': volunteerData['photoUrl'] ?? '',
      });
    }
  }

  Future<void> _sendMessage(Map<String, dynamic> volunteerData) async {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final chatId = _buildChatId(_currentUserId, widget.volunteerId);
    final chatRef = _firestore.collection('chats').doc(chatId);

    await _ensureChatExists(chatId: chatId, volunteerData: volunteerData);

    final messageRef = chatRef.collection('messages').doc();

    await messageRef.set({
      'messageId': messageRef.id,
      'text': text,
      'senderId': _currentUserId,
      'receiverId': widget.volunteerId,
      'createdAt': FieldValue.serverTimestamp(),
      'isSeen': false,
      'type': 'text',
    });

    await chatRef.update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSenderId': _currentUserId,
    });

    _messageController.clear();

    _scrollToBottom();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _audioRecorder.hasPermission();

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Microphone permission is required',
              'إذن الميكروفون مطلوب',
            ),
          ),
        ),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopAndSendVoice(Map<String, dynamic> volunteerData) async {
    if (_isSendingVoice) return;

    setState(() {
      _isSendingVoice = true;
    });

    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
      });

      if (path == null) {
        setState(() {
          _isSendingVoice = false;
        });
        return;
      }

      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final chatId = _buildChatId(_currentUserId, widget.volunteerId);
      final chatRef = _firestore.collection('chats').doc(chatId);

      await _ensureChatExists(chatId: chatId, volunteerData: volunteerData);

      final file = File(path);
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      final storageRef = _storage
          .ref()
          .child('chat_voice_messages')
          .child(chatId)
          .child(fileName);

      await storageRef.putFile(file);

      final audioUrl = await storageRef.getDownloadURL();

      final messageRef = chatRef.collection('messages').doc();

      await messageRef.set({
        'messageId': messageRef.id,
        'text': '',
        'audioUrl': audioUrl,
        'senderId': _currentUserId,
        'receiverId': widget.volunteerId,
        'createdAt': FieldValue.serverTimestamp(),
        'isSeen': false,
        'type': 'voice',
      });

      await chatRef.update({
        'lastMessage': 'Voice message',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': _currentUserId,
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isRecording = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('Voice message failed: $e', 'فشل إرسال الرسالة الصوتية: $e'),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingVoice = false;
        });
      }
    }
  }

  Future<void> _playVoice(String audioUrl) async {
    try {
      if (_playingUrl == audioUrl) {
        await _audioPlayer.stop();
        setState(() {
          _playingUrl = null;
        });
        return;
      }

      await _audioPlayer.stop();

      setState(() {
        _playingUrl = audioUrl;
      });

      await _audioPlayer.play(UrlSource(audioUrl));

      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            _playingUrl = null;
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('Could not play voice: $e', 'تعذر تشغيل الصوت: $e'),
          ),
        ),
      );
    }
  }

  Future<void> _markMessagesAsSeen(String chatId) async {
    final query = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: _currentUserId)
        .where('isSeen', isEqualTo: false)
        .get();

    for (final doc in query.docs) {
      await doc.reference.update({'isSeen': true});
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final date = timestamp.toDate();
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? tr('pm', 'م') : tr('am', 'ص');

    return '$hour:$minute $period';
  }

  String _formatHeaderDate(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final date = timestamp.toDate();

    final weekDaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekDaysAr = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    final dayName =
        isArabic ? weekDaysAr[date.weekday - 1] : weekDaysEn[date.weekday - 1];

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? tr('PM', 'م') : tr('AM', 'ص');

    return '$dayName $hour:$minute $period';
  }

  Widget _buildTextBubble({
    required String text,
    required bool isMe,
    required String time,
  }) {
    return Align(
      alignment: isMe
          ? (isArabic ? Alignment.centerLeft : Alignment.centerRight)
          : (isArabic ? Alignment.centerRight : Alignment.centerLeft),
      child: Column(
        crossAxisAlignment: isMe
            ? (isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.end)
            : (isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start),
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 240),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFF2F2F2) : const Color(0xFF87CEEB),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isMe ? 12 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 12),
              ),
            ),
            child: Text(
              text,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.black87 : Colors.white,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildVoiceBubble({
    required String audioUrl,
    required bool isMe,
    required String time,
  }) {
    final bool isPlaying = _playingUrl == audioUrl;

    return Align(
      alignment: isMe
          ? (isArabic ? Alignment.centerLeft : Alignment.centerRight)
          : (isArabic ? Alignment.centerRight : Alignment.centerLeft),
      child: Column(
        crossAxisAlignment: isMe
            ? (isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.end)
            : (isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start),
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 240),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFF2F2F2) : const Color(0xFF87CEEB),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isMe ? 12 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _playVoice(audioUrl),
                  borderRadius: BorderRadius.circular(30),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: isMe
                        ? const Color(0xFF87CEEB)
                        : Colors.white.withOpacity(0.95),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: isMe ? Colors.white : const Color(0xFF87CEEB),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.graphic_eq_rounded,
                  color: isMe ? Colors.black54 : Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  tr('Voice', 'صوت'),
                  style: TextStyle(
                    color: isMe ? Colors.black87 : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInputBar(Map<String, dynamic> volunteerData) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE6E6E6)),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      textInputAction: TextInputAction.send,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      onFieldSubmitted: (_) => _sendMessage(volunteerData),
                      decoration: InputDecoration(
                        hintText: _isRecording
                            ? tr('Recording voice...', 'جاري تسجيل الصوت...')
                            : tr('Type a message', 'اكتب رسالة'),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.paperclip,
                        color: Colors.grey,
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.photo_camera_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: _isSendingVoice
                ? null
                : () {
                    if (_isRecording) {
                      _stopAndSendVoice(volunteerData);
                    } else {
                      _startRecording();
                    }
                  },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : const Color(0xFF87CEEB),
                shape: BoxShape.circle,
              ),
              child: _isSendingVoice
                  ? const Padding(
                      padding: EdgeInsets.all(13),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 23,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _sendMessage(volunteerData),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF87CEEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> volunteerData) {
    final String name = widget.volunteerName;
    final String photoUrl = (volunteerData['photoUrl'] ?? '').toString();
    final bool isAvailable = volunteerData['isAvailable'] ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              isArabic ? Icons.arrow_forward : Icons.arrow_back,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 4),
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF87CEEB),
                backgroundImage:
                    photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty
                    ? const Icon(Icons.person_outline, color: Colors.black)
                    : null,
              ),
              PositionedDirectional(
                end: 1,
                top: 1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    AppSettingsStore.instance.removeListener(_onLanguageChanged);
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Directionality(
        textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Scaffold(
          body: Center(
            child: Text(tr('Please login first', 'يرجى تسجيل الدخول أولاً')),
          ),
        ),
      );
    }

    final volunteerRef = _firestore.collection('users').doc(widget.volunteerId);

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: volunteerRef.snapshots(),
        builder: (context, volunteerSnapshot) {
          if (volunteerSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!volunteerSnapshot.hasData || !volunteerSnapshot.data!.exists) {
            return Scaffold(
              body: Center(
                child: Text(
                    tr('Volunteer not found', 'لم يتم العثور على المتطوع')),
              ),
            );
          }

          final volunteerData = volunteerSnapshot.data!.data()!;
          final chatId = _buildChatId(_currentUserId, widget.volunteerId);
          final chatRef = _firestore.collection('chats').doc(chatId);

          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 14),
                    _buildHeader(volunteerData),
                    const SizedBox(height: 12),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: chatRef
                            .collection('messages')
                            .orderBy('createdAt')
                            .snapshots(),
                        builder: (context, messageSnapshot) {
                          if (messageSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final messages = messageSnapshot.data?.docs ?? [];

                          if (messages.isNotEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _markMessagesAsSeen(chatId);

                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(
                                  _scrollController.position.maxScrollExtent,
                                );
                              }
                            });
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ListView.separated(
                              controller: _scrollController,
                              itemCount: messages.length + 1,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  final firstTimestamp = messages.isNotEmpty
                                      ? messages.first.data()['createdAt']
                                          as Timestamp?
                                      : null;

                                  return Center(
                                    child: Text(
                                      firstTimestamp != null
                                          ? _formatHeaderDate(firstTimestamp)
                                          : '',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                }

                                final message = messages[index - 1].data();
                                final bool isMe =
                                    message['senderId'] == _currentUserId;

                                final String type =
                                    (message['type'] ?? 'text').toString();

                                if (type == 'voice') {
                                  return _buildVoiceBubble(
                                    audioUrl:
                                        (message['audioUrl'] ?? '').toString(),
                                    isMe: isMe,
                                    time: _formatTime(
                                      message['createdAt'] as Timestamp?,
                                    ),
                                  );
                                }

                                return _buildTextBubble(
                                  text: message['text'] ?? '',
                                  isMe: isMe,
                                  time: _formatTime(
                                    message['createdAt'] as Timestamp?,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    _buildInputBar(volunteerData),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
