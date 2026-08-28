import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_spacing.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';

class CoupleModeScreen extends ConsumerStatefulWidget {
  const CoupleModeScreen({super.key});

  @override
  ConsumerState<CoupleModeScreen> createState() => _CoupleModeScreenState();
}

class _CoupleModeScreenState extends ConsumerState<CoupleModeScreen> {
  final _emailController = TextEditingController();
  bool _inviteSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalsState = ref.watch(goalsViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final sharedGoals = goalsState.goals.where((g) => g.isShared).toList();

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Couple Shared Mode',
        onBackPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Linked Partner Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isLight ? AppColors.border : AppColors.borderDark,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('👩‍❤️‍👨', style: TextStyle(fontSize: 28)),
                  ),
                  AppSpacing.widthM,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Linked Partner: Priya',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Collaborating on ${sharedGoals.length} shared goal targets.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Inline Invite Panel
            Container(
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
                  Row(
                    children: [
                      const Text('✉️', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        'Link Another Partner',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Input partner\'s email below to link another dashboard and budget segments.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Partner email address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: _inviteSent ? 'INVITATION SENT' : 'SEND CONNECTION INVITE',
                    onPressed: _inviteSent
                        ? null
                        : () {
                            if (_emailController.text.contains('@')) {
                              setState(() {
                                _inviteSent = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Invitation sent to ${_emailController.text}!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              _emailController.clear();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid email address'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const MiSectionHeader(title: "Shared Savings Paths"),
            const SizedBox(height: 8),

            if (sharedGoals.isEmpty)
              const EmptyState(
                title: 'No Shared Goals Active',
                description: 'Invite your partner to connect and co-pilot plans together.',
              )
            else
              ...sharedGoals.map((g) {
                const youSavings = 250000.0;
                const partnerSavings = 200000.0;
                const totalSaved = youSavings + partnerSavings;
                final totalTarget = g.targetAmount;

                final youPct = youSavings / totalTarget;
                final partnerPct = partnerSavings / totalTarget;

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
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
                          Text(g.name, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                          GoalHealthBadge(health: g.health),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'YOUR DEPOSIT',
                                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: isLight ? AppColors.textSecondary : AppColors.textLightDark),
                              ),
                              const SizedBox(height: 4),
                              MoneyDisplay(
                                amount: youSavings,
                                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'PARTNER DEPOSIT',
                                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: isLight ? AppColors.textSecondary : AppColors.textLightDark),
                              ),
                              const SizedBox(height: 4),
                              MoneyDisplay(
                                amount: partnerSavings,
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isLight ? AppColors.primary : AppColors.accentDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _DualSegmentProgress(
                        youPct: youPct,
                        partnerPct: partnerPct,
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Combined Progress: ',
                              style: AppTextStyles.caption.copyWith(color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark),
                            ),
                            MoneyDisplay(
                              amount: totalSaved,
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isLight ? AppColors.primary : AppColors.accentDark,
                              ),
                            ),
                            Text(' of ', style: AppTextStyles.caption.copyWith(color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark)),
                            MoneyDisplay(
                              amount: totalTarget,
                              style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _DualSegmentProgress extends StatelessWidget {
  final double youPct;
  final double partnerPct;

  const _DualSegmentProgress({required this.youPct, required this.partnerPct});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double youWidth = (width * youPct).clamp(0.0, width);
        final double partnerWidth = (width * partnerPct).clamp(
          0.0,
          width - youWidth,
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 6,
            width: width,
            color: isLight ? AppColors.border : AppColors.borderDark,
            child: Row(
              children: [
                Container(width: youWidth, color: isLight ? AppColors.primary : AppColors.accentDark),
                Container(width: partnerWidth, color: AppColors.secondary),
              ],
            ),
          ),
        );
      },
    );
  }
}
