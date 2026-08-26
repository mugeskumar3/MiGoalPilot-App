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
      appBar: const MiAppBar(
        title: 'Activity History',
        subtitle: 'Track your contributions and purchases',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MONTHLY SAVINGS TARGET (AUGUST 2026)',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
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
                          style: AppTextStyles.displayMedium,
                        ),
                        const SizedBox(width: 8),
                        const Text('saved of ', style: AppTextStyles.caption),
                        const MoneyDisplay(
                          amount: targetThisMonth,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    Text(
                      '${(percent * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isLight
                            ? AppColors.secondary
                            : AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                AppSpacing.heightS,
                GoalProgress(progress: percent, color: AppColors.secondary),
              ],
            ),
          ),
          const Divider(height: 1),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: ['All', 'Savings', 'Gold'].map((t) {
                final isSelected = _filter == t;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      t,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
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
              padding: const EdgeInsets.all(20),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final t = filtered[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isLight ? AppColors.border : AppColors.borderDark,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isLight
                              ? AppColors.background
                              : AppColors.backgroundDark,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          t.goalId == 'g_gold' ? Icons.stars : Icons.wallet,
                          color: isLight
                              ? AppColors.primary
                              : AppColors.primaryDark,
                          size: 16,
                        ),
                      ),
                      AppSpacing.widthM,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.note ?? 'Contribution',
                              style: AppTextStyles.titleMedium,
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
      appBar: AppBar(
        title: const Text('Notifications'),
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
              title: 'All caught up! 🎉',
              description: 'You have no new notifications right now.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = state.items[index];
                return Container(
                  decoration: BoxDecoration(
                    color: item.isRead
                        ? (isLight ? Colors.white : AppColors.surfaceDark)
                        : (isLight
                              ? AppColors.secondary.withValues(alpha: 0.03)
                              : AppColors.surfaceDark.withValues(alpha: 0.8)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: !item.isRead && isLight
                          ? AppColors.secondary.withValues(alpha: 0.15)
                          : (isLight ? AppColors.border : AppColors.borderDark),
                      width: !item.isRead ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
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
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: !item.isRead
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(item.message, style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('hh:mm a, dd MMM').format(item.timestamp),
                          style: AppTextStyles.caption,
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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final userName = user?.name ?? 'Mugesh';
    final userEmail = user?.email ?? 'mugesh@migoalpilot.com';

    return Scaffold(
      appBar: const MiAppBar(
        title: 'Profile',
        subtitle: 'Manage your settings and preferences',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: isLight
                          ? AppColors.primary.withValues(alpha: 0.05)
                          : AppColors.surfaceDark,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isLight
                            ? AppColors.border
                            : AppColors.borderDark,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'M',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isLight
                              ? AppColors.primary
                              : AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(userName, style: AppTextStyles.headlineLarge),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            _profileGroup(context, 'Account Settings', [
              _profileTile(
                context,
                Icons.lock_outline,
                'Security & App Lock',
                '/security',
              ),
              _profileTile(
                context,
                Icons.notifications_none,
                'Notifications Prefs',
                '/notification-settings',
              ),
              _profileTile(
                context,
                Icons.color_lens_outlined,
                'Theme Preference',
                '/theme-settings',
              ),
              _profileTile(
                context,
                Icons.people_outline,
                'Couple Shared Mode',
                '/couple-mode',
              ),
            ]),
            const SizedBox(height: 24),

            _profileGroup(context, 'Legal & Info', [
              _profileTile(
                context,
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                '/privacy',
              ),
              _profileTile(
                context,
                Icons.help_outline,
                'Help & Support Center',
                '/help',
              ),
              _profileTile(
                context,
                Icons.info_outline,
                'About MiGoalPilot',
                '/about',
              ),
            ]),
            const SizedBox(height: 36),

            SecondaryButton(
              text: 'Sign Out',
              onPressed: () {
                ref.read(authViewModelProvider.notifier).logout();
                context.go('/login');
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _profileGroup(BuildContext context, String title, List<Widget> tiles) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        AppSpacing.heightS,
        Container(
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLight ? AppColors.border : AppColors.borderDark,
            ),
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _profileTile(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(label, style: AppTextStyles.titleMedium),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12),
      onTap: () => context.push(route),
    );
  }
}

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileViewModelProvider);

    return Scaffold(
      appBar: MiBackAppBar(
        title: 'Security & Safety',
        onBackPressed: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text(
                'App Lock Pin',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Requires verification on startup.',
                style: AppTextStyles.caption,
              ),
              value: state.appLockEnabled,
              onChanged: (val) => ref
                  .read(profileViewModelProvider.notifier)
                  .toggleAppLock(val),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text(
                'Hide Dashboard Balance',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Replaces saved portfolio figures with asterisks.',
                style: AppTextStyles.caption,
              ),
              value: state.hideBalance,
              onChanged: (val) => ref
                  .read(profileViewModelProvider.notifier)
                  .toggleHideBalance(val),
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
    return Scaffold(
      appBar: MiBackAppBar(
        title: 'Notification Preferences',
        onBackPressed: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text(
                'Savings Reminders',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Weekly notifications when planning targets are due.',
                style: AppTextStyles.caption,
              ),
              value: _reminders,
              onChanged: (val) => setState(() => _reminders = val),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text(
                'Goal Milestones',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Alert me when goals cross 25%, 50% benchmarks.',
                style: AppTextStyles.caption,
              ),
              value: _milestones,
              onChanged: (val) => setState(() => _milestones = val),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text(
                'Deadline warnings',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Receive planning indicators 30 days before deadline.',
                style: AppTextStyles.caption,
              ),
              value: _deadlines,
              onChanged: (val) => setState(() => _deadlines = val),
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

    return Scaffold(
      appBar: MiBackAppBar(
        title: 'Theme Settings',
        onBackPressed: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Application Mode',
              style: AppTextStyles.headlineLarge,
            ),
            AppSpacing.heightS,
            Text(
              'Select standard light styling or high contrast dark midnight modes.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: SegmentedButton<ThemeMode>(
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

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MiBackAppBar(
        title: 'Privacy Policy',
        onBackPressed: () => context.pop(),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Privacy Commitment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'MiGoalPilot is built to help you track goals securely. We store your tokens locally using Flutter Secure Storage. Your personal financial information is never shared with third parties. All AI analysis occurs via secure endpoints which scrub private financial metadata before matching.',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
