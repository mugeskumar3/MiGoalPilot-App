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
import 'package:migoalpilot/core/services/goal_health_calculator.dart';
import 'package:migoalpilot/core/services/goal_milestone_calculator.dart';
import 'package:migoalpilot/core/services/gold_goal_calculator.dart';
import 'package:migoalpilot/core/models/models.dart';

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

class GoldGoalDetailScreen extends ConsumerStatefulWidget {
  final String goalId;

  const GoldGoalDetailScreen({super.key, required this.goalId});

  @override
  ConsumerState<GoldGoalDetailScreen> createState() => _GoldGoalDetailScreenState();
}

class _GoldGoalDetailScreenState extends ConsumerState<GoldGoalDetailScreen> {
  bool _showHealthDetails = false;
  bool _showFullHistory = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalDetailViewModelProvider(widget.goalId));
    final goldState = ref.watch(goldViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (state.isLoading) return const Scaffold(body: LoadingState());
    if (state.goal == null) {
      return Scaffold(
        appBar: MiBackAppBar(
          title: 'Gold Goal',
          onBackPressed: () => context.pop(),
        ),
        body: const Center(child: Text('Goal not found')),
      );
    }

    final g = state.goal!;
    final spotPrice = goldState.livePrice?.rate22K;

    final double targetGrams = g.targetGrams;
    final double purchasedGrams = g.purchasedGrams;
    final double remainingGrams = (targetGrams - purchasedGrams).clamp(0.0, double.infinity);
    final double progressPercentage = g.progressPercentage;

    // Monetary values
    final String formattedCurrentValue = spotPrice != null 
        ? '₹${NumberFormat('#,##,###').format(purchasedGrams * spotPrice)}' 
        : 'Gold price unavailable';
    final String formattedTargetValue = spotPrice != null 
        ? '₹${NumberFormat('#,##,###').format(targetGrams * spotPrice)}' 
        : 'Gold price unavailable';

    // Health calculations
    final healthResult = GoalHealthCalculator.calculate(g, state.transactions);

    // Milestones
    final milestones = GoalMilestoneCalculator.calculateMilestones(g, state.transactions);

    // Insight
    final insight = GoldGoalCalculator.generateSmartInsight(
      goal: g,
      transactions: state.transactions,
      spotPrice: spotPrice,
      dailyChangePercentage: goldState.livePrice?.dailyChangePercentage,
    );

    // Monthly Accumulation
    final monthlyData = GoldGoalCalculator.getMonthlyAccumulation(state.transactions);

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: g.name,
        onBackPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Progress Card
              _buildSectionCard(
                isLight: isLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GOLD GOAL PROGRESS',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isLight ? AppColors.softSurface : AppColors.borderDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(progressPercentage * 100).toStringAsFixed(1)}%',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isLight ? AppColors.primary : AppColors.accentDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${purchasedGrams.toStringAsFixed(2)} g',
                          style: AppTextStyles.displayLarge.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isLight ? AppColors.primary : AppColors.accentDark,
                          ),
                        ),
                        Text(
                          'of ${targetGrams.toStringAsFixed(1)} g target',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildProgressBar(progressPercentage, isLight),
                    const SizedBox(height: 12),
                    Text(
                      remainingGrams <= 0 
                          ? 'Goal Completed! 🎉'
                          : '${remainingGrams.toStringAsFixed(2)} g remaining',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: remainingGrams <= 0 
                            ? AppColors.success 
                            : (isLight ? AppColors.textSecondary : AppColors.textSecondaryDark),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CURRENT VALUE',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formattedCurrentValue,
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TARGET VALUE',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formattedTargetValue,
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            '22K GOLD',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          spotPrice != null 
                              ? '₹${NumberFormat('#,##,###').format(spotPrice)} / g' 
                              : 'Gold price unavailable',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Updated today',
                          style: AppTextStyles.caption.copyWith(
                            color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Smart Insight Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLight
                        ? [
                            AppColors.lightGold.withValues(alpha: 0.3),
                            AppColors.accent.withValues(alpha: 0.1),
                          ]
                        : [
                            AppColors.surfaceDark,
                            AppColors.elevatedSurfaceDark,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SMART GOLD INSIGHT',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            insight,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Health Score Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MiSectionHeader(title: 'Gold Goal Health'),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showHealthDetails = !_showHealthDetails;
                      });
                    },
                    child: Text(
                      _showHealthDetails ? 'Hide Details' : 'View Details',
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        GoalHealthScoreWidget(result: healthResult),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCheckRow(
                                label: 'Gold accumulation is on track',
                                isOk: healthResult.isSavingsPaceHealthy,
                                isLight: isLight,
                              ),
                              const SizedBox(height: 8),
                              _buildCheckRow(
                                label: 'Target weight is achievable',
                                isOk: healthResult.isDeadlineRealistic,
                                isLight: isLight,
                              ),
                              const SizedBox(height: 8),
                              _buildCheckRow(
                                label: 'Current gold price increased',
                                isOk: goldState.livePrice != null && goldState.livePrice!.dailyChangePercentage > 0,
                                isWarning: true,
                                isLight: isLight,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_showHealthDetails) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(),
                      ),
                      GoalHealthBreakdownWidget(
                        result: healthResult,
                        targetDate: g.targetDate,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Gold Accumulation Section
              const MiSectionHeader(title: 'Gold Accumulation'),
              const SizedBox(height: 8),
              _buildSectionCard(
                isLight: isLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MONTHLY GRAMS ADDED',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMonthlyAccumulation(monthlyData, isLight),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Milestones Section
              const MiSectionHeader(title: 'Milestones'),
              const SizedBox(height: 8),
              _buildSectionCard(
                isLight: isLight,
                child: _buildMilestones(milestones, isLight),
              ),
              const SizedBox(height: 24),

              // History Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MiSectionHeader(title: 'Gold History'),
                  if (state.transactions.length > 3)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showFullHistory = !_showFullHistory;
                        });
                      },
                      child: Text(
                        _showFullHistory ? 'Show Less' : 'Show All (${state.transactions.length})',
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
                child: _buildHistoryList(
                  _showFullHistory ? state.transactions : state.transactions.take(3).toList(),
                  isLight,
                  spotPrice,
                ),
              ),
              const SizedBox(height: 32),

              // Contextual Action Buttons
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Add Gold Saving',
                      onPressed: () => context.push('/add-saving/${widget.goalId}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: isLight ? Colors.white : AppColors.surfaceDark,
                      border: Border.all(
                        color: isLight ? AppColors.border : AppColors.borderDark,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications_active_outlined,
                        color: isLight ? AppColors.primary : AppColors.accentDark,
                      ),
                      onPressed: () => context.push('/gold-alerts'),
                      tooltip: 'Set Price Alerts',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
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

  Widget _buildProgressBar(double progress, bool isLight) {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isLight ? AppColors.softSurface : AppColors.borderDark,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.accent,
                AppColors.lightGold,
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckRow({required String label, required bool isOk, required bool isLight, bool isWarning = false}) {
    IconData icon;
    Color iconColor;
    if (isWarning) {
      icon = isOk ? Icons.warning_amber_rounded : Icons.check_circle_rounded;
      iconColor = isOk ? AppColors.warning : AppColors.success;
    } else {
      icon = isOk ? Icons.check_circle_rounded : Icons.warning_amber_rounded;
      iconColor = isOk ? AppColors.success : AppColors.warning;
    }

    // Adjust label text dynamically if warning
    String text = label;
    if (isWarning) {
      text = isOk ? 'Current gold price increased' : 'Current gold price is stable';
    }

    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyAccumulation(List<MonthlyAccumulation> data, bool isLight) {
    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'No accumulation history yet.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
            ),
          ),
        ),
      );
    }

    final maxGrams = data.map((e) => e.grams).reduce((a, b) => a > b ? a : b);

    return Column(
      children: data.map((item) {
        final double fraction = maxGrams > 0 ? (item.grams / maxGrams) : 0.0;
        final barFlex = (fraction * 100).toInt().clamp(1, 100);
        final emptyFlex = ((1.0 - fraction) * 100).toInt().clamp(0, 100);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  item.label.split(' ')[0], // e.g. "AUG"
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: barFlex,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.accent,
                              AppColors.lightGold,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    if (emptyFlex > 0)
                      Expanded(
                        flex: emptyFlex,
                        child: const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${item.grams.toStringAsFixed(1)} g',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 70,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '₹${NumberFormat('#,##,###').format(item.amount)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMilestones(List<GoalMilestone> milestones, bool isLight) {
    if (milestones.isEmpty) return const SizedBox.shrink();

    // Check if any milestone was recently unlocked to show alert
    final recentlyReached = milestones.where((m) => m.completed).toList();
    final latestMilestone = recentlyReached.isNotEmpty ? recentlyReached.reduce((a, b) => a.percentage > b.percentage ? a : b) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (latestMilestone != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${latestMilestone.targetAmount.toStringAsFixed(1)} g milestone reached!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        ...milestones.map((m) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Icon(
                  m.completed ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                  color: m.completed ? AppColors.success : (isLight ? AppColors.border : AppColors.borderDark),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '${m.targetAmount.toStringAsFixed(2)} g',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: m.completed
                        ? (isLight ? AppColors.textPrimary : AppColors.textPrimaryDark)
                        : (isLight ? AppColors.textSecondary : AppColors.textSecondaryDark),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${m.percentage}%)',
                  style: AppTextStyles.caption.copyWith(
                    color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
                  ),
                ),
                const Spacer(),
                Text(
                  m.completed
                      ? (m.completedAt != null ? 'Reached ${DateFormat('dd MMM').format(m.completedAt!)}' : 'Reached')
                      : 'Pending',
                  style: AppTextStyles.caption.copyWith(
                    color: m.completed ? AppColors.success : (isLight ? AppColors.textSecondary : AppColors.textSecondaryDark),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
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
