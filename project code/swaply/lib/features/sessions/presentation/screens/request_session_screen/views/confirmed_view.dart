import 'package:flutter/material.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/shared_atoms/big_button.dart';
import 'package:swaply/root.dart';

class ConfirmedView extends StatelessWidget {
  final String mentorName;
  const ConfirmedView({super.key, required this.mentorName});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.greenBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 40, color: colors.green),
              ),
              const SizedBox(height: 20),
              Text(
                'Request sent!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We notified $mentorName. We will notify you once they accept.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colors.muted),
              ),
              const SizedBox(height: 32),
              BigBtn(
                label: 'View Sessions',
                filled: true,
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => RootView(index: 1)),
                ),
              ),
              const SizedBox(height: 10),
              BigBtn(
                label: 'Back to Home',
                filled: false,
                onTap: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
