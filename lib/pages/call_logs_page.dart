import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CallLogsPage extends StatelessWidget {
  final String userId;

  const CallLogsPage({
    super.key,
    required this.userId,
  });

  String _formatStatus(String status) {
    switch (status) {
      case 'accepted':
        return 'Answered';
      case 'rejected':
        return 'Rejected';
      case 'missed':
        return 'Missed';
      case 'failed':
        return 'Failed';
      case 'calling':
        return 'Calling';
      case 'ringing':
        return 'Ringing';
      case 'ended':
        return 'Ended';
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
    return "${dt.day}/${dt.month} - ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Call History"),
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
            return const Center(
              child: Text(
                "Index required. Create Firestore index from console.",
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No calls yet"));
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
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formatStatus(status)),
                      Text(
                        isOutgoing ? "Outgoing Call" : "Incoming Call",
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
    );
  }
}
