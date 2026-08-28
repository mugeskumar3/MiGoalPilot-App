import 'package:flutter/material.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/features/analytics/presentation/screens/goal_analytics_views.dart';
import 'package:migoalpilot/features/monthly_snapshot/presentation/screens/monthly_snapshot_views.dart';
import 'package:migoalpilot/features/profile/presentation/screens/profile_views.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final activeColor = isLight ? AppColors.primary : AppColors.accentDark;

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Insights Cockpit',
              style: TextStyle(
                color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Financial snapshot, patterns & activity ledger',
              style: AppTextStyles.caption.copyWith(
                color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                fontSize: 11,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: activeColor,
                labelColor: activeColor,
                unselectedLabelColor: isLight
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryDark,
                labelStyle: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: AppTextStyles.bodyMedium,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: 'Analytics'),
                  Tab(text: 'Monthly Snapshot'),
                  Tab(text: 'Activity Ledger'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GoalAnalyticsScreen(isEmbedded: true),
          MonthlySnapshotScreen(isEmbedded: true),
          ActivityScreen(isEmbedded: true),
        ],
      ),
    );
  }
}
