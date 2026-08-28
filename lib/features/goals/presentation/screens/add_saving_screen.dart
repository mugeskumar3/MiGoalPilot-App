import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_spacing.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';

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
