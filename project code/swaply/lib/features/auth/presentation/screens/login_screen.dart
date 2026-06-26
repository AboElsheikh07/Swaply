import 'package:flutter/material.dart';
import 'package:swaply/core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/core/constants/app_colors.dart';
import 'package:swaply/features/forgot_password/presentation/screens/forgot_password_screen.dart';
import 'package:swaply/root.dart';
import 'package:swaply/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:swaply/features/auth/presentation/cubit/auth_state.dart';
import 'package:swaply/features/auth/data/repositories/auth_repository_firebase.dart';
import 'signup_screen.dart';
import 'auth_widgets.dart';



const authPrimary = AppColors.primary;
const authMutedFg = AppColors.mutedFg;
const authBorder = AppColors.border;
const authErrorColor = AppColors.rose;

// ════════════════════════════════════════
//  Entry point
// ════════════════════════════════════════
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(FirebaseAuthRepository()),
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
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool showPassword = false;
  bool savePassword = true;
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
                backgroundColor: Theme.of(context).extension<AppColorTheme>()!.rose,
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
                    'Welcome back',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign in to continue trading skills on Swaply.',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).extension<AppColorTheme>()!.mutedFg),
                  ),
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
                        showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Theme.of(context).extension<AppColorTheme>()!.mutedFg,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Save password + Forgot
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => savePassword = !savePassword),
                        child: Row(
                          children: [
                            AuthCheckbox(value: savePassword),
                            SizedBox(width: 8),
                            Text(
                              'Save password',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).extension<AppColorTheme>()!.mutedFg,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).extension<AppColorTheme>()!.primary,
                          ),
                        ),
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
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 14, color: Theme.of(context).extension<AppColorTheme>()!.mutedFg),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).extension<AppColorTheme>()!.primary,
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
