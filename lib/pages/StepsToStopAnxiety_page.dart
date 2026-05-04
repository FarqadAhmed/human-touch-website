import 'package:flutter/material.dart';

import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';

class StepsToStopAnxietyPage extends StatelessWidget {
  const StepsToStopAnxietyPage({super.key});

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
                            '10 Steps to Stop Anxiety',
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
                        'assets/images/StepsToStopAnxiety.png',
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
                        'Here are clear and practical steps to help stop or manage anxiety:\n\n'
                        '1. Notice anxiety early\n'
                        'Pay attention to signs like a fast heartbeat, overthinking, or restlessness.\n\n'
                        '2. Control your breathing\n'
                        'Try breathing in for 4 seconds, hold for 4 seconds, and breathe out for 6 seconds.\n\n'
                        '3. Ground yourself\n'
                        'Use the 5-4-3-2-1 method to focus on what you can see, touch, hear, smell, and taste.\n\n'
                        '4. Challenge negative thoughts\n'
                        'Ask yourself if your thoughts are realistic and replace fear with logic.\n\n'
                        '5. Move your body\n'
                        'A short walk, stretching, or light exercise can help reduce stress hormones.\n\n'
                        '6. Reduce triggers\n'
                        'Limit caffeine, reduce social media use, and avoid overwhelming situations when possible.\n\n'
                        '7. Talk to someone\n'
                        'Speaking with a trusted person can help you feel calmer.\n\n'
                        '8. Improve your sleep\n'
                        'Lack of sleep can make anxiety worse, so aim for 7–9 hours.\n\n'
                        '9. Practice daily relaxation\n'
                        'Try meditation, journaling, or deep breathing for at least a few minutes every day.\n\n'
                        '10. Accept the feeling\n'
                        'Do not fight the anxiety too hard. Acknowledge it and remind yourself that it can pass.\n\n'
                        'When to get help:\n'
                        'If anxiety happens often, affects your sleep, or makes daily life difficult, consider talking to a mental health professional.',
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
