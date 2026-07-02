import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/auth/data/repositories/auth_repository_firebase.dart';
import 'package:swaply/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:swaply/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:swaply/features/profile/presentation/cubit/profile_cubit.dart';

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
    return MultiBlocProvider(
      providers: [
        // ── Auth ─────────────────────────────────────────
        BlocProvider(
          create: (_) => AuthCubit(FirebaseAuthRepository())..getCurrentUser(),
        ),

        // ── Profile (dark mode + local prefs) ────────────
        BlocProvider(
          create: (_) => ProfileCubit(
            ProfileLocalDataSource(),
            initialDarkMode: initialDarkMode,
          )..loadSettings(),
        ),
      ],
      child: child,
    );
  }
}
