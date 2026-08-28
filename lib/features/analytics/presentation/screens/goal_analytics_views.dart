import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/viewmodels/goal_analytics_state.dart';
import 'package:migoalpilot/core/viewmodels/goal_analytics_viewmodel.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

class GoalFilterOption {
  final String label;
  final String emoji;
  final GoalType? type;

  GoalFilterOption(this.label, this.emoji, this.type);
}

final List<GoalFilterOption> filterOptions = [
  GoalFilterOption('All Goals', '🎯', null),
  GoalFilterOption('Marriage', '💍', GoalType.marriage),
  GoalFilterOption('Gold', '🥇', GoalType.gold),
  GoalFilterOption('Travel', '✈️', GoalType.travel),
  GoalFilterOption('House', '🏠', GoalType.house),
  GoalFilterOption('Car', '🚗', GoalType.car),
  GoalFilterOption('Education', '🎓', GoalType.education),
  GoalFilterOption('Custom', '🎯', GoalType.custom),
];

class GoalAnalyticsScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const GoalAnalyticsScreen({super.key, this.isEmbedded = false});

  @override
  ConsumerState<GoalAnalyticsScreen> createState() => _GoalAnalyticsScreenState();
}

class _GoalAnalyticsScreenState extends ConsumerState<GoalAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalAnalyticsViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    final body = state.isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => ref.read(goalAnalyticsViewModelProvider.notifier).loadAnalytics(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Range Selector (3M / 6M / 12M / Custom)
                      _buildRangeSelector(context, ref, state, isLight),
                      const SizedBox(height: 16),

                      // Horizontal category scrolling filters
                      _buildCategoryFilters(ref, state, isLight),
                      const SizedBox(height: 24),

                      // Gold vs General modes
                      if (state.selectedGoalType == GoalType.gold) ...[
                        _buildGoldAnalyticsMode(ref, state, isLight),
                      ] else ...[
                        _buildGeneralAnalyticsMode(ref, state, isLight),
                      ],
                      const SizedBox(height: 24),

                      // Smart Insights
                      _buildInsightsSection(state, isLight),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );

    if (widget.isEmbedded) return body;

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Goal Analytics',
        onBackPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: body,
      ),
    );
  }

  Widget _buildRangeSelector(BuildContext context, WidgetRef ref, GoalAnalyticsState state, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isLight ? AppColors.softSurface : AppColors.borderDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: AnalyticsRange.values.map((range) {
          final isSelected = state.range == range;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (range == AnalyticsRange.custom) {
                  _selectCustomRange(context, ref);
                } else {
                  ref.read(goalAnalyticsViewModelProvider.notifier).setRange(range);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isLight ? Colors.white : AppColors.surfaceDark)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected && isLight
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  range == AnalyticsRange.custom && state.customStartDate != null && state.customEndDate != null
                      ? '${DateFormat('MMM').format(state.customStartDate!)} - ${DateFormat('MMM').format(state.customEndDate!)}'
                      : range.label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? (isLight ? AppColors.primary : AppColors.accentDark)
                        : (isLight ? AppColors.textSecondary : AppColors.textSecondaryDark),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _selectCustomRange(BuildContext context, WidgetRef ref) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 90)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.accent,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref.read(goalAnalyticsViewModelProvider.notifier).setRange(
            AnalyticsRange.custom,
            start: picked.start,
            end: picked.end,
          );
    }
  }

  Widget _buildCategoryFilters(WidgetRef ref, GoalAnalyticsState state, bool isLight) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filterOptions.length,
        itemBuilder: (context, idx) {
          final opt = filterOptions[idx];
          final isSelected = state.selectedGoalType == opt.type;
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {
                ref.read(goalAnalyticsViewModelProvider.notifier).setGoalFilter(opt.type, null);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent
                      : (isLight ? Colors.white : AppColors.surfaceDark),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accent
                        : (isLight ? AppColors.border : AppColors.borderDark),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Text(opt.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      opt.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isLight ? AppColors.textPrimary : AppColors.textPrimaryDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGeneralAnalyticsMode(WidgetRef ref, GoalAnalyticsState state, bool isLight) {
    final res = state.generalResult;
    if (res == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart Header
        Text(
          'YOUR SAVING PATTERN',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),

        // Line Chart
        Container(
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight ? AppColors.border : AppColors.borderDark,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Savings',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: res.monthlySavingsPoints.isEmpty
                    ? const Center(child: Text('No savings recorded.'))
                    : LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 45,
                                getTitlesWidget: (val, meta) {
                                  if (val % 10000 != 0 || val == 0) return const SizedBox.shrink();
                                  return Text(
                                    '₹${(val / 1000).toStringAsFixed(0)}K',
                                    style: AppTextStyles.caption.copyWith(
                                      color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                getTitlesWidget: (val, meta) {
                                  final idx = val.toInt();
                                  if (idx < 0 || idx >= res.monthlySavingsPoints.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final date = res.monthlySavingsPoints.keys.elementAt(idx);
                                  return Text(
                                    DateFormat('MMM').format(date).toUpperCase(),
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(res.monthlySavingsPoints.length, (idx) {
                                final val = res.monthlySavingsPoints.values.elementAt(idx);
                                return FlSpot(idx.toDouble(), val);
                              }),
                              isCurved: true,
                              color: isLight ? AppColors.primary : AppColors.accentDark,
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, idx) {
                                  return FlDotCirclePainter(
                                    radius: idx == barData.spots.length - 1 ? 5 : 2,
                                    color: AppColors.accent,
                                    strokeColor: AppColors.accent,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: (isLight ? AppColors.primary : AppColors.accentDark).withValues(alpha: 0.05),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Key Metrics
        Text(
          'KEY METRICS',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),

        // 3-Column Stats Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight ? AppColors.border : AppColors.borderDark,
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      'Average Monthly Saving',
                      '₹${NumberFormat('#,##,###').format(res.monthlyAverage)}',
                      isLight,
                    ),
                  ),
                  Container(width: 1.2, height: 48, color: isLight ? AppColors.border : AppColors.borderDark),
                  Expanded(
                    child: _buildMetricTile(
                      'Best Month',
                      res.highestMonth,
                      isLight,
                      subtitle: '₹${NumberFormat('#,##,###').format(res.highestSaving)} saved',
                    ),
                  ),
                  Container(width: 1.2, height: 48, color: isLight ? AppColors.border : AppColors.borderDark),
                  Expanded(
                    child: _buildConsistencyTile(res.consistencyScore, res.consistencyLabel, isLight),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      'Total Saved',
                      '₹${NumberFormat('#,##,###').format(res.totalSaved)}',
                      isLight,
                    ),
                  ),
                  Container(width: 1.2, height: 48, color: isLight ? AppColors.border : AppColors.borderDark),
                  Expanded(
                    child: _buildMetricTile(
                      'Saving Trend',
                      res.savingTrendDirection,
                      isLight,
                      subtitle: '${res.savingTrendPct >= 0 ? "+" : ""}${res.savingTrendPct.toStringAsFixed(0)}% vs start',
                    ),
                  ),
                  Container(width: 1.2, height: 48, color: isLight ? AppColors.border : AppColors.borderDark),
                  Expanded(
                    child: _buildMetricTile(
                      'Active Goals Funded',
                      '${res.activeGoalsFunded} Goal${res.activeGoalsFunded == 1 ? "" : "s"}',
                      isLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Goal Contribution Distribution
        if (res.goalContributions.isNotEmpty) ...[
          Text(
            'GOAL CONTRIBUTION',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isLight ? AppColors.border : AppColors.borderDark,
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distribution Profile',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                ...res.goalContributions.map((c) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(c.goalType.emoji, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  c.goalName,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '₹${NumberFormat('#,##,###').format(c.totalContributed)} (${c.percentage.toStringAsFixed(0)}%)',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GoalProgress(progress: c.percentage / 100, height: 6),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGoldAnalyticsMode(WidgetRef ref, GoalAnalyticsState state, bool isLight) {
    final goldRes = state.goldResult;
    if (goldRes == null) return const SizedBox.shrink();

    // Chart Mode Spots Mapping
    final List<FlSpot> spots = [];
    double maxY = 0.0;
    for (int i = 0; i < goldRes.monthlyGoldAdded.length; i++) {
      final item = goldRes.monthlyGoldAdded[i];
      double val = 0.0;
      if (state.goldChartMetric == 'Price') {
        val = item.price;
      } else if (state.goldChartMetric == 'Weight') {
        val = item.weight;
      } else if (state.goldChartMetric == 'Value') {
        val = item.value;
      }
      if (val > maxY) maxY = val;
      spots.add(FlSpot(i.toDouble(), val));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Purity Selector [ 22K ] [ 24K ]
        Row(
          children: [
            Expanded(
              child: Text(
                'GOLD PRICE TREND',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isLight ? AppColors.softSurface : AppColors.borderDark.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: ['22K', '24K'].map((purity) {
                  final isSelected = state.goldPurity == purity;
                  return GestureDetector(
                    onTap: () {
                      ref.read(goalAnalyticsViewModelProvider.notifier).setGoldPurity(purity);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isLight ? Colors.white : AppColors.surfaceDark)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        purity,
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.accent
                              : (isLight ? AppColors.textSecondary : AppColors.textSecondaryDark),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Gold Trend Selector Chart
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight ? AppColors.border : AppColors.borderDark,
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.goldPurity} Gold Trend',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: ['Price', 'Weight', 'Value'].map((metric) {
                      final isSelected = state.goldChartMetric == metric;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: GestureDetector(
                          onTap: () {
                            ref.read(goalAnalyticsViewModelProvider.notifier).setGoldChartMetric(metric);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? AppColors.accent : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              metric,
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.accent : (isLight ? AppColors.textSecondary : AppColors.textSecondaryDark),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: spots.isEmpty
                    ? const Center(child: Text('No Gold activity.'))
                    : LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 45,
                                getTitlesWidget: (val, meta) {
                                  if (val == 0 || val == maxY) return const SizedBox.shrink();
                                  String label = '';
                                  if (state.goldChartMetric == 'Price') {
                                    label = '₹${(val / 1000).toStringAsFixed(1)}K';
                                  } else if (state.goldChartMetric == 'Weight') {
                                    label = '${val.toStringAsFixed(1)}g';
                                  } else if (state.goldChartMetric == 'Value') {
                                    label = '₹${(val / 1000).toStringAsFixed(0)}K';
                                  }
                                  return Text(
                                    label,
                                    style: AppTextStyles.caption.copyWith(
                                      color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                getTitlesWidget: (val, meta) {
                                  final idx = val.toInt();
                                  if (idx < 0 || idx >= goldRes.monthlyGoldAdded.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final date = goldRes.monthlyGoldAdded[idx].month;
                                  return Text(
                                    DateFormat('MMM').format(date).toUpperCase(),
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: AppColors.accent,
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, idx) {
                                  return FlDotCirclePainter(
                                    radius: idx == barData.spots.length - 1 ? 5 : 2,
                                    color: AppColors.accent,
                                    strokeColor: AppColors.accent,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.accent.withValues(alpha: 0.05),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Gold Key Metrics
        Text(
          'GOLD METRICS',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight ? AppColors.border : AppColors.borderDark,
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      'Total Gold',
                      '${goldRes.totalGoldWeight.toStringAsFixed(2)} g',
                      isLight,
                    ),
                  ),
                  Container(width: 1.2, height: 48, color: isLight ? AppColors.border : AppColors.borderDark),
                  Expanded(
                    child: _buildMetricTile(
                      'Average Monthly',
                      '${goldRes.monthlyAverageWeight.toStringAsFixed(2)} g',
                      isLight,
                    ),
                  ),
                  Container(width: 1.2, height: 48, color: isLight ? AppColors.border : AppColors.borderDark),
                  Expanded(
                    child: _buildMetricTile(
                      'Best Month',
                      goldRes.bestMonth,
                      isLight,
                      subtitle: '${goldRes.bestMonthWeight.toStringAsFixed(2)}g added',
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
                  Expanded(
                    child: _buildMetricTile(
                      'Current Rate',
                      '₹${NumberFormat('#,##,###').format(goldRes.currentRate)} / g',
                      isLight,
                    ),
                  ),
                  Container(width: 1.2, height: 48, color: isLight ? AppColors.border : AppColors.borderDark),
                  Expanded(
                    child: _buildMetricTile(
                      'Price Change',
                      '${goldRes.priceChangeVsPreviousPct >= 0 ? "+" : ""}${goldRes.priceChangeVsPreviousPct.toStringAsFixed(1)}%',
                      isLight,
                      subtitle: 'vs previous day',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Monthly Gold Added Timeline
        Text(
          'MONTHLY GOLD ADDED',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight ? AppColors.border : AppColors.borderDark,
              width: 1.2,
            ),
          ),
          child: Column(
            children: goldRes.monthlyGoldAdded.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(item.month),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${item.weight.toStringAsFixed(2)} g',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '₹${NumberFormat('#,##,###').format(item.value)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String title, String val, bool isLight, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          val,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConsistencyTile(int score, String label, bool isLight) {
    Color badgeColor = AppColors.success;
    if (label == 'INCONSISTENT') {
      badgeColor = AppColors.warning;
    } else if (label == 'MODERATE') {
      badgeColor = Colors.orange;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Consistency',
          style: AppTextStyles.caption.copyWith(
            color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$score',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightsSection(GoalAnalyticsState state, bool isLight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SMART INSIGHTS',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLight
                  ? [
                      AppColors.lightGold.withValues(alpha: 0.15),
                      AppColors.accent.withValues(alpha: 0.05),
                    ]
                  : [
                      AppColors.surfaceDark,
                      AppColors.elevatedSurfaceDark,
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.2),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: state.insights.map((insight) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        insight,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
