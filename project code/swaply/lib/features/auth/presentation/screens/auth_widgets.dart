import 'package:flutter/material.dart';

const authPrimary    = Color(0xFF5B4CB8);
const authMutedFg    = Color(0xFF8A8A9A);
const authBorder     = Color(0xFFEAEAF0);
const authErrorColor = Color(0xFFE53935);

// ── Back Button ──────────────────────────
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: authBorder),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
      ),
    );
  }
}

// ── Input Field ──────────────────────────
class AuthInputField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final IconData icon;
  final String? error;
  final bool obscureText;
  final Widget? trailing;
  final TextInputType keyboardType;

  const AuthInputField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.icon,
    this.error,
    this.obscureText = false,
    this.trailing,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(error!, style: const TextStyle(fontSize: 11, color: authErrorColor)),
        ],
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: hasError ? authErrorColor : authBorder),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(icon, size: 20, color: authMutedFg),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: const TextStyle(color: authMutedFg, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Checkbox ─────────────────────────────
class AuthCheckbox extends StatelessWidget {
  final bool value;
  final double size;

  const AuthCheckbox({super.key, required this.value, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: value ? authPrimary : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: value ? authPrimary : authBorder, width: 1.5),
      ),
      child: value
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
          : null,
    );
  }
}

// ── Primary Button ───────────────────────
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: authPrimary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: authPrimary.withOpacity(0.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Divider ──────────────────────────────
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: authBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        ),
        const Expanded(child: Divider(color: authBorder)),
      ],
    );
  }
}

// ── Social Button ────────────────────────
class AuthSocialButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AuthSocialButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: authBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // استبدل بـ Image.asset('assets/icons/google.png') لما يكون عندك الأيقونة
            const Icon(Icons.g_mobiledata_rounded, size: 24, color: Colors.red),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
