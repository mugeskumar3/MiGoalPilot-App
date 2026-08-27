import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot_app/app/theme/app_colors.dart';
import 'package:migoalpilot_app/app/theme/app_spacing.dart';
import 'package:migoalpilot_app/app/theme/app_text_styles.dart';
import 'package:migoalpilot_app/core/widgets/shared_widgets.dart';
import 'package:migoalpilot_app/core/viewmodels/viewmodels.dart';
import 'package:migoalpilot_app/core/models/models.dart';

class MarriagePlannerScreen extends ConsumerWidget {
  const MarriagePlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marriageViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (state.isLoading && state.plan == null) {
      return const Scaffold(body: LoadingState());
    }

    final plan = state.plan;
    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Our Marriage Plan')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Failed to load plan.',
                style: AppTextStyles.bodyMedium,
              ),
              AppSpacing.heightM,
              ElevatedButton(
                onPressed: () => ref.read(marriageViewModelProvider.notifier).loadMarriagePlan(),
                child: const Text('Retry Loading Plan'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiAppBar(
        title: 'Our Marriage Journey',
        subtitle: '18 months to go',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                    '💍 WEDDING PLANNER',
                    style: AppTextStyles.caption.copyWith(
                      color: isLight ? AppColors.primary : AppColors.accentDark,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BUDGET LIMIT',
                            style: AppTextStyles.caption.copyWith(
                              color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          MoneyDisplay(
                            amount: plan.totalBudget,
                            style: AppTextStyles.displayMedium.copyWith(
                              color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '18 months left',
                          style: AppTextStyles.caption.copyWith(
                            color: isLight ? AppColors.primary : AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const MiSectionHeader(title: "Planning Dashboard"),
            const SizedBox(height: 8),
            _menuRow(
              context,
              '💰',
              'Budget Planner',
              'Estimate and track wedding expenses.',
              '/marriage-budget',
            ),
            _menuRow(
              context,
              '📅',
              'Milestone Timeline',
              'Contract dates and reservations.',
              '/marriage-timeline',
            ),
            _menuRow(
              context,
              '🎛️',
              'What-If Simulator',
              'Simulate guest count adjustments.',
              '/what-if-simulator',
            ),
            const SizedBox(height: 24),

            AiInsightCard(
              title: 'Optimize My Marriage Plan',
              description: 'AI Suggestion: You can save up to ₹40,000 by adjusting the photography budget and postponing honeymoon booking by two weeks.',
              onViewDetails: () => context.push('/ai'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _menuRow(
    BuildContext context,
    String emoji,
    String title,
    String subtitle,
    String route,
  ) {
    final isLight = Theme.of(context).brightness == Brightness.light;
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
              color: isLight ? AppColors.border : AppColors.borderDark,
              width: 1.2,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            onTap: () => context.push(route),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isLight ? AppColors.background : AppColors.backgroundDark,
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            title: Text(title, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark)),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isLight ? AppColors.primary : AppColors.accentDark),
          ),
        ),
      ),
    );
  }
}

class MarriageBudgetScreen extends ConsumerWidget {
  const MarriageBudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marriageViewModelProvider);
    final plan = state.plan;
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (plan == null) return const Scaffold(body: LoadingState());

    double totalSpent = plan.budgetItems.fold(0, (sum, item) => sum + item.actualSpent);

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Marriage Budget',
        onBackPressed: () => context.pop(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BUDGET LIMIT',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      MoneyDisplay(
                        amount: plan.totalBudget,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
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
                        'TOTAL SPENT',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      MoneyDisplay(
                        amount: totalSpent,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: plan.budgetItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = plan.budgetItems[index];
                final spendPct = item.estimatedCost > 0 ? (item.actualSpent / item.estimatedCost) : 0.0;
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.category,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_note_rounded,
                              size: 22,
                              color: isLight ? AppColors.primary : AppColors.accentDark,
                            ),
                            onPressed: () => _showEditDialog(context, ref, item),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estimate',
                                style: AppTextStyles.caption.copyWith(color: isLight ? AppColors.textSecondary : AppColors.textLightDark),
                              ),
                              const SizedBox(height: 2),
                              MoneyDisplay(
                                amount: item.estimatedCost,
                                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Spent', style: AppTextStyles.caption.copyWith(color: isLight ? AppColors.textSecondary : AppColors.textLightDark)),
                              const SizedBox(height: 2),
                              MoneyDisplay(
                                amount: item.actualSpent,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: item.actualSpent > 0 ? AppColors.success : null,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (item.actualSpent > 0) ...[
                        const SizedBox(height: 12),
                        GoalProgress(
                          progress: spendPct.clamp(0.0, 1.0),
                          color: AppColors.secondary,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, BudgetItem item) {
    final estController = TextEditingController(text: item.estimatedCost.toStringAsFixed(0));
    final actController = TextEditingController(text: item.actualSpent.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${item.category}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Estimated Cost (₹)',
                controller: estController,
                keyboardType: TextInputType.number,
              ),
              AppSpacing.heightM,
              AppTextField(
                label: 'Actual Spent (₹)',
                controller: actController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 44),
              ),
              onPressed: () {
                final est = double.tryParse(estController.text) ?? item.estimatedCost;
                final act = double.tryParse(actController.text) ?? item.actualSpent;
                ref.read(marriageViewModelProvider.notifier).updateItem(
                      item.copyWith(estimatedCost: est, actualSpent: act),
                    );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class MarriageTimelineScreen extends ConsumerWidget {
  const MarriageTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marriageViewModelProvider);
    final plan = state.plan;
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (plan == null) return const Scaffold(body: LoadingState());

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Milestones Timeline',
        onBackPressed: () => context.pop(),
      ),
      body: ListView.builder(
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
                        color: t.isCompleted ? AppColors.accent : Colors.transparent,
                        border: Border.all(
                          color: AppColors.accent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    if (index < plan.timelineTasks.length - 1)
                      Container(
                        width: 2,
                        height: 70,
                        color: t.isCompleted
                            ? AppColors.secondary 
                            : (isLight ? AppColors.border : AppColors.borderDark),
                      ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: AppTextStyles.titleLarge.copyWith(
                                  decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                                  color: t.isCompleted ? (isLight ? AppColors.textLight : AppColors.textLightDark) : null,
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
                            ref.read(marriageViewModelProvider.notifier).toggleTask(t.id, val ?? false);
                          },
                          activeColor: AppColors.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class WhatIfSimulatorScreen extends ConsumerStatefulWidget {
  const WhatIfSimulatorScreen({super.key});

  @override
  ConsumerState<WhatIfSimulatorScreen> createState() => _WhatIfSimulatorScreenState();
}

class _WhatIfSimulatorScreenState extends ConsumerState<WhatIfSimulatorScreen> {
  double _budget = 1000000;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final plan = ref.read(marriageViewModelProvider).plan;
      if (plan != null) {
        setState(() => _budget = plan.totalBudget);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marriageViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    final currentBudget = state.plan?.totalBudget ?? 1050000.0;
    final diff = _budget - currentBudget;
    final monthlyImpact = diff / 18.0;

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Wedding Simulator',
        onBackPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wedding Target Simulator',
                style: AppTextStyles.displayMedium.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Slide the wedding budget below to simulate how target shifts affect your monthly saving parameters.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 48),

              Center(
                child: Column(
                  children: [
                    Text(
                      'SIMULATED TARGET BUDGET',
                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    MoneyDisplay(
                      amount: _budget,
                      style: AppTextStyles.displayLarge.copyWith(
                        color: isLight ? AppColors.primary : AppColors.accentDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Slider(
                min: 1000000,
                max: 1500000,
                divisions: 10,
                value: _budget,
                activeColor: isLight ? AppColors.primary : AppColors.accentDark,
                inactiveColor: isLight ? AppColors.border : AppColors.borderDark,
                onChanged: (val) {
                  setState(() => _budget = val);
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('₹10.0L', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                  Text('₹12.5L', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                  Text('₹15.0L', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 32),

              _impactMetricRow('Additional Target Needed', diff, context),
              _impactMetricRow('Monthly Target Impact', monthlyImpact, context),
              const SizedBox(height: 32),

              AiInsightCard(
                title: 'GoalPilot AI Feedback',
                description: diff == 0
                    ? 'Your current plan is stable. Increasing budget limits requires higher monthly targets.'
                    : diff > 0
                        ? 'This keeps your wedding goal achievable, but you\'ll need to increase your monthly savings by ₹${NumberFormat('#,##,###').format(monthlyImpact.abs())} to maintain plan safety.'
                        : 'Reducing budget by ₹${NumberFormat('#,##,###').format(diff.abs())} decreases monthly target load. You can re-allocate saved margins to House goal.',
              ),

              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Apply Target Budget Change',
                onPressed: () {
                  ref.read(marriageViewModelProvider.notifier).updateBudget(_budget);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Budget updated to simulated parameters.'),
                    ),
                  );
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _impactMetricRow(String title, double val, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isNegative = val < 0;
    final color = isNegative
        ? AppColors.success
        : (val > 0 ? AppColors.error : (isLight ? AppColors.textPrimary : AppColors.textPrimaryDark));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  if (val > 0)
                    Text(
                      '+',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  MoneyDisplay(
                    amount: val,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: isLight ? AppColors.border : AppColors.borderDark),
        ],
      ),
    );
  }
}
