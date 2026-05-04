import 'package:flutter/material.dart';

import 'Dashboard_page.dart';
import 'Profile_page.dart';
import 'Settings_page.dart';

class DietForHealthyLifePage extends StatelessWidget {
  const DietForHealthyLifePage({super.key});

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
                            'Diet for Healthy Life',
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
                        'assets/images/Diet_For_Healthy_Life.webp',
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
                        'Here is a simple and practical diet plan for a healthy life:\n\n'
                        '1. Start your day right\n'
                        'Choose whole grains, protein, and fruits.\n'
                        'Example: oatmeal with yogurt and fruit.\n\n'
                        '2. Eat a balanced lunch\n'
                        'Include lean protein, complex carbohydrates, and vegetables.\n'
                        'Example: grilled chicken with brown rice and mixed vegetables.\n\n'
                        '3. Have a light and early dinner\n'
                        'Keep dinner lighter than lunch and focus on protein and vegetables.\n'
                        'Example: grilled fish with salad.\n\n'
                        '4. Choose healthy snacks\n'
                        'Try nuts, seeds, fruits, or yogurt instead of chips and sugary snacks.\n\n'
                        '5. Stay hydrated\n'
                        'Drink 6–8 glasses of water daily and reduce sugary drinks.\n\n'
                        '6. Limit sugar and processed foods\n'
                        'Reduce sweets, fast food, and packaged items.\n\n'
                        '7. Control salt intake\n'
                        'Too much salt may affect blood pressure, so use herbs and spices instead.\n\n'
                        '8. Include healthy fats\n'
                        'Choose avocados, olive oil, and nuts, and avoid trans fats.\n\n'
                        '9. Eat on time\n'
                        'Do not skip meals and try to eat at regular times.\n\n'
                        '10. Practice portion control\n'
                        'Avoid overeating and stop when you feel full.\n\n'
                        'Bonus Tip:\n'
                        'Combine a healthy diet with regular exercise and good sleep for better overall health.',
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
