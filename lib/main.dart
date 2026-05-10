import 'package:flutter/material.dart';

import 'package:humantouch/pages/Communication_page.dart';
import 'package:humantouch/pages/Dashboard_page.dart';
import 'package:humantouch/pages/Emergency_page.dart';
import 'package:humantouch/pages/ForgetPassword_page.dart';
import 'package:humantouch/pages/Health_page.dart';
import 'package:humantouch/pages/Login_page.dart';
import 'package:humantouch/pages/Map_page.dart';
import 'package:humantouch/pages/Profile2_page.dart';
import 'package:humantouch/pages/Profile_page.dart';
import 'package:humantouch/pages/RemindersCompanion_page.dart';
import 'package:humantouch/pages/Reminders_page.dart';
import 'package:humantouch/pages/Settings_page.dart';
import 'package:humantouch/pages/SignUpCompanion_page.dart';
import 'package:humantouch/pages/SignUpPatient_page.dart';
import 'package:humantouch/pages/SignUpVolunteer_page.dart';
import 'package:humantouch/pages/SignUp_page.dart';
import 'package:humantouch/pages/Splash_page.dart';
import 'package:humantouch/pages/VolunteerHelp_page.dart';
import 'package:humantouch/pages/Welcome_page.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 🔥 FCM SERVICE
import 'package:humantouch/pages/services/fcm_service.dart';

/// 🔥 LANGUAGE STORE
import 'package:humantouch/pages/app_settings_store.dart';

/// 🔥 Navigator Key for Notifications → Navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('en', null);
  await initializeDateFormatting('ar', null);

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings();

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await notificationsPlugin.initialize(initSettings);

  /// 🔥 INIT FCM SYSTEM
  await FCMService.init(navigatorKey);

  runApp(const HumanTouchApp());
}

class HumanTouchApp extends StatefulWidget {
  const HumanTouchApp({super.key});

  @override
  State<HumanTouchApp> createState() => _HumanTouchAppState();
}

class _HumanTouchAppState extends State<HumanTouchApp> {
  @override
  void initState() {
    super.initState();

    AppSettingsStore.instance.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// 🔥 REQUIRED FOR NOTIFICATION NAVIGATION
      navigatorKey: navigatorKey,

      debugShowCheckedModeBanner: false,
      title: 'Human Touch',

      /// 🌍 LANGUAGE
      locale: AppSettingsStore.instance.locale,

      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F4F4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF87CEEB),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF87CEEB),
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.black,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF4F4F4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF87CEEB),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF87CEEB),
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),

      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashPage(),
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/signupVolunteer': (context) => const SignUpVolunteerPage(),
        '/signupCompanion': (context) => const SignUpCompanionPage(),
        '/signupPatient': (context) => const SignUpPatientPage(),
        '/forgetPassword': (context) => const ForgetPasswordPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/reminders': (context) => const RemindersPage(),
        '/companionReminders': (context) => const CompanionRemindersPage(),
        '/health': (context) => const HealthPage(),
        '/communication': (context) => const CommunicationPage(),
        '/emergency': (context) => const EmergencyPage(),
        '/map': (context) => const MapPage(),
        '/volunteerHelp': (context) => const VolunteerHelpPage(),
        '/profile': (context) => const ProfilePage(),
        '/profile2': (context) => const Profile2Page(),
        '/settings': (context) => const SettingsPage(),
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                'Page not found',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        );
      },
    );
  }
}
