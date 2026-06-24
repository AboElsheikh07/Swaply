import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/sessions/data/repositories/session_repository.dart';
// import 'package:swaply/features/auth/presentation/screens/welcome_screen.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_cubit.dart';
import 'package:swaply/features/sessions/presentation/screens/sessions_screen.dart';
// import 'package:swaply/root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
          // create: (_) => AuthCubit()..checkAuth(),
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
        home: const SessionsScreen(),
      ),
    );
  }
}
