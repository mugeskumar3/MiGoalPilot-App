import 'package:migoalpilot/core/services/goal_analytics_calculator.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

enum AnalyticsRange {
  threeMonths('3 Months'),
  sixMonths('6 Months'),
  twelveMonths('12 Months'),
  custom('Custom Range');

  final String label;
  const AnalyticsRange(this.label);
}

class GoalAnalyticsState {
  final AnalyticsRange range;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  
  // Selected filter (null represents "All Goals")
  final GoalType? selectedGoalType;
  final String? selectedGoalId;

  // Gold mode settings
  final String goldPurity; // "22K" or "24K"
  final String goldChartMetric; // "Price" or "Weight" or "Value"

  final GoalAnalyticsResult? generalResult;
  final GoldAnalyticsResult? goldResult;
  final List<String> insights;

  final bool isLoading;
  final String? error;

  GoalAnalyticsState({
    this.range = AnalyticsRange.sixMonths,
    this.customStartDate,
    this.customEndDate,
    this.selectedGoalType,
    this.selectedGoalId,
    this.goldPurity = '22K',
    this.goldChartMetric = 'Price',
    this.generalResult,
    this.goldResult,
    this.insights = const [],
    this.isLoading = false,
    this.error,
  });

  GoalAnalyticsState copyWith({
    AnalyticsRange? range,
    DateTime? customStartDate,
    DateTime? customEndDate,
    GoalType? selectedGoalType,
    String? selectedGoalId,
    String? goldPurity,
    String? goldChartMetric,
    GoalAnalyticsResult? generalResult,
    GoldAnalyticsResult? goldResult,
    List<String>? insights,
    bool? isLoading,
    String? error,
    bool clearGoalId = false,
    bool clearGoalType = false,
  }) {
    return GoalAnalyticsState(
      range: range ?? this.range,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      selectedGoalType: clearGoalType ? null : (selectedGoalType ?? this.selectedGoalType),
      selectedGoalId: clearGoalId ? null : (selectedGoalId ?? this.selectedGoalId),
      goldPurity: goldPurity ?? this.goldPurity,
      goldChartMetric: goldChartMetric ?? this.goldChartMetric,
      generalResult: generalResult ?? this.generalResult,
      goldResult: goldResult ?? this.goldResult,
      insights: insights ?? this.insights,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
