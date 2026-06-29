import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:swaply/l10n/app_localizations.dart';

import 'package:swaply/core/app_providers.dart';
import 'package:swaply/core/app_theme.dart';
import 'package:swaply/core/authenticated_providers.dart';

import 'package:swaply/features/auth/presentation/screens/welcome_screen.dart';
import 'package:swaply/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:swaply/features/profile/presentation/cubit/profile_state.dart';
import 'package:swaply/root.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('is_dark_mode') ?? false;

  runApp(MyApp(initialDarkMode: isDarkMode));
}

class MyApp extends StatelessWidget {
  final bool initialDarkMode;
  const MyApp({super.key, required this.initialDarkMode});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      initialDarkMode: initialDarkMode,
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Swaply',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode:
                profileState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: Locale(profileState.language == 'Arabic' ? 'ar' : 'en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('ar', ''), // Arabic
            ],
            builder: (context, child) {
              return StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return AuthenticatedProviders(
                      uid: snapshot.data!.uid,
                      child: child!,
                    );
                  }
                  return child!;
                },
              );
            },
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                // ── Waiting for auth state ──
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                // ── Logged in ──
                if (snapshot.hasData && snapshot.data != null) {
                  return const RootView();
                }

                // ── Not logged in ──
                return const WelcomeScreen();
              },
            ),
          );
        },
      ),
    );
  }
}