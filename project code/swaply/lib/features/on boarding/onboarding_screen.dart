import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swaply/features/on%20boarding/onboarding_cubit.dart';
import 'package:swaply/features/on%20boarding/onboarding_state.dart';

const _primary     = Color(0xFF5B4CB8);
const _primarySoft = Color(0xFFEEECFB);
const _mutedFg     = Color(0xFF8A8A9A);
const _border      = Color(0xFFEAEAF0);
const _dark        = Color(0xFF1A1A2E);
const _errorColor  = Color(0xFFE53935);

const _skillPool = [
  'UI Design', 'UX Research', 'Figma', 'Design Systems', 'Illustration',
  'Branding', 'JavaScript', 'TypeScript', 'React', 'Next.js', 'Flutter',
  'Python', 'Public Speaking', 'Copywriting', 'Video Editing', 'Photography',
  'Spanish', 'French', 'Mandarin', 'Guitar', 'Piano', 'Yoga',
  'Meditation', 'Cooking', 'Marketing', 'SEO', 'Data Science', 'Figma',
  'Adobe XD', 'After Effects', 'Kotlin', 'Swift', 'Node.js',
];

// ════════════════════════════════════════
//  Entry point
// ════════════════════════════════════════
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: const OnboardingFlow(),
    );
  }
}

// ════════════════════════════════════════
//  Flow controller
// ════════════════════════════════════════
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => OnboardingFlowState();
}

class OnboardingFlowState extends State<OnboardingFlow> {
  int step = 0; // 0=photo, 1=skills, 2=price

  // Shared state across steps
  File? profileImage;
  List<String> teachSkills = [];
  List<String> learnSkills = [];
  int pricePerHour = 30;

