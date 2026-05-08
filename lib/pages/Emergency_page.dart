import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class VolunteerContact {
  final String name;
  final String phone;
  final double latitude;
  final double longitude;
  final bool available;

  const VolunteerContact({
    required this.name,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.available,
  });
}

class _EmergencyPageState extends State<EmergencyPage> {
  bool _isSending = false;
  bool _isLoadingSettings = true;

  String _statusMessage = '';
  String _companionPhone = '';

  bool _callCompanion = true;
  bool _sendSmsToCompanion = true;
  bool _alertNearbyVolunteers = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencySettingsFromFirebase();
  }

  Future<void> _loadEmergencySettingsFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _isLoadingSettings = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data() ?? {};

      if (!mounted) return;

      setState(() {
        _companionPhone = (data['companionPhone'] ?? '').toString();
        _callCompanion = data['callCompanion'] ?? true;
        _sendSmsToCompanion = data['sendSmsToCompanion'] ?? true;
        _alertNearbyVolunteers = data['alertNearbyVolunteers'] ?? true;
        _isLoadingSettings = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingSettings = false;
        _statusMessage = 'Failed to load emergency settings.';
      });
    }
  }

  void _goToPage(int index) {
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

  Widget _bottomItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => _goToPage(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF87CEEB), size: 27),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF87CEEB),
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

  Future<Position> _getCurrentLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied forever.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<List<VolunteerContact>> _loadVolunteersFromFirebase() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'volunteer')
        .where('isAvailable', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data();

          return VolunteerContact(
            name: (data['name'] ?? 'Volunteer').toString(),
            phone: (data['phone'] ?? data['phoneNumber'] ?? '').toString(),
            latitude: (data['latitude'] ?? 0).toDouble(),
            longitude: (data['longitude'] ?? 0).toDouble(),
            available: data['isAvailable'] ?? false,
          );
        })
        .where((volunteer) {
          return volunteer.phone.trim().isNotEmpty &&
              volunteer.latitude != 0 &&
              volunteer.longitude != 0;
        })
        .toList();
  }

  Future<VolunteerContact?> _findNearestVolunteer(
    Position patientPosition,
  ) async {
    final availableVolunteers = await _loadVolunteersFromFirebase();

    if (availableVolunteers.isEmpty) return null;

    VolunteerContact nearest = availableVolunteers.first;

    double nearestDistance = Geolocator.distanceBetween(
      patientPosition.latitude,
      patientPosition.longitude,
      nearest.latitude,
      nearest.longitude,
    );

    for (final volunteer in availableVolunteers.skip(1)) {
      final distance = Geolocator.distanceBetween(
        patientPosition.latitude,
        patientPosition.longitude,
        volunteer.latitude,
        volunteer.longitude,
      );

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = volunteer;
      }
    }

    return nearest;
  }

  Future<void> _callCompanionPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not place call to companion.');
    }
  }

  Future<void> _sendEmergencySms({
    required List<String> recipients,
    required String message,
  }) async {
    await sendSMS(message: message, recipients: recipients);
  }

  Future<void> _saveEmergencyLog({
    required Position position,
    VolunteerContact? nearestVolunteer,
    required String status,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('emergency_logs').add({
      'userId': user.uid,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'companionPhone': _companionPhone,
      'callCompanion': _callCompanion,
      'sendSmsToCompanion': _sendSmsToCompanion,
      'alertNearbyVolunteers': _alertNearbyVolunteers,
      'nearestVolunteerName': nearestVolunteer?.name ?? '',
      'nearestVolunteerPhone': nearestVolunteer?.phone ?? '',
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _triggerSOS() async {
    if (_isSending) return;

    await _loadEmergencySettingsFromFirebase();

    if (_companionPhone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add companion phone number in settings first.'),
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
      _statusMessage = 'Preparing emergency alert...';
    });

    try {
      final position = await _getCurrentLocation();

      VolunteerContact? nearestVolunteer;

      if (_alertNearbyVolunteers) {
        setState(() {
          _statusMessage = 'Finding nearest volunteer...';
        });

        nearestVolunteer = await _findNearestVolunteer(position);
      }

      final locationText =
          'https://maps.google.com/?q=${position.latitude},${position.longitude}';

      final companionMessage =
          '''
Emergency alert from Human Touch.
The patient may need immediate help.

Current location:
$locationText
''';

      String volunteerMessage =
          '''
Emergency alert from Human Touch.
A nearby patient may need urgent assistance.

Current location:
$locationText
''';

      if (nearestVolunteer != null) {
        volunteerMessage +=
            '\nNearest volunteer selected: ${nearestVolunteer.name}';
      }

      if (_callCompanion) {
        setState(() {
          _statusMessage = 'Calling companion...';
        });

        await _callCompanionPhone(_companionPhone);
      }

      if (_sendSmsToCompanion) {
        setState(() {
          _statusMessage = 'Sending SMS to companion...';
        });

        await _sendEmergencySms(
          recipients: [_companionPhone],
          message: companionMessage,
        );
      }

      if (_alertNearbyVolunteers && nearestVolunteer != null) {
        setState(() {
          _statusMessage = 'Sending SMS to nearest volunteer...';
        });

        await _sendEmergencySms(
          recipients: [nearestVolunteer.phone],
          message: volunteerMessage,
        );
      }

      String finalStatus = 'Emergency action completed.';

      if (_alertNearbyVolunteers && nearestVolunteer == null) {
        finalStatus =
            'Emergency sent to companion. No available volunteer found.';
      }

      await _saveEmergencyLog(
        position: position,
        nearestVolunteer: nearestVolunteer,
        status: finalStatus,
      );

      if (!mounted) return;

      setState(() {
        _statusMessage = finalStatus;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_statusMessage)));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _statusMessage = 'Emergency failed: ${e.toString()}';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_statusMessage)));
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentSettingsInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x22FFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Emergency Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Companion Phone: ${_companionPhone.isEmpty ? "Not set" : _companionPhone}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              'Call Companion: ${_callCompanion ? "On" : "Off"}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              'SMS to Companion: ${_sendSmsToCompanion ? "On" : "Off"}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              'Nearby Volunteers: ${_alertNearbyVolunteers ? "On" : "Off"}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoadingSettings) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 160),
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: IconButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardPage(),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Icon(Icons.warning_rounded, color: Colors.white, size: 80),
          ),
          const SizedBox(height: 8),
          const Text(
            'Emergency',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Press SOS to send emergency',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 30),
          Center(
            child: GestureDetector(
              onTap: _triggerSOS,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Color(0x40000000),
                      offset: Offset(0, 8),
                    ),
                  ],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _isSending
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 38,
                              height: 38,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Sending...',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SOS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'EMERGENCY',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.phone_rounded,
                    text: 'Call companion immediately',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.sms_outlined,
                    text: 'SMS to companion and nearest volunteer',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.location_on_rounded,
                    text: 'Use current location to find nearest volunteer',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.wifi_off_rounded,
                    text: 'Designed to work without internet',
                  ),
                ],
              ),
            ),
          ),
          _buildCurrentSettingsInfo(),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 14, 40, 30),
            child: Text(
              _statusMessage.isEmpty
                  ? 'Your current location and emergency message will be shared based on your emergency settings.'
                  : _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF87CEEB),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
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
        ),
        body: SafeArea(child: _buildBodyContent()),
      ),
    );
  }
}
