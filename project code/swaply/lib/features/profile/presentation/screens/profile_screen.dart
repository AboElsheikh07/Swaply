import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swaply/features/auth/presentation/screens/welcome_screen.dart';
import 'package:swaply/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:swaply/features/sessions/presentation/screens/sessions_screen/sessions_screen.dart';
import 'top_up_screen.dart';
import 'withdraw_points_screen.dart';

import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'package:swaply/l10n/app_localizations.dart';
import 'package:swaply/features/user/cubit/user_cubit.dart';
import 'package:swaply/features/user/cubit/user_state.dart';
import 'package:swaply/features/user/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileView();
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        final user = context.watch<UserCubit>().currentUser;
        return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _ProfileColors.pageBackground,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: _ProfileColors.pageBackground,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            elevation: 0,
            titleSpacing: 16,
            title: Text(
              l10n.myProfile,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AvatarSection(state: state, user: user),
                const SizedBox(height: 18),
                _PointsCard(
                  l10n: l10n,
                  points: user.balance,
                  onTopUp: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TopUpScreen())),
                  onWithdraw: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WithdrawPointsScreen())),
                ),
                const SizedBox(height: 14),
                _StatsRow(l10n: l10n, state: state, user: user),
                const SizedBox(height: 16),
                _SkillsSection(
                  l10n: l10n,
                  skills: user.skillsCanTeach,
                  onAddSkill: () => _showAddSkillDialog(context),
                ),
                const SizedBox(height: 14),
                _SettingsSection(
                  l10n: l10n,
                  state: state,
                  onEditProfile: () => _showEditProfileDialog(context, user),
                  onManageSkills: () => _showManageSkillsSheet(context, user),
                  onSessionHistory: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SessionsScreen()),
                  ),
                  onNotifications: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                  onPrivacy: () => _showPrivacyDialog(context),
                  onLanguage: () => _showLanguageDialog(context),
                  onDarkModeChanged: (bool _) => context
                      .read<ProfileCubit>()
                      .toggleDarkMode(),
                ),
                const SizedBox(height: 18),
                _LogoutButton(
                  l10n: l10n,
                  onTap: () {
                    final navigator = Navigator.of(context);
                    FirebaseAuth.instance.signOut().then((_) {
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                        (route) => false,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        );
          },
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, UserModel user) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: user.username);
    final emailController = TextEditingController(text: FirebaseAuth.instance.currentUser?.email ?? '');

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.editProfile),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                if (name.isEmpty || email.isEmpty) return;
                final userCubit = context.read<UserCubit>();
                userCubit.updateProfile(
                  username: name,
                  
                );
                Navigator.of(context).pop();
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final skillController = TextEditingController();
    final userCubit = context.read<UserCubit>();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.addSkill),
          content: TextField(
            controller: skillController,
            decoration: InputDecoration(
              labelText: l10n.newSkill,
              hintText: 'e.g. Illustration',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final skill = skillController.text.trim();
                if (skill.isEmpty) return;
                userCubit.addTeachSkill(skill);
                Navigator.of(context).pop();
              },
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }

  void _showManageSkillsSheet(BuildContext context, UserModel user) {
    final l10n = AppLocalizations.of(context)!;
    final newSkillController = TextEditingController();
    final skills = List<String>.from(user.skillsCanTeach);
    final userCubit = context.read<UserCubit>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.manageSkills,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 14),
                  if (skills.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        l10n.noSkillsAddedYet,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    )
                  else
                    Column(
                      children: skills.map((skill) {
                        return ListTile(
                          title: Text(skill),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: () {
                              userCubit.removeTeachSkill(skill);
                              setState(() => skills.remove(skill));
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  const Divider(height: 32),
                  TextField(
                    controller: newSkillController,
                    decoration: const InputDecoration(
                      labelText: 'New skill',
                      hintText: 'Add a new skill',
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      final skill = newSkillController.text.trim();
                      if (skill.isEmpty) return;
                      userCubit.addTeachSkill(skill);
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.close),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final skill = newSkillController.text.trim();
                            if (skill.isEmpty) return;
                            userCubit.addTeachSkill(skill);
                            Navigator.of(context).pop();
                          },
                          child: Text(l10n.addSkill),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languages = ['English', 'Arabic'];

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) {
              return ListTile(
                title: Text(language),
                onTap: () {
                  context.read<ProfileCubit>().updateLanguage(language);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  void _showPointsDialog(BuildContext context, bool isTopUp) {
    final l10n = AppLocalizations.of(context)!;
    final amounts = [20, 50, 100];

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isTopUp ? 'Top up points' : 'Withdraw points'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: amounts.map((amount) {
              return ListTile(
                title: Text('$amount pts'),
                onTap: () {
                  if (isTopUp) {
                    context.read<ProfileCubit>().topUpPoints(amount);
                  } else {
                    context.read<ProfileCubit>().withdrawPoints(amount);
                  }
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.privacySecurity),
          content: const Text(
            'Your privacy settings are in a safe place. You can manage app permissions,/n data sharing and security notifications here.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final ProfileState state;
  final UserModel user;

  const _AvatarSection({required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              final file = await picker.pickImage(source: ImageSource.gallery);
              if (file != null && context.mounted) {
                context.read<ProfileCubit>().updateProfileImage(file.path);
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    image: state.profileImagePath != null
                        ? DecorationImage(
                            image: FileImage(File(state.profileImagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                    border: Border.all(color: Theme.of(context).cardColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: state.profileImagePath == null
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).unselectedWidgetColor,
                        )
                      : null,
                ),
                Positioned(
                  right: -1,
                  bottom: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).cardColor, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.username,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            (FirebaseAuth.instance.currentUser?.email ?? ''),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  final AppLocalizations l10n;
  final int points;
  final VoidCallback onTopUp;
  final VoidCallback onWithdraw;

  const _PointsCard({
    required this.l10n,
    required this.points,
    required this.onTopUp,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_ProfileColors.primary, _ProfileColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _ProfileColors.primary.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            right: 10,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.monetization_on_outlined,
                color: Colors.white.withValues(alpha: 0.65),
                size: 28,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.points,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$points pts',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 0.95,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Earn points by teaching skills.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.84),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _BalanceActionButton(
                        label: l10n.topUp,
                        isPrimary: true,
                        onTap: onTopUp,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _BalanceActionButton(
                        label: l10n.withdraw,
                        isPrimary: false,
                        onTap: onWithdraw,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _BalanceActionButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary
              ? Colors.white
              : Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
          border: isPrimary
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isPrimary ? _ProfileColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AppLocalizations l10n;
  final ProfileState state;
  final UserModel user;

  const _StatsRow({
    required this.l10n,required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.star_rounded,
            iconColor: _ProfileColors.star,
            value: user.ratingAvg.toStringAsFixed(1),
            label: l10n.rating,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(value: user.ratingCount.toString(), label: l10n.reviews),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(value: '0', label: l10n.sessions),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String value;
  final String label;

  const _StatCard({
    this.icon,
    this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ProfileColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: iconColor),
                SizedBox(width: 4),
              ],
              Text(
                value,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  final AppLocalizations l10n;
  final List<String> skills;
  final VoidCallback onAddSkill;

  _SkillsSection({required this.l10n, required this.skills, required this.onAddSkill});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.skillsCanTeach.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final skill in skills) _SkillChip(label: skill),
            _AddSkillChip(onTap: onAddSkill),
          ],
        ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;

  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _ProfileColors.skillChipBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _ProfileColors.primary,
        ),
      ),
    );
  }
}

class _AddSkillChip extends StatelessWidget {
  final VoidCallback onTap;

  const _AddSkillChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRRectPainter(
          color: _ProfileColors.dashedBorder,
          radius: 18,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            '+ ${l10n.addSkill}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final AppLocalizations l10n;
  final ProfileState state;
  final VoidCallback onEditProfile;
  final VoidCallback onManageSkills;
  final VoidCallback onSessionHistory;
  final VoidCallback onNotifications;
  final VoidCallback onPrivacy;
  final VoidCallback onLanguage;
  final ValueChanged<bool> onDarkModeChanged;

  const _SettingsSection({
    required this.l10n,
    required this.state,
    required this.onEditProfile,
    required this.onManageSkills,
    required this.onSessionHistory,
    required this.onNotifications,
    required this.onPrivacy,
    required this.onLanguage,
    required this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ProfileColors.border),
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.mode_edit_outline_outlined,
            label: l10n.editProfile,
            onTap: onEditProfile,
          ),
          const _SettingsDivider(),
          _SettingsTile(
            icon: Icons.auto_awesome_motion_outlined,
            label: l10n.manageSkills,
            onTap: onManageSkills,
          ),
          const _SettingsDivider(),
          _SettingsTile(
            icon: Icons.calendar_today_outlined,
            label: l10n.sessionHistory,
            onTap: onSessionHistory,
          ),
          const _SettingsDivider(),
          _SettingsTile(
            icon: Icons.notifications_none_rounded,
            label: l10n.notifications,
            onTap: onNotifications,
          ),
          const _SettingsDivider(),
          _SettingsTile(
            icon: Icons.shield_outlined,
            label: l10n.privacySecurity,
            onTap: onPrivacy,
          ),
          const _SettingsDivider(),
          _SettingsTile(
            icon: Icons.language_rounded,
            label: l10n.language,
            onTap: onLanguage,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.language,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ],
            ),
          ),
          const _SettingsDivider(),
          _SettingsTile(
            icon: CupertinoIcons.moon,
            label: l10n.darkMode,
            trailing: CupertinoSwitch(
              value: state.isDarkMode,
              onChanged: onDarkModeChanged,
              activeTrackColor: _ProfileColors.primary,
              thumbColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: _ProfileColors.iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 15, color: _ProfileColors.primary),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: _ProfileColors.divider,
      indent: 14,
      endIndent: 14,
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback? onTap;

  const _LogoutButton({
    required this.l10n,this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _ProfileColors.logoutBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              size: 18,
              color: _ProfileColors.logoutText,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.logout,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _ProfileColors.logoutText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedRRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    const dashWidth = 5.0;
    const dashSpace = 4.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

abstract class _ProfileColors {
  static const Color pageBackground = Color(0xFFF7F6FB);
  static const Color title = Color(0xFF17141F);
  static const Color subtleText = Color(0xFF8D8A98);
  static const Color border = Color(0xFFE6E2EF);
  static const Color divider = Color(0xFFEEEAF5);
  static const Color avatarBackground = Color(0xFFE8E7EA);
  static const Color iconBackground = Color(0xFFF1EDFF);
  static const Color skillChipBackground = Color(0xFFF1EDFF);
  static const Color dashedBorder = Color(0xFFD4D0DD);
  static const Color primary = Color(0xFF5B47E7);
  static const Color primaryDark = Color(0xFF6A58EE);
  static const Color star = Color(0xFFF4B400);
  static const Color logoutBackground = Color(0xFFFBEAEB);
  static const Color logoutText = Color(0xFFE74A5A);
}
