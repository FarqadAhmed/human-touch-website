import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'VolunteerHelpChat.dart';
import 'VolunteerHelpCall.dart';
import 'call_engine_service.dart';

import 'package:humantouch/pages/app_settings_store.dart';

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

  bool get isArabic => AppSettingsStore.instance.isArabic;

  String tr(String en, String ar) => isArabic ? ar : en;

  String get _volunteerId => widget.volunteer['id'].toString();

  String get _volunteerName =>
      widget.volunteer['name']?.toString() ?? 'Volunteer';

  String get _helpType =>
      widget.volunteer['helpType']?.toString() ??
      widget.volunteer['volunteerType']?.toString() ??
      'Daily Support';

  String get _phone =>
      widget.volunteer['phone']?.toString() ??
      widget.volunteer['phoneNumber']?.toString() ??
      '';

  String get _bio => widget.volunteer['volunteerBio']?.toString() ?? '';

  String get _skill => widget.volunteer['volunteerSkill']?.toString() ?? '';

  String get _specialty =>
      widget.volunteer['volunteerSpecialty']?.toString() ?? '';

  String get _work => widget.volunteer['volunteerWork']?.toString() ?? '';

  String helpTypeText(String value) {
    switch (value) {
      case 'Medical':
        return tr('Medical', 'طبي');
      case 'Shopping':
        return tr('Shopping', 'تسوق');
      case 'Transportation':
        return tr('Transportation', 'مواصلات');
      case 'Daily Support':
        return tr('Daily Support', 'دعم يومي');
      case 'Other':
        return tr('Other', 'أخرى');
      default:
        return value;
    }
  }

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
    super.dispose();
  }

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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Directionality(
          textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
    });
  }

  Future<void> _book() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Please choose date and time first',
              'يرجى اختيار التاريخ والوقت أولاً',
            ),
          ),
        ),
      );
      return;
    }

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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'You already booked this time',
              'لقد حجزت هذا الوقت مسبقاً',
            ),
          ),
        ),
      );
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
      'requestDateTime': Timestamp.fromDate(_selectedDate!),
      'needTitle': helpTypeText(_helpType),
      'needDescription': tr(
        'Patient requested help from volunteer.',
        'المريض طلب مساعدة من المتطوع.',
      ),
      'location': userData['location'] ?? '',
    });

    setState(() => _loading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('Booking sent', 'تم إرسال الحجز'))),
    );

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
        return tr('Calling...', 'جاري الاتصال...');
      case 'ringing':
        return tr('Ringing...', 'يرن...');
      case 'accepted':
        return tr('Connected', 'متصل');
      case 'rejected':
        return tr('Rejected', 'مرفوض');
      case 'missed':
        return tr('Missed Call', 'مكالمة فائتة');
      case 'ended':
        return tr('Call Ended', 'انتهت المكالمة');
      case 'failed':
        return tr('Failed', 'فشل');
      default:
        return tr('Ready', 'جاهز');
    }
  }

  Widget _infoRow(IconData icon, String title, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF87CEEB), size: 23),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF263238),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeChip(String time) {
    final selected = _selectedTime == time;

    return ChoiceChip(
      label: Text(time),
      selected: selected,
      selectedColor: const Color(0xFF87CEEB),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF263238),
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) {
        setState(() {
          _selectedTime = time;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _volunteerName;

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: SafeArea(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 130,
                    width: double.infinity,
                    color: const Color(0xFF87CEEB),
                  ),
                  Container(
                    height: 40,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        isArabic ? Icons.arrow_forward : Icons.arrow_back,
                        size: 28,
                        color: const Color(0xFF263238),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          tr('Volunteer Details', 'تفاصيل المتطوع'),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 42,
                              backgroundColor: Color(0xFFE3F6FF),
                              child: Icon(
                                Icons.person,
                                color: Color(0xFF2196F3),
                                size: 46,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF025590),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              helpTypeText(_helpType),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            StreamBuilder<double>(
                              stream: _ratingStream(),
                              builder: (context, snap) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${tr('Rating', 'التقييم')}: ${snap.data?.toStringAsFixed(1) ?? '0.0'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: isArabic
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('Information', 'المعلومات'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _infoRow(
                                Icons.phone, tr('Phone', 'الهاتف'), _phone),
                            _infoRow(
                              Icons.medical_services_outlined,
                              tr('Specialty', 'التخصص'),
                              _specialty,
                            ),
                            _infoRow(
                              Icons.star_outline,
                              tr('Skill', 'المهارة'),
                              _skill,
                            ),
                            _infoRow(
                              Icons.info_outline,
                              tr('About', 'نبذة'),
                              _bio,
                            ),
                            _infoRow(
                              Icons.favorite_outline,
                              tr('Volunteer Work', 'عمل التطوع'),
                              _work,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _openChat,
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: Text(tr('Chat', 'محادثة')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF87CEEB),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _openCall,
                              icon: const Icon(Icons.call),
                              label: Text(tr('Call', 'اتصال')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF87CEEB),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: isArabic
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('Book Appointment', 'حجز موعد'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: _pickDate,
                                icon: const Icon(Icons.calendar_month),
                                label: Text(
                                  _selectedDate == null
                                      ? tr('Choose Date', 'اختر التاريخ')
                                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _times.map(_timeChip).toList(),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _book,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF87CEEB),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  _loading
                                      ? tr('Booking...', 'جاري الحجز...')
                                      : tr('Book', 'حجز'),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