  void nextStep() => setState(() => step++);
  void prevStep() => setState(() => step--);

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingSuccess) {
          // Navigate to home after onboarding completes
          Navigator.of(context).pushReplacementNamed('/home');
        }
        if (state is OnboardingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: _errorColor,
            ),
          );
          context.read<OnboardingCubit>().resetState();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: switch (step) {
            0 => StepPhotoScreen(
                profileImage: profileImage,
                onImagePicked: (f) => setState(() => profileImage = f),
                onNext: nextStep,
              ),
            1 => StepSkillsScreen(
                teachSkills: teachSkills,
                learnSkills: learnSkills,
                onTeachChanged: (s) => setState(() => teachSkills = s),
                onLearnChanged: (s) => setState(() => learnSkills = s),
                onNext: nextStep,
                onBack: prevStep,
              ),
            2 => StepPriceScreen(
                price: pricePerHour,
                onPriceChanged: (p) => setState(() => pricePerHour = p),
                onBack: prevStep,
                onFinish: () => context.read<OnboardingCubit>().completeOnboarding(
                  teachSkills: teachSkills,
                  learnSkills: learnSkills,
                  pricePerHour: pricePerHour,
                  profileImage: profileImage,
                ),
              ),
            _ => const SizedBox(),
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
//  Shared top bar widget
// ════════════════════════════════════════
class OnboardingHeader extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  final double progress; // 0.0 → 1.0
  final VoidCallback? onBack;

  const OnboardingHeader({
    super.key,
    required this.step,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5FA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              ),
            )
          else
            const SizedBox(height: 40),
          const SizedBox(height: 16),

          Text(step,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: _primary)),
          const SizedBox(height: 6),
          Text(title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(fontSize: 13, color: _mutedFg, height: 1.4)),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFEAEAF0),
              valueColor: const AlwaysStoppedAnimation(_primary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════
//  STEP 1 — Profile Photo
// ════════════════════════════════════════
class StepPhotoScreen extends StatelessWidget {
  final File? profileImage;
  final ValueChanged<File> onImagePicked;
  final VoidCallback onNext;

  const StepPhotoScreen({
    super.key,
    required this.profileImage,
    required this.onImagePicked,
    required this.onNext,
  });

  Future<void> pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                    color: _border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: _primary),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: _primary),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) onImagePicked(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OnboardingHeader(
          step: 'STEP 1 OF 3',
          title: 'Add a profile photo',
          subtitle: 'A photo helps other members recognize you and builds trust.',
          progress: 1 / 3,
        ),
        const SizedBox(height: 48),

        // Avatar picker
        GestureDetector(
          onTap: () => pickImage(context),
          child: Stack(
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: _primarySoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: _border, width: 2),
                ),
                child: profileImage != null
                    ? ClipOval(
                        child: Image.file(profileImage!, fit: BoxFit.cover))
                    : const Icon(Icons.person_outline_rounded,
                        color: _primary, size: 52),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: _primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profileImage != null ? 'Tap to change photo' : 'Tap to add a photo',
          style: const TextStyle(fontSize: 13, color: _mutedFg),
        ),
        const Spacer(),

        // Footer
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                  child: Text(
                    profileImage != null ? 'Continue' : 'Continue without photo',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════
//  STEP 2 — Skills
// ════════════════════════════════════════
class StepSkillsScreen extends StatefulWidget {
  final List<String> teachSkills;
  final List<String> learnSkills;
  final ValueChanged<List<String>> onTeachChanged;
  final ValueChanged<List<String>> onLearnChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StepSkillsScreen({
    super.key,
    required this.teachSkills,
    required this.learnSkills,
    required this.onTeachChanged,
    required this.onLearnChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<StepSkillsScreen> createState() => StepSkillsScreenState();
}

class StepSkillsScreenState extends State<StepSkillsScreen> {
  bool isTeachTab = true;
  String query    = '';

  List<String> get activeList =>
      isTeachTab ? widget.teachSkills : widget.learnSkills;

  void toggle(String skill) {
    final current = List<String>.from(activeList);
    if (current.contains(skill)) {
      current.remove(skill);
    } else {
      current.add(skill);
    }
    if (isTeachTab) {
      widget.onTeachChanged(current);
    } else {
      widget.onLearnChanged(current);
    }
  }

  List<String> get filtered => _skillPool
      .where((s) => s.toLowerCase().contains(query.toLowerCase()))
      .toList();

  bool get canContinue =>
      widget.teachSkills.isNotEmpty || widget.learnSkills.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OnboardingHeader(
          step: 'STEP 2 OF 3',
          title: 'Pick your skills',
          subtitle: 'Choose what you can teach and what you\'d like to learn.',
          progress: 2 / 3,
          onBack: widget.onBack,
        ),
        const SizedBox(height: 16),

        // Toggle tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5FA),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              children: [
                Expanded(child: _TabBtn(
                  label: 'I can teach'
                      '${widget.teachSkills.isNotEmpty ? " · ${widget.teachSkills.length}" : ""}',
                  active: isTeachTab,
                  onTap: () => setState(() => isTeachTab = true),
                )),
                Expanded(child: _TabBtn(
                  label: 'I want to learn'
                      '${widget.learnSkills.isNotEmpty ? " · ${widget.learnSkills.length}" : ""}',
                  active: !isTeachTab,
                  onTap: () => setState(() => isTeachTab = false),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded, size: 18, color: _mutedFg),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => query = v),
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Search skills...',
                      hintStyle: TextStyle(color: _mutedFg, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Count label
        if (activeList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${activeList.length} skill${activeList.length == 1 ? "" : "s"} selected',
                style: const TextStyle(fontSize: 12, color: _mutedFg),
              ),
            ),
          ),

        // Skills chips
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filtered.map((skill) {
                final selected = activeList.contains(skill);
                return GestureDetector(
                  onTap: () => toggle(skill),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: selected ? _primary : Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border:
                          Border.all(color: selected ? _primary : _border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected) ...[
                          const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          skill,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : _dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Footer
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _border)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onNext,
                child: const Text('Skip for now',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _mutedFg)),
              ),
              const Spacer(),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: canContinue ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _border,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                  child: const Text('Continue',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 1))
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? _dark : _mutedFg,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
//  STEP 3 — Price per hour
// ════════════════════════════════════════
class StepPriceScreen extends StatefulWidget {
  final int price;
  final ValueChanged<int> onPriceChanged;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  const StepPriceScreen({
    super.key,
    required this.price,
    required this.onPriceChanged,
    required this.onBack,
    required this.onFinish,
  });

  @override
  State<StepPriceScreen> createState() => StepPriceScreenState();
}

class StepPriceScreenState extends State<StepPriceScreen> {
  static const _min       = 5;
  static const _max       = 150;
  static const _suggested = [10, 25, 50, 75];

  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.price}');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int clamp(int val) => val.clamp(_min, _max);

  void setPrice(int val) {
    final clamped = clamp(val);
    widget.onPriceChanged(clamped);
    _ctrl.text = '$clamped';
    _ctrl.selection =
        TextSelection.collapsed(offset: _ctrl.text.length);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final isLoading = state is OnboardingLoading;

        return Column(
          children: [
            OnboardingHeader(
              step: 'STEP 3 OF 3',
              title: 'Set your price',
              subtitle:
                  'How many points per hour would you like to charge for teaching sessions?',
              progress: 1.0,
              onBack: widget.onBack,
            ),
            const SizedBox(height: 24),

            // Price display card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _primarySoft,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  children: [
                    const Text('YOUR RATE',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: _mutedFg)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Minus button
                        _PriceBtn(
                          icon: Icons.remove_rounded,
                          onTap: () => setPrice(widget.price - 5),
                        ),
                        const SizedBox(width: 20),
                        // Price input
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Icon(Icons.toll_rounded,
                                color: _primary, size: 24),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 90,
                              child: TextField(
                                controller: _ctrl,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: _dark,
                                ),
                                decoration: const InputDecoration(
                                    border: InputBorder.none),
                                onChanged: (v) {
                                  final n = int.tryParse(v);
                                  if (n != null) setPrice(n);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        // Plus button
                        _PriceBtn(
                          icon: Icons.add_rounded,
                          onTap: () => setPrice(widget.price + 5),
                        ),
                      ],
                    ),
                    const Text('points per hour',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _primary,
                      inactiveTrackColor: _border,
                      thumbColor: _primary,
                      overlayColor: _primary.withOpacity(0.12),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      min: _min.toDouble(),
                      max: _max.toDouble(),
                      divisions: ((_max - _min) / 5).round(),
                      value: widget.price.toDouble(),
                      onChanged: (v) => setPrice(v.round()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('$_min pts',
                            style:
                                TextStyle(fontSize: 11, color: _mutedFg)),
                        Text('$_max pts',
                            style:
                                TextStyle(fontSize: 11, color: _mutedFg)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Suggested chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SUGGESTED',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: _mutedFg)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _suggested.map((s) {
                      final active = widget.price == s;
                      return GestureDetector(
                        onTap: () => setPrice(s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: active ? _primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: active ? _primary : _border),
                          ),
                          child: Text(
                            '$s pts/hr',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: active ? Colors.white : _dark,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hint
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: _mutedFg),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You can change this anytime from your profile.',
                        style: TextStyle(fontSize: 12, color: _mutedFg),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Finish button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : widget.onFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('Finish Setup',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PriceBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PriceBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08), blurRadius: 6)
          ],
        ),
        child: Icon(icon, size: 20, color: _dark),
      ),
    );
  }
}
