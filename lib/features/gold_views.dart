import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

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
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        return Container(
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.surfaceDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: const _GoldAlertBottomSheetContent(),
        );
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
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      appBar: MiAppBar(
        title: 'Gold Marketplace',
        subtitle: 'Live price tracker & linked targets',
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_active_outlined,
              color: isLight ? AppColors.primary : AppColors.accentDark,
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                        price: state.livePrice?.rate22K ?? 0.0,
                        change: state.livePrice?.dailyChangePercentage ?? 0.0,
                        karat: '22K',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GoldPriceWidget(
                        price: state.livePrice?.rate24K ?? 0.0,
                        change: state.livePrice?.dailyChangePercentage ?? 0.0,
                        karat: '24K',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Rates closing closure: ${DateFormat('hh:mm a').format(state.livePrice!.lastUpdated)}',
                    style: AppTextStyles.caption.copyWith(
                      color: isLight
                          ? AppColors.textSecondary
                          : AppColors.textLightDark,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if ((state.livePrice?.dailyChangePercentage ?? 0.0) < -1.0) ...[
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
                      'Gold is down ${state.livePrice!.dailyChangePercentage.abs()}% today. Ideal time to purchase grams for active linked targets.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const MiSectionHeader(title: "Price History"),
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
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? (isLight
                                        ? AppColors.primary
                                        : AppColors.accentDark)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              val,
                              style: AppTextStyles.caption.copyWith(
                                color: active
                                    ? (isLight
                                          ? Colors.white
                                          : AppColors.backgroundDark)
                                    : (isLight
                                          ? AppColors.textSecondary
                                          : AppColors.textSecondaryDark),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  height: 180,
                  padding: const EdgeInsets.only(
                    top: 20,
                    right: 20,
                    bottom: 8,
                    left: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLight ? AppColors.border : AppColors.borderDark,
                      width: 1.2,
                    ),
                  ),
                  child: state.history.isEmpty
                      ? const Center(child: Text('Loading price indices...'))
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
                                color: isLight
                                    ? AppColors.primary
                                    : AppColors.accentDark,
                                barWidth: 2.5,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                        final isLast =
                                            index == barData.spots.length - 1;
                                        return FlDotCirclePainter(
                                          radius: isLast ? 5 : 0,
                                          color: AppColors.accent,
                                          strokeColor: AppColors.accent,
                                          strokeWidth: 1,
                                        );
                                      },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color:
                                      (isLight
                                              ? AppColors.primary
                                              : AppColors.accentDark)
                                          .withValues(alpha: 0.05),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 32),

                const MiSectionHeader(title: "Statistics"),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLight ? AppColors.border : AppColors.borderDark,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      _statIndexRow('7 Day High', 12850, context),
                      _statIndexRow('7 Day Low', 12380, context),
                      _statIndexRow('30 Day Average', 12610, context),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

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
            ],
          ),
        ),
      ),
    );
  }

  Widget _statIndexRow(String label, double val, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isLight
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          MoneyDisplay(
            amount: val,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: isLight
                  ? AppColors.textPrimary
                  : AppColors.textPrimaryDark,
            ),
          ),
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
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      appBar: MiBackAppBar(title: g.name, onBackPressed: () => context.pop()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : AppColors.surfaceDark,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isLight
                              ? AppColors.border
                              : AppColors.borderDark,
                          width: 1.2,
                        ),
                      ),
                      child: const Text('🥇', style: TextStyle(fontSize: 48)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${g.purchasedGrams}g Purchased',
                      style: AppTextStyles.displayMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
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
              const SizedBox(height: 40),
              const MiSectionHeader(title: "Gram Trajectory Details"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isLight ? AppColors.border : AppColors.borderDark,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    _detailRow(
                      'Target Weight',
                      '${g.targetGrams} grams',
                      context,
                    ),
                    _detailRow(
                      'Purchased Weight',
                      '${g.purchasedGrams} grams',
                      context,
                    ),
                    _detailRow(
                      'Remaining Weight Gap',
                      '${remainingGrams.toStringAsFixed(2)} grams',
                      context,
                    ),
                    _detailRow(
                      'Spot Reference (22K)',
                      '₹${NumberFormat('#,##,###').format(spotPrice)}/g',
                      context,
                    ),
                    _detailRow(
                      'Estimated Gap Value',
                      '₹${NumberFormat('#,##,###').format(estimatedValueRemaining)}',
                      context,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Record Gold Purchase',
                onPressed: () => context.push('/add-saving/$goalId'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isLight
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: isLight
                  ? AppColors.textPrimary
                  : AppColors.textPrimaryDark,
            ),
          ),
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
      _GoldAlertBottomSheetContentState();
}

class _GoldAlertBottomSheetContentState
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
