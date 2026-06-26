import re

with open('d:\\depi\\Swaply\\project code\\swaply\\lib\\features\\profile\\presentation\\screens\\profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Fix Theme Colors
content = re.sub(r'color:\s*_ProfileColors\.title', r'color: Theme.of(context).textTheme.bodyLarge?.color', content)
content = re.sub(r'color:\s*_ProfileColors\.subtleText', r'color: Theme.of(context).textTheme.bodyMedium?.color', content)
content = re.sub(r'color:\s*Colors\.grey\.shade600', r'color: Theme.of(context).textTheme.bodyMedium?.color', content)

# Fix consts around Theme
for _ in range(5):
    content = re.sub(r'const\s+([A-Za-z0-9_]+)\(([\s\S]{0,400}?)Theme\.of\(context\)', r'\1(\2Theme.of(context)', content)

# Routing
content = content.replace("onTopUp: () => _showPointsDialog(context, true),", "onTopUp: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TopUpScreen())),")
content = content.replace("onWithdraw: () => _showPointsDialog(context, false),", "onWithdraw: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WithdrawPointsScreen())),")
content = re.sub(r'void _showPointsDialog\([\s\S]*?showDialog[\s\S]*?\}\);\s*\}', '', content)

# Imports
content = content.replace("import 'package:swaply/features/sessions/presentation/screens/sessions_screen.dart';", "import 'package:swaply/features/sessions/presentation/screens/sessions_screen.dart';\nimport 'top_up_screen.dart';\nimport 'withdraw_points_screen.dart';")
content = content.replace("import 'package:flutter_bloc/flutter_bloc.dart';", "import 'dart:io';\nimport 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:image_picker/image_picker.dart';")

# Cubit and isDarkMode fixes missed from earlier commits
content = content.replace('isDarkModeEnabled', 'isDarkMode')
content = content.replace('ProfileCubit()', 'ProfileCubit(context.read<ProfileLocalDataSource>())')

# Image Picker Avatar
old_stack = '''          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  color: _ProfileColors.avatarBackground,
                  shape: BoxShape.circle,
                ),
              ),
              Positioned(
                right: -1,
                bottom: 2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _ProfileColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),'''

new_stack = '''          GestureDetector(
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
                    color: _ProfileColors.avatarBackground,
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
          ),'''

content = content.replace(old_stack, new_stack)

with open('d:\\depi\\Swaply\\project code\\swaply\\lib\\features\\profile\\presentation\\screens\\profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
