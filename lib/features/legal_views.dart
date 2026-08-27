import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot_app/app/theme/app_colors.dart';
import 'package:migoalpilot_app/app/theme/app_text_styles.dart';
import 'package:migoalpilot_app/core/widgets/shared_widgets.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tab = GoRouterState.of(context).uri.queryParameters['tab'];
    if (tab == 'terms') {
      _tabController.index = 0;
    } else if (tab == 'privacy') {
      _tabController.index = 1;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildTermSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Legal Documents',
        onBackPressed: () => context.pop(),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: isLight ? AppColors.primary : AppColors.accentDark,
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          );
        },
        child: Icon(Icons.arrow_upward, color: isLight ? Colors.white : AppColors.backgroundDark),
      ),
      body: Column(
        children: [
          // Segmented Switcher for Terms and Privacy
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isLight ? AppColors.surface : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isLight ? AppColors.border : AppColors.borderDark,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _tabController.animateTo(0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _tabController.index == 0
                              ? (isLight ? AppColors.primary : AppColors.accentDark)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _tabController.index == 0
                                  ? (isLight ? Colors.white : AppColors.backgroundDark)
                                  : (isLight ? AppColors.textSecondary : AppColors.textSecondaryDark),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _tabController.animateTo(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _tabController.index == 1
                              ? (isLight ? AppColors.primary : AppColors.accentDark)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _tabController.index == 1
                                  ? (isLight ? Colors.white : AppColors.backgroundDark)
                                  : (isLight ? AppColors.textSecondary : AppColors.textSecondaryDark),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content TabViews
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 0: Terms & Conditions
                SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terms & Conditions',
                        style: AppTextStyles.headlineLarge.copyWith(
                            fontWeight: FontWeight.w800, color: isLight ? AppColors.primary : Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Last Updated: August 2026',
                        style: AppTextStyles.caption.copyWith(
                            color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 24),
                      _buildTermSection(
                        '1. Introduction',
                        'Welcome to MiGoalPilot, a goal-planning and savings-tracking companion application. By registering an account and using our service, you enter into a binding agreement with us. You must be at least 18 years of age to register or use this application.',
                      ),
                      _buildTermSection(
                        '2. Description of the Service',
                        'MiGoalPilot provides personal financial goal-planning interfaces, contribution logs, gold spot price alerts, wedding planner tools, and AI-driven goal companion recommendations. These services are provided "as is" and features are subject to change over time.',
                      ),
                      _buildTermSection(
                        '3. User Account',
                        'You are responsible for maintaining the confidentiality of your login credentials and for all activities that occur under your account. You agree to provide accurate and updated information at all times. We reserve the right to suspend accounts violating these terms.',
                      ),
                      _buildTermSection(
                        '4. Goal and Savings Information',
                        'Any information logged in the application, including target savings and gold purchases, is for your personal tracking. Users are solely responsible for verifying the accuracy of all target dates, amounts, and progress percentages. MiGoalPilot does not promise or guarantee that logging saving milestones will ensure the acquisition of physical assets.',
                      ),
                      _buildTermSection(
                        '5. Gold Price Information',
                        'Gold pricing indices displayed in the application are retrieved from third-party market data APIs. Prices change rapidly, may be delayed, and should be treated as estimates. Real transaction prices depend on your local dealer, taxes, making charges, and direct market rates. Do not use this application as a commercial gold exchange trading platform.',
                      ),
                      _buildTermSection(
                        '6. AI-Generated Information',
                        'Any suggestions, plans, or analysis generated by GoalPilot AI are purely informational. AI models can produce incorrect outputs. The companion should not be treated as a licensed financial advisory service. Always review AI output independently.',
                      ),
                      _buildTermSection(
                        '7. Financial Disclaimer',
                        'MiGoalPilot is a financial tracking and planning calculator. It is NOT a bank, a brokerage, an investment adviser, or a custodian. We do not hold user funds, deposits, or execute actual financial transactions.',
                      ),
                      _buildTermSection(
                        '8. Notifications and Reminders',
                        'Goal updates, savings reminders, and AI notifications rely on device notification services, OS permissions, and network availability. We cannot guarantee timely delivery of push notifications.',
                      ),
                      _buildTermSection(
                        '9. Acceptable Use',
                        'You agree not to misuse the service, reverse engineer the application, inject malicious code, or attempt unauthorized access to other users\' goal parameters.',
                      ),
                      _buildTermSection(
                        '10. Intellectual Property',
                        'The application interface, logo, design system, source code, and AI model weights are the exclusive intellectual property of MiGoalPilot. You retain ownership of your personal goal records.',
                      ),
                      _buildTermSection(
                        '11. Third-Party Services',
                        'Our services integrate third-party APIs for authentication, gold rates, and AI model execution. Usage is subject to the terms and privacy rules of those respective service providers.',
                      ),
                      _buildTermSection(
                        '12. Service Availability',
                        'While we strive for maximum uptime, maintenance, cloud server interruptions, and updates may cause brief outages. We are not liable for any temporary loss of service.',
                      ),
                      _buildTermSection(
                        '13. Disclaimers',
                        'MiGoalPilot makes no warranties of any kind regarding goal achievement or gold asset preservation. The app is provided on an "as available" basis without warranties of merchantability.',
                      ),
                      _buildTermSection(
                        '14. Limitation of Liability',
                        'Subject to applicable law, MiGoalPilot shall not be liable for any direct or indirect financial losses, investment failures, or data loss arising out of your reliance on application features.',
                      ),
                      _buildTermSection(
                        '15. Indemnification',
                        'You agree to indemnify and hold harmless MiGoalPilot and its developers from any claims, damages, or legal expenses arising from your misuse of the application or violation of these terms.',
                      ),
                      _buildTermSection(
                        '16. Termination',
                        'You can terminate your account at any time by contacting support. We reserve the right to restrict access to the application in cases of fraud or terms violation.',
                      ),
                      _buildTermSection(
                        '17. Changes to Terms',
                        'We may modify these terms occasionally. We will notify you of any changes by updating the "Last Updated" date at the top of this document.',
                      ),
                      _buildTermSection(
                        '18. Governing Law',
                        '[Governing jurisdiction to be specified by the app owner prior to final publication]',
                      ),
                      _buildTermSection(
                        '19. Contact Support',
                        'For help with terms or account inquiries, contact support at: support@example.com (app owner placeholder).',
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),

                // Tab 1: Privacy Policy
                SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy Policy',
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isLight ? AppColors.primary : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Last Updated: August 2026',
                        style: AppTextStyles.caption.copyWith(
                            color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 24),
                      _buildPrivacySection('1. Overview', 'We committed to protecting your privacy. This policy describes how we collect, store, and process your target goal figures and preferences.'),
                      _buildPrivacySection('2. Information We Collect', '• Account info: Full Name, Email address, and phone number.\n• Goal info: Targets, milestones, target dates, and monthly savings contributions.\n• Preferences: Theme Mode, selected currency index, and app lock pin parameters.'),
                      _buildPrivacySection('3. AI Analysis Data Flow', 'When using GoalPilot AI assistant, goal names, current savings, and inputs may be processed through external language model endpoints. To secure your privacy, no personal identifying info (like your full name, email or phone) is shared with the AI models. All suggestions are computed on scrubbed parameters.'),
                      _buildPrivacySection('4. Gold Rates API', 'Gold prices are fetched from third-party APIs. No user location or identification data is sent during these rate queries.'),
                      _buildPrivacySection('5. Data Storage & Security', 'Your data is securely saved in the local database and synced to secure cloud endpoints. Your theme and security configurations are preserved locally using secure device parameters.'),
                      _buildPrivacySection('6. Account Deletion', 'You can delete your account and associated goal entries. To completely wipe your data immediately, go to Profile -> Delete Account or contact our team.'),
                      _buildPrivacySection('7. Questions & Contact', 'For privacy requests, reach out to: support@example.com (app owner placeholder).'),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
