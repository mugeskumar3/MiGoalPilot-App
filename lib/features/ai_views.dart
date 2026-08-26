import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';
import '../core/widgets/shared_widgets.dart';
import '../core/viewmodels/viewmodels.dart';
import '../core/models/models.dart';
import '../shared/enums/enums.dart';

// --- 25. AI ASSISTANT CHAT SCREEN ---
class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      ref.read(aiViewModelProvider.notifier).sendMessage(text);
      _messageController.clear();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(title: const Text('GoalPilot AI')),
      body: Column(
        children: [
          // Subheader banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: isLight
                  ? AppColors.secondary.withValues(alpha: 0.04)
                  : AppColors.surfaceDark,
              border: Border(
                bottom: BorderSide(
                  color: isLight ? AppColors.border : AppColors.borderDark,
                ),
              ),
            ),
            child: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 16)),
                AppSpacing.widthS,
                Expanded(
                  child: Text(
                    'GoalPilot co-pilot. Simulate budgets and ask planning advice.',
                    style: AppTextStyles.caption.copyWith(
                      color: isLight
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Message log / suggestions
          Expanded(
            child: state.messages.isEmpty
                ? _buildQuickSuggestions()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      return _buildMessageRow(msg, context);
                    },
                  ),
          ),

          if (state.isTyping)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.secondary,
                      ),
                    ),
                    AppSpacing.widthS,
                    Text(
                      'GoalPilot is drafting...',
                      style: AppTextStyles.caption.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Input bar
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : AppColors.surfaceDark,
              border: Border(
                top: BorderSide(
                  color: isLight ? AppColors.border : AppColors.borderDark,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Ask AI Planner...',
                    controller: _messageController,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: isLight ? AppColors.primary : AppColors.primaryDark,
                  ),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    final suggestions = [
      'Can I afford my goals?',
      'How much should I save?',
      'Optimize my wedding plan',
      'What if I shift my house deadline?',
    ];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✈️', style: TextStyle(fontSize: 48)),
          AppSpacing.heightM,
          const Text('Suggested Actions', style: AppTextStyles.titleLarge),
          AppSpacing.heightS,
          const Text(
            'Tap a prompt below to run co-pilot optimization simulations.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: suggestions.map((p) {
              return ActionChip(
                label: Text(p, style: const TextStyle(fontSize: 12)),
                onPressed: () {
                  ref.read(aiViewModelProvider.notifier).sendMessage(p);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageRow(ChatMessage msg, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isLight ? AppColors.primary : AppColors.surfaceDark,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
          child: Text(
            msg.text,
            style: TextStyle(
              color: isLight ? Colors.white : AppColors.textPrimaryDark,
            ),
          ),
        ),
      );
    } else {
      // AI Message with custom parsed structured block layouts (INSIGHT, PLAN, OPTIONS, ACTION)
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: _buildStructuredMessageBlocks(msg.text, context),
        ),
      );
    }
  }

  Widget _buildStructuredMessageBlocks(String text, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    // We will parse response into custom structured boxes
    // E.g. Check for keywords in the message
    bool hasInsight =
        text.contains('uses') ||
        text.contains('paces') ||
        text.contains('budget') ||
        text.contains('down');
    bool hasPlan =
        text.contains('Recommending:') ||
        text.contains('consider') ||
        text.contains('recommend');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isLight
                    ? AppColors.secondary.withValues(alpha: 0.1)
                    : Colors.black12,
                shape: BoxShape.circle,
              ),
              child: const Text('✨', style: TextStyle(fontSize: 10)),
            ),
            const SizedBox(width: 8),
            Text(
              'GOALPILOT ASSISTANT',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
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
              // Main text block
              Text(text, style: AppTextStyles.bodyLarge.copyWith(fontSize: 14)),
              if (hasInsight) ...[
                const SizedBox(height: 16),
                _blockCard(
                  context,
                  'INSIGHT',
                  'Simulated available limits: ₹45,000/month. Goal balance constraints mapped.',
                  Icons.analytics_outlined,
                  AppColors.info,
                ),
              ],
              if (hasPlan) ...[
                const SizedBox(height: 12),
                _blockCard(
                  context,
                  'PLAN ACTIONS',
                  'Extend lower tier targets by 4 months, or adjust weekly parameters.',
                  Icons.checklist_rtl_outlined,
                  AppColors.warning,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _blockCard(
    BuildContext context,
    String header,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  header,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 9. AI GOAL CREATION SCREEN (Draft intent parsing) ---
class AiGoalCreationScreen extends ConsumerStatefulWidget {
  const AiGoalCreationScreen({super.key});

  @override
  ConsumerState<AiGoalCreationScreen> createState() =>
      _AiGoalCreationScreenState();
}

class _AiGoalCreationScreenState extends ConsumerState<AiGoalCreationScreen> {
  final _inputController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _structuredIntent;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _analyze() async {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      setState(() => _isLoading = true);
      final intent = await ref
          .read(aiViewModelProvider.notifier)
          .parseGoalCreationQuery(text);
      setState(() {
        _structuredIntent = intent;
        _isLoading = false;
      });
    }
  }

  void _confirm() {
    if (_structuredIntent != null) {
      final goal = Goal(
        id: 'g_ai_${DateTime.now().millisecondsSinceEpoch}',
        name: _structuredIntent!['name'] as String,
        type: GoalType.values.firstWhere(
          (e) => e.name == _structuredIntent!['type'],
          orElse: () => GoalType.custom,
        ),
        targetAmount: (_structuredIntent!['targetAmount'] as num).toDouble(),
        currentSavings: 0,
        targetDate: DateTime.now().add(
          Duration(days: (_structuredIntent!['months'] as int) * 30),
        ),
        priority: GoalPriority.high,
        health: GoalHealth.onTrack,
      );

      ref.read(goalsViewModelProvider.notifier).addGoal(goal);
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(title: const Text('AI Goal Creation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Describe your dream plan',
              style: AppTextStyles.headlineLarge,
            ),
            AppSpacing.heightS,
            Text(
              'Input details naturally. Example: "I want to save for a car worth 8 lakh in two years."',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _inputController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe your destination goal target...',
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'ANALYZE PLAN INTENT',
              isLoading: _isLoading,
              onPressed: _analyze,
            ),

            if (_structuredIntent != null) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),
              Text(
                'UNDERSTOOD DRAFT TARGET',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLight ? AppColors.border : AppColors.borderDark,
                  ),
                ),
                child: Column(
                  children: [
                    _draftRow(
                      'Draft Goal Category',
                      _structuredIntent!['type'].toString().toUpperCase(),
                    ),
                    _draftRow('Goal Name Estimate', _structuredIntent!['name']),
                    _draftRow(
                      'Estimated Target Budget',
                      '₹${NumberFormat('#,##,###').format(_structuredIntent!['targetAmount'])}',
                    ),
                    _draftRow(
                      'Timeline Maturity',
                      '${_structuredIntent!['months']} Months',
                    ),
                    _draftRow(
                      'Target Monthly Savings',
                      '₹${NumberFormat('#,##,###').format(_structuredIntent!['monthlySavingsNeeded'])}/month',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'EDIT DRAFT',
                      onPressed: () => context.push('/create-goal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'CONFIRM PLAN',
                      onPressed: _confirm,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _draftRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
