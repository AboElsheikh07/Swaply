import 'package:flutter/material.dart';
import 'package:swaply/core/constants/app_colors.dart';



// ── Back Button ──────────────────────────
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator.canPop(context) == true
        ? GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).extension<AppColorTheme>()!.card,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).extension<AppColorTheme>()!.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
            ),
          )
        : Container();
  }
}

// ── Input Field ──────────────────────────
class AuthInputField extends StatefulWidget {
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
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTheme>()!;
    final hasError = widget.error != null;

    final borderColor = hasError
        ? colors.rose
        : _focused
            ? colors.primary
            : colors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            widget.error!,
            style: TextStyle(fontSize: 11, color: colors.rose),
          ),
        ],
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: colors.background, // darker than card → field now recesses instead of blending
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: hasError || _focused ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(
                widget.icon,
                size: 20,
                color: _focused ? colors.primary : colors.mutedFg,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  style: TextStyle(fontSize: 14, color: colors.text),
                  cursorColor: colors.primary,
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: TextStyle(
                      color: colors.mutedFg,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (widget.trailing != null) ...[
                widget.trailing!,
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
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: value ? Theme.of(context).extension<AppColorTheme>()!.primary : Theme.of(context).extension<AppColorTheme>()!.card,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: value ? Theme.of(context).extension<AppColorTheme>()!.primary : Theme.of(context).extension<AppColorTheme>()!.border,
          width: 1.5,
        ),
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
          backgroundColor: Theme.of(context).extension<AppColorTheme>()!.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Theme.of(context).extension<AppColorTheme>()!.primary.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
        Expanded(child: Divider(color: Theme.of(context).extension<AppColorTheme>()!.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(fontSize: 12, color: Theme.of(context).extension<AppColorTheme>()!.muted),
          ),
        ),
        Expanded(child: Divider(color: Theme.of(context).extension<AppColorTheme>()!.border)),
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
          side: BorderSide(color: Theme.of(context).extension<AppColorTheme>()!.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.g_mobiledata_rounded, size: 24, color: Colors.red),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).extension<AppColorTheme>()!.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
