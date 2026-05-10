import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Profile_page.dart';
import 'Settings_page.dart';

import 'package:humantouch/pages/app_settings_store.dart';

class VolunteerDashboardPage extends StatefulWidget {
  const VolunteerDashboardPage({super.key});

  @override
  State<VolunteerDashboardPage> createState() => _VolunteerDashboardPageState();
}

class _VolunteerDashboardPageState extends State<VolunteerDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _tipTitleController = TextEditingController();
  final TextEditingController _tipDescController = TextEditingController();

  String _selectedTipCategory = 'Health';
  String _volunteerName = 'Volunteer';

  final List<String> _tipCategories = [
    'Health',
    'Food',
    'Medicine',
    'Exercise',
    'Mental Health',
    'Others',
  ];

  bool get isArabic => AppSettingsStore.instance.isArabic;

  String tr(String en, String ar) => isArabic ? ar : en;

  String categoryText(String category) {
    switch (category) {
      case 'Health':
        return tr('Health', 'الصحة');
      case 'Food':
        return tr('Food', 'الغذاء');
      case 'Medicine':
        return tr('Medicine', 'الدواء');
      case 'Exercise':
        return tr('Exercise', 'الرياضة');
      case 'Mental Health':
        return tr('Mental Health', 'الصحة النفسية');
      case 'Others':
        return tr('Others', 'أخرى');
      default:
        return category;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    AppSettingsStore.instance.addListener(_onLanguageChanged);
    _loadVolunteerName();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppSettingsStore.instance.removeListener(_onLanguageChanged);
    _tabController.dispose();
    _tipTitleController.dispose();
    _tipDescController.dispose();
    super.dispose();
  }

  Future<void> _loadVolunteerName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    setState(() {
      _volunteerName = doc.data()?['name'] ?? 'Volunteer';
    });
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Widget _buildHeader() {
    return Column(
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
                color: Color(0xFFF5FBFF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(
            children: [
              IconButton(
                onPressed: _goBack,
                icon: Icon(
                  isArabic ? Icons.arrow_forward : Icons.arrow_back,
                  size: 28,
                  color: const Color(0xFF263238),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    tr('Volunteer', 'المتطوع'),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
          child: Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              tr('Welcome, $_volunteerName', 'مرحباً، $_volunteerName'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    await FirebaseFirestore.instance
        .collection('volunteer_requests')
        .doc(requestId)
        .update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});

    await FirebaseFirestore.instance.collection('notifications').add({
      'title': status == 'accepted' ? 'Request Accepted' : 'Request Rejected',
      'message': status == 'accepted'
          ? 'Volunteer accepted the patient request.'
          : 'Volunteer rejected the patient request.',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _sendTipToPatient() async {
    final user = FirebaseAuth.instance.currentUser;

    if (_tipTitleController.text.trim().isEmpty ||
        _tipDescController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Please write the tip title and details',
              'يرجى كتابة عنوان النصيحة والتفاصيل',
            ),
          ),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('healthTips').add({
      'volunteerId': user?.uid ?? '',
      'volunteerName': _volunteerName,
      'personName': _volunteerName,
      'personType': 'Volunteer',
      'title': _tipTitleController.text.trim(),
      'shortTip': _tipDescController.text.trim(),
      'fullTip': _tipDescController.text.trim(),
      'description': _tipDescController.text.trim(),
      'category': _selectedTipCategory,
      'emoji': _getEmojiForCategory(_selectedTipCategory),
      'color': _getColorForCategory(_selectedTipCategory).value,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _tipTitleController.clear();
    _tipDescController.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(
            'Tip sent to patient successfully',
            'تم إرسال النصيحة للمريض بنجاح',
          ),
        ),
      ),
    );
  }

  String _getEmojiForCategory(String category) {
    switch (category) {
      case 'Health':
        return '💙';
      case 'Food':
        return '🥗';
      case 'Medicine':
        return '💊';
      case 'Exercise':
        return '🏃';
      case 'Mental Health':
        return '🧠';
      case 'Others':
        return '✨';
      default:
        return '💡';
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Health':
        return const Color(0xFFC5E7F5);
      case 'Food':
        return const Color(0xFFFFC6FF);
      case 'Medicine':
        return const Color(0xFFCAFFBF);
      case 'Exercise':
        return const Color(0xFF9BF6FF);
      case 'Mental Health':
        return const Color(0xFFFFADAD);
      case 'Others':
        return const Color(0xFFFDFFB6);
      default:
        return const Color(0xFFC5E7F5);
    }
  }

  void _openChatSheet(Map<String, dynamic> data) {
    final TextEditingController messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  tr(
                    'Contact ${data['patientName'] ?? 'Patient'}',
                    'التواصل مع ${data['patientName'] ?? 'المريض'}',
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tr(
                    'Ask the patient for more details before accepting or rejecting.',
                    'اسأل المريض عن تفاصيل أكثر قبل القبول أو الرفض.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    hintText: tr(
                      'Write your message here...',
                      'اكتب رسالتك هنا...',
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF87CEEB),
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () async {
                      if (messageController.text.trim().isEmpty) return;

                      await FirebaseFirestore.instance
                          .collection('messages')
                          .add({
                        'requestId': data['requestId'] ?? '',
                        'patientName': data['patientName'] ?? '',
                        'patientId': data['patientId'] ?? '',
                        'senderRole': 'volunteer',
                        'senderName': _volunteerName,
                        'message': messageController.text.trim(),
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      if (!mounted) return;
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tr(
                              'Message sent to patient',
                              'تم إرسال الرسالة للمريض',
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: Text(
                      tr('Send Message', 'إرسال الرسالة'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> _requestsStream(String status) {
    return FirebaseFirestore.instance
        .collection('volunteer_requests')
        .where('status', isEqualTo: status)
        .orderBy('requestDateTime')
        .snapshots();
  }

  void _goToPage(int index) {
    if (index == 0) {
      return;
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      );
    }
  }

  Widget _bottomItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => _goToPage(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 27),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<BoxShadow> _shadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ];
  }

  Widget _buildBottomBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF87CEEB),
        borderRadius: BorderRadius.circular(30),
        boxShadow: _shadow(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomItem(Icons.home_rounded, tr('Home', 'الرئيسية'), 0),
          _bottomItem(Icons.person_rounded, tr('Profile', 'الملف'), 1),
          _bottomItem(Icons.settings_rounded, tr('Settings', 'الإعدادات'), 2),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5FBFF),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF2196F3),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF2196F3),
                tabs: [
                  Tab(text: tr('Requests', 'الطلبات')),
                  Tab(text: tr('Accepted', 'المقبولة')),
                  Tab(text: tr('Tips', 'النصائح')),
                  Tab(text: tr('Notifications', 'الإشعارات')),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRequestsTab(),
                    _buildAcceptedTab(),
                    _buildTipsTab(),
                    _buildNotificationsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildRequestsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _requestsStream('pending'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return _emptyText(tr('No pending requests', 'لا توجد طلبات معلقة'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            data['requestId'] = docs[index].id;

            return _requestCard(
              requestId: docs[index].id,
              data: data,
              showActions: true,
            );
          },
        );
      },
    );
  }

  Widget _buildAcceptedTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _requestsStream('accepted'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return _emptyText(tr('No accepted requests', 'لا توجد طلبات مقبولة'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            data['requestId'] = docs[index].id;

            return _requestCard(
              requestId: docs[index].id,
              data: data,
              showActions: false,
            );
          },
        );
      },
    );
  }

  Widget _requestCard({
    required String requestId,
    required Map<String, dynamic> data,
    required bool showActions,
  }) {
    final patientName = data['patientName'] ?? tr('Patient', 'المريض');
    final needTitle = data['needTitle'] ?? tr('Need help', 'يحتاج مساعدة');
    final needDescription = data['needDescription'] ??
        tr(
          'Patient needs volunteer support',
          'المريض يحتاج إلى دعم من متطوع',
        );
    final location =
        data['location'] ?? tr('Unknown location', 'موقع غير معروف');
    final date = data['date'] ?? '';
    final time = data['time'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFE3F6FF),
                child: Icon(Icons.person, color: Color(0xFF2196F3)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  patientName,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.access_time, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(time),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            needTitle,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            needDescription,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(date),
              const SizedBox(width: 16),
              const Icon(Icons.location_on, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openChatSheet(data),
              icon: const Icon(Icons.chat_bubble_outline),
              label: Text(tr('Chat with Patient', 'الدردشة مع المريض')),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2196F3),
                side: const BorderSide(color: Color(0xFF2196F3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          if (showActions) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _updateRequestStatus(requestId, 'accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      tr('Accept', 'قبول'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _updateRequestStatus(requestId, 'rejected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      tr('Reject', 'رفض'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              tr('Send Health Tip to Patient', 'إرسال نصيحة صحية للمريض'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _tipTitleController,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              decoration: _inputDecoration(tr('Tip title', 'عنوان النصيحة')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tipDescController,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              maxLines: 4,
              decoration: _inputDecoration(
                tr('Tip description', 'تفاصيل النصيحة'),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedTipCategory,
              items: _tipCategories.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(categoryText(item)),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedTipCategory = value;
                });
              },
              decoration: _inputDecoration(tr('Category', 'التصنيف')),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _sendTipToPatient,
                icon: const Icon(Icons.send, color: Colors.white),
                label: Text(
                  tr(
                    'Send to Patient Health Page',
                    'إرسال إلى صفحة صحة المريض',
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF87CEEB),
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return _emptyText(tr('No notifications yet', 'لا توجد إشعارات بعد'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE3F6FF),
                    child: Icon(Icons.notifications, color: Color(0xFF2196F3)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] ?? tr('Notification', 'إشعار'),
                          textAlign:
                              isArabic ? TextAlign.right : TextAlign.left,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['message'] ?? '',
                          textAlign:
                              isArabic ? TextAlign.right : TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5FBFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _emptyText(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
      ),
    );
  }
}
