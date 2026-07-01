// main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swaply/core/constants/app_colors.dart';
import 'package:swaply/features/sessions/services/sessions_notifications.dart';

import 'package:swaply/core/app_providers.dart';
import 'package:swaply/features/auth/presentation/screens/welcome_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  OneSignal.initialize("badf98d9-e2dd-4bde-8da7-9108d945ce6f");
  OneSignal.Notifications.requestPermission(true);
  await SessionNotificationService.init();
  FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (user != null) {
      OneSignal.login(user.uid); // tags this device with the Firebase uid
    } else {
      OneSignal.logout();
    }
  });

  // await SeedCategories.seed();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('is_dark_mode') ?? false;

  runApp(MyApp(initialDarkMode: isDarkMode));
}

class MyApp extends StatelessWidget {
  final bool initialDarkMode;
  const MyApp({super.key, this.initialDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      initialDarkMode: initialDarkMode,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Swaply',

        theme: ThemeData(
          useMaterial3: true,
          extensions: const <ThemeExtension<dynamic>>[AppColors.light],
        ),

        darkTheme: ThemeData(
          useMaterial3: true,
          extensions: const <ThemeExtension<dynamic>>[AppColors.dark],
        ),

        themeMode: initialDarkMode ? ThemeMode.dark : ThemeMode.light,

        home: const WelcomeScreen(),
      ),
    );
  }
}
