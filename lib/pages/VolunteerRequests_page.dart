import 'VolunteerRequests_page.dart';
import 'package:flutter/material.dart';
import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';

class VolunteerRequestsPage extends StatefulWidget {
  const VolunteerRequestsPage({super.key});

  @override
  State<VolunteerRequestsPage> createState() => _VolunteerRequestsPageState();
}

class _VolunteerRequestsPageState extends State<VolunteerRequestsPage> {
  final List<Map<String, dynamic>> _requests = [
    {
      'patientName': 'Fatema Ali',
      'time': '10:30 AM',
      'date': DateTime(2026, 5, 5),
      'location': 'UOB - Building S40',
      'requestType': 'Medical Assistance',
      'note': 'Patient needs help reaching the clinic.',
      'status': 'Pending',
    },
    {
      'patientName': 'Ahmed Hassan',
      'time': '09:15 AM',
      'date': DateTime(2026, 5, 4),
      'location': 'Seef Mall',
      'requestType': 'Transportation',
      'note': 'Needs help moving to the entrance.',
      'status': 'Pending',
    },
    {
      'patientName': 'Sara Mohamed',
      'time': '01:00 PM',
      'date': DateTime(2026, 5, 3),
      'location': 'Salmaniya Hospital',
      'requestType': 'Daily Support',
      'note': 'Needs someone to guide her inside.',
      'status': 'Pending',
    },
  ];

  @override
  void initState() {
    super.initState();

    _requests.sort((a, b) {
      final DateTime dateA = a['date'];
      final DateTime dateB = b['date'];
      return dateB.compareTo(dateA);
    });
  }

  void _acceptRequest(int index) {
    setState(() {
      _requests[index]['status'] = 'Accepted';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request accepted successfully'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _rejectRequest(int index) {
    setState(() {
      _requests[index]['status'] = 'Rejected';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request rejected'),
        backgroundColor: Color(0xFFE57373),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _statusColor(String status) {
    if (status == 'Accepted') return const Color(0xFFDFF5E1);
    if (status == 'Rejected') return const Color(0xFFFDE2E2);
    return const Color(0xFFFFF3CD);
  }

  Color _statusTextColor(String status) {
    if (status == 'Accepted') return const Color(0xFF2E7D32);
    if (status == 'Rejected') return const Color(0xFFC62828);
    return const Color(0xFF9A6A00);
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    }
  }

  int _selectedIndex = 0;

  void _onBottomTap(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 165,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF87CEEB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(70),
                  bottomRight: Radius.circular(70),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: _goBack,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Requests / Notifications',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Center(
                      child: Text(
                        'Patient assistance requests',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _requests.isEmpty
                  ? const Center(
                      child: Text(
                        'No requests available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final request = _requests[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 55,
                                    width: 55,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEAF8FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.volunteer_activism_rounded,
                                      color: Color(0xFF4BAFD8),
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          request['patientName'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2D2D2D),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          request['requestType'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(request['status']),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      request['status'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _statusTextColor(
                                          request['status'],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              _infoRow(
                                Icons.access_time_rounded,
                                'Time',
                                request['time'],
                              ),
                              const SizedBox(height: 10),
                              _infoRow(
                                Icons.calendar_month_rounded,
                                'Date',
                                _formatDate(request['date']),
                              ),
                              const SizedBox(height: 10),
                              _infoRow(
                                Icons.location_on_rounded,
                                'Location',
                                request['location'],
                              ),

                              const SizedBox(height: 15),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6FBFF),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  request['note'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF555555),
                                    height: 1.4,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              if (request['status'] == 'Pending')
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _acceptRequest(index),
                                        icon: const Icon(Icons.check_rounded),
                                        label: const Text('Accept'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF87CEEB,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 13,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _rejectRequest(index),
                                        icon: const Icon(Icons.close_rounded),
                                        label: const Text('Reject'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFFE57373,
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFFE57373),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 13,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomTap,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF87CEEB),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4BAFD8)),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ),
      ],
    );
  }
}
