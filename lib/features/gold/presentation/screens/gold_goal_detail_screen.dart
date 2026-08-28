import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';
import 'package:migoalpilot/features/goals/domain/services/goal_health_calculator.dart';
import 'package:migoalpilot/features/goals/domain/services/goal_milestone_calculator.dart';
import 'package:migoalpilot/features/gold/domain/services/gold_goal_calculator.dart';
import 'package:migoalpilot/features/gold/presentation/widgets/gold_goal_progress_widget.dart';
import 'package:migoalpilot/features/gold/presentation/widgets/gold_smart_insight_widget.dart';
import 'package:migoalpilot/features/gold/presentation/widgets/gold_health_section_widget.dart';
import 'package:migoalpilot/features/gold/presentation/widgets/gold_accumulation_chart_widget.dart';
import 'package:migoalpilot/features/gold/presentation/widgets/gold_milestones_widget.dart';
import 'package:migoalpilot/features/gold/presentation/widgets/gold_history_widget.dart';
import 'package:migoalpilot/features/gold/presentation/widgets/gold_actions_widget.dart';

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
                child: GoldGoalProgressWidget(
                  goal: g,
                  spotPrice: spotPrice,
                ),
              ),
              const SizedBox(height: 20),

              // Smart Insight Card
              GoldSmartInsightWidget(insight: insight),
              const SizedBox(height: 24),

              // Health Score Section
              GoldHealthSectionWidget(
                healthResult: healthResult,
                livePrice: goldState.livePrice,
                targetDate: g.targetDate,
                showDetails: _showHealthDetails,
                onToggleDetails: () {
                  setState(() {
                    _showHealthDetails = !_showHealthDetails;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Gold Accumulation Section
              GoldAccumulationChartWidget(monthlyData: monthlyData),
              const SizedBox(height: 24),

              // Milestones Section
              GoldMilestonesWidget(milestones: milestones),
              const SizedBox(height: 24),

              // History Section
              GoldHistoryWidget(
                transactions: state.transactions,
                spotPrice: spotPrice,
                showFullHistory: _showFullHistory,
                onToggleHistory: () {
                  setState(() {
                    _showFullHistory = !_showFullHistory;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Contextual Action Buttons
              GoldActionsWidget(goalId: widget.goalId),
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
}
