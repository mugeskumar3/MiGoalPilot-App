import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';

import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/shared/enums/enums.dart';
import 'package:migoalpilot/features/goals/domain/services/goal_health_calculator.dart';
import 'package:migoalpilot/features/goals/domain/services/goal_milestone_calculator.dart';


class GoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalDetailViewModelProvider(goalId));
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (state.isLoading) {
      return const Scaffold(body: LoadingState());
    }

    if (state.error != null || state.goal == null) {
      return Scaffold(
        body: ErrorState(
          error: state.error ?? 'Goal details failed to load.',
          onRetry: () => ref
              .read(goalDetailViewModelProvider(goalId).notifier)
              .loadDetails(),
        ),
      );
    }

    final g = state.goal!;

    final remaining = (g.targetAmount - g.currentSavings).clamp(
      0.0,
      double.infinity,
    );
    final daysLeft = g.targetDate.difference(DateTime.now()).inDays;
    final monthsLeft = (daysLeft / 30).clamp(1.0, double.infinity);
    final monthlyTarget = remaining / monthsLeft;
    final weeklyTarget = remaining / (daysLeft / 7).clamp(1.0, double.infinity);

    final marriageState = g.type == GoalType.marriage
        ? ref.watch(marriageViewModelProvider)
        : null;

    final isMarriage = g.type == GoalType.marriage;
    final healthResult = GoalHealthCalculator.calculate(g, state.transactions);

    if (state.newlyUnlockedMilestone != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMilestoneCelebrationDialog(
          context,
          ref,
          state.newlyUnlockedMilestone!,
          g,
        );
      });
    }

    return DefaultTabController(
      length: isMarriage ? 7 : 4,
      child: Scaffold(
        backgroundColor: isLight
            ? AppColors.background
            : AppColors.backgroundDark,
        appBar: MiAppBar(
          title: '${g.type.emoji} ${g.name}',
          subtitle:
              '${(g.progressPercentage * 100).toStringAsFixed(0)}% saved · ${g.health.label.toUpperCase()}',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
          actions: [
            if (isMarriage)
              IconButton(
                icon: const Icon(Icons.dashboard_customize_outlined),
                onPressed: () => context.push('/marriage-planner'),
              ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isLight ? AppColors.border : AppColors.borderDark,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GoalHealthBadge(health: g.health),
                        Text(
                          'Maturity: ${DateFormat('dd MMM yyyy').format(g.targetDate)}',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        MoneyDisplay(
                          amount: g.currentSavings,
                          style: AppTextStyles.displayMedium.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'saved of ',
                          style: AppTextStyles.caption.copyWith(
                            color: isLight
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                        MoneyDisplay(
                          amount: g.targetAmount,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GoalJourneyProgress(
                      progress: g.progressPercentage,
                      health: g.health,
                    ),
                  ],
                ),
              ),
            ),
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: isLight ? AppColors.border : AppColors.borderDark,
              indicatorColor: isLight
                  ? AppColors.primary
                  : AppColors.accentDark,
              labelColor: isLight ? AppColors.primary : AppColors.accentDark,
              unselectedLabelColor: isLight
                  ? AppColors.textSecondary
                  : AppColors.textLightDark,
              labelStyle: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              tabs: isMarriage
                  ? const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Milestones'),
                      Tab(text: 'Savings'),
                      Tab(text: 'Health Analysis'),
                      Tab(text: 'Marriage Budget'),
                      Tab(text: 'Marriage Timeline'),
                      Tab(text: 'AI Optimizer'),
                    ]
                  : const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Milestones'),
                      Tab(text: 'Savings'),
                      Tab(text: 'Health Analysis'),
                    ],
            ),
            Expanded(
              child: TabBarView(
                children: isMarriage
                    ? [
                        _OverviewTab(
                          remaining: remaining,
                          monthlyTarget: monthlyTarget,
                          weeklyTarget: weeklyTarget,
                          goalId: goalId,
                        ),
                        _MilestonesTab(
                          goal: g,
                          transactions: state.transactions,
                        ),
                        _SavingsTab(transactions: state.transactions),
                        _HealthAnalysisTab(result: healthResult, goal: g),
                        _MarriageBudgetTab(marriageState: marriageState!),
                        _MarriageTimelineTab(
                          marriageState: marriageState,
                          ref: ref,
                        ),
                        _AiOptimizerTab(goal: g),
                      ]
                    : [
                        _OverviewTab(
                          remaining: remaining,
                          monthlyTarget: monthlyTarget,
                          weeklyTarget: weeklyTarget,
                          goalId: goalId,
                        ),
                        _MilestonesTab(
                          goal: g,
                          transactions: state.transactions,
                        ),
                        _SavingsTab(transactions: state.transactions),
                        _HealthAnalysisTab(result: healthResult, goal: g),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMilestoneCelebrationDialog(
    BuildContext context,
    WidgetRef ref,
    GoalMilestone milestone,
    Goal goal,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        final isLight = Theme.of(ctx).brightness == Brightness.light;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isLight ? Colors.white : AppColors.surfaceDark,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉 Milestone Unlocked!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'You\'ve completed ${milestone.percentage}% of your ${goal.name}.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    goal.type == GoalType.gold
                        ? '${milestone.targetAmount.toStringAsFixed(2)}g saved'
                        : '₹${(milestone.targetAmount).toStringAsFixed(0)} saved',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Awesome!',
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ref
                        .read(goalDetailViewModelProvider(goal.id).notifier)
                        .clearCelebration();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final double remaining;
  final double monthlyTarget;
  final double weeklyTarget;
  final String goalId;

  const _OverviewTab({
    required this.remaining,
    required this.monthlyTarget,
    required this.weeklyTarget,
    required this.goalId,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MiSectionHeader(title: "Co-pilot Trajectory Indices"),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                _statRow('Outstanding Balance Needed', remaining, context),
                _statRow('Monthly Savings Target', monthlyTarget, context),
                _statRow('Weekly Savings Target', weeklyTarget, context),
              ],
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Add Savings Contribution',
            onPressed: () => context.push('/add-saving/$goalId'),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String title, double val, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
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
              fontWeight: FontWeight.w800,
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

class _SavingsTab extends StatelessWidget {
  final List<SavingsTransaction> transactions;

  const _SavingsTab({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    if (transactions.isEmpty) {
      return const EmptyState(
        title: 'No savings recorded yet',
        description: 'Deposits appear here as soon as you add them.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final t = transactions[index];
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLight ? AppColors.border : AppColors.borderDark,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.note ?? 'Savings Contribution',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(t.date),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              MoneyDisplay(
                amount: t.amount,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MarriageBudgetTab extends StatelessWidget {
  final MarriageState marriageState;

  const _MarriageBudgetTab({required this.marriageState});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final plan = marriageState.plan;
    if (plan == null) {
      return const Center(child: Text('Marriage Plan not initialized.'));
    }
    double totalSpent = plan.budgetItems.fold(
      0,
      (sum, item) => sum + item.actualSpent,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MiSectionHeader(title: "Budget Summary"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _miniMetricCard(
                  context,
                  'Total Budget Limit',
                  plan.totalBudget,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniMetricCard(
                  context,
                  'Total Spent',
                  totalSpent,
                  isSpent: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const MiSectionHeader(title: "Allocated Trajectory"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLight ? AppColors.border : AppColors.borderDark,
                width: 1.2,
              ),
            ),
            child: Column(
              children: plan.budgetItems.take(5).map((item) {
                final pct = item.estimatedCost / plan.totalBudget;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.category,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          MoneyDisplay(
                            amount: item.estimatedCost,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GoalProgress(progress: pct, color: AppColors.secondary),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          SecondaryButton(
            text: 'View Full Marriage Planner',
            onPressed: () => context.push('/marriage-planner'),
          ),
        ],
      ),
    );
  }

  Widget _miniMetricCard(
    BuildContext context,
    String label,
    double val, {
    bool isSpent = false,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight ? AppColors.border : AppColors.borderDark,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          MoneyDisplay(
            amount: val,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: isSpent ? AppColors.success : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarriageTimelineTab extends StatelessWidget {
  final MarriageState marriageState;
  final WidgetRef ref;

  const _MarriageTimelineTab({required this.marriageState, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final plan = marriageState.plan;
    if (plan == null) {
      return const Center(child: Text('Timeline not initialized.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: plan.timelineTasks.length,
      itemBuilder: (context, index) {
        final t = plan.timelineTasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.isCompleted
                          ? AppColors.secondary
                          : Colors.transparent,
                      border: Border.all(
                        color: AppColors.secondary,
                        width: 2.5,
                      ),
                    ),
                  ),
                  if (index < plan.timelineTasks.length - 1)
                    Container(
                      width: 2,
                      height: 54,
                      color: isLight ? AppColors.border : AppColors.borderDark,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        decoration: t.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: t.isCompleted
                            ? (isLight
                                  ? AppColors.textLight
                                  : AppColors.textLightDark)
                            : (isLight
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimaryDark),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Due: ${DateFormat('dd MMM yyyy').format(t.deadline)} (${t.category})',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: t.isCompleted,
                onChanged: (val) {
                  ref
                      .read(marriageViewModelProvider.notifier)
                      .toggleTask(t.id, val ?? false);
                },
                activeColor: AppColors.secondary,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AiOptimizerTab extends StatelessWidget {
  final Goal goal;

  const _AiOptimizerTab({required this.goal});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AiInsightCard(
            title: 'GoalPilot AI recommendations',
            description: goal.health == GoalHealth.onTrack
                ? 'Your savings are currently ${goal.health.label}. GoalPilot has determined you are ₹2,500 ahead of schedule. Keep this pace or extend your budget constraint by 5%.'
                : 'Your flight is experiencing minor headwinds. Savings are behind schedule. GoalPilot recommends extending your target date by 3 months or increasing your weekly contribution by ₹450 to re-track.',
          ),
          const SizedBox(height: 32),
          const Text(
            'Ask GoalPilot AI about this goal',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 12),
          _actionPrompt(context, 'Optimize my targets'),
          _actionPrompt(context, 'What if I delay the date?'),
          _actionPrompt(context, 'Analyze my monthly gaps'),
        ],
      ),
    );
  }

  Widget _actionPrompt(BuildContext context, String prompt) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Card(
      color: isLight ? AppColors.surface : AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLight ? AppColors.border : AppColors.borderDark,
          width: 1.2,
        ),
      ),
      child: ListTile(
        title: Text(
          prompt,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Icon(
          Icons.arrow_right_alt,
          color: isLight ? AppColors.primary : AppColors.accentDark,
        ),
        onTap: () => context.push('/ai'),
      ),
    );
  }
}

class _HealthAnalysisTab extends StatelessWidget {
  final GoalHealthResult result;
  final Goal goal;

  const _HealthAnalysisTab({required this.result, required this.goal});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          GoalHealthScoreWidget(result: result),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Health Parameters Breakdown",
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          GoalHealthBreakdownWidget(
            result: result,
            targetDate: goal.targetDate,
          ),
        ],
      ),
    );
  }
}

class _MilestonesTab extends StatelessWidget {
  final Goal goal;
  final List<SavingsTransaction> transactions;

  const _MilestonesTab({required this.goal, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: GoalMilestonesTimelineWidget(
        goal: goal,
        transactions: transactions,
      ),
    );
  }
}
