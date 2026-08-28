import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/models/models.dart';

class GoldHistoryWidget extends StatelessWidget {
  final List<SavingsTransaction> transactions;
  final double? spotPrice;
  final bool showFullHistory;
  final VoidCallback onToggleHistory;

  const GoldHistoryWidget({
    super.key,
    required this.transactions,
    required this.spotPrice,
    required this.showFullHistory,
    required this.onToggleHistory,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final displayedTxs = showFullHistory ? transactions : transactions.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const MiSectionHeader(title: 'Gold History'),
            if (transactions.length > 3)
              TextButton(
                onPressed: onToggleHistory,
                child: Text(
                  showFullHistory ? 'Show Less' : 'Show All (${transactions.length})',
                  style: TextStyle(
                    color: isLight ? AppColors.primary : AppColors.accentDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _buildSectionCard(
          isLight: isLight,
          child: _buildHistoryList(displayedTxs, isLight, spotPrice),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required bool isLight, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLight ? AppColors.border : AppColors.borderDark,
          width: 1.5,
        ),
      ),
      child: child,
    );
  }

  Widget _buildHistoryList(List<SavingsTransaction> txs, bool isLight, double? spotPrice) {
    if (txs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            'No transactions recorded.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
            ),
          ),
        ),
      );
    }

    return Column(
      children: txs.map((t) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isLight ? AppColors.softSurface : AppColors.borderDark.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  t.goldGrams != null ? '🥇' : '💰',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.note ?? (t.goldGrams != null ? 'Gold Purchase' : 'Savings Deposit'),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMM yyyy').format(t.date),
                      style: AppTextStyles.caption.copyWith(
                        color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    t.goldGrams != null ? '+${t.goldGrams!.toStringAsFixed(2)} g' : '+0.00 g',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${NumberFormat('#,##,###').format(t.amount)}',
                    style: AppTextStyles.caption.copyWith(
                      color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
