import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  String get _currentUserId => _auth.currentUser!.uid;

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

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final date = timestamp.toDate();
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'pm' : 'am';

    return '$hour:$minute $period';
  }

  String _formatHeaderDate(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final date = timestamp.toDate();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = weekDays[date.weekday - 1];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$dayName $hour:$minute $period';
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isMe,
    required String time,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                      onFieldSubmitted: (_) => _sendMessage(volunteerData),
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
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
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
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
              Positioned(
                right: 1,
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
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    final volunteerRef = _firestore.collection('users').doc(widget.volunteerId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: volunteerRef.snapshots(),
      builder: (context, volunteerSnapshot) {
        if (volunteerSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!volunteerSnapshot.hasData || !volunteerSnapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Volunteer not found')),
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

                              return _buildMessageBubble(
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
    );
  }
}
