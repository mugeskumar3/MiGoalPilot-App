import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';
import '../core/widgets/shared_widgets.dart';
import '../core/viewmodels/viewmodels.dart';
import '../core/models/models.dart';
import '../shared/enums/enums.dart';

// --- 10. HOME DASHBOARD ---
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

    // Calculate total saved across goals
    double totalSaved = 0;
    for (var g in goalsState.goals) {
      totalSaved += g.currentSavings;
    }

    return Scaffold(
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
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Total Saved Hero (Typography first)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL SAVED',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            fontSize: 10,
                            color: isLight
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            MoneyDisplay(
                              amount: totalSaved,
                              style: AppTextStyles.displayLarge.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isLight
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimaryDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
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
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Very subtle progress line
                        Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: isLight
                                ? AppColors.border
                                : AppColors.borderDark,
                            borderRadius: BorderRadius.circular(1),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: 0.65,
                            child: Container(color: AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // AI Insight
                    if (aiState.dashboardInsight != null) ...[
                      AiInsightCard(
                        title: aiState.dashboardInsight!.title,
                        description: aiState.dashboardInsight!.description,
                        onViewDetails: () => context.push('/ai'),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Today's Action Section
                    const MiSectionHeader(title: "Today's Next Step"),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isLight
                              ? AppColors.border
                              : AppColors.borderDark,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(
                                alpha: 0.08,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '💍',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          AppSpacing.widthM,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Marriage Goal',
                                  style: AppTextStyles.titleMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Save ₹750 this week to stay on plan.',
                                  style: AppTextStyles.caption.copyWith(
                                    color: isLight
                                        ? AppColors.textSecondary
                                        : AppColors.textSecondaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final marriageGoal = goalsState.goals.firstWhere(
                                (g) => g.type == GoalType.marriage,
                                orElse: () => goalsState.goals.first,
                              );
                              context.push('/add-saving/${marriageGoal.id}');
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(90, 36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Add Saving',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Gold Rates Snippet
                    if (goldState.livePrice != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: GoldPriceWidget(
                              price: goldState.livePrice!.rate22K,
                              change:
                                  goldState.livePrice!.dailyChangePercentage,
                              karat: '22K',
                            ),
                          ),
                          AppSpacing.widthM,
                          Expanded(
                            child: GoldPriceWidget(
                              price: goldState.livePrice!.rate24K,
                              change:
                                  goldState.livePrice!.dailyChangePercentage,
                              karat: '24K',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Active goals header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const MiSectionHeader(title: "Your Journey"),
                        TextButton(
                          onPressed: () => context.push('/goals'),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(
                            'See All',
                            style: TextStyle(
                              color: isLight
                                  ? AppColors.primary
                                  : AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Goals List preview
                    if (goalsState.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (goalsState.goals.isEmpty)
                      const EmptyState(
                        title: 'No active goals yet',
                        description: 'Start tracking your milestones.',
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
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
                                          AppSpacing.widthS,
                                          Text(
                                            g.name,
                                            style: AppTextStyles.titleMedium,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${(g.progressPercentage * 100).toStringAsFixed(0)}%',
                                            style: AppTextStyles.titleMedium
                                                .copyWith(
                                                  color: isLight
                                                      ? AppColors.primary
                                                      : AppColors.primaryDark,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(width: 8),
                                          GoalHealthBadge(health: g.health),
                                        ],
                                      ),
                                    ],
                                  ),
                                  AppSpacing.heightS,
                                  GoalJourneyProgress(
                                    progress: g.progressPercentage,
                                    health: g.health,
                                  ),
                                  AppSpacing.heightS,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Saved: ',
                                            style: AppTextStyles.caption,
                                          ),
                                          MoneyDisplay(
                                            amount: g.currentSavings,
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const Text(
                                            ' of ',
                                            style: AppTextStyles.caption,
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
                                        DateFormat(
                                          'MMM yyyy',
                                        ).format(g.targetDate),
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                  AppSpacing.heightS,
                                  const Divider(height: 1),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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

// --- 11. GOALS LIST ---
class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalsViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    List<Goal> filtered = state.goals;
    if (_filter == 'On Track') {
      filtered = state.goals
          .where((g) => g.health == GoalHealth.onTrack)
          .toList();
    } else if (_filter == 'Needs Attention') {
      filtered = state.goals
          .where(
            (g) =>
                g.health == GoalHealth.needsAttention ||
                g.health == GoalHealth.atRisk,
          )
          .toList();
    } else if (_filter == 'Completed') {
      filtered = state.goals
          .where((g) => g.health == GoalHealth.completed)
          .toList();
    }

    // Calculations
    double totalSaved = 0;
    for (var g in state.goals) {
      totalSaved += g.currentSavings;
    }

    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final formattedSaved = formatter.format(totalSaved);

    return Scaffold(
      appBar: MiAppBar(
        title: 'My Goals',
        subtitle: '${state.goals.length} active goals · $formattedSaved saved',
        actions: [
          GestureDetector(
            onTap: () => context.push('/goal-selection'),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.accent, width: 1.5),
              ),
              child: const Icon(Icons.add, color: AppColors.accent, size: 18),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.tune_outlined,
              color: isLight
                  ? AppColors.textPrimary
                  : AppColors.textPrimaryDark,
              size: 20,
            ),
            onPressed: () => context.push('/multi-goal'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: ['All', 'On Track', 'Needs Attention', 'Completed'].map(
                (tab) {
                  final isSelected = _filter == tab;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        tab,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _filter = tab);
                      },
                      selectedColor: isLight
                          ? AppColors.secondary.withValues(alpha: 0.08)
                          : AppColors.secondaryDark.withValues(alpha: 0.15),
                      checkmarkColor: isLight
                          ? AppColors.primary
                          : AppColors.primaryDark,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? (isLight
                                  ? AppColors.primary
                                  : AppColors.primaryDark)
                            : (isLight
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryDark),
                      ),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? (isLight
                                    ? AppColors.primary
                                    : AppColors.primaryDark)
                              : (isLight
                                    ? AppColors.border
                                    : AppColors.borderDark),
                          width: 1.0,
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const LoadingState()
                : filtered.isEmpty
                ? const EmptyState(
                    title: 'No goals found',
                    description:
                        'Create a plan or adjust filters to see progress.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final g = filtered[index];
                      return InkWell(
                        onTap: () => context.push('/goals/${g.id}'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                      AppSpacing.widthS,
                                      Text(
                                        g.name,
                                        style: AppTextStyles.titleLarge
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  GoalHealthBadge(health: g.health),
                                ],
                              ),
                              AppSpacing.heightS,
                              GoalJourneyProgress(
                                progress: g.progressPercentage,
                                health: g.health,
                              ),
                              AppSpacing.heightS,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Saved: ',
                                        style: AppTextStyles.caption,
                                      ),
                                      MoneyDisplay(
                                        amount: g.currentSavings,
                                        style: AppTextStyles.caption.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        ' of ',
                                        style: AppTextStyles.caption,
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
                                    '${(g.progressPercentage * 100).toStringAsFixed(0)}%',
                                    style: AppTextStyles.caption.copyWith(
                                      color: isLight
                                          ? AppColors.primary
                                          : AppColors.primaryDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.heightS,
                              const Divider(height: 1),
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
}

// --- 12. CREATE GOAL (6-step guided PageView flow) ---
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
      appBar: AppBar(
        title: Text('Step ${_currentStep + 1} of 6'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevStep,
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
      ),
      body: Column(
        children: [
          // Progress bar indicators
          Row(
            children: List.generate(6, (index) {
              final active = index <= _currentStep;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: active
                      ? (isLight ? AppColors.primary : AppColors.primaryDark)
                      : (isLight ? AppColors.border : AppColors.borderDark),
                ),
              );
            }),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(), // Goal Category Selection
                _buildStep2(), // Goal Name & Amount
                _buildStep3(), // Target Date Selector
                _buildStep4(), // Current Savings
                _buildStep5(), // Importance Priority
                _buildStep6(), // Confirmation Draft
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: PrimaryButton(
              text: _currentStep == 5 ? 'CREATE GOAL PLAN' : 'CONTINUE',
              onPressed: _nextStep,
            ),
          ),
        ],
      ),
    );
  }

  // Step 1: Category Selection
  Widget _buildStep1() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHAT ARE YOU DREAMING ABOUT?',
            style: AppTextStyles.headlineLarge,
          ),
          AppSpacing.heightS,
          Text(
            'Select a path below to start building your savings flight target.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.heightL,
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemCount: GoalType.values.length,
              itemBuilder: (context, index) {
                final t = GoalType.values[index];
                final selected = _type == t;
                return InkWell(
                  onTap: () => setState(() => _type = t),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? (isLight
                                ? AppColors.primary.withValues(alpha: 0.05)
                                : AppColors.surfaceDark)
                          : (isLight ? Colors.white : AppColors.backgroundDark),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? (isLight
                                  ? AppColors.primary
                                  : AppColors.primaryDark)
                            : (isLight
                                  ? AppColors.border
                                  : AppColors.borderDark),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(t.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 6),
                        Text(
                          t.label,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
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

  // Step 2: Goal Name & Value
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HOW MUCH DO YOU NEED?',
            style: AppTextStyles.headlineLarge,
          ),
          AppSpacing.heightS,
          Text(
            'Input the monetary target. If Gold category, input the target weight in grams first.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.heightXL,
          AppTextField(
            label: 'Goal Name',
            controller: _nameController,
            hint: 'e.g. My Dream Marriage, Custom SUV Car',
          ),
          AppSpacing.heightM,
          if (_type == GoalType.gold) ...[
            AppTextField(
              label: 'Target Grams (g)',
              controller: _gramsController,
              keyboardType: TextInputType.number,
            ),
            AppSpacing.heightM,
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

  // Step 3: Date Picker
  Widget _buildStep3() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHEN DO YOU WANT TO ACHIEVE IT?',
            style: AppTextStyles.headlineLarge,
          ),
          AppSpacing.heightS,
          Text(
            'Select your target timeline. GoalPilot calculates requirements accordingly.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isLight ? AppColors.border : AppColors.borderDark,
                ),
              ),
              child: Column(
                children: [
                  const Text('📅', style: TextStyle(fontSize: 48)),
                  AppSpacing.heightM,
                  Text(
                    DateFormat('dd MMMM yyyy').format(_date),
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: isLight
                          ? AppColors.primary
                          : AppColors.primaryDark,
                    ),
                  ),
                  AppSpacing.heightS,
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

  // Step 4: Already Saved
  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHAT HAVE YOU ALREADY SAVED?',
            style: AppTextStyles.headlineLarge,
          ),
          AppSpacing.heightS,
          Text(
            'If you have initial capital or bought grams for this goal, record it here.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.heightXL,
          AppTextField(
            label: 'Already Saved Amount (₹)',
            controller: _currentController,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  // Step 5: Importance Category
  Widget _buildStep5() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HOW IMPORTANT IS THIS GOAL?',
            style: AppTextStyles.headlineLarge,
          ),
          AppSpacing.heightS,
          Text(
            'GoalPilot AI balances goals by priority in case your total budget overflows.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.heightXL,
          Expanded(
            child: ListView.separated(
              itemCount: GoalPriority.values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = GoalPriority.values[index];
                final selected = _priority == p;
                return InkWell(
                  onTap: () => setState(() => _priority = p),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selected
                          ? (isLight
                                ? AppColors.primary.withValues(alpha: 0.05)
                                : AppColors.surfaceDark)
                          : (isLight ? Colors.white : AppColors.backgroundDark),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? (isLight
                                  ? AppColors.primary
                                  : AppColors.primaryDark)
                            : (isLight
                                  ? AppColors.border
                                  : AppColors.borderDark),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p.label, style: AppTextStyles.titleMedium),
                        if (selected)
                          Icon(
                            Icons.check_circle,
                            color: isLight
                                ? AppColors.primary
                                : AppColors.primaryDark,
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

  // Step 6: Confirmation Plan
  Widget _buildStep6() {
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR FLIGHT TARGET PLAN',
            style: AppTextStyles.headlineLarge,
          ),
          AppSpacing.heightS,
          Text(
            'Verify details below. We generated target save indices for your co-pilot cockpit.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.heightXL,
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
          _confirmRow('Deadline', DateFormat('dd MMM yyyy').format(_date)),
          _confirmRow(
            'Monthly Index Needed',
            '₹${NumberFormat('#,##,###').format(monthly)}/month',
          ),
          _confirmRow(
            'Weekly Target Needed',
            '₹${NumberFormat('#,##,###').format(weekly)}/week',
          ),
        ],
      ),
    );
  }

  Widget _confirmRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 2),
          Text(
            val,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

// --- 13. GOAL DETAIL ---
class GoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalDetailViewModelProvider(goalId));

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

    // Watch marriage state if relevant
    final marriageState = g.type == GoalType.marriage
        ? ref.watch(marriageViewModelProvider)
        : null;

    final isMarriage = g.type == GoalType.marriage;

    return DefaultTabController(
      length: isMarriage ? 5 : 2,
      child: Scaffold(
        appBar: MiAppBar(
          title: '${g.type.emoji} ${g.name}',
          subtitle:
              '${(g.progressPercentage * 100).toStringAsFixed(0)}% saved · ${g.health.label.toUpperCase()}',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => Navigator.of(context).pop(),
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
            // Top Stats (Editorial style, no card border, spacious)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GoalHealthBadge(health: g.health),
                      Text(
                        'Target maturity: ${DateFormat('dd MMM yyyy').format(g.targetDate)}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      MoneyDisplay(
                        amount: g.currentSavings,
                        style: AppTextStyles.displayMedium,
                      ),
                      const SizedBox(width: 8),
                      const Text('saved of ', style: AppTextStyles.caption),
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
            TabBar(
              isScrollable: isMarriage,
              tabAlignment: isMarriage ? TabAlignment.start : null,
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

// --- Overview Sub-Tab ---
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CO-PILOT PLANNING TARGETS',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _statRow('Outstanding Balance Needed', remaining),
          _statRow('Monthly Savings Target', monthlyTarget),
          _statRow('Weekly Savings Target', weeklyTarget),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Add Savings Contribution',
            onPressed: () => context.push('/add-saving/$goalId'),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String title, double val) {
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
                  color: AppColors.textSecondary,
                ),
              ),
              MoneyDisplay(
                amount: val,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
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

// --- Savings Sub-Tab ---
class _SavingsTab extends StatelessWidget {
  final List<SavingsTransaction> transactions;

  const _SavingsTab({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const EmptyState(
        title: 'No savings recorded yet',
        description: 'Deposits appear here as soon as you add them.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final t = transactions[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.note ?? 'Savings Contribution',
                    style: AppTextStyles.titleMedium,
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

// --- Redesigned Marriage Budget Tab directly inside Goal Details ---
class _MarriageBudgetTab extends StatelessWidget {
  final MarriageState marriageState;

  const _MarriageBudgetTab({required this.marriageState});

  @override
  Widget build(BuildContext context) {
    final plan = marriageState.plan;
    if (plan == null) {
      return const Center(child: Text('Marriage Plan not initialized.'));
    }
    // Calculations
    double totalSpent = plan.budgetItems.fold(
      0,
      (sum, item) => sum + item.actualSpent,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BUDGET SUMMARY',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 20),
          Text(
            'WHERE YOUR MONEY GOES',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...plan.budgetItems.take(5).map((item) {
            final pct = item.estimatedCost / plan.totalBudget;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.category,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      MoneyDisplay(
                        amount: item.estimatedCost,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GoalProgress(progress: pct, color: AppColors.secondary),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLight ? AppColors.border : AppColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          MoneyDisplay(
            amount: val,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isSpent ? AppColors.success : null,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Redesigned Marriage Timeline Tab directly inside Goal Details ---
class _MarriageTimelineTab extends StatelessWidget {
  final MarriageState marriageState;
  final WidgetRef ref;

  const _MarriageTimelineTab({required this.marriageState, required this.ref});

  @override
  Widget build(BuildContext context) {
    final plan = marriageState.plan;
    if (plan == null) {
      return const Center(child: Text('Timeline not initialized.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: plan.timelineTasks.length,
      itemBuilder: (context, index) {
        final t = plan.timelineTasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.isCompleted
                          ? AppColors.secondary
                          : Colors.transparent,
                      border: Border.all(color: AppColors.secondary, width: 2),
                    ),
                  ),
                  if (index < plan.timelineTasks.length - 1)
                    Container(width: 2, height: 50, color: AppColors.border),
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
                        color: t.isCompleted ? AppColors.textLight : null,
                      ),
                    ),
                    const SizedBox(height: 2),
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

// --- Goal AI Optimizer Tab ---
class _AiOptimizerTab extends StatelessWidget {
  final Goal goal;

  const _AiOptimizerTab({required this.goal});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AiInsightCard(
            title: 'GoalPilot AI suggestions',
            description: goal.health == GoalHealth.onTrack
                ? 'Your savings are currently ${goal.health.label}. GoalPilot has determined you are ₹2,500 ahead of schedule. Keep this pace or extend your budget constraint by 5%.'
                : 'Your flight is experiencing minor headwinds. Savings are behind schedule. GoalPilot recommends extending your target date by 3 months or increasing your weekly contribution by ₹450 to re-track.',
          ),
          const SizedBox(height: 24),
          const Text(
            'Ask GoalPilot AI about this goal',
            style: AppTextStyles.titleLarge,
          ),
          AppSpacing.heightS,
          _actionPrompt(context, 'Optimize my targets'),
          _actionPrompt(context, 'What if I delay the date?'),
          _actionPrompt(context, 'Analyze my monthly gaps'),
        ],
      ),
    );
  }

  Widget _actionPrompt(BuildContext context, String prompt) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(prompt, style: AppTextStyles.titleMedium),
        trailing: const Icon(Icons.arrow_right_alt),
        onTap: () {
          context.push('/ai');
        },
      ),
    );
  }
}

// --- 14. ADD SAVINGS SCREEN (Celebration + Clean validation) ---
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
    if (_isSuccess) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              AppSpacing.heightM,
              const Text(
                'Contribution Recorded!',
                style: AppTextStyles.displayMedium,
              ),
              AppSpacing.heightS,
              Text(
                'Goal progress has been recalculated. You are flying closer to your dreams.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: 'Go to Cockpit',
                onPressed: () => context.go('/dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Savings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECORD CONTRIBUTION',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
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
              label: 'Deposit note',
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
