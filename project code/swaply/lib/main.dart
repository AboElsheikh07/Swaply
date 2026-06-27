// main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:swaply/features/on%20boarding/onboarding_screen.dart';
import 'package:swaply/root.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/core/constants/app_colors.dart';
import 'package:swaply/features/auth/presentation/screens/welcome_screen.dart';
import 'package:swaply/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:swaply/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:swaply/features/profile/presentation/cubit/profile_state.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_cubit.dart';
import 'package:swaply/features/sessions/data/repositories/session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    return MultiBlocProvider(
      providers: [
        // ── Auth ─────────────────────────────
        // BlocProvider(
        //   create: (_) => AuthCubit()..checkAuth(),
        // ),

        // ── Sessions ─────────────────────────
        BlocProvider(
          create: (_) => SessionsCubit(
            currentUid: FirebaseAuth.instance.currentUser!.uid,
            repo: SessionRepository(),
          )..loadSessions(),
        ),

        // ── Your teammate's cubits go here ───
        BlocProvider(
          create: (_) => ProfileCubit(
            ProfileLocalDataSource(),
            initialDarkMode: initialDarkMode,
          )..loadData(),
        ),
        // BlocProvider(create: (_) => ChatCubit()),
        // BlocProvider(create: (_) => ExploresCubit()),
      ],
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Swaply',
            themeMode: profileState.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            theme: ThemeData.light().copyWith(
              primaryColor: const Color(0xFF5B4CB8),
              canvasColor: Colors.white,
              scaffoldBackgroundColor: const Color(0xFFF9FAFB),
              cardColor: Colors.white,
              bottomAppBarTheme: const BottomAppBarThemeData(
                color: Colors.white,
              ),
              unselectedWidgetColor: Colors.grey.shade700,
              iconTheme: const IconThemeData(color: Colors.black87),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.black87),
                bodyMedium: TextStyle(color: Colors.black54),
                titleLarge: TextStyle(color: Colors.black87),
                titleMedium: TextStyle(color: Colors.black87),
              ),
              extensions: <ThemeExtension<dynamic>>[AppColors.light],
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: const Color(0xFF8A7DE4),
              canvasColor: const Color(0xFF1E1E1E),
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardColor: const Color(0xFF1E1E1E),
              bottomAppBarTheme: const BottomAppBarThemeData(
                color: Color(0xFF2C2C2C),
              ),
              unselectedWidgetColor: Colors.grey.shade400,
              iconTheme: const IconThemeData(color: Colors.white),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white70),
                titleLarge: TextStyle(color: Colors.white),
                titleMedium: TextStyle(color: Colors.white),
              ),
              extensions: <ThemeExtension<dynamic>>[AppColors.dark],
            ),
            home: FirebaseAuth.instance.currentUser == null
                ? const WelcomeScreen()
                : const RootView(),
            // home: const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
