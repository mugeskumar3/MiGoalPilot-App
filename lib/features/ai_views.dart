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
import 'package:migoalpilot_app/shared/enums/enums.dart';

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
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiAppBar(
        title: 'GoalPilot AI',
        subtitle: 'Personal savings & deadline co-pilot',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty
                ? _buildQuickSuggestions()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      return _buildMessageRow(msg, context);
                    },
                  ),
          ),

          if (state.isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.secondary,
                      ),
                    ),
                    AppSpacing.widthS,
                    Text(
                      'GoalPilot AI is writing...',
                      style: AppTextStyles.caption.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 14,
              bottom: MediaQuery.of(context).padding.bottom + 14,
            ),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : AppColors.surfaceDark,
              border: Border(
                top: BorderSide(
                  color: isLight ? AppColors.border : AppColors.borderDark,
                  width: 1.2,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Ask AI Decision Assistant...',
                    controller: _messageController,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: isLight ? AppColors.primary : AppColors.accentDark,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: isLight ? Colors.white : AppColors.backgroundDark,
                      size: 20,
                    ),
                    onPressed: _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final suggestions = [
      'Can I afford my goals?',
      'How much should I save?',
      'Optimize my wedding plan',
      'What if I shift my house deadline?',
    ];
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : AppColors.surfaceDark,
              shape: BoxShape.circle,
              border: Border.all(
                color: isLight ? AppColors.border : AppColors.borderDark,
                width: 1.2,
              ),
            ),
            child: const Text('✨', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 24),
          const Text('Suggested Action Projections', style: AppTextStyles.headlineLarge),
          AppSpacing.heightS,
          Text(
            'Tap a prompt below to run co-pilot optimization simulations.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: suggestions.map((p) {
              return ActionChip(
                backgroundColor: isLight ? Colors.white : AppColors.surfaceDark,
                side: BorderSide(color: isLight ? AppColors.border : AppColors.borderDark, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                label: Text(
                  p, 
                  style: TextStyle(
                    fontSize: 13, 
                    fontWeight: FontWeight.bold,
                    color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                  ),
                ),
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
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isLight ? AppColors.primary : AppColors.surfaceDark,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            border: Border.all(
              color: isLight ? AppColors.primary : AppColors.borderDark,
              width: 1.2,
            ),
          ),
          child: Text(
            msg.text,
            style: TextStyle(
              color: isLight ? Colors.white : AppColors.textPrimaryDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else {
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

    bool hasInsight = text.contains('uses') || text.contains('paces') || text.contains('budget') || text.contains('down');
    bool hasPlan = text.contains('Recommending:') || text.contains('consider') || text.contains('recommend');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isLight ? AppColors.secondary.withValues(alpha: 0.1) : Colors.black12,
                shape: BoxShape.circle,
              ),
              child: const Text('✨', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 10),
            Text(
              'GOALPILOT CO-PILOT AI',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
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
              Text(
                text, 
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 14.5,
                  height: 1.5,
                  color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                ),
              ),
              if (hasInsight) ...[
                const SizedBox(height: 20),
                _blockCard(
                  context,
                  'CO-PILOT CAPACITY INSIGHT',
                  'Simulated available limits: ₹45,000/month. Goal balance constraints mapped.',
                  Icons.analytics_outlined,
                  AppColors.info,
                ),
              ],
              if (hasPlan) ...[
                const SizedBox(height: 12),
                _blockCard(
                  context,
                  'RECOMMENDED ADJUSTMENTS',
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
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
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AiGoalCreationScreen extends ConsumerStatefulWidget {
  const AiGoalCreationScreen({super.key});

  @override
  ConsumerState<AiGoalCreationScreen> createState() => _AiGoalCreationScreenState();
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
      final intent = await ref.read(aiViewModelProvider.notifier).parseGoalCreationQuery(text);
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
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'AI Goal Creation',
        onBackPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Describe your target dream',
              style: AppTextStyles.displayMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Input details naturally. Example: "I want to save for a car worth 8 lakh in two years."',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _inputController,
              maxLines: 4,
              style: const TextStyle(fontSize: 14.5),
              decoration: InputDecoration(
                hintText: 'Describe your destination goal target details...',
                filled: true,
                fillColor: isLight ? Colors.white : AppColors.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'ANALYZE PLAN INTENT',
              isLoading: _isLoading,
              onPressed: _analyze,
            ),

            if (_structuredIntent != null) ...[
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 24),
              const MiSectionHeader(title: "Understood Draft Projections"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isLight ? AppColors.border : AppColors.borderDark,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    _draftRow('Category Path', _structuredIntent!['type'].toString().toUpperCase(), context),
                    _draftRow('Goal Name Estimate', _structuredIntent!['name'], context),
                    _draftRow('Estimated Target Budget', '₹${NumberFormat('#,##,###').format(_structuredIntent!['targetAmount'])}', context),
                    _draftRow('Timeline Maturity', '${_structuredIntent!['months']} Months', context),
                    _draftRow('Target Monthly Savings', '₹${NumberFormat('#,##,###').format(_structuredIntent!['monthlySavingsNeeded'])}/month', context),
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
                  const SizedBox(width: 16),
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

  Widget _draftRow(String label, String value, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
