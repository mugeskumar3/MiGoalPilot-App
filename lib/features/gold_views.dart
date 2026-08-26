import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot_app/app/theme/app_colors.dart';
import 'package:migoalpilot_app/app/theme/app_spacing.dart';
import 'package:migoalpilot_app/app/theme/app_text_styles.dart';
import 'package:migoalpilot_app/core/widgets/shared_widgets.dart';
import 'package:migoalpilot_app/core/viewmodels/viewmodels.dart';
import 'package:migoalpilot_app/shared/enums/enums.dart';

class GoldDashboardScreen extends ConsumerStatefulWidget {
  const GoldDashboardScreen({super.key});

  @override
  ConsumerState<GoldDashboardScreen> createState() =>
      _GoldDashboardScreenState();
}

class _GoldDashboardScreenState extends ConsumerState<GoldDashboardScreen> {
  String _range = '30D';

  void _showAlertBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const _GoldAlertBottomSheetContent();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goldViewModelProvider);
    final goalsState = ref.watch(goalsViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    final goldGoals = goalsState.goals
        .where((g) => g.type == GoalType.gold)
        .toList();

    return Scaffold(
      appBar: MiAppBar(
        title: '🥇 Gold',
        subtitle: 'Track your price and progress',
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.accent,
              size: 22,
            ),
            onPressed: () => _showAlertBottomSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(goldViewModelProvider.notifier).loadGoldData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.isLoading && state.livePrice == null)
                const LoadingState()
              else if (state.livePrice != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: GoldPriceWidget(
                        price: state.livePrice!.rate22K,
                        change: state.livePrice!.dailyChangePercentage,
                        karat: '22K',
                      ),
                    ),
                    AppSpacing.widthM,
                    Expanded(
                      child: GoldPriceWidget(
                        price: state.livePrice!.rate24K,
                        change: state.livePrice!.dailyChangePercentage,
                        karat: '24K',
                      ),
                    ),
                  ],
                ),
                AppSpacing.heightS,
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Updated ${DateFormat('hh:mm a').format(state.livePrice!.lastUpdated)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (state.livePrice!.dailyChangePercentage < -1.0) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🥇', style: TextStyle(fontSize: 16)),
                            AppSpacing.widthS,
                            Text(
                              'BUYING OPPORTUNITY',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.heightS,
                        Text(
                          'Gold is down ${state.livePrice!.dailyChangePercentage.abs()}% today. Gram requirements are currently ₹3,000 cheaper than yesterday.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PRICE HISTORY',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: ['7D', '30D', '3M', '1Y'].map((val) {
                        final active = _range == val;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _range = val);
                            ref
                                .read(goldViewModelProvider.notifier)
                                .changeHistoryRange(val);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? (isLight
                                        ? AppColors.primary
                                        : AppColors.primaryDark)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              val,
                              style: AppTextStyles.caption.copyWith(
                                color: active
                                    ? Colors.white
                                    : (isLight
                                          ? AppColors.textSecondary
                                          : AppColors.textSecondaryDark),
                                fontWeight: active
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                AppSpacing.heightM,

                Container(
                  height: 180,
                  padding: const EdgeInsets.only(top: 12, right: 16, bottom: 4),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isLight ? AppColors.border : AppColors.borderDark,
                    ),
                  ),
                  child: state.history.isEmpty
                      ? const Center(child: Text('Loading chart history...'))
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(state.history.length, (
                                  idx,
                                ) {
                                  return FlSpot(
                                    idx.toDouble(),
                                    state.history[idx],
                                  );
                                }),
                                isCurved: true,
                                color:
                                    AppColors.secondary,
                                barWidth: 2.5,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    final isLast =
                                        index == barData.spots.length - 1;
                                    return FlDotCirclePainter(
                                      radius: isLast ? 4 : 0,
                                      color: AppColors
                                          .accent,
                                      strokeColor: AppColors.accent,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.04,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 28),

                Text(
                  'STATISTICS',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                AppSpacing.heightS,
                _statIndexRow('7 Day High', 12850),
                _statIndexRow('7 Day Low', 12380),
                _statIndexRow('30 Day Average', 12610),
                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LINKED GOLD GOALS',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/goals'),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(
                        'Manage',
                        style: TextStyle(
                          color: isLight
                              ? AppColors.secondary
                              : AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.heightS,

                if (goldGoals.isEmpty)
                  const EmptyState(
                    title: 'No gold goals active',
                    description:
                        'Link a gold goal plan to start tracking gram purchases.',
                  )
                else
                  ...goldGoals.map((g) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isLight
                              ? AppColors.border
                              : AppColors.borderDark,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => context.push('/gold-goals/${g.id}'),
                        leading: const Text(
                          '🥇',
                          style: TextStyle(fontSize: 24),
                        ),
                        title: Text(g.name, style: AppTextStyles.titleMedium),
                        subtitle: Text(
                          '${g.purchasedGrams}g accumulated of ${g.targetGrams}g target',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                      ),
                    );
                  }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statIndexRow(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              MoneyDisplay(
                amount: val,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class GoldGoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const GoldGoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalDetailViewModelProvider(goalId));
    final goldState = ref.watch(goldViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (state.isLoading) return const Scaffold(body: LoadingState());
    if (state.goal == null) {
      return const Scaffold(body: Center(child: Text('Goal not found')));
    }

    final g = state.goal!;
    final spotPrice = goldState.livePrice?.rate22K ?? 12500.0;

    final remainingGrams = (g.targetGrams - g.purchasedGrams).clamp(
      0.0,
      double.infinity,
    );
    final estimatedValueRemaining = remainingGrams * spotPrice;

    return Scaffold(
      appBar: MiBackAppBar(title: g.name, onBackPressed: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Text('🥇', style: TextStyle(fontSize: 56)),
                  AppSpacing.heightS,
                  Text(
                    '${g.purchasedGrams}g Purchased',
                    style: AppTextStyles.displayMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of ${g.targetGrams}g target (${(g.progressPercentage * 100).toStringAsFixed(1)}%)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isLight
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 20),

            _detailRow('Target Weight', '${g.targetGrams} grams'),
            _detailRow('Purchased Weight', '${g.purchasedGrams} grams'),
            _detailRow(
              'Remaining Weight Gap',
              '${remainingGrams.toStringAsFixed(2)} grams',
            ),
            _detailRow(
              'Spot Rate Reference (22K)',
              '₹${NumberFormat('#,##,###').format(spotPrice)}/g',
            ),
            _detailRow(
              'Estimated Outstanding Budget',
              '₹${NumberFormat('#,##,###').format(estimatedValueRemaining)}',
            ),

            const Spacer(),
            PrimaryButton(
              text: 'Record Gold Purchase',
              onPressed: () => context.push('/add-saving/$goalId'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

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
    return Scaffold(
      appBar: MiBackAppBar(
        title: 'Alert Configuration',
        onBackPressed: () => context.pop(),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: _GoldAlertBottomSheetContent(isFullScreenRoute: true),
      ),
    );
  }
}

class _GoldAlertBottomSheetContent extends ConsumerStatefulWidget {
  final bool isFullScreenRoute;

  const _GoldAlertBottomSheetContent({this.isFullScreenRoute = false});

  @override
  ConsumerState<_GoldAlertBottomSheetContent> createState() =>
      __GoldAlertBottomSheetContentState();
}

class __GoldAlertBottomSheetContentState
    extends ConsumerState<_GoldAlertBottomSheetContent> {
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
        left: 20,
        right: 20,
        top: 20,
        bottom: widget.isFullScreenRoute
            ? 20
            : MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isFullScreenRoute) ...[
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isLight ? AppColors.border : AppColors.borderDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          const Text(
            'WHEN SHOULD WE ALERT YOU?',
            style: AppTextStyles.headlineLarge,
          ),
          AppSpacing.heightS,
          Text(
            'GoalPilot monitors spot price feeds and alerts you immediately when thresholds match.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'ALERT TRIGGER PRICE DROP',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.heightS,
          DropdownButtonFormField<double>(
            decoration: const InputDecoration(labelText: 'Trigger Percentage'),
            initialValue: _threshold,
            items: const [
              DropdownMenuItem(value: 0.5, child: Text('0.5% price drop')),
              DropdownMenuItem(value: 1.0, child: Text('1.0% price drop')),
              DropdownMenuItem(value: 2.0, child: Text('2.0% price drop')),
              DropdownMenuItem(value: 3.0, child: Text('3.0% price drop')),
            ],
            onChanged: (val) => setState(() => _threshold = val ?? 1.0),
          ),
          const SizedBox(height: 20),

          SwitchListTile(
            title: const Text(
              'Daily Morning Update',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Summary of market closing rates sent at 9:00 AM.',
              style: AppTextStyles.caption,
            ),
            value: _daily,
            onChanged: (val) => setState(() => _daily = val),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 32),

          PrimaryButton(
            text: 'SAVE PRICE ALERT PREFERENCE',
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
