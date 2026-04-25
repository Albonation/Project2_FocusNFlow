//the file defines a helper that allows us to easily access our custom theme extensions from the BuildContext
import 'package:flutter/material.dart';
import 'app_colors_extension.dart';

extension AppThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  TextTheme get text => theme.textTheme;

  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}