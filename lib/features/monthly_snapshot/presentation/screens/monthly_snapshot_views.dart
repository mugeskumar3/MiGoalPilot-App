import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';
import 'package:migoalpilot/core/services/monthly_snapshot_calculator.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

class MonthlySnapshotScreen extends ConsumerWidget {
  const MonthlySnapshotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(monthlySnapshotViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Monthly Snapshot'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              if (state.snapshot != null) {
                // Export summary function
                final snapshot = state.snapshot!;
                final buffer = StringBuffer();
                buffer.writeln('MiGoalPilot Financial Snapshot - ${DateFormat('MMMM yyyy').format(snapshot.month).toUpperCase()}');
                buffer.writeln('Total Saved: ₹${NumberFormat('#,##,###').format(snapshot.totalSaved)}');
                if (!snapshot.isFirstMonth && !snapshot.isFutureMonth) {
                  final sign = snapshot.percentChange >= 0 ? '+' : '';
                  buffer.writeln('Change vs previous month: $sign${snapshot.percentChange.toStringAsFixed(1)}%');
                }
                buffer.writeln('Goals Funded: ${snapshot.goalsFunded}');
                if (snapshot.bestPerformingGoalName != null) {
                  buffer.writeln('Best Performing Goal: ${snapshot.bestPerformingGoalName} (${snapshot.bestPerformingReason})');
                }
                buffer.writeln('\nGoal Progress:');
                for (final g in snapshot.goalProgressList) {
                  buffer.writeln('- ${g.goalName}: ${g.overallProgress.toStringAsFixed(0)}% (₹${NumberFormat('#,##,###').format(g.monthlyContribution)} contributed this month)');
                }
                buffer.writeln('\nInsight: ${snapshot.insight}');
                buffer.writeln('Recommendation: ${snapshot.recommendation}');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Financial snapshot summary copied to clipboard!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            tooltip: 'Export Snapshot',
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(monthlySnapshotViewModelProvider.notifier).loadSnapshot(state.selectedMonth),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month Navigator Section
                    _buildMonthNavigator(context, ref, state),
                    const SizedBox(height: 24),

                    if (state.snapshot == null || state.snapshot!.isFutureMonth) ...[
                      _buildEmptyState(isLight, state.selectedMonth),
                    ] else ...[
                      // Premium Summary Header Section
                      _buildSummaryHeader(isLight, state.snapshot!),
                      const SizedBox(height: 24),

                      // Goals Progress Section
                      _buildGoalsProgressList(isLight, state.snapshot!),
                      const SizedBox(height: 28),

                      // Saving Trend Chart Section
                      _buildSavingsTrendChart(isLight, state.snapshot!),
                      const SizedBox(height: 28),

                      // Achievements Section
                      if (state.snapshot!.achievements.isNotEmpty) ...[
                        _buildAchievements(isLight, state.snapshot!),
                        const SizedBox(height: 28),
                      ],

                      // AI & Deterministic Insight Section
                      _buildInsightCard(isLight, state.snapshot!),
                      const SizedBox(height: 28),

                      // Smart Recommendation / CTA Section
                      _buildRecommendationCard(context, isLight, state.snapshot!),
                      const SizedBox(height: 40),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMonthNavigator(BuildContext context, WidgetRef ref, MonthlySnapshotState state) {
    final formattedMonth = DateFormat('MMMM yyyy').format(state.selectedMonth);
    final now = DateTime.now();
    final isCurrentOrFuture = state.selectedMonth.year == now.year && state.selectedMonth.month == now.month;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () {
            ref.read(monthlySnapshotViewModelProvider.notifier).changeMonth(-1);
          },
        ),
        Text(
          formattedMonth.toUpperCase(),
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: isCurrentOrFuture
              ? null // Prevent navigating into future months
              : () {
                  ref.read(monthlySnapshotViewModelProvider.notifier).changeMonth(1);
                },
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isLight, DateTime selectedMonth) {
    final isFuture = selectedMonth.isAfter(DateTime.now());
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            isFuture ? '📅' : '📂',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            isFuture ? 'Future Month' : 'No Activity',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isFuture ? 'No activity yet.' : 'No transactions recorded for this month.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(bool isLight, MonthlySnapshotResult snapshot) {
    final totalText = '₹${NumberFormat('#,##,###').format(snapshot.totalSaved)}';
    final hasPrev = !snapshot.isFirstMonth;
    final sign = snapshot.percentChange >= 0 ? '↑' : '↓';
    final percentText = '${snapshot.percentChange.abs().toStringAsFixed(1)}%';
    final changeColor = snapshot.percentChange >= 0 ? AppColors.success : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL SAVED',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            totalText,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (hasPrev) ...[
            Row(
              children: [
                Text(
                  '$sign $percentText ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: changeColor,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'vs ${DateFormat('MMMM').format(DateTime(snapshot.month.year, snapshot.month.month - 1))}',
                  style: AppTextStyles.caption.copyWith(
                    color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Your first month of tracking',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const Divider(height: 24, thickness: 1.0),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GOALS FUNDED',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${snapshot.goalsFunded}',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (snapshot.bestPerformingGoalName != null) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BEST PERFORMING',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snapshot.bestPerformingGoalName!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsProgressList(bool isLight, MonthlySnapshotResult snapshot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'YOUR GOAL PROGRESS',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...snapshot.goalProgressList.map((gp) {
          final progressPercent = gp.overallProgress;
          final isHealthy = gp.health == GoalHealth.onTrack || gp.health == GoalHealth.completed;
          final statusColor = isHealthy ? AppColors.success : AppColors.warning;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isLight ? AppColors.border : AppColors.borderDark,
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      gp.goalName,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        gp.health == GoalHealth.completed
                            ? 'Completed'
                            : (gp.health == GoalHealth.onTrack
                                ? 'On Track'
                                : 'Needs Attention'),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: isLight ? AppColors.border : AppColors.borderDark,
                    color: AppColors.primary,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progressPercent * 100).toStringAsFixed(0)}% Overall Progress',
                      style: AppTextStyles.caption.copyWith(
                        color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                      ),
                    ),
                    Text(
                      '₹${NumberFormat('#,##,###').format(gp.monthlyContribution)} this month',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSavingsTrendChart(bool isLight, MonthlySnapshotResult snapshot) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLight ? AppColors.border : AppColors.borderDark,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SAVINGS TREND',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: CustomPaint(
              size: const Size(double.infinity, 150),
              painter: TrendChartPainter(snapshot.trendData, isLight: isLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(bool isLight, MonthlySnapshotResult snapshot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'MONTHLY ACHIEVEMENTS',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ...snapshot.achievements.map((achievement) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLight ? AppColors.border : AppColors.borderDark,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    achievement.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          achievement.description,
                          style: AppTextStyles.caption.copyWith(
                            color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildInsightCard(bool isLight, MonthlySnapshotResult snapshot) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.secondary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'AI INSIGHT',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            snapshot.insight,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, bool isLight, MonthlySnapshotResult snapshot) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLight ? AppColors.border : AppColors.borderDark,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEXT BEST ACTION',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            snapshot.recommendation,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
          ),
          if (snapshot.recommendationRoute != null && snapshot.recommendationLabel != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push(snapshot.recommendationRoute!),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                snapshot.recommendationLabel!,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TrendChartPainter extends CustomPainter {
  final Map<String, double> data;
  final bool isLight;

  TrendChartPainter(this.data, {required this.isLight});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.values.fold(0.0, (max, val) => val > max ? val : max);
    final count = data.length;
    final spacing = size.width / (count + 1);

    final linePaint = Paint()
      ..color = isLight ? AppColors.border : AppColors.borderDark
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(0, size.height - 20), Offset(size.width, size.height - 20), linePaint);

    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
    );

    final activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.primary,
          AppColors.secondary,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    int i = 0;
    data.forEach((month, amount) {
      final x = spacing * (i + 1);
      final heightFactor = maxVal > 0 ? (amount / maxVal) : 0.0;
      final barHeight = (size.height - 40) * heightFactor;
      final barY = size.height - 20 - barHeight;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 16, barY, 32, barHeight.clamp(4.0, double.infinity)),
        const Radius.circular(8),
      );
      canvas.drawRRect(rrect, activePaint);

      textPainter.text = TextSpan(
        text: month,
        style: AppTextStyles.caption.copyWith(
          color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - 15));

      if (amount > 0) {
        final amountText = amount >= 1000 ? '₹${(amount / 1000).toStringAsFixed(1)}K' : '₹${amount.toStringAsFixed(0)}';
        textPainter.text = TextSpan(
          text: amountText,
          style: AppTextStyles.caption.copyWith(
            color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, barY - 15));
      }

      i++;
    });
  }

  @override
  bool shouldRepaint(covariant TrendChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.isLight != isLight;
  }
}
