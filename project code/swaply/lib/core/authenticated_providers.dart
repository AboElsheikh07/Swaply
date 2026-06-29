import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/sessions/data/repositories/session_repository.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_cubit.dart';
import 'package:swaply/features/user/data/repositories/user_repository.dart';
import 'package:swaply/features/user/cubit/user_cubit.dart';

class AuthenticatedProviders extends StatelessWidget {
  final Widget child;
  final String uid;

  const AuthenticatedProviders({
    super.key,
    required this.child,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => UserCubit(
            currentUid: uid,
            repo: UserRepository(),
          )..watchUser(),
        ),
        BlocProvider(
          create: (_) => SessionsCubit(
            currentUid: uid,
            repo: SessionRepository(),
          )..loadSessions(),
        ),
      ],
      child: child,
    );
  }
}
