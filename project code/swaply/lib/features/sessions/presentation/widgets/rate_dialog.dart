import 'package:flutter/material.dart';
import 'package:swaply/core/constants/app_colors.dart';

class RateDialog {
  static void show(
    BuildContext context, {
    required String name,
    required String skill,
    required String role, // 'teacher' or 'student'
    required void Function(int stars, String? review) onSubmit,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => _RateDialogContent(
        name: name,
        skill: skill,
        role: role,
        onSubmit: onSubmit,
      ),
    );
  }
}

class _RateDialogContent extends StatefulWidget {
  final String name;
  final String skill;
  final String role;
  final void Function(int stars, String? review) onSubmit;

  const _RateDialogContent({
    required this.name,
    required this.skill,
    required this.role,
    required this.onSubmit,
  });

  @override
  State<_RateDialogContent> createState() => _RateDialogContentState();
}

class _RateDialogContentState extends State<_RateDialogContent> {
  int _selected = 0;
  int _hovered = 0;
  final _reviewController = TextEditingController();

  static const _labels = ['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent!'];
  static const _labelColors = [
    Colors.transparent,
    AppColors.rose,
    AppColors.amber,
    AppColors.green,
    AppColors.sky,
    AppColors.primary,
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayStar = _hovered > 0 ? _hovered : _selected;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          // ← ADD THIS
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Close button ────────────────
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // ── Avatar ──────────────────────
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEECFB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),

              const SizedBox(height: 12),

              // ── Name ────────────────────────
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 6),

              // ── Skill tag ───────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEECFB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.skill,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 20),

              // ── Question ────────────────────
              Text(
                'How was your session with\n${widget.name}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 16),

              // ── Stars ───────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final val = i + 1;
                  final filled = val <= displayStar;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = val),
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hovered = val),
                      onExit: (_) => setState(() => _hovered = 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          filled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: filled ? 42 : 38,
                          color: filled ? AppColors.amber : AppColors.border,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // ── Star label ──────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: _selected > 0
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _labels[_selected],
                          key: ValueKey(_selected),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _labelColors[_selected],
                          ),
                        ),
                      )
                    : const SizedBox(height: 26),
              ),

              const SizedBox(height: 16),

              // ── Review input ────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Leave a review ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      TextSpan(
                        text: '(optional)',
                        style: TextStyle(fontSize: 13, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _reviewController,
                maxLines: 3,
                maxLength: 300,
                style: const TextStyle(fontSize: 13, color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'Share your experience with this ${widget.role}…',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.muted,
                  ),
                  counterStyle: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Buttons ─────────────────────
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Submit
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _selected == 0
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              widget.onSubmit(
                                _selected,
                                _reviewController.text.trim().isEmpty
                                    ? null
                                    : _reviewController.text.trim(),
                              );
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: _selected == 0
                              ? AppColors.primary.withValues(alpha: 0.35)
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Text(
                            'Submit Rating',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
