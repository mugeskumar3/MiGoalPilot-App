import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot_app/app/theme/app_colors.dart';
import 'package:migoalpilot_app/app/theme/app_spacing.dart';
import 'package:migoalpilot_app/app/theme/app_text_styles.dart';
import 'package:migoalpilot_app/core/widgets/shared_widgets.dart';
import 'package:migoalpilot_app/core/viewmodels/viewmodels.dart';
import 'package:migoalpilot_app/core/models/models.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final txs = [
      SavingsTransaction(
        id: 'tx1',
        goalId: 'g_marriage',
        amount: 10000,
        date: DateTime.now(),
        note: 'Saved for Wedding Ceremony',
      ),
      SavingsTransaction(
        id: 'tx2',
        goalId: 'g_gold',
        amount: 5000,
        date: DateTime.now().subtract(const Duration(days: 1)),
        note: 'Bought 0.4g gold (Jewellery)',
      ),
      SavingsTransaction(
        id: 'tx3',
        goalId: 'g_house',
        amount: 15000,
        date: DateTime.now().subtract(const Duration(days: 5)),
        note: 'Downpayment reservation deposit',
      ),
      SavingsTransaction(
        id: 'tx4',
        goalId: 'g_travel',
        amount: 3000,
        date: DateTime.now().subtract(const Duration(days: 10)),
        note: 'Europe flight price re-track deposit',
      ),
    ];

    List<SavingsTransaction> filtered = txs;
    if (_filter == 'Savings') {
      filtered = txs.where((t) => t.goalId != 'g_gold').toList();
    } else if (_filter == 'Gold') {
      filtered = txs.where((t) => t.goalId == 'g_gold').toList();
    }

    final totalSavedThisMonth = filtered.fold<double>(
      0.0,
      (acc, t) => acc + t.amount,
    );
    const targetThisMonth = 35000.0;
    final percent = (totalSavedThisMonth / targetThisMonth).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      appBar: const MiAppBar(
        title: 'Activity Ledger',
        subtitle: 'Contributions history index',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MONTHLY SAVINGS TARGET',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        MoneyDisplay(
                          amount: totalSavedThisMonth,
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
                          amount: targetThisMonth,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${(percent * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isLight
                            ? AppColors.primary
                            : AppColors.accentDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                AppSpacing.heightS,
                GoalProgress(
                  progress: percent,
                  color: isLight ? AppColors.primary : AppColors.accentDark,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: ['All', 'Savings', 'Gold'].map((t) {
                final isSelected = _filter == t;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    backgroundColor: isLight
                        ? Colors.white
                        : AppColors.surfaceDark,
                    selectedColor: isLight
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : AppColors.surfaceDark,
                    checkmarkColor: isLight
                        ? AppColors.primary
                        : AppColors.accentDark,
                    side: BorderSide(
                      color: isSelected
                          ? (isLight ? AppColors.primary : AppColors.accentDark)
                          : (isLight ? AppColors.border : AppColors.borderDark),
                      width: 1.2,
                    ),
                    label: Text(
                      t,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isSelected
                            ? (isLight
                                  ? AppColors.primary
                                  : AppColors.accentDark)
                            : (isLight
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryDark),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _filter = t);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final t = filtered[index];
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isLight
                              ? AppColors.background
                              : AppColors.backgroundDark,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          t.goalId == 'g_gold'
                              ? Icons.toll_outlined
                              : Icons.account_balance_wallet_outlined,
                          color: isLight
                              ? AppColors.primary
                              : AppColors.accentDark,
                          size: 18,
                        ),
                      ),
                      AppSpacing.widthM,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.note ?? 'Contribution',
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
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      appBar: MiAppBar(
        title: 'Notifications',
        subtitle: 'System updates and insights',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(notificationViewModelProvider.notifier).clearAll(),
            child: const Text(
              'Clear All',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: state.items.isEmpty
          ? const EmptyState(
              title: 'All Caught Up! 🎉',
              description: 'You have no new notifications right now.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = state.items[index];
                final itemBgColor = item.isRead
                    ? (isLight ? AppColors.surface : AppColors.surfaceDark)
                    : (isLight
                          ? AppColors.secondary.withValues(alpha: 0.05)
                          : AppColors.surfaceDark.withValues(alpha: 0.8));
                return Material(
                  color: itemBgColor,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: !item.isRead && isLight
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : (isLight
                                  ? AppColors.border
                                  : AppColors.borderDark),
                        width: !item.isRead ? 1.5 : 1.2,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      onTap: () {
                        ref
                            .read(notificationViewModelProvider.notifier)
                            .markAsRead(item.id);
                        if (item.deepLink != null) {
                          context.push(item.deepLink!);
                        }
                      },
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: !item.isRead
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isLight
                                    ? AppColors.primary
                                    : AppColors.accentDark,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            item.message,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isLight
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimaryDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat(
                              'hh:mm a, dd MMM',
                            ).format(item.timestamp),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final userName = user?.name ?? 'Mugesh R';
    final userEmail = user?.email ?? 'mugesh@example.com';
    const joinDate = 'Member since Aug 2024';

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Premium Profile Header ───
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isLight
                      ? [
                          AppColors.primary,
                          const Color(0xFF1A4435),
                          const Color(0xFF1E5040),
                        ]
                      : [
                          const Color(0xFF101E17),
                          const Color(0xFF0D1A13),
                          AppColors.backgroundDark,
                        ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    children: [
                      // Top bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Profile',
                            style: AppTextStyles.headlineLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Avatar Row
                      Row(
                        children: [
                          _buildAvatar(userName, isLight),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        userName,
                                        style: AppTextStyles.titleLarge.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          fontSize: 19,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  userEmail,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 12.5,
                                    color: Colors.white.withValues(alpha: 0.55),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  joinDate,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.accent.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Quick Stat Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.savings_outlined,
                              value: '₹12.4K',
                              label: 'Total Saved',
                              isLight: isLight,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.flag_outlined,
                              value: '4',
                              label: 'Active Goals',
                              isLight: isLight,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.local_fire_department_outlined,
                              value: '18',
                              label: 'Day Streak',
                              isLight: isLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Menu Groups ───
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _profileGroup(context, 'Account', [
                  _profileTile(context, Icons.person_outline_rounded, 'Personal Information', 'Name, email, phone & country', '/profile-detail'),
                  _tileDivider(isLight),
                  _profileTile(context, Icons.lock_outline_rounded, 'Security & App Lock', 'Pin lock, balance visibility', '/security'),
                ]),
                const SizedBox(height: 18),

                _profileGroup(context, 'Preferences', [
                  _profileTile(context, Icons.palette_outlined, 'Theme Configuration', 'Light mode, dark mode, system', '/theme-settings'),
                  _tileDivider(isLight),
                  _profileTile(context, Icons.notifications_none_rounded, 'Notification Preferences', 'Reminders, milestones, deadlines', '/notification-settings'),
                  _tileDivider(isLight),
                  _profileTile(context, Icons.people_outline_rounded, 'Couple Shared Mode', 'Linked partner goals & tracking', '/couple-mode'),
                ]),
                const SizedBox(height: 18),

                _profileGroup(context, 'Goals & AI', [
                  _profileTile(context, Icons.compass_calibration_outlined, 'Goal Insights', 'Progress analytics & projections', '/goals'),
                  _tileDivider(isLight),
                  _profileTile(context, Icons.assistant_outlined, 'GoalPilot AI Assistant', 'AI savings companion settings', '/ai'),
                ]),
                const SizedBox(height: 18),

                _profileGroup(context, 'Legal & Support', [
                  _profileTile(context, Icons.gavel_outlined, 'Terms & Privacy Policy', 'Legal documents & data policy', '/privacy?tab=terms'),
                  _tileDivider(isLight),
                  _profileTile(context, Icons.support_agent_rounded, 'Help & Projections Center', 'FAQs, guides & contact support', '/help'),
                  _tileDivider(isLight),
                  _profileTile(context, Icons.info_outline_rounded, 'About MiGoalPilot', 'Version info & credits', '/about'),
                ]),
                const SizedBox(height: 22),

                // ─── Account Actions ───
                _profileGroup(context, 'Account Actions', [
                  _buildActionTile(
                    context,
                    ref,
                    Icons.logout_rounded,
                    'Sign Out',
                    'Log out of your account',
                    isDestructive: false,
                    onTap: () {
                      ref.read(authViewModelProvider.notifier).logout();
                      context.go('/login');
                    },
                  ),
                  _tileDivider(isLight),
                  _buildActionTile(
                    context,
                    ref,
                    Icons.delete_forever_outlined,
                    'Delete Account',
                    'Permanently remove all data',
                    isDestructive: true,
                    onTap: () => _showDeleteDialog(context, isLight),
                  ),
                ]),

                const SizedBox(height: 32),

                // Version footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        'MiGoalPilot v1.0.0',
                        style: AppTextStyles.caption.copyWith(
                          color: isLight ? AppColors.textLight : AppColors.textLightDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Powered by Jeev Labs',
                        style: AppTextStyles.caption.copyWith(
                          color: isLight
                              ? AppColors.textLight.withValues(alpha: 0.6)
                              : AppColors.textLightDark.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildAvatar(String userName, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent,
            Color(0xFFB8963A),
            AppColors.accent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: isLight ? Colors.white : AppColors.surfaceDark,
          shape: BoxShape.circle,
          border: Border.all(
            color: isLight ? AppColors.primary : AppColors.backgroundDark,
            width: 2.5,
          ),
        ),
        child: Center(
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'M',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isLight ? AppColors.primary : AppColors.accentDark,
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required bool isLight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.accent.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.45),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }



  // ─── Group / Tile Helpers ───

  Widget _tileDivider(bool isLight) {
    return Padding(
      padding: const EdgeInsets.only(left: 76, right: 18),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: isLight ? AppColors.border : AppColors.borderDark,
      ),
    );
  }

  Widget _profileGroup(BuildContext context, String title, List<Widget> tiles) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: isLight ? AppColors.secondary : AppColors.textLightDark,
              letterSpacing: 1.2,
              fontSize: 10.5,
            ),
          ),
        ),
        Material(
          color: isLight ? AppColors.surface : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLight ? AppColors.border : AppColors.borderDark,
                width: 0.8,
              ),
            ),
            child: Column(children: tiles),
          ),
        ),
      ],
    );
  }

  Widget _profileTile(
    BuildContext context,
    IconData icon,
    String label,
    String subtitle,
    String route,
  ) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isLight
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.accentDark.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isLight ? AppColors.primary : AppColors.accentDark,
          size: 19,
        ),
      ),
      title: Text(
        label,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
          fontSize: 13.5,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(
          color: isLight ? AppColors.textLight : AppColors.textLightDark,
          fontSize: 10.5,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 13,
        color: isLight ? AppColors.textLight : AppColors.textLightDark,
      ),
      onTap: () => context.push(route),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    String label,
    String subtitle, {
    required bool isDestructive,
    required VoidCallback onTap,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final color = isDestructive
        ? AppColors.error
        : (isLight ? AppColors.textSecondary : AppColors.textSecondaryDark);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.07)
              : (isLight ? AppColors.softSurface : AppColors.elevatedSurfaceDark),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 19),
      ),
      title: Text(
        label,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: isDestructive
              ? AppColors.error
              : (isLight ? AppColors.textPrimary : AppColors.textPrimaryDark),
          fontSize: 13.5,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(
          color: isLight ? AppColors.textLight : AppColors.textLightDark,
          fontSize: 10.5,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 13,
        color: isDestructive
            ? AppColors.error.withValues(alpha: 0.4)
            : (isLight ? AppColors.textLight : AppColors.textLightDark),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteDialog(BuildContext context, bool isLight) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isLight ? AppColors.surface : AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Account?',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: isLight ? AppColors.primary : Colors.white,
          ),
        ),
        content: const Text(
          'This operation is permanent. To request deletion of all your goals, linked gold targets, and shared couple records, tap Confirm.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion request submitted. Support will contact you shortly.'),
                ),
              );
            },
            child: const Text(
              'Confirm Deletion',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Security & Safety',
        onBackPressed: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                'App Lock Pin',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLight ? AppColors.primary : Colors.white,
                ),
              ),
              subtitle: Text(
                'Requires verification on startup.',
                style: AppTextStyles.caption.copyWith(
                  color: isLight
                      ? AppColors.textSecondary
                      : AppColors.textLightDark,
                ),
              ),
              value: state.appLockEnabled,
              onChanged: (val) => ref
                  .read(profileViewModelProvider.notifier)
                  .toggleAppLock(val),
              activeTrackColor: isLight
                  ? AppColors.primary
                  : AppColors.accentDark,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: Text(
                'Hide Dashboard Balance',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLight ? AppColors.primary : Colors.white,
                ),
              ),
              subtitle: Text(
                'Replaces saved portfolio figures with asterisks.',
                style: AppTextStyles.caption.copyWith(
                  color: isLight
                      ? AppColors.textSecondary
                      : AppColors.textLightDark,
                ),
              ),
              value: state.hideBalance,
              onChanged: (val) => ref
                  .read(profileViewModelProvider.notifier)
                  .toggleHideBalance(val),
              activeTrackColor: isLight
                  ? AppColors.primary
                  : AppColors.accentDark,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _reminders = true;
  bool _milestones = true;
  bool _deadlines = true;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Notification Prefs',
        onBackPressed: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                'Savings Reminders',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLight ? AppColors.primary : Colors.white,
                ),
              ),
              subtitle: Text(
                'Weekly notifications when planning targets are due.',
                style: AppTextStyles.caption.copyWith(
                  color: isLight
                      ? AppColors.textSecondary
                      : AppColors.textLightDark,
                ),
              ),
              value: _reminders,
              onChanged: (val) => setState(() => _reminders = val),
              activeTrackColor: isLight
                  ? AppColors.primary
                  : AppColors.accentDark,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: Text(
                'Goal Milestones',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLight ? AppColors.primary : Colors.white,
                ),
              ),
              subtitle: Text(
                'Alert me when goals cross 25%, 50% benchmarks.',
                style: AppTextStyles.caption.copyWith(
                  color: isLight
                      ? AppColors.textSecondary
                      : AppColors.textLightDark,
                ),
              ),
              value: _milestones,
              onChanged: (val) => setState(() => _milestones = val),
              activeTrackColor: isLight
                  ? AppColors.primary
                  : AppColors.accentDark,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: Text(
                'Deadline Warnings',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLight ? AppColors.primary : Colors.white,
                ),
              ),
              subtitle: Text(
                'Receive planning indicators 30 days before deadline.',
                style: AppTextStyles.caption.copyWith(
                  color: isLight
                      ? AppColors.textSecondary
                      : AppColors.textLightDark,
                ),
              ),
              value: _deadlines,
              onChanged: (val) => setState(() => _deadlines = val),
              activeTrackColor: isLight
                  ? AppColors.primary
                  : AppColors.accentDark,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Theme Settings',
        onBackPressed: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Application Mode',
              style: AppTextStyles.displayMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: isLight ? AppColors.primary : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select standard light styling or high contrast dark midnight modes.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isLight
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: SegmentedButton<ThemeMode>(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: isLight
                      ? AppColors.primary
                      : AppColors.accentDark,
                  selectedForegroundColor: isLight
                      ? Colors.white
                      : AppColors.backgroundDark,
                ),
                segments: const [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.settings_suggest_outlined),
                  ),
                ],
                selected: {state.themeMode},
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  ref
                      .read(profileViewModelProvider.notifier)
                      .toggleTheme(newSelection.first);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

