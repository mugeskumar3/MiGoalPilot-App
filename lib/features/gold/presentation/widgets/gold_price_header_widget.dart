import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/models/models.dart';

class GoldPriceHeaderWidget extends StatelessWidget {
  final GoldPrice livePrice;

  const GoldPriceHeaderWidget({super.key, required this.livePrice});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: GoldPriceWidget(
                price: livePrice.rate22K,
                change: livePrice.dailyChangePercentage,
                karat: '22K',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GoldPriceWidget(
                price: livePrice.rate24K,
                change: livePrice.dailyChangePercentage,
                karat: '24K',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Rates closing closure: ${DateFormat('hh:mm a').format(livePrice.lastUpdated)}',
            style: AppTextStyles.caption.copyWith(
              color: isLight
                  ? AppColors.textSecondary
                  : AppColors.textLightDark,
            ),
          ),
        ),
        const SizedBox(height: 24),

        if (livePrice.dailyChangePercentage < -1.0) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              'Gold is down ${livePrice.dailyChangePercentage.abs()}% today. Ideal time to purchase grams for active linked targets.',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}
