import 'package:flutter/material.dart';

const _primary    = Color(0xFF5B4CB8);
const _primaryMid = Color(0xFF6556C8);
const _primaryEnd = Color(0xFF4338CA);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── Top gradient section ──
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_primary, _primaryMid, _primaryEnd],
                    ),
                  ),
                ),
                // Decorative blobs
                Positioned(
                  right: -40, top: -40,
                  child: _blob(256, Colors.white.withOpacity(0.10)),
                ),
                Positioned(
                  left: -40, bottom: 80,
                  child: _blob(256, Colors.indigo.shade400.withOpacity(0.20)),
                ),
                // Logo + text
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          // استبدله بـ Image.asset('assets/images/logo.png')
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 64,
                            height: 64,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Swaply',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Trade skills with people around the world —\nteach what you know, learn what you love.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.white.withOpacity(0.82),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom white section ──
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _btn(
                  label: 'Create Account',
                  onTap: () {/* Navigator.push -> SignupScreen */},
                  bg: _primary,
                  fg: Colors.white,
                  elevation: 4,
                  shadowColor: _primary.withOpacity(0.4),
                ),
                const SizedBox(height: 12),
                _btn(
                  label: 'I already have an account',
                  onTap: () {/* Navigator.push -> LoginScreen */},
                  bg: const Color(0xFFF0EFF8),
                  fg: _primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _btn({
    required String label,
    required VoidCallback onTap,
    required Color bg,
    required Color fg,
    double elevation = 0,
    Color? shadowColor,
  }) =>
      SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            elevation: elevation,
            shadowColor: shadowColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
}