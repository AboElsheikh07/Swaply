import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/forgot_password_repository_mock.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import 'forgot_password_widgets.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordCubit(MockForgotPasswordRepository()),
      child: const ResetPasswordView(),
    );
  }
}

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => ResetPasswordViewState();
}

class ResetPasswordViewState extends State<ResetPasswordView> {
  final newCtrl     = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool showNew      = false;
  bool showConfirm  = false;
  String? newError;
  String? confirmError;

  @override
  void dispose() {
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get rules => [
    {'label': 'At least 8 characters', 'ok': newCtrl.text.length >= 8},
    {'label': 'One uppercase letter',   'ok': RegExp(r'[A-Z]').hasMatch(newCtrl.text)},
    {'label': 'One number',             'ok': RegExp(r'\d').hasMatch(newCtrl.text)},
    {'label': 'One special character',  'ok': RegExp(r'[^A-Za-z0-9]').hasMatch(newCtrl.text)},
  ];

  void submit(BuildContext context) {
    setState(() {
      newError = confirmError = null;
      if (newCtrl.text.isEmpty) {
        newError = 'Please enter a new password';
      } else if (!rules.every((r) => r['ok'] as bool)) {
        newError = "Password doesn't meet all requirements";
      }
      if (confirmCtrl.text.isEmpty) {
        confirmError = 'Please confirm your password';
      } else if (newCtrl.text != confirmCtrl.text) {
        confirmError = "Passwords don't match";
      }
    });
    if (newError != null || confirmError != null) return;
    context.read<ForgotPasswordCubit>().resetPassword(newPassword: newCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ResetSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ResetSuccessScreen()),
            );
          }
          if (state is ForgotPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: fpErrorColor),
            );
            context.read<ForgotPasswordCubit>().resetState();
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const FpBackButton(),
                  const SizedBox(height: 32),
                  const Text('Reset Password',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Choose a new strong password for your account.',
                      style: TextStyle(fontSize: 14, color: fpMutedFg)),
                  const SizedBox(height: 32),

                  FpInputField(
                    label: 'New Password',
                    placeholder: 'Enter new password',
                    controller: newCtrl,
                    icon: Icons.lock_outline_rounded,
                    error: newError,
                    obscureText: !showNew,
                    trailing: GestureDetector(
                      onTap: () => setState(() => showNew = !showNew),
                      child: Icon(
                        showNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: fpMutedFg, size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  FpInputField(
                    label: 'Confirm Password',
                    placeholder: 'Confirm new password',
                    controller: confirmCtrl,
                    icon: Icons.lock_outline_rounded,
                    error: confirmError,
                    obscureText: !showConfirm,
                    trailing: GestureDetector(
                      onTap: () => setState(() => showConfirm = !showConfirm),
                      child: Icon(
                        showConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: fpMutedFg, size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password rules
                  ...rules.map((r) {
                    final ok = r['ok'] as bool;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 18, height: 18,
                            decoration: BoxDecoration(
                              color: ok ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5FA),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              ok ? Icons.check_rounded : Icons.close_rounded,
                              size: 12,
                              color: ok ? const Color(0xFF2E7D32) : fpMutedFg,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(r['label'] as String,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: ok ? const Color(0xFF1A1A2E) : fpMutedFg)),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  FpPrimaryButton(
                    label: 'Reset Password',
                    isLoading: state is ForgotPasswordLoading,
                    onTap: () => submit(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Success screen ───────────────────────
class ResetSuccessScreen extends StatelessWidget {
  const ResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Color(0xFF2E7D32), size: 44),
              ),
              const SizedBox(height: 24),
              const Text('Password Reset!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Your password has been reset. You can now sign in.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: fpMutedFg),
              ),
              const SizedBox(height: 32),
              FpPrimaryButton(
                label: 'Back to Login',
                isLoading: false,
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
