import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';

class GoldActionsWidget extends StatelessWidget {
  final String goalId;

  const GoldActionsWidget({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            text: 'Add Gold Saving',
            onPressed: () => context.push('/add-saving/$goalId'),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.surfaceDark,
            border: Border.all(
              color: isLight ? AppColors.border : AppColors.borderDark,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications_active_outlined,
              color: isLight ? AppColors.primary : AppColors.accentDark,
            ),
            onPressed: () => context.push('/gold-alerts'),
            tooltip: 'Set Price Alerts',
          ),
        ),
      ],
    );
  }
}
