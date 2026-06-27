import 'package:flutter/material.dart';
import 'package:swaply/core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/auth/presentation/screens/login_screen.dart';
import 'package:swaply/root.dart';
import 'package:swaply/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:swaply/features/auth/presentation/cubit/auth_state.dart';
import 'package:swaply/features/auth/data/repositories/auth_repository_firebase.dart';
import 'auth_widgets.dart';

// ════════════════════════════════════════
//  Entry point
// ════════════════════════════════════════
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(FirebaseAuthRepository()),
      child: const SignupView(),
    );
  }
}

// ════════════════════════════════════════
//  View
// ════════════════════════════════════════
class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => SignupViewState();
}

class SignupViewState extends State<SignupView> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool showPassword = false;
  bool agreed = false;
  String? nameError;
  String? emailError;
  String? passwordError;
  String? termsError;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  bool validate() {
    setState(() {
      nameError = passwordError = emailError = termsError = null;
      if (nameCtrl.text.trim().isEmpty) nameError = 'Please enter your name';
      if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(emailCtrl.text)) {
        emailError = 'Please enter a valid email';
      }
      if (passwordCtrl.text.length < 8) passwordError = 'At least 8 characters';
      if (!agreed) termsError = 'Please accept the terms to continue';
    });
    return nameError == null &&
        emailError == null &&
        passwordError == null &&
        termsError == null;
  }

  void submit(BuildContext context) {
    if (!validate()) return;
    context.read<AuthCubit>().signup(
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      password: passwordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const RootView()),
              (route) => false, // removes all previous routes
            );
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(
                  context,
                ).extension<AppColorTheme>()!.rose,
              ),
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
                  const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join Swaply and start trading your skills with people around you.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).extension<AppColorTheme>()!.mutedFg,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name
                  AuthInputField(
                    label: 'Full Name',
                    placeholder: 'Your full name',
                    controller: nameCtrl,
                    icon: Icons.person_outline_rounded,
                    error: nameError,
                  ),
                  const SizedBox(height: 16),

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
                    placeholder: 'At least 8 characters',
                    controller: passwordCtrl,
                    icon: Icons.lock_outline_rounded,
                    error: passwordError,
                    obscureText: !showPassword,
                    trailing: GestureDetector(
                      onTap: () => setState(() => showPassword = !showPassword),
                      child: Icon(
                        showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Theme.of(
                          context,
                        ).extension<AppColorTheme>()!.mutedFg,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Terms
                  GestureDetector(
                    onTap: () => setState(() => agreed = !agreed),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthCheckbox(value: agreed, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).extension<AppColorTheme>()!.mutedFg,
                              ),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).extension<AppColorTheme>()!.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).extension<AppColorTheme>()!.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (termsError != null) ...[
                    SizedBox(height: 4),
                    Text(
                      termsError!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(
                          context,
                        ).extension<AppColorTheme>()!.rose,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  AuthPrimaryButton(
                    label: 'Sign Up',
                    isLoading: isLoading,
                    onTap: () {
                      submit(context);
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => const RootView(),
                      //   ),
                      // );
                    },
                  ),
                  const SizedBox(height: 24),

                  const AuthDivider(),
                  const SizedBox(height: 24),

                  AuthSocialButton(label: 'Continue with Google', onTap: () {}),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).extension<AppColorTheme>()!.mutedFg,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).extension<AppColorTheme>()!.primary,
                          ),
                        ),
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
