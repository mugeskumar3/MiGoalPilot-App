import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/services/goal_template_calculator.dart';
import 'package:migoalpilot/core/viewmodels/goal_template_state.dart';
import 'package:migoalpilot/core/viewmodels/goal_template_viewmodel.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

class GoalTemplateSetupScreen extends ConsumerStatefulWidget {
  final String templateId;
  const GoalTemplateSetupScreen({super.key, required this.templateId});

  @override
  ConsumerState<GoalTemplateSetupScreen> createState() => _GoalTemplateSetupScreenState();
}

class _GoalTemplateSetupScreenState extends ConsumerState<GoalTemplateSetupScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _targetAmountController;
  late final TextEditingController _currentSavingsController;

  // Emergency Fund
  late final TextEditingController _expensesController;
  late final TextEditingController _customMonthsController;

  // Gold
  late final TextEditingController _gramsController;

  // House / Car
  late final TextEditingController _propertyCostController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(goalTemplateViewModelProvider(widget.templateId));

    _nameController = TextEditingController(text: state.name);
    _targetAmountController = TextEditingController(text: state.targetAmount.toStringAsFixed(0));
    _currentSavingsController = TextEditingController(text: state.currentSavings.toStringAsFixed(0));

    _expensesController = TextEditingController(text: state.essentialExpenses.toStringAsFixed(0));
    _customMonthsController = TextEditingController(text: state.safetyMonths.toString());

    _gramsController = TextEditingController(text: state.targetGrams.toString());

    _propertyCostController = TextEditingController(text: state.propertyCost.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentSavingsController.dispose();
    _expensesController.dispose();
    _customMonthsController.dispose();
    _gramsController.dispose();
    _propertyCostController.dispose();
    super.dispose();
  }

  void _submit() async {
    final notifier = ref.read(goalTemplateViewModelProvider(widget.templateId).notifier);
    final goalsNotifier = ref.read(goalsViewModelProvider.notifier);

    final success = await notifier.saveGoal(goalsNotifier);
    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final state = ref.watch(goalTemplateViewModelProvider(widget.templateId));
    final notifier = ref.read(goalTemplateViewModelProvider(widget.templateId).notifier);

    // Dynamic Monthly Savings calculation
    final suggestedSavings = GoalTemplateCalculator.calculateSuggestedMonthlySaving(
      targetAmount: state.template.id == 'gold' ? state.targetAmount : state.targetAmount,
      currentSavings: state.currentSavings,
      targetDate: state.targetDate,
    );

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Setup ${state.template.title}',
        onBackPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Template Overview Card
              _buildTemplateCard(state, isLight),
              const SizedBox(height: 24),

              // 2. Dynamic recommendations banner
              _buildRecommendationCard(state, suggestedSavings, isLight),
              const SizedBox(height: 24),

              if (state.error != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 3. Form Sections
              _buildFormSectionHeader('PLAN IDENTIFIER', isLight),
              _buildInputContainer(isLight, [
                _buildTextField(
                  controller: _nameController,
                  label: 'Goal Name',
                  hint: 'e.g. Dream Wedding Fund',
                  onChanged: (val) => notifier.updateName(val),
                ),
              ]),
              const SizedBox(height: 24),

              // Conditional widgets based on template category
              if (state.template.id == 'emergency_fund') ...[
                _buildFormSectionHeader('EMERGENCY CALCULATOR', isLight),
                _buildInputContainer(isLight, [
                  _buildTextField(
                    controller: _expensesController,
                    label: 'Monthly Essential Expenses',
                    hint: 'e.g. ₹50,000',
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final valDouble = double.tryParse(val) ?? 0.0;
                      notifier.updateEssentialExpenses(valDouble);
                      _targetAmountController.text =
                          (valDouble * state.safetyMonths).toStringAsFixed(0);
                    },
                  ),
                  const Divider(height: 1),
                  _buildBufferSelector(state, notifier, isLight),
                ]),
                const SizedBox(height: 24),
              ] else if (state.template.id == 'gold') ...[
                _buildFormSectionHeader('GOLD ACCUMULATION SETUP', isLight),
                _buildInputContainer(isLight, [
                  _buildTextField(
                    controller: _gramsController,
                    label: 'Target Gold Weight (grams)',
                    hint: 'e.g. 10',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) {
                      final valDouble = double.tryParse(val) ?? 0.0;
                      notifier.updateTargetGrams(valDouble);
                    },
                  ),
                  const Divider(height: 1),
                  _buildPuritySelector(state, notifier, isLight),
                ]),
                const SizedBox(height: 24),
              ] else if (state.template.id == 'house' || state.template.id == 'car') ...[
                _buildFormSectionHeader('DOWN-PAYMENT TARGET BUILDER', isLight),
                _buildInputContainer(isLight, [
                  _buildTextField(
                    controller: _propertyCostController,
                    label: state.template.id == 'house' ? 'Estimated Property Value' : 'Estimated Vehicle Cost',
                    hint: 'e.g. ₹50,00,000',
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final valDouble = double.tryParse(val) ?? 0.0;
                      notifier.updatePropertyCost(valDouble);
                      _targetAmountController.text =
                          ((valDouble * state.downPaymentPercent) / 100).toStringAsFixed(0);
                    },
                  ),
                  const Divider(height: 1),
                  _buildDownPaymentPercentSlider(state, notifier, isLight),
                ]),
                const SizedBox(height: 24),
              ],

              // Target savings and deadlines
              _buildFormSectionHeader('TARGET & DEADLINE', isLight),
              _buildInputContainer(isLight, [
                if (state.template.id != 'gold') ...[
                  _buildTextField(
                    controller: _targetAmountController,
                    label: 'Target Savings Goal (₹)',
                    hint: 'e.g. ₹3,00,000',
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final valDouble = double.tryParse(val) ?? 0.0;
                      notifier.updateTargetAmount(valDouble);
                    },
                  ),
                  const Divider(height: 1),
                ],
                _buildTextField(
                  controller: _currentSavingsController,
                  label: 'Current Already Saved (₹)',
                  hint: 'e.g. ₹10,000',
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final valDouble = double.tryParse(val) ?? 0.0;
                    notifier.updateCurrentSavings(valDouble);
                  },
                ),
                const Divider(height: 1),
                _buildDatePickerTile(state, notifier, isLight),
              ]),
              const SizedBox(height: 24),

              // Priority Selector
              _buildFormSectionHeader('STRATEGY PRIORITY', isLight),
              _buildInputContainer(isLight, [
                _buildPrioritySelector(state, notifier, isLight),
              ]),
              const SizedBox(height: 40),

              PrimaryButton(
                text: 'CREATE GOAL PLAN',
                isLoading: state.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(GoalTemplateState state, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isLight ? AppColors.border : AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Text(state.template.icon, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.template.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  state.template.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(GoalTemplateState state, double suggestedSavings, bool isLight) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    final targetStr = state.template.id == 'gold'
        ? '${state.targetGrams}g (${state.goldPurity}K)'
        : currencyFormat.format(state.targetAmount);

    final suggestedSavingsStr = suggestedSavings == 0
        ? '₹0/month'
        : '${currencyFormat.format(suggestedSavings)}/month';

    final timelineStr = DateFormat('MMMM yyyy').format(state.targetDate);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLight
              ? [AppColors.primary, const Color(0xFF1D4D3D)]
              : [AppColors.surfaceDark, AppColors.elevatedSurfaceDark],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'SMART RECOMMENDATIONS',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecommendationRow('RECOMMENDED TARGET', targetStr),
          const SizedBox(height: 8),
          _buildRecommendationRow('SUGGESTED SAVING', suggestedSavingsStr),
          const SizedBox(height: 8),
          _buildRecommendationRow('TARGET DATE', timelineStr),
        ],
      ),
    );
  }

  Widget _buildRecommendationRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(
          val,
          style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildFormSectionHeader(String title, bool isLight) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.bold,
          color: isLight ? AppColors.primary : AppColors.textSecondaryDark,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildInputContainer(bool isLight, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isLight ? AppColors.border : AppColors.borderDark),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerTile(GoalTemplateState state, GoalTemplateViewModel notifier, bool isLight) {
    final formattedDate = DateFormat('MMMM dd, yyyy').format(state.targetDate);
    return ListTile(
      title: const Text('Deadline Target Date', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),
      trailing: const Icon(Icons.calendar_month, size: 20),
      onTap: () async {
        final chosen = await showDatePicker(
          context: context,
          initialDate: state.targetDate.isAfter(DateTime.now()) ? state.targetDate : DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (chosen != null) {
          notifier.updateTargetDate(chosen);
        }
      },
    );
  }

  Widget _buildPrioritySelector(GoalTemplateState state, GoalTemplateViewModel notifier, bool isLight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Strategy Allocation Priority',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: GoalPriority.values.map((p) {
              final selected = state.priority == p;
              return GestureDetector(
                onTap: () => notifier.updatePriority(p),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : (isLight ? AppColors.background : AppColors.backgroundDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : (isLight ? AppColors.border : AppColors.borderDark),
                    ),
                  ),
                  child: Text(
                    p.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: selected ? Colors.white : (isLight ? AppColors.textPrimary : Colors.white70),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBufferSelector(GoalTemplateState state, GoalTemplateViewModel notifier, bool isLight) {
    final buffers = [3, 6, 9, 12];
    final isCustom = state.isCustomSafetyMonths;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Safety Buffer (Months)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...buffers.map((m) {
                final selected = !isCustom && state.safetyMonths == m;
                return GestureDetector(
                  onTap: () {
                    notifier.toggleCustomSafetyMonths(false);
                    notifier.updateSafetyMonths(m);
                    _targetAmountController.text =
                        (state.essentialExpenses * m).toStringAsFixed(0);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent : (isLight ? AppColors.background : AppColors.backgroundDark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? Colors.transparent : (isLight ? AppColors.border : AppColors.borderDark),
                      ),
                    ),
                    child: Text(
                      '$m Mo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: selected ? Colors.black : (isLight ? AppColors.textPrimary : Colors.white70),
                      ),
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: () {
                  notifier.toggleCustomSafetyMonths(true);
                  final months = int.tryParse(_customMonthsController.text) ?? 6;
                  notifier.updateSafetyMonths(months);
                  _targetAmountController.text =
                      (state.essentialExpenses * months).toStringAsFixed(0);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCustom ? AppColors.accent : (isLight ? AppColors.background : AppColors.backgroundDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCustom ? Colors.transparent : (isLight ? AppColors.border : AppColors.borderDark),
                    ),
                  ),
                  child: const Text(
                    'Custom',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          if (isCustom) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _customMonthsController,
              keyboardType: TextInputType.number,
              onChanged: (val) {
                final valInt = int.tryParse(val) ?? 0;
                notifier.updateSafetyMonths(valInt);
                _targetAmountController.text =
                    (state.essentialExpenses * valInt).toStringAsFixed(0);
              },
              decoration: const InputDecoration(
                labelText: 'Enter Custom Months Buffer',
                labelStyle: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                border: UnderlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Your emergency fund can help cover essential expenses during unexpected situations. This safety recommendation serves as a planning reference guidelines and is not guaranteed financial advice.',
            style: TextStyle(
              fontSize: 11,
              color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPuritySelector(GoalTemplateState state, GoalTemplateViewModel notifier, bool isLight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Gold Purity Quality',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [22, 24].map((p) {
              final selected = state.goldPurity == p;
              return Expanded(
                child: GestureDetector(
                  onTap: () => notifier.updateGoldPurity(p),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent : (isLight ? AppColors.background : AppColors.backgroundDark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? Colors.transparent : (isLight ? AppColors.border : AppColors.borderDark),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${p}K Gold',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: selected ? Colors.black : (isLight ? AppColors.textPrimary : Colors.white70),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDownPaymentPercentSlider(GoalTemplateState state, GoalTemplateViewModel notifier, bool isLight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Down-Payment Target Percentage',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              Text(
                '${state.downPaymentPercent.toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: state.downPaymentPercent,
            min: 5,
            max: 100,
            divisions: 19,
            activeColor: AppColors.accent,
            onChanged: (val) {
              notifier.updateDownPaymentPercent(val);
              _targetAmountController.text =
                  ((state.propertyCost * val) / 100).toStringAsFixed(0);
            },
          ),
        ],
      ),
    );
  }
}
