import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';

class MoneyDisplay extends ConsumerWidget {
  final double amount;
  final TextStyle? style;
  final bool isSecure;
  final String? prefix;

  const MoneyDisplay({
    super.key,
    required this.amount,
    this.style,
    this.isSecure = false,
    this.prefix,
  });

  static String format(WidgetRef ref, double amount, {bool isSecure = false}) {
    final hideBalance = ref.read(profileViewModelProvider).hideBalance;
    if (isSecure || hideBalance) {
      return '₹••••••';
    }
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideBalance = ref.watch(profileViewModelProvider.select((s) => s.hideBalance));
    if (isSecure || hideBalance) {
      final prefixText = prefix ?? '';
      return Text(
        '$prefixText₹••••••',
        style: style ??
            AppTextStyles.headlineMedium.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.textPrimary
                  : AppColors.textPrimaryDark,
            ),
      );
    }
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final formatted = formatter.format(amount);
    return Text(
      prefix != null ? '$prefix$formatted' : formatted,
      style:
          style ??
          AppTextStyles.headlineMedium.copyWith(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.textPrimary
                : AppColors.textPrimaryDark,
          ),
    );
  }
}
