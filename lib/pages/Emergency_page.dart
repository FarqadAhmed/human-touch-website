import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sms/flutter_sms.dart';

import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';
import 'EmergencySettings_store.dart';

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
  final EmergencySettingsStore settingsStore = EmergencySettingsStore.instance;

  bool _isSending = false;
  String _statusMessage = '';

  final List<VolunteerContact> _volunteers = const [
    VolunteerContact(
      name: 'Ali',
      phone: '+97331111111',
      latitude: 26.2235,
      longitude: 50.5876,
      available: true,
    ),
    VolunteerContact(
      name: 'Sara',
      phone: '+97332222222',
      latitude: 26.2100,
      longitude: 50.5800,
      available: true,
    ),
    VolunteerContact(
      name: 'Fatima',
      phone: '+97333333333',
      latitude: 26.2400,
      longitude: 50.6000,
      available: false,
    ),
  ];

  Widget _buildBottomNavItem({
    required IconData icon,
    required VoidCallback onTap,
    bool isCurrent = false,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: icon == Icons.settings_outlined ? 45 : 50,
        color: isCurrent ? const Color(0xFF87CEEB) : Colors.black,
      ),
      splashColor: Colors.grey.withOpacity(0.20),
      highlightColor: Colors.grey.withOpacity(0.12),
    );
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

  VolunteerContact? _findNearestVolunteer(Position patientPosition) {
    final availableVolunteers = _volunteers
        .where((volunteer) => volunteer.available)
        .toList();

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

  Future<void> _callCompanion(String phone) async {
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

  Future<void> _triggerSOS() async {
    if (_isSending) return;

    if (settingsStore.companionPhone.trim().isEmpty) {
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
      if (settingsStore.alertNearbyVolunteers) {
        nearestVolunteer = _findNearestVolunteer(position);
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

      if (settingsStore.callCompanion) {
        setState(() {
          _statusMessage = 'Calling companion...';
        });

        await _callCompanion(settingsStore.companionPhone);
      }

      if (settingsStore.sendSmsToCompanion) {
        setState(() {
          _statusMessage = 'Sending SMS to companion...';
        });

        await _sendEmergencySms(
          recipients: [settingsStore.companionPhone],
          message: companionMessage,
        );
      }

      if (settingsStore.alertNearbyVolunteers && nearestVolunteer != null) {
        setState(() {
          _statusMessage = 'Sending SMS to nearest volunteer...';
        });

        await _sendEmergencySms(
          recipients: [nearestVolunteer.phone],
          message: volunteerMessage,
        );
      }

      if (!mounted) return;

      setState(() {
        _statusMessage = 'Emergency action completed.';
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
    return AnimatedBuilder(
      animation: settingsStore,
      builder: (context, _) {
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
                  'Companion Phone: ${settingsStore.companionPhone}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  'Call Companion: ${settingsStore.callCompanion ? "On" : "Off"}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  'SMS to Companion: ${settingsStore.sendSmsToCompanion ? "On" : "Off"}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  'Nearby Volunteers: ${settingsStore.alertNearbyVolunteers ? "On" : "Off"}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsStore,
      builder: (context, _) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: const Color(0xFF87CEEB),
            bottomNavigationBar: Container(
              width: double.infinity,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomNavItem(
                    icon: Icons.home_outlined,
                    isCurrent: false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardPage(),
                        ),
                      );
                    },
                  ),
                  _buildBottomNavItem(
                    icon: Icons.person_outlined,
                    isCurrent: false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                  ),
                  _buildBottomNavItem(
                    icon: Icons.settings_outlined,
                    isCurrent: false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
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
                      child: Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 80,
                      ),
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
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: const [
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
                              text:
                                  'Use current location to find nearest volunteer',
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
