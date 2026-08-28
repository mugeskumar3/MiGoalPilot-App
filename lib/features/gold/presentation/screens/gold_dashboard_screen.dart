import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';
import 'package:migoalpilot/shared/enums/enums.dart';
import 'package:migoalpilot/features/gold/presentation/widgets/gold_price_header_widget.dart';
import 'package:migoalpilot/features/gold/presentation/widgets/gold_price_chart_widget.dart';
import 'package:migoalpilot/features/gold/presentation/widgets/gold_linked_goals_widget.dart';
import 'package:migoalpilot/features/gold/presentation/screens/gold_alert_settings_screen.dart';

class GoldDashboardScreen extends ConsumerStatefulWidget {
  const GoldDashboardScreen({super.key});

  @override
  ConsumerState<GoldDashboardScreen> createState() =>
      _GoldDashboardScreenState();
}

class _GoldDashboardScreenState extends ConsumerState<GoldDashboardScreen> {
  String _range = '30D';

  void _showAlertBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        return Container(
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.surfaceDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: const GoldAlertBottomSheetContent(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goldViewModelProvider);
    final goalsState = ref.watch(goalsViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    final goldGoals = goalsState.goals
        .where((g) => g.type == GoalType.gold)
        .toList();

    return Scaffold(
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      appBar: MiAppBar(
        title: 'Gold Marketplace',
        subtitle: 'Live price tracker & linked targets',
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_active_outlined,
              color: isLight ? AppColors.primary : AppColors.accentDark,
              size: 22,
            ),
            onPressed: () => _showAlertBottomSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(goldViewModelProvider.notifier).loadGoldData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.isLoading && state.livePrice == null)
                const LoadingState()
              else if (state.livePrice != null) ...[
                GoldPriceHeaderWidget(livePrice: state.livePrice!),

                GoldPriceChartWidget(
                  history: state.history,
                  selectedRange: _range,
                  onRangeChanged: (val) {
                    setState(() => _range = val);
                    ref
                        .read(goldViewModelProvider.notifier)
                        .changeHistoryRange(val);
                  },
                ),
                const SizedBox(height: 32),

                GoldLinkedGoalsWidget(goldGoals: goldGoals),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
