import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot_app/app/theme/app_colors.dart';
import 'package:migoalpilot_app/app/theme/app_spacing.dart';
import 'package:migoalpilot_app/app/theme/app_text_styles.dart';
import 'package:migoalpilot_app/core/widgets/shared_widgets.dart';
import 'package:migoalpilot_app/core/viewmodels/viewmodels.dart';

class CoupleModeScreen extends ConsumerWidget {
  const CoupleModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsState = ref.watch(goalsViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    final sharedGoals = goalsState.goals.where((g) => g.isShared).toList();

    return Scaffold(
      appBar: MiBackAppBar(
        title: 'Couple Shared Mode',
        onBackPressed: () => context.pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: () => context.push('/invite-partner'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isLight
                    ? AppColors.secondary.withValues(alpha: 0.04)
                    : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLight
                      ? AppColors.secondary.withValues(alpha: 0.15)
                      : AppColors.borderDark,
                ),
              ),
              child: Row(
                children: [
                  const Text('👩‍❤️‍👨', style: TextStyle(fontSize: 36)),
                  AppSpacing.widthM,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Linked Partner: PRIYA',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSpacing.heightXXS,
                        Text(
                          'Collaborating on ${sharedGoals.length} shared goal targets.',
                          style: AppTextStyles.caption.copyWith(
                            color: isLight
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'SHARED SAVINGS PATHS',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            AppSpacing.heightS,

            if (sharedGoals.isEmpty)
              const EmptyState(
                title: 'No shared goals active',
                description:
                    'Invite your partner to connect and co-pilot plans together.',
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isLight ? AppColors.border : AppColors.borderDark,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(g.name, style: AppTextStyles.titleLarge),
                          GoalHealthBadge(health: g.health),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'YOUR DEPOSIT',
                                style: AppTextStyles.caption,
                              ),
                              MoneyDisplay(
                                amount: youSavings,
                                style: AppTextStyles.titleMedium,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'PARTNER DEPOSIT',
                                style: AppTextStyles.caption,
                              ),
                              MoneyDisplay(
                                amount: partnerSavings,
                                style: AppTextStyles.titleMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _DualSegmentProgress(
                        youPct: youPct,
                        partnerPct: partnerPct,
                      ),
                      const SizedBox(height: 12),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Combined: ',
                              style: AppTextStyles.caption,
                            ),
                            MoneyDisplay(
                              amount: totalSaved,
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(' of ', style: AppTextStyles.caption),
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
                Container(width: youWidth, color: AppColors.primary),
                Container(width: partnerWidth, color: AppColors.secondary),
              ],
            ),
          ),
        );
      },
    );
  }
}

class InvitePartnerScreen extends StatefulWidget {
  const InvitePartnerScreen({super.key});

  @override
  State<InvitePartnerScreen> createState() => _InvitePartnerScreenState();
}

class _InvitePartnerScreenState extends State<InvitePartnerScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      appBar: MiBackAppBar(
        title: 'Invite Partner',
        onBackPressed: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text('✉️', style: TextStyle(fontSize: 56))),
            AppSpacing.heightM,
            const Text('Connect Accounts', style: AppTextStyles.displayMedium),
            AppSpacing.heightS,
            Text(
              'Input your partner\'s email below. A request link will link your dashboard and budget segments.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isLight
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 32),
            AppTextField(
              label: 'Partner email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'SEND CONNECTION INVITE',
              onPressed: () {
                if (_emailController.text.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invitation sent successfully!'),
                    ),
                  );
                  context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
