import 'package:flutter/material.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';

class MiSectionHeader extends StatelessWidget {
  final String title;

  const MiSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: isLight
              ? AppColors.textSecondary
              : AppColors.textSecondaryDark,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          fontSize: 10,
        ),
      ),
    );
  }
}
