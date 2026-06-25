// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/auth/presentation/screens/login_screen.dart';
import 'package:swaply/features/sessions/presentation/screens/sessions_screen.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_cubit.dart';
import 'package:swaply/features/sessions/data/repositories/session_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            currentUid: 'demo-uid', // replace with real uid from AuthCubit
            repo: SessionRepository(),
          )..loadSessions(),
        ),

        // ── Your teammate's cubits go here ───
        // BlocProvider(create: (_) => ProfileCubit()..loadProfile()),
        // BlocProvider(create: (_) => ChatCubit()),
        // BlocProvider(create: (_) => ExploresCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Swaply',
        home: const LoginScreen(),
      ),
    );
  }
}
