import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_spacing.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';

import 'package:migoalpilot/shared/enums/enums.dart';

import 'package:migoalpilot/core/services/smart_reminder_engine.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final goalsState = ref.watch(goalsViewModelProvider);
    final goldState = ref.watch(goldViewModelProvider);
    final aiState = ref.watch(aiViewModelProvider);
    final reminderState = ref.watch(smartReminderViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    final userName = authState.user?.name ?? 'Mugesh';
    final userInitials = userName.isNotEmpty ? userName[0].toUpperCase() : 'M';

    double totalSaved = 0;
    for (var g in goalsState.goals) {
      totalSaved += g.currentSavings;
    }

    return Scaffold(
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(goalsViewModelProvider.notifier).loadGoals();
          ref.read(goldViewModelProvider.notifier).loadGoldData();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            MiSliverAppBar(
              userName: userName,
              avatarInitials: userInitials,
              onAvatarTap: () => context.push('/profile'),
              onNotificationTap: () => context.push('/notifications'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Financial Dashboard Header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL SAVINGS BALANCE',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            fontSize: 10,
                            color: isLight
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            MoneyDisplay(
                              amount: totalSaved,
                              style: AppTextStyles.displayLarge.copyWith(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: isLight
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimaryDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '+₹18,500 this month',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isLight
                                ? AppColors.border
                                : AppColors.borderDark,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: 0.65,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isLight
                                      ? AppColors.primary
                                      : AppColors.accentDark,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // AI Insight Widget (Clean and integrated)
                    if (aiState.dashboardInsight != null) ...[
                      AiInsightCard(
                        title: aiState.dashboardInsight?.title ?? '',
                        description:
                            aiState.dashboardInsight?.description ?? '',
                        onViewDetails: () => context.push('/ai'),
                      ),
                      const SizedBox(height: 32),
                    ],

                    if (reminderState.activeReminder != null) ...[
                      _buildSmartReminderBanner(
                        context,
                        reminderState.activeReminder!,
                        isLight,
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Monthly Snapshot Entry Point Card
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 32),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isLight
                              ? [
                                  AppColors.secondary.withValues(alpha: 0.06),
                                  AppColors.secondary.withValues(alpha: 0.02),
                                ]
                              : [
                                  AppColors.surfaceDark,
                                  AppColors.backgroundDark,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isLight
                              ? AppColors.secondary.withValues(alpha: 0.12)
                              : AppColors.borderDark,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('📊', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                'MONTHLY SNAPSHOT',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isLight ? AppColors.secondary : AppColors.accentDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your Goal Progress Check-In',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Review how your savings, goal health, and contributions stack up this month compared to last.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.push('/monthly-snapshot'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLight ? AppColors.secondary : AppColors.accentDark,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'View Financial Snapshot',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Smart Savings Plan Banner Card
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 32),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isLight
                              ? [
                                  AppColors.primary.withValues(alpha: 0.06),
                                  AppColors.primary.withValues(alpha: 0.02),
                                ]
                              : [
                                  AppColors.surfaceDark,
                                  AppColors.backgroundDark,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isLight
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.borderDark,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('💡', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                'SMART SAVINGS PLAN',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isLight
                                      ? AppColors.primary
                                      : AppColors.primaryDark,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Balance monthly savings capacity dynamically across all active goals to optimize your timelines.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13,
                              color: isLight
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.push('/multi-goal'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLight
                                  ? AppColors.primary
                                  : AppColors.primaryDark,
                              foregroundColor: isLight
                                  ? Colors.white
                                  : AppColors.backgroundDark,
                              elevation: 0,
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Open Rebalancing Cockpit',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Next Action Center
                    const MiSectionHeader(title: "Today's Next Action"),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isLight
                              ? AppColors.border
                              : AppColors.borderDark,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(
                                alpha: 0.08,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '💍',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          AppSpacing.widthM,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Marriage Journey Plan',
                                  style: AppTextStyles.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Save ₹750 this week to maintain trajectory.',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isLight
                                        ? AppColors.textSecondary
                                        : AppColors.textSecondaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: goalsState.goals.isEmpty
                                ? () => context.push('/goal-selection')
                                : () {
                                    final marriageGoal = goalsState.goals
                                        .firstWhere(
                                          (g) => g.type == GoalType.marriage,
                                          orElse: () => goalsState.goals.first,
                                        );
                                    context.push(
                                      '/add-saving/${marriageGoal.id}',
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLight
                                  ? AppColors.primary
                                  : AppColors.accentDark,
                              foregroundColor: isLight
                                  ? Colors.white
                                  : AppColors.backgroundDark,
                              elevation: 0,
                              minimumSize: const Size(0, 40),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Add Saving',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isLight
                                    ? Colors.white
                                    : AppColors.backgroundDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Gold Overview
                    if (goldState.livePrice != null) ...[
                      const MiSectionHeader(title: "Gold Market Rates"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GoldPriceWidget(
                              price: goldState.livePrice?.rate22K ?? 0.0,
                              change:
                                  goldState.livePrice?.dailyChangePercentage ??
                                  0.0,
                              karat: '22K',
                            ),
                          ),
                          AppSpacing.widthM,
                          Expanded(
                            child: GoldPriceWidget(
                              price: goldState.livePrice?.rate24K ?? 0.0,
                              change:
                                  goldState.livePrice?.dailyChangePercentage ??
                                  0.0,
                              karat: '24K',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Goal Journeys Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const MiSectionHeader(title: "Active Journeys"),
                        TextButton(
                          onPressed: () => context.push('/goals'),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(
                            'See All',
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

                    // Active Journeys List
                    if (goalsState.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (goalsState.goals.isEmpty)
                      const EmptyState(
                        title: 'No Active Goals Yet',
                        description:
                            'Every journey begins with a calculated destination.',
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: goalsState.goals.take(3).length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final g = goalsState.goals[index];
                          return InkWell(
                            onTap: () => context.push(g.type == GoalType.gold ? '/gold-goals/${g.id}' : '/goals/${g.id}'),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isLight
                                    ? Colors.white
                                    : AppColors.surfaceDark,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isLight
                                      ? AppColors.border
                                      : AppColors.borderDark,
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            g.type.emoji,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            g.name,
                                            style: AppTextStyles.titleLarge
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GoalHealthBadge(health: g.health),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  (isLight
                                                          ? AppColors.primary
                                                          : AppColors
                                                                .primaryDark)
                                                      .withValues(alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${g.healthScore}',
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: isLight
                                                        ? AppColors.primary
                                                        : AppColors.primaryDark,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  GoalJourneyProgress(
                                    progress: g.progressPercentage,
                                    health: g.health,
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          MoneyDisplay(
                                            amount: g.currentSavings,
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Text(
                                            ' of ',
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  color: isLight
                                                      ? AppColors.textSecondary
                                                      : AppColors
                                                            .textSecondaryDark,
                                                ),
                                          ),
                                          MoneyDisplay(
                                            amount: g.targetAmount,
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Target: ${DateFormat('MMM yyyy').format(g.targetDate)}',
                                        style: AppTextStyles.caption.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartReminderBanner(
    BuildContext context,
    ReminderResult r,
    bool isLight,
  ) {
    final isHigh = r.priority == ReminderPriority.high;
    final isMedium = r.priority == ReminderPriority.medium;

    Color iconBgColor;
    String emoji;
    if (isHigh) {
      iconBgColor = AppColors.error.withValues(alpha: 0.08);
      emoji = '⚠️';
    } else if (isMedium) {
      iconBgColor = AppColors.warning.withValues(alpha: 0.08);
      emoji = '💡';
    } else {
      iconBgColor = AppColors.success.withValues(alpha: 0.08);
      emoji = '🔔';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHigh
              ? AppColors.error.withValues(alpha: 0.2)
              : (isMedium
                    ? AppColors.warning.withValues(alpha: 0.2)
                    : (isLight ? AppColors.border : AppColors.borderDark)),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Text(
                r.title.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isHigh
                      ? AppColors.error
                      : (isLight
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryDark),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            r.message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push(r.actionRoute),
            style: ElevatedButton.styleFrom(
              backgroundColor: isHigh
                  ? AppColors.error
                  : (isLight ? AppColors.primary : AppColors.primaryDark),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              r.actionLabel,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
