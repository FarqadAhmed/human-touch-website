import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Profile_page.dart';
import 'Settings_page.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadVolunteerName();
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
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VolunteerDashboardPage()),
      );
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
                icon: const Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: Color(0xFF263238),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Volunteer',
                    style: TextStyle(
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
            alignment: Alignment.centerLeft,
            child: Text(
              'Welcome, $_volunteerName',
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
        const SnackBar(content: Text('Please write the tip title and details')),
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
      const SnackBar(content: Text('Tip sent to patient successfully')),
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
        return Padding(
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
                'Contact ${data['patientName'] ?? 'Patient'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ask the patient for more details before accepting or rejecting.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your message here...',
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
                      const SnackBar(content: Text('Message sent to patient')),
                    );
                  },
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text(
                    'Send Message',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
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
          _bottomItem(Icons.home_rounded, 'Home', 0),
          _bottomItem(Icons.person_rounded, 'Profile', 1),
          _bottomItem(Icons.settings_rounded, 'Settings', 2),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tipTitleController.dispose();
    _tipDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              tabs: const [
                Tab(text: 'Requests'),
                Tab(text: 'Accepted'),
                Tab(text: 'Tips'),
                Tab(text: 'Notifications'),
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
          return _emptyText('No pending requests');
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
          return _emptyText('No accepted requests');
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
    final patientName = data['patientName'] ?? 'Patient';
    final needTitle = data['needTitle'] ?? 'Need help';
    final needDescription =
        data['needDescription'] ?? 'Patient needs volunteer support';
    final location = data['location'] ?? 'Unknown location';
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(needDescription, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(date),
              const SizedBox(width: 16),
              const Icon(Icons.location_on, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(child: Text(location)),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openChatSheet(data),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Chat with Patient'),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(color: Colors.white),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(color: Colors.white),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Health Tip to Patient',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _tipTitleController,
              decoration: _inputDecoration('Tip title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tipDescController,
              maxLines: 4,
              decoration: _inputDecoration('Tip description'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedTipCategory,
              items: _tipCategories
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTipCategory = value!;
                });
              },
              decoration: _inputDecoration('Category'),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _sendTipToPatient,
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  'Send to Patient Health Page',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF87CEEB),
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
          return _emptyText('No notifications yet');
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] ?? 'Notification',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(data['message'] ?? ''),
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
        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
      ),
    );
  }
}
