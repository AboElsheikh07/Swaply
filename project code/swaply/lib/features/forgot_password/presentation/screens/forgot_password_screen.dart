import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/forgot_password_repository_mock.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import 'forgot_password_widgets.dart';
import 'verify_code_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordCubit(MockForgotPasswordRepository()),
      child: const ForgotPasswordView(),
    );
  }
}

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => ForgotPasswordViewState();
}

class ForgotPasswordViewState extends State<ForgotPasswordView> {
  final emailCtrl = TextEditingController();
  String? emailError;

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  void submit(BuildContext context) {
    setState(() {
      emailError = null;
      if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(emailCtrl.text)) {
        emailError = 'Please enter a valid email';
      }
    });
    if (emailError != null) return;
    context.read<ForgotPasswordCubit>().sendCode(email: emailCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is CodeSentSuccess) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const VerifyCodeScreen()));
            context.read<ForgotPasswordCubit>().resetState();
          }
          if (state is ForgotPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: fpErrorColor,
              ),
            );
            context.read<ForgotPasswordCubit>().resetState();
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const FpBackButton(),
                  const SizedBox(height: 32),
                  const Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your email and we'll send you a verification code.",
                    style: TextStyle(fontSize: 14, color: fpMutedFg),
                  ),
                  const SizedBox(height: 32),
                  FpInputField(
                    label: 'Email',
                    placeholder: 'you@example.com',
                    controller: emailCtrl,
                    icon: Icons.mail_outline_rounded,
                    error: emailError,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  FpPrimaryButton(
                    label: 'Send Code',
                    isLoading: state is ForgotPasswordLoading,
                    onTap: () => submit(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
