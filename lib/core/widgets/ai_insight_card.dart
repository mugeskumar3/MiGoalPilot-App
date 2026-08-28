import 'package:flutter/material.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';

class AiInsightCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onViewDetails;

  const AiInsightCard({
    super.key,
    required this.title,
    required this.description,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF2EFE8) : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLight ? const Color(0xFFE5DFD0) : AppColors.borderDark,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isLight
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Text('✨', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: isLight ? AppColors.primary : AppColors.accentDark,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.primary : const Color(0xFFE2E8F0),
              height: 1.5,
              fontSize: 14,
              fontWeight: isLight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (onViewDetails != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onViewDetails,
              child: Row(
                children: [
                  Text(
                    'Consult GoalPilot AI',
                    style: AppTextStyles.caption.copyWith(
                      color: isLight ? AppColors.primary : AppColors.accentDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: isLight ? AppColors.primary : AppColors.accentDark,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
