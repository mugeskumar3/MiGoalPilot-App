import 'package:migoalpilot/shared/enums/enums.dart';

class GoalTemplate {
  final String id;
  final GoalType type;
  final String title;
  final String description;
  final String icon;
  final double defaultTargetAmount;
  final int defaultDurationMonths;

  GoalTemplate({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.defaultTargetAmount,
    required this.defaultDurationMonths,
  });
}

class GoalTemplateRegistry {
  static final List<GoalTemplate> templates = [
    GoalTemplate(
      id: 'marriage',
      type: GoalType.marriage,
      title: 'Marriage',
      description: 'Plan your dream wedding ceremony',
      icon: '💍',
      defaultTargetAmount: 500000.0,
      defaultDurationMonths: 24, // 2 years default
    ),
    GoalTemplate(
      id: 'emergency_fund',
      type: GoalType.emergencyFund,
      title: 'Emergency Fund',
      description: 'Build your financial safety buffer',
      icon: '🛡️',
      defaultTargetAmount: 300000.0,
      defaultDurationMonths: 12, // 1 year default
    ),
    GoalTemplate(
      id: 'gold',
      type: GoalType.gold,
      title: 'Gold',
      description: 'Build your gold target weight',
      icon: '🪙',
      defaultTargetAmount: 75000.0, // approx 10g value
      defaultDurationMonths: 12,
    ),
    GoalTemplate(
      id: 'house',
      type: GoalType.house,
      title: 'House',
      description: 'Plan your property down-payment fund',
      icon: '🏠',
      defaultTargetAmount: 1000000.0,
      defaultDurationMonths: 60, // 5 years default
    ),
    GoalTemplate(
      id: 'car',
      type: GoalType.car,
      title: 'Car',
      description: 'Save for your next vehicle down-payment',
      icon: '🚗',
      defaultTargetAmount: 200000.0,
      defaultDurationMonths: 36, // 3 years default
    ),
    GoalTemplate(
      id: 'travel',
      type: GoalType.travel,
      title: 'Travel',
      description: 'Turn your dream trip into a plan',
      icon: '✈️',
      defaultTargetAmount: 150000.0,
      defaultDurationMonths: 6, // 6 months default
    ),
    GoalTemplate(
      id: 'education',
      type: GoalType.education,
      title: 'Education',
      description: 'Prepare for tuition and education expenses',
      icon: '🎓',
      defaultTargetAmount: 400000.0,
      defaultDurationMonths: 48, // 4 years default
    ),
    GoalTemplate(
      id: 'gadgets',
      type: GoalType.laptop,
      title: 'Gadgets',
      description: 'Save before your next hardware upgrade',
      icon: '💻',
      defaultTargetAmount: 80000.0,
      defaultDurationMonths: 6, // 6 months default
    ),
    GoalTemplate(
      id: 'custom',
      type: GoalType.custom,
      title: 'Custom Goal',
      description: 'Create your own custom savings target',
      icon: '🎯',
      defaultTargetAmount: 100000.0,
      defaultDurationMonths: 12,
    ),
  ];

  static GoalTemplate getTemplateById(String id) {
    return templates.firstWhere(
      (t) => t.id == id,
      orElse: () => templates.last, // Fallback to custom
    );
  }
}
