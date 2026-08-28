import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';

class GoldPriceWidget extends StatelessWidget {
  final double price;
  final double change;
  final String karat;

  const GoldPriceWidget({
    super.key,
    required this.price,
    required this.change,
    this.karat = '22K',
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? AppColors.surface : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLight ? AppColors.border : AppColors.borderDark,
          width: 1.2,
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLight) ...[
            Container(
              height: 3,
              width: 24,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gold $karat',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isLight ? AppColors.primary : null,
                  letterSpacing: 0.5,
                ),
              ),
              PriceChangeIndicator(change: change),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${formatter.format(price)}/g',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: isLight ? AppColors.primary : AppColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class PriceChangeIndicator extends StatelessWidget {
  final double change;

  const PriceChangeIndicator({super.key, required this.change});

  @override
  Widget build(BuildContext context) {
    final isNegative = change < 0;
    final color = isNegative ? AppColors.error : AppColors.success;
    final bg = color.withValues(alpha: 0.08);
    final icon = isNegative ? Icons.south_east : Icons.north_east;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 2),
          Text(
            '${change.abs().toStringAsFixed(1)}%',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
