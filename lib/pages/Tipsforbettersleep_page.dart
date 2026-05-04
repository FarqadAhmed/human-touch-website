import 'package:flutter/material.dart';

import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';

class TipsforbettersleepPage extends StatelessWidget {
  const TipsforbettersleepPage({super.key});

  Widget _buildBottomNavItem({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: icon == Icons.settings_outlined ? 45 : 50,
        color: Colors.black,
      ),
      splashColor: Colors.grey.withOpacity(0.20),
      highlightColor: Colors.grey.withOpacity(0.12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 130,
                        color: const Color(0xFF87CEEB),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Container(
                          width: double.infinity,
                          height: 41.1,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF4F4F4),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(70),
                              topRight: Radius.circular(70),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 30),
                        ),
                        const Expanded(
                          child: Text(
                            '10 Tips for Better Sleep',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/Batter_sleep.jpg',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'Here are 10 practical tips to help you sleep better:\n\n'
                        '1. Stick to a consistent schedule\n'
                        'Go to bed and wake up at the same time every day, even on weekends, to regulate your body clock.\n\n'
                        '2. Create a relaxing bedtime routine\n'
                        'Wind down with calming activities like reading, stretching, or taking a warm shower.\n\n'
                        '3. Limit screen time before bed\n'
                        'Avoid phones, tablets, and TVs at least 30–60 minutes before sleep, as blue light can disrupt melatonin production.\n\n'
                        '4. Keep your room cool and dark\n'
                        'A comfortable environment that is slightly cool, quiet, and dark promotes deeper sleep.\n\n'
                        '5. Watch your caffeine intake\n'
                        'Avoid coffee, tea, and energy drinks in the afternoon and evening.\n\n'
                        '6. Exercise regularly\n'
                        'Physical activity during the day helps you fall asleep faster and improves sleep quality.\n\n'
                        '7. Avoid heavy meals late at night\n'
                        'Eating too much before bed can cause discomfort and disrupt sleep.\n\n'
                        '8. Limit naps during the day\n'
                        'If you nap, keep it short for 20–30 minutes and avoid late-afternoon naps.\n\n'
                        '9. Manage stress and anxiety\n'
                        'Try journaling, meditation, or deep breathing to calm your mind before bed.\n\n'
                        '10. Use your bed only for sleep\n'
                        'Avoid working, eating, or watching TV in bed so your brain associates it with rest.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.7,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                  ),
                  _buildBottomNavItem(
                    icon: Icons.settings_outlined,
                    onTap: () {
                      Navigator.push(
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
          ],
        ),
      ),
    );
  }
}
