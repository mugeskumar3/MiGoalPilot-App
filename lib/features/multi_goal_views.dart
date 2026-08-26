import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot_app/app/theme/app_colors.dart';
import 'package:migoalpilot_app/app/theme/app_spacing.dart';
import 'package:migoalpilot_app/app/theme/app_text_styles.dart';
import 'package:migoalpilot_app/core/widgets/shared_widgets.dart';

class MultiGoalScreen extends ConsumerStatefulWidget {
  const MultiGoalScreen({super.key});

  @override
  ConsumerState<MultiGoalScreen> createState() => _MultiGoalScreenState();
}

class _MultiGoalScreenState extends ConsumerState<MultiGoalScreen> {
  final double _availableToSave = 50000.0;

  // Custom local state variables to simulate slider allocations
  double _marriageAlloc = 25000.0;
  double _goldAlloc = 10000.0;
  double _houseAlloc = 15000.0;
  double _travelAlloc = 12500.0;

  bool _isOptimized = false;

  void _applyOptimization() {
    setState(() {
      // AI suggestion: extend Travel Goal by 4 months
      // Mapped travel allocation decreases from 12500 to 0 (or down by 12500) to balance target
      _travelAlloc = 0;
      _isOptimized = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Travel goal extended by 4 months. Target balanced!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sum calculations
    final currentRequired =
        _marriageAlloc + _goldAlloc + _houseAlloc + _travelAlloc;
    final diff = currentRequired - _availableToSave;
    final hasWarning = diff > 0;

    return Scaffold(
      appBar: MiBackAppBar(
        title: 'Goal Balance',
        onBackPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            const Text('YOUR MONTHLY PLAN', style: AppTextStyles.headlineLarge),
            AppSpacing.heightS,
            Text(
              'Balance monthly savings limits across active goals to prevent planning shortfalls.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Metrics Display
            Row(
              children: [
                Expanded(
                  child: _metricBox(
                    'Available Monthly limit',
                    _availableToSave,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _metricBox(
                    'Required Savings Sum',
                    currentRequired,
                    isDanger: hasWarning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Warning Section
            if (hasWarning) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('⚠️', style: TextStyle(fontSize: 16)),
                        AppSpacing.widthS,
                        Text(
                          'LIMIT OVERFLOW WARNING',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.heightS,
                    Text(
                      'Your goals require ₹${NumberFormat('#,##,###').format(diff)} more than your planned monthly savings limit.',
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Goal Allocations List with sliders
            Text(
              'GOAL ALLOCATIONS',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            AppSpacing.heightS,
            _allocationSlider('💍 Marriage Goal', _marriageAlloc, 35000.0, (
              val,
            ) {
              setState(() => _marriageAlloc = val);
            }),
            _allocationSlider('🥇 Gold Goal', _goldAlloc, 20000.0, (val) {
              setState(() => _goldAlloc = val);
            }),
            _allocationSlider('🏠 House Goal', _houseAlloc, 25000.0, (val) {
              setState(() => _houseAlloc = val);
            }),
            _allocationSlider('🌍 Travel Goal', _travelAlloc, 15000.0, (val) {
              setState(() => _travelAlloc = val);
            }),
            const SizedBox(height: 24),

            // Co-pilot AI suggestion Card
            if (hasWarning && !_isOptimized) ...[
              AiInsightCard(
                title: 'GoalPilot balance optimization',
                description:
                    'Travel Goal has the lowest priority in your settings. Extending its target date by 4 months would bring your savings plan within budget.',
                onViewDetails: _applyOptimization,
              ),
              const SizedBox(height: 32),
            ],

            PrimaryButton(
              text: 'CONFIRM MONTHLY BALANCE PLAN',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Plan balance saved in your cockpit!'),
                  ),
                );
                context.pop();
              },
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              text: 'Keep Current Parameters',
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricBox(String label, double val, {bool isDanger = false}) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDanger
              ? AppColors.error.withValues(alpha: 0.3)
              : (isLight ? AppColors.border : AppColors.borderDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          MoneyDisplay(
            amount: val,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: isDanger ? AppColors.error : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _allocationSlider(
    String name,
    double value,
    double maxVal,
    ValueChanged<double> onChanged,
  ) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isLight ? AppColors.border : AppColors.borderDark,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppTextStyles.titleMedium),
              MoneyDisplay(
                amount: value,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (value > 0) ...[
            Slider(
              min: 0,
              max: maxVal,
              divisions: 10,
              value: value,
              activeColor: AppColors.secondary,
              onChanged: onChanged,
            ),
          ] else ...[
            AppSpacing.heightS,
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Goal extended (Paused or completed)',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.healthPaused,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
