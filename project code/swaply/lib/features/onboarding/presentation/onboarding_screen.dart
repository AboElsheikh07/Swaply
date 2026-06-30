import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swaply/core/constants/app_colors.dart';
import 'package:swaply/root.dart';
import 'controllers/cubit/onboarding_cubit.dart';
import 'controllers/cubit/onboarding_state.dart';

const _skillPool = [
  'UI Design',
  'UX Research',
  'Figma',
  'Design Systems',
  'Illustration',
  'Branding',
  'JavaScript',
  'TypeScript',
  'React',
  'Next.js',
  'Flutter',
  'Python',
  'Public Speaking',
  'Copywriting',
  'Video Editing',
  'Photography',
  'Spanish',
  'French',
  'Mandarin',
  'Guitar',
  'Piano',
  'Yoga',
  'Meditation',
  'Cooking',
  'Marketing',
  'SEO',
  'Data Science',
  'Adobe XD',
  'After Effects',
  'Kotlin',
  'Swift',
  'Node.js',
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
  int step = 0;

  File? profileImage;
  List<String> teachSkills = [];
  List<String> learnSkills = [];
  int pricePerHour = 30;

  void nextStep() => setState(() => step++);
  void prevStep() => setState(() => step--);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTheme>()!;

    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingSuccess) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        if (state is OnboardingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colors.rose,
            ),
          );
          context.read<OnboardingCubit>().resetState();
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
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
              onFinish: () =>
                  context.read<OnboardingCubit>().completeOnboarding(
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
  final double progress;
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
    final colors = Theme.of(context).extension<AppColorTheme>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.card,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: colors.text,
                ),
              ),
            )
          else
            const SizedBox(height: 40),
          const SizedBox(height: 16),
          Text(
            step,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: colors.mutedFg, height: 1.4),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation(colors.primary),
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
class StepPhotoScreen extends StatefulWidget {
  final File? profileImage;
  final ValueChanged<File> onImagePicked;
  final VoidCallback onNext;

  const StepPhotoScreen({
    super.key,
    required this.profileImage,
    required this.onImagePicked,
    required this.onNext,
  });

  @override
  State<StepPhotoScreen> createState() => _StepPhotoScreenState();
}

