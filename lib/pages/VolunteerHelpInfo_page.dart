import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'VolunteerHelpChat.dart';
import 'VolunteerHelpCall.dart';
import 'call_engine_service.dart';

class VolunteerHelpInfoPage extends StatefulWidget {
  final Map<String, dynamic> volunteer;

  const VolunteerHelpInfoPage({super.key, required this.volunteer});

  @override
  State<VolunteerHelpInfoPage> createState() => _VolunteerHelpInfoPageState();
}

class _VolunteerHelpInfoPageState extends State<VolunteerHelpInfoPage> {
  DateTime? _selectedDate;
  String? _selectedTime;

  bool _loading = false;

  final List<String> _times = [
    '09:00 AM',
    '11:00 AM',
    '02:00 PM',
    '04:00 PM',
    '06:00 PM',
  ];

  String get _volunteerId => widget.volunteer['id'].toString();

  String get _volunteerName =>
      widget.volunteer['name']?.toString() ?? 'Volunteer';

  Stream<double> _ratingStream() {
    return FirebaseFirestore.instance
        .collection('volunteer_reviews')
        .where('volunteerId', isEqualTo: _volunteerId)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return 0.0;

      double total = 0;
      for (var d in snap.docs) {
        final data = d.data();
        total += (data['stars'] ?? 0).toDouble();
      }

      return total / snap.docs.length;
    });
  }

  Future<void> _book() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_selectedDate == null || _selectedTime == null) return;

    setState(() => _loading = true);

    final dateKey =
        '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';

    final exists = await FirebaseFirestore.instance
        .collection('volunteer_requests')
        .where('volunteerId', isEqualTo: _volunteerId)
        .where('patientId', isEqualTo: user.uid)
        .where('date', isEqualTo: dateKey)
        .where('time', isEqualTo: _selectedTime)
        .get();

    if (exists.docs.isNotEmpty) {
      setState(() => _loading = false);
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data() ?? {};

    await FirebaseFirestore.instance.collection('volunteer_requests').add({
      'volunteerId': _volunteerId,
      'volunteerName': _volunteerName,
      'patientId': user.uid,
      'patientName': userData['name'] ?? 'Patient',
      'date': dateKey,
      'time': _selectedTime,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => _loading = false);

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VolunteerHelpChatPage(
          volunteerId: _volunteerId,
          volunteerName: _volunteerName,
        ),
      ),
    );
  }

  void _openCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VolunteerHelpCallPage(
          volunteerId: _volunteerId,
          volunteerName: _volunteerName,
        ),
      ),
    );
  }

  String _formatCallStatus(String status) {
    switch (status) {
      case 'calling':
        return 'Calling...';
      case 'ringing':
        return 'Ringing...';
      case 'accepted':
        return 'Connected';
      case 'rejected':
        return 'Rejected';
      case 'missed':
        return 'Missed Call';
      case 'ended':
        return 'Call Ended';
      case 'failed':
        return 'Failed';
      default:
        return 'Ready';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _volunteerName;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text(name),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _openChat,
                    child: const Text('Chat'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _openCall,
                    child: const Text('Call'),
                  ),
                ),
              ],
            ),
            StreamBuilder<String>(
              stream: CallEngineService.instance.statusStream,
              initialData: CallEngineService.instance.callStatus,
              builder: (context, snap) {
                return Text(
                  _formatCallStatus(snap.data ?? 'idle'),
                  style: const TextStyle(color: Colors.grey),
                );
              },
            ),
            StreamBuilder<double>(
              stream: _ratingStream(),
              builder: (context, snap) {
                return Text(
                  'Rating: ${snap.data?.toStringAsFixed(1) ?? '0.0'}',
                );
              },
            ),
            ElevatedButton(
              onPressed: _loading ? null : _book,
              child: Text(_loading ? 'Booking...' : 'Book'),
            ),
          ],
        ),
      ),
    );
  }
}
