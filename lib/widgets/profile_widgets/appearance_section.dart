import 'package:flutter/material.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';
import 'package:focus_n_flow/theme/theme_controller.dart';

class AppearanceSection extends StatelessWidget {
  final ThemeController themeController;

  const AppearanceSection({
    super.key,
    required this.themeController,
  });

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Appearance',
          style: context.text.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        AppSpacing.gapMd,

        AnimatedBuilder(
          animation: themeController,
          builder: (context, _) {
            return DropdownButtonFormField<ThemeMode>(
              initialValue: themeController.themeMode,
              decoration: const InputDecoration(
                labelText: 'Theme Mode',
              ),
              items: ThemeMode.values.map((mode) {
                return DropdownMenuItem<ThemeMode>(
                  value: mode,
                  child: Text(
                    _themeModeLabel(mode),
                  ),
                );
              }).toList(),
              onChanged: (mode) async {
                if (mode == null) return;

                await themeController.setTheme(mode);
              },
            );
          },
        ),
      ],
    );
  }
}