class _StepPhotoScreenState extends State<StepPhotoScreen> {
  Future<void> _pickImage() async {
    // ✅ capture context-dependent things before any await
    final colors = Theme.of(context).extension<AppColorTheme>()!;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    // ✅ Step 1 — show bottom sheet
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      useRootNavigator: true, // ← ADD THIS — prevents context issues
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: colors.primary),
              title: Text('Take a photo', style: TextStyle(color: colors.text)),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: colors.primary,
              ),
              title: Text(
                'Choose from gallery',
                style: TextStyle(color: colors.text),
              ),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    // ✅ user dismissed sheet without picking
    if (source == null) return;

    // ✅ Step 2 — pick image
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800, // ← ADD THIS — reduces memory pressure
        maxHeight: 800, // ← ADD THIS
      );

      if (!mounted || picked == null) return;
      widget.onImagePicked(File(picked.path));
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'camera_access_denied' || e.code == 'photo_access_denied') {
        _showPermissionDialog(nav);
      }
    } catch (e) {
      // ✅ ADD — catches any other crash silently instead of closing the app
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not pick image. Please try again.'),
        ),
      );
    }
  }

  void _showPermissionDialog(NavigatorState nav) {
    nav.push(
      DialogRoute(
        context: nav.context,
        builder: (_) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Please allow access in your device settings to continue.',
          ),
          actions: [
            TextButton(onPressed: () => nav.pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                nav.pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTheme>()!;

    return Column(
      children: [
        OnboardingHeader(
          step: 'STEP 1 OF 3',
          title: 'Add a profile photo',
          subtitle:
              'A photo helps other members recognize you and builds trust.',
          progress: 1 / 3,
        ),
        const SizedBox(height: 48),
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colors.primarySoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border, width: 2),
                ),
                child: widget.profileImage != null
                    ? ClipOval(
                        child: Image.file(
                          widget.profileImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person_outline_rounded,
                        color: colors.primary,
                        size: 52,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.card, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.profileImage != null
              ? 'Tap to change photo'
              : 'Tap to add a photo',
          style: TextStyle(fontSize: 13, color: colors.mutedFg),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: Text(
                widget.profileImage != null
                    ? 'Continue'
                    : 'Continue without photo',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
  String query = '';

  List<String> get activeList =>
      isTeachTab ? widget.teachSkills : widget.learnSkills;

  void toggle(String skill) {
    final current = List<String>.from(activeList);
    current.contains(skill) ? current.remove(skill) : current.add(skill);
    isTeachTab
        ? widget.onTeachChanged(current)
        : widget.onLearnChanged(current);
  }

  List<String> get filtered => _skillPool
      .where((s) => s.toLowerCase().contains(query.toLowerCase()))
      .toList();

  bool get canContinue =>
      widget.teachSkills.isNotEmpty || widget.learnSkills.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTheme>()!;

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TabBtn(
                    label:
                        'I can teach'
                        '${widget.teachSkills.isNotEmpty ? " · ${widget.teachSkills.length}" : ""}',
                    active: isTeachTab,
                    onTap: () => setState(() => isTeachTab = true),
                  ),
                ),
                Expanded(
                  child: _TabBtn(
                    label:
                        'I want to learn'
                        '${widget.learnSkills.isNotEmpty ? " · ${widget.learnSkills.length}" : ""}',
                    active: !isTeachTab,
                    onTap: () => setState(() => isTeachTab = false),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(Icons.search_rounded, size: 18, color: colors.mutedFg),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => query = v),
                    style: TextStyle(fontSize: 13, color: colors.text),
                    decoration: InputDecoration(
                      hintText: 'Search skills...',
                      hintStyle: TextStyle(color: colors.mutedFg, fontSize: 13),
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
        if (activeList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${activeList.length} skill${activeList.length == 1 ? "" : "s"} selected',
                style: TextStyle(fontSize: 12, color: colors.mutedFg),
              ),
            ),
          ),
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
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? colors.primary : colors.card,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: selected ? colors.primary : colors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected) ...[
                          const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          skill,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : colors.text,
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
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: colors.card,
            border: Border(top: BorderSide(color: colors.border)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onNext,
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.mutedFg,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: canContinue ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: colors.border,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTheme>()!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? colors.card : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? colors.text : colors.mutedFg,
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
  static const _min = 5;
  static const _max = 150;
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
    _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTheme>()!;

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.primarySoft,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      'YOUR RATE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: colors.mutedFg,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _PriceBtn(
                          icon: Icons.remove_rounded,
                          onTap: () => setPrice(widget.price - 5),
                        ),
                        const SizedBox(width: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Icon(
                              Icons.toll_rounded,
                              color: colors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 90,
                              child: TextField(
                                controller: _ctrl,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: colors.text,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                onChanged: (v) {
                                  final n = int.tryParse(v);
                                  if (n != null) setPrice(n);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        _PriceBtn(
                          icon: Icons.add_rounded,
                          onTap: () => setPrice(widget.price + 5),
                        ),
                      ],
                    ),
                    Text(
                      'points per hour',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: colors.primary,
                      inactiveTrackColor: colors.border,
                      thumbColor: colors.primary,
                      overlayColor: colors.primary.withOpacity(0.12),
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
                      children: [
                        Text(
                          '$_min pts',
                          style: TextStyle(fontSize: 11, color: colors.mutedFg),
                        ),
                        Text(
                          '$_max pts',
                          style: TextStyle(fontSize: 11, color: colors.mutedFg),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUGGESTED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: colors.mutedFg,
                    ),
                  ),
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
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: active ? colors.primary : colors.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active ? colors.primary : colors.border,
                            ),
                          ),
                          child: Text(
                            '$s pts/hr',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: active ? Colors.white : colors.text,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: colors.mutedFg,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You can change this anytime from your profile.',
                        style: TextStyle(fontSize: 12, color: colors.mutedFg),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : widget.onFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
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
                      : const Text(
                          'Finish Setup',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
    final colors = Theme.of(context).extension<AppColorTheme>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.card,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6),
          ],
        ),
        child: Icon(icon, size: 20, color: colors.text),
      ),
    );
  }
}
