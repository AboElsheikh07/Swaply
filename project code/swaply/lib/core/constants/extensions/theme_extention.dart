import 'package:flutter/material.dart';
import 'package:swaply/core/constants/app_colors.dart';

extension AppTheme on BuildContext {
  AppColorTheme get colors => Theme.of(this).extension<AppColorTheme>()!;
}
