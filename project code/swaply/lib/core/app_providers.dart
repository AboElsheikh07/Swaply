import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/auth/data/repositories/auth_repository_firebase.dart';
import 'package:swaply/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:swaply/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:swaply/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:swaply/features/sessions/data/repositories/session_repository.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_cubit.dart';
import 'package:swaply/features/user/data/repositories/user_repository.dart';
import 'package:swaply/features/user/cubit/user_cubit.dart';

class AppProviders extends StatelessWidget {
  final Widget child;
  final bool initialDarkMode;

  const AppProviders({
    super.key,
    required this.child,
    required this.initialDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    // Safe uid — empty string if not logged in yet.
    // Each cubit handles the empty-uid case gracefully.
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return MultiBlocProvider(
      providers: [
        // ── Auth ─────────────────────────────────────────
        BlocProvider(
          create: (_) =>
              AuthCubit(FirebaseAuthRepository())..getCurrentUser(),
        ),

        // ── Current user (balance, skills, profile) ──────
        BlocProvider(
          create: (_) => UserCubit(
            currentUid: uid,
            repo: UserRepository(),
          )..watchUser(),
        ),

        // ── Sessions ─────────────────────────────────────
        BlocProvider(
          create: (_) => SessionsCubit(
            currentUid: uid,
            repo: SessionRepository(),
          )..loadSessions(),
        ),

        // ── Profile (dark mode + local prefs) ────────────
        BlocProvider(
          create: (_) => ProfileCubit(
            ProfileLocalDataSource(),
            initialDarkMode: initialDarkMode,
          )..loadData(),
        ),
      ],
      child: child,
    );
  }
}