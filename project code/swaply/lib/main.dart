// main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/auth/presentation/screens/welcome_screen.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_cubit.dart';
import 'package:swaply/features/sessions/data/repositories/session_repository.dart';
import 'package:swaply/features/chat/presentation/controllers/chat_cubit.dart';
import 'package:swaply/features/chat/data/repositories/chat_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final uuid = FirebaseAuth.instance.currentUser?.uid;

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
          create: (_) =>
              SessionsCubit(currentUid: uuid!, repo: SessionRepository())
                ..loadSessions(),
        ),

        // ── Chat & Messaging ─────────────────
        BlocProvider(
          create: (_) =>
              ChatCubit(repository: ChatRepository(), currentUserId: uuid!),
        ),

        // ── Your teammate's cubits go here ───
        // BlocProvider(create: (_) => ProfileCubit()..loadProfile()),
        // BlocProvider(create: (_) => ExploresCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Swaply',
        home: const WelcomeScreen(),
      ),
    );
  }
}
