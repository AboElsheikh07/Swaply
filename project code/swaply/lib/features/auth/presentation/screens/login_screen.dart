import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/forgot_password/presentation/screens/forgot_password_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../data/repositories/auth_repository_mock.dart';
import 'signup_screen.dart';
import 'auth_widgets.dart';

// ════════════════════════════════════════
//  Entry point
// ════════════════════════════════════════
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // ✅ بدّل MockAuthRepository بـ FirebaseAuthRepository لما Firebase يتجهز
      create: (_) => AuthCubit(MockAuthRepository()),
      child: const LoginView(),
    );
  }
}

// ════════════════════════════════════════
//  View
// ════════════════════════════════════════
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  final emailCtrl    = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool showPassword  = false;
  bool savePassword  = true;
  String? emailError;
  String? passwordError;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  bool validate() {
    setState(() {
      emailError = null;
      passwordError = null;
      if (emailCtrl.text.trim().isEmpty) {
        emailError = 'Please enter your email';
      } else if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(emailCtrl.text)) {
        emailError = 'Please enter a valid email';
      }
      if (passwordCtrl.text.isEmpty) {
        passwordError = 'Please enter your password';
      }
    });
    return emailError == null && passwordError == null;
  }

  void submit(BuildContext context) {
    if (!validate()) return;
    context.read<AuthCubit>().login(
      email: emailCtrl.text.trim(),
      password: passwordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: authErrorColor),
            );
            context.read<AuthCubit>().resetState();
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const AuthBackButton(),
                  const SizedBox(height: 32),
                  const Text('Welcome back',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Sign in to continue trading skills on Swaply.',
                      style: TextStyle(fontSize: 14, color: authMutedFg)),
                  const SizedBox(height: 32),

                  // Email
                  AuthInputField(
                    label: 'Email',
                    placeholder: 'you@example.com',
                    controller: emailCtrl,
                    icon: Icons.mail_outline_rounded,
                    error: emailError,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  AuthInputField(
                    label: 'Password',
                    placeholder: 'Your password',
                    controller: passwordCtrl,
                    icon: Icons.lock_outline_rounded,
                    error: passwordError,
                    obscureText: !showPassword,
                    trailing: GestureDetector(
                      onTap: () => setState(() => showPassword = !showPassword),
                      child: Icon(
                        showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: authMutedFg, size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Save password + Forgot
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => savePassword = !savePassword),
                        child: Row(
                          children: [
                            AuthCheckbox(value: savePassword),
                            const SizedBox(width: 8),
                            const Text('Save password',
                                style: TextStyle(fontSize: 12, color: authMutedFg)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          );
                        },
                        child: const Text('Forgot password?',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: authPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  AuthPrimaryButton(
                    label: 'Login',
                    isLoading: isLoading,
                    onTap: () => submit(context),
                  ),
                  const SizedBox(height: 24),

                  const AuthDivider(),
                  const SizedBox(height: 24),

                  AuthSocialButton(label: 'Continue with Google', onTap: () {}),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ",
                          style: TextStyle(fontSize: 14, color: authMutedFg)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        ),
                        child: const Text('Sign Up',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: authPrimary)),
                      ),
                    ],
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
