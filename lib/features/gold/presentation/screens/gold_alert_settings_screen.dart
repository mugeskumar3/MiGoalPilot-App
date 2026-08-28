import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/features/gold/presentation/viewmodels/gold_viewmodel.dart';

class GoldAlertSettingsScreen extends ConsumerStatefulWidget {
  const GoldAlertSettingsScreen({super.key});

  @override
  ConsumerState<GoldAlertSettingsScreen> createState() =>
      _GoldAlertSettingsScreenState();
}

class _GoldAlertSettingsScreenState
    extends ConsumerState<GoldAlertSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Alert Configuration',
        onBackPressed: () => context.pop(),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: GoldAlertBottomSheetContent(isFullScreenRoute: true),
      ),
    );
  }
}

class GoldAlertBottomSheetContent extends ConsumerStatefulWidget {
  final bool isFullScreenRoute;

  const GoldAlertBottomSheetContent({super.key, this.isFullScreenRoute = false});

  @override
  ConsumerState<GoldAlertBottomSheetContent> createState() =>
      _GoldAlertBottomSheetContentState();
}

class _GoldAlertBottomSheetContentState
    extends ConsumerState<GoldAlertBottomSheetContent> {
  double _threshold = 1.0;
  bool _daily = true;

  @override
  void initState() {
    super.initState();
    final state = ref.read(goldViewModelProvider);
    _threshold = state.alertThreshold;
    _daily = state.dailyUpdatesEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: widget.isFullScreenRoute
            ? 24
            : MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isFullScreenRoute) ...[
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isLight ? AppColors.border : AppColors.borderDark,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            'Price Alert Preferences',
            style: AppTextStyles.displayMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'GoalPilot monitors spot price feeds and alerts you immediately when thresholds match.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isLight
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'ALERT TRIGGER PRICE DROP',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<double>(
            dropdownColor: isLight ? Colors.white : AppColors.surfaceDark,
            decoration: InputDecoration(
              filled: true,
              fillColor: isLight ? Colors.white : AppColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            initialValue: _threshold,
            items: const [
              DropdownMenuItem(value: 0.5, child: Text('0.5% price drop')),
              DropdownMenuItem(value: 1.0, child: Text('1.0% price drop')),
              DropdownMenuItem(value: 2.0, child: Text('2.0% price drop')),
              DropdownMenuItem(value: 3.0, child: Text('3.0% price drop')),
            ],
            onChanged: (val) => setState(() => _threshold = val ?? 1.0),
          ),
          const SizedBox(height: 24),

          SwitchListTile(
            title: Text(
              'Daily Morning Update',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Summary of market closing rates sent at 9:00 AM.',
              style: AppTextStyles.caption.copyWith(
                color: isLight
                    ? AppColors.textSecondary
                    : AppColors.textLightDark,
              ),
            ),
            value: _daily,
            onChanged: (val) => setState(() => _daily = val),
            activeThumbColor: isLight
                ? AppColors.primary
                : AppColors.accentDark,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 36),

          PrimaryButton(
            text: 'Save Projections Alert',
            onPressed: () {
              ref
                  .read(goldViewModelProvider.notifier)
                  .saveAlertSettings(_threshold, _daily);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alert preferences saved successfully.'),
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
