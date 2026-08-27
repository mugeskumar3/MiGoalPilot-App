import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_spacing.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final goalsState = ref.watch(goalsViewModelProvider);
    final goldState = ref.watch(goldViewModelProvider);
    final aiState = ref.watch(aiViewModelProvider);
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
                            onTap: () => context.push('/goals/${g.id}'),
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
                                      GoalHealthBadge(health: g.health),
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
}

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalsViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    double totalSaved = state.goals.fold(0, (sum, g) => sum + g.currentSavings);

    return Scaffold(
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      appBar: MiAppBar(
        title: 'Active Journeys',
        subtitle:
            '${state.goals.length} targets · ₹${NumberFormat('#,##,###').format(totalSaved)} saved',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24),
            onPressed: () => context.push('/goal-selection'),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.goals.isEmpty
          ? EmptyState(
              title: 'No Active Goals',
              description:
                  'Every flight requires planning. Map your next savings milestone.',
              actionText: 'Create Goal Plan',
              onAction: () => context.push('/goal-selection'),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: state.goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final g = state.goals[index];
                return InkWell(
                  onTap: () => context.push('/goals/${g.id}'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  g.type.emoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  g.name,
                                  style: AppTextStyles.titleLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            GoalHealthBadge(health: g.health),
                          ],
                        ),
                        const SizedBox(height: 14),
                        GoalJourneyProgress(
                          progress: g.progressPercentage,
                          health: g.health,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                MoneyDisplay(
                                  amount: g.currentSavings,
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' of ',
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
                            Text(
                              'Target: ${DateFormat('dd MMM yyyy').format(g.targetDate)}',
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
    );
  }
}

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _gramsController = TextEditingController();
  final _currentController = TextEditingController();

  GoalType _type = GoalType.custom;
  GoalPriority _priority = GoalPriority.medium;
  DateTime _date = DateTime.now().add(const Duration(days: 365));

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _gramsController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 5) {
      FocusScope.of(context).unfocus();
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _save();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      FocusScope.of(context).unfocus();
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _save() {
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : '${_type.label} Plan';
    final amt = double.tryParse(_amountController.text) ?? 0.0;
    final grams = double.tryParse(_gramsController.text) ?? 0.0;
    final current = double.tryParse(_currentController.text) ?? 0.0;

    final goal = Goal(
      id: 'g_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: _type,
      targetAmount: amt,
      currentSavings: current,
      targetDate: _date,
      priority: _priority,
      health: GoalHealth.onTrack,
      targetGrams: grams,
    );

    ref.read(goalsViewModelProvider.notifier).addGoal(goal);
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Step ${_currentStep + 1} of 6',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
            fontSize: 16,
          ),
        ),
        leading: _currentStep > 0
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isLight
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryDark,
                ),
                onPressed: _prevStep,
              )
            : IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: isLight
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryDark,
                ),
                onPressed: () => context.pop(),
              ),
      ),
      body: Column(
        children: [
          Row(
            children: List.generate(6, (index) {
              final active = index <= _currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: active
                        ? (isLight ? AppColors.primary : AppColors.accentDark)
                        : (isLight ? AppColors.border : AppColors.borderDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
                _buildStep5(),
                _buildStep6(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: PrimaryButton(
              text: _currentStep == 5 ? 'CREATE GOAL PLAN' : 'CONTINUE',
              onPressed: _nextStep,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your target goal?',
            style: AppTextStyles.displayLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a path below to start building your savings flight target.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isLight
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: GoalType.values.length,
              itemBuilder: (context, index) {
                final t = GoalType.values[index];
                final selected = _type == t;
                return InkWell(
                  onTap: () => setState(() => _type = t),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? (isLight
                                ? AppColors.primary.withValues(alpha: 0.05)
                                : AppColors.surfaceDark)
                          : (isLight
                                ? Colors.white
                                : AppColors.surfaceDark.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? (isLight
                                  ? AppColors.primary
                                  : AppColors.accentDark)
                            : (isLight
                                  ? AppColors.border
                                  : AppColors.borderDark),
                        width: selected ? 2 : 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(t.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 8),
                        Text(
                          t.label,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How much do you need?',
            style: AppTextStyles.displayLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Input the monetary target. If Gold category, input the target weight in grams first.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isLight
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 32),
          AppTextField(
            label: 'Goal Name',
            controller: _nameController,
            hint: 'e.g. My Wedding, Custom SUV Car',
          ),
          const SizedBox(height: 20),
          if (_type == GoalType.gold) ...[
            AppTextField(
              label: 'Target Grams (g)',
              controller: _gramsController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
          ],
          AppTextField(
            label: 'Target Amount (₹)',
            controller: _amountController,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'When do you want it?',
            style: AppTextStyles.displayLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your target timeline. GoalPilot calculates requirements accordingly.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isLight
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryDark,
            ),
          ),
          const Spacer(),
          Center(
            child: Container(
              padding: const EdgeInsets.all(28),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('📅', style: TextStyle(fontSize: 36)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_date),
                    style: AppTextStyles.displayMedium.copyWith(
                      color: isLight ? AppColors.primary : AppColors.accentDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 3650),
                        ),
                      );
                      if (picked != null) {
                        setState(() => _date = picked);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLight
                          ? AppColors.primary
                          : AppColors.accentDark,
                      foregroundColor: isLight
                          ? Colors.white
                          : AppColors.backgroundDark,
                      minimumSize: const Size(140, 44),
                    ),
                    child: const Text('Change Date'),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What have you saved?',
            style: AppTextStyles.displayLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'If you have initial capital or bought grams for this goal, record it here.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isLight
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 32),
          AppTextField(
            label: 'Already Saved Amount (₹)',
            controller: _currentController,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal Priority',
            style: AppTextStyles.displayLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'GoalPilot AI balances goals by priority in case your total budget overflows.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isLight
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: GoalPriority.values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = GoalPriority.values[index];
                final selected = _priority == p;
                return InkWell(
                  onTap: () => setState(() => _priority = p),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: selected
                          ? (isLight
                                ? AppColors.primary.withValues(alpha: 0.05)
                                : AppColors.surfaceDark)
                          : (isLight
                                ? Colors.white
                                : AppColors.surfaceDark.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? (isLight
                                  ? AppColors.primary
                                  : AppColors.accentDark)
                            : (isLight
                                  ? AppColors.border
                                  : AppColors.borderDark),
                        width: selected ? 2 : 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          p.label,
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (selected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: isLight
                                ? AppColors.primary
                                : AppColors.accentDark,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep6() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : '${_type.label} Plan';
    final amt = double.tryParse(_amountController.text) ?? 0.0;
    final current = double.tryParse(_currentController.text) ?? 0.0;
    final rem = (amt - current).clamp(0.0, double.infinity);

    final days = _date.difference(DateTime.now()).inDays;
    final months = (days / 30).clamp(1.0, double.infinity);
    final monthly = rem / months;
    final weekly = rem / (days / 7).clamp(1.0, double.infinity);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verify & Launch',
            style: AppTextStyles.displayLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verify details below. We generated target save indices for your co-pilot cockpit.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isLight
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 24),
          Container(
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
              children: [
                _confirmRow('Category Path', '${_type.emoji} ${_type.label}'),
                _confirmRow('Goal Name', name),
                _confirmRow(
                  'Target Amount',
                  '₹${NumberFormat('#,##,###').format(amt)}',
                ),
                _confirmRow(
                  'Initial Capital',
                  '₹${NumberFormat('#,##,###').format(current)}',
                ),
                _confirmRow(
                  'Outstanding Gap',
                  '₹${NumberFormat('#,##,###').format(rem)}',
                ),
                _confirmRow(
                  'Deadline',
                  DateFormat('dd MMM yyyy').format(_date),
                ),
                _confirmRow(
                  'Monthly Target',
                  '₹${NumberFormat('#,##,###').format(monthly)}/month',
                ),
                _confirmRow(
                  'Weekly Target',
                  '₹${NumberFormat('#,##,###').format(weekly)}/week',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmRow(String label, String val) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryDark,
            ),
          ),
          Text(
            val,
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

    return DefaultTabController(
      length: isMarriage ? 5 : 2,
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
              isScrollable: isMarriage,
              tabAlignment: isMarriage ? TabAlignment.start : null,
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
                      Tab(text: 'Savings'),
                      Tab(text: 'Marriage Budget'),
                      Tab(text: 'Marriage Timeline'),
                      Tab(text: 'AI Optimizer'),
                    ]
                  : const [Tab(text: 'Overview'), Tab(text: 'Savings')],
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
                        _SavingsTab(transactions: state.transactions),
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
                        _SavingsTab(transactions: state.transactions),
                      ],
              ),
            ),
          ],
        ),
      ),
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

class AddSavingScreen extends ConsumerStatefulWidget {
  final String goalId;

  const AddSavingScreen({super.key, required this.goalId});

  @override
  ConsumerState<AddSavingScreen> createState() => _AddSavingScreenState();
}

class _AddSavingScreenState extends ConsumerState<AddSavingScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _gramsController = TextEditingController();
  bool _isSuccess = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _gramsController.dispose();
    super.dispose();
  }

  void _submit() async {
    final amt = double.tryParse(_amountController.text) ?? 0;
    final grams = double.tryParse(_gramsController.text);
    if (amt > 0) {
      await ref
          .read(goalDetailViewModelProvider(widget.goalId).notifier)
          .addSavingContribution(
            amt,
            _noteController.text.trim().isNotEmpty
                ? _noteController.text.trim()
                : 'Savings Deposit',
            grams: grams,
          );
      setState(() => _isSuccess = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (_isSuccess) {
      return Scaffold(
        backgroundColor: isLight
            ? AppColors.background
            : AppColors.backgroundDark,
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.surfaceDark,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLight ? AppColors.border : AppColors.borderDark,
                    width: 1.2,
                  ),
                ),
                child: const Text('🎉', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 32),
              Text(
                'Contribution Recorded!',
                style: AppTextStyles.displayMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.heightS,
              Text(
                'Goal progress has been recalculated. You are flying closer to your dreams.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isLight
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: 'Go to Dashboard',
                onPressed: () => context.go('/dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Add Savings',
        onBackPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MiSectionHeader(title: "Record Contribution"),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Amount (₹)',
              controller: _amountController,
              keyboardType: TextInputType.number,
            ),
            AppSpacing.heightM,
            AppTextField(
              label: 'Gold Weight in Grams (Optional)',
              controller: _gramsController,
              keyboardType: TextInputType.number,
            ),
            AppSpacing.heightM,
            AppTextField(
              label: 'Deposit Note',
              controller: _noteController,
              hint: 'e.g. Monthly salary contribution',
            ),
            const SizedBox(height: 32),
            PrimaryButton(text: 'RECORD CONTRIBUTION', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
