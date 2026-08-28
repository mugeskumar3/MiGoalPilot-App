import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/models/models.dart';

class GoldLinkedGoalsWidget extends StatelessWidget {
  final List<Goal> goldGoals;

  const GoldLinkedGoalsWidget({super.key, required this.goldGoals});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const MiSectionHeader(title: "Linked Gold Goals"),
            TextButton(
              onPressed: () => context.push('/goals'),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                'Manage',
                style: TextStyle(
                  color: isLight
                      ? AppColors.primary
                      : AppColors.accentDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (goldGoals.isEmpty)
          const EmptyState(
            title: 'No Linked Gold Goals',
            description:
                'Link a gold target to purchase grams periodically.',
          )
        else
          ...goldGoals.map((g) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: isLight ? AppColors.surface : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLight
                          ? AppColors.border
                          : AppColors.borderDark,
                      width: 1.2,
                    ),
                  ),
                  child: ListTile(
                    onTap: () => context.push('/gold-goals/${g.id}'),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isLight
                            ? AppColors.background
                            : AppColors.backgroundDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '🥇',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text(
                      g.name,
                      style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${g.purchasedGrams}g accumulated of ${g.targetGrams}g target',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isLight
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryDark,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: isLight
                          ? AppColors.primary
                          : AppColors.accentDark,
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
