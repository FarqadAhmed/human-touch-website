import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'app_settings_store.dart';

class CallLogsPage extends StatelessWidget {
  final String userId;

  const CallLogsPage({
    super.key,
    required this.userId,
  });

  bool get isArabic => AppSettingsStore.instance.isArabic;

  String tr(String en, String ar) => isArabic ? ar : en;

  String _formatStatus(String status) {
    switch (status) {
      case 'accepted':
        return tr('Answered', 'تم الرد');
      case 'rejected':
        return tr('Rejected', 'مرفوضة');
      case 'missed':
        return tr('Missed', 'فائتة');
      case 'failed':
        return tr('Failed', 'فشلت');
      case 'calling':
        return tr('Calling', 'جاري الاتصال');
      case 'ringing':
        return tr('Ringing', 'يرن');
      case 'ended':
        return tr('Ended', 'انتهت');
      default:
        return status;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.call;
      case 'missed':
        return Icons.call_missed;
      case 'rejected':
      case 'failed':
      case 'ended':
        return Icons.call_end;
      default:
        return Icons.call;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'missed':
        return Colors.orange;
      case 'rejected':
      case 'failed':
        return Colors.red;
      case 'ended':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(Timestamp? time) {
    if (time == null) return '';

    final dt = time.toDate();
    final minute = dt.minute.toString().padLeft(2, '0');

    return '${dt.day}/${dt.month} - ${dt.hour}:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('Call History', 'سجل المكالمات')),
          backgroundColor: const Color(0xFF87CEEB),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('call_logs')
              .where(
                Filter.or(
                  Filter('callerId', isEqualTo: userId),
                  Filter('receiverId', isEqualTo: userId),
                ),
              )
              .orderBy('updatedAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  tr(
                    'Index required. Create Firestore index from console.',
                    'تحتاج إنشاء Index في Firestore من لوحة التحكم.',
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return Center(
                child: Text(tr('No calls yet', 'لا توجد مكالمات بعد')),
              );
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final data = docs[i].data() as Map<String, dynamic>;

                final isOutgoing = data['callerId'] == userId;

                final otherPartyName = isOutgoing
                    ? data['receiverName'] ?? data['receiverId']
                    : data['callerName'] ?? data['callerId'];

                final status = data['status'] ?? 'unknown';
                final time = _formatTime(data['updatedAt']);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(status).withOpacity(0.15),
                      child: Icon(
                        _statusIcon(status),
                        color: _statusColor(status),
                      ),
                    ),
                    title: Text(
                      otherPartyName.toString(),
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(_formatStatus(status)),
                        Text(
                          isOutgoing
                              ? tr('Outgoing Call', 'مكالمة صادرة')
                              : tr('Incoming Call', 'مكالمة واردة'),
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
