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
