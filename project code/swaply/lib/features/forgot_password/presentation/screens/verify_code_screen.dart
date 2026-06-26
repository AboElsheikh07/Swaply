import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/forgot_password_repository_mock.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import 'forgot_password_widgets.dart';
import 'reset_password_screen.dart';

class VerifyCodeScreen extends StatelessWidget {
  const VerifyCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordCubit(MockForgotPasswordRepository()),
      child: const VerifyCodeView(),
    );
  }
}

class VerifyCodeView extends StatefulWidget {
  const VerifyCodeView({super.key});

  @override
  State<VerifyCodeView> createState() => VerifyCodeViewState();
}

class VerifyCodeViewState extends State<VerifyCodeView> {
  final List<TextEditingController> ctrls = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> nodes = List.generate(4, (_) => FocusNode());
  String? error;
  int seconds = 59;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    setState(() { seconds = 59; canResend = false; });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => seconds--);
      if (seconds <= 0) { setState(() => canResend = true); return false; }
      return true;
    });
  }

  void onDigit(BuildContext context, int index, String val) {
    if (val.length == 1 && index < 3) nodes[index + 1].requestFocus();
    final code = ctrls.map((c) => c.text).join();
    if (code.length == 4) {
      context.read<ForgotPasswordCubit>().verifyCode(code: code);
    }
  }

  void clearBoxes() {
    for (final c in ctrls) { c.clear(); }
    nodes[0].requestFocus();
  }

  @override
  void dispose() {
    for (final c in ctrls) { c.dispose(); }
    for (final n in nodes) { n.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is CodeVerifiedSuccess) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
            );
          }
          if (state is ForgotPasswordError) {
            setState(() => error = state.message);
            clearBoxes();
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
                  const Text('Verification Code',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the 4-digit code we just sent to your email.',
                    style: TextStyle(fontSize: 14, color: fpMutedFg),
                  ),
                  const SizedBox(height: 40),

                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 60, height: 64,
                        child: TextField(
                          controller: ctrls[i],
                          focusNode: nodes[i],
                          autofocus: i == 0,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: const Color(0xFFF5F5FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: fpBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: fpPrimary, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: fpBorder),
                            ),
                          ),
                          onChanged: (val) => onDigit(context, i, val),
                        ),
                      ),
                    )),
                  ),

                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Text(error!,
                          style: const TextStyle(
                              fontSize: 12, color: fpErrorColor, fontWeight: FontWeight.w600)),
                    ),
                  ],
                  const SizedBox(height: 32),

                  Center(
                    child: canResend
                        ? GestureDetector(
                            onTap: startTimer,
                            child: const Text('Resend code',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600, color: fpPrimary)),
                          )
                        : RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 14, color: fpMutedFg),
                              children: [
                                const TextSpan(text: 'Try again in '),
                                TextSpan(
                                  text: '${seconds}s',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                                ),
                              ],
                            ),
                          ),
                  ),

                  if (state is ForgotPasswordLoading) ...[
                    const SizedBox(height: 24),
                    const Center(child: CircularProgressIndicator(color: fpPrimary)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
