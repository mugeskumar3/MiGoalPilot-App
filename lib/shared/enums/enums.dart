enum GoalHealth {
  onTrack('On Track', '🟢'),
  needsAttention('Needs Attention', '🟡'),
  atRisk('At Risk', '🔴'),
  completed('Completed', '🔵'),
  paused('Paused', '⚪');

  final String label;
  final String emoji;
  const GoalHealth(this.label, this.emoji);
}

enum GoalPriority {
  critical('Critical'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;
  const GoalPriority(this.label);
}

enum GoalType {
  marriage('Marriage', '💍'),
  gold('Gold', '🥇'),
  house('House', '🏠'),
  car('Car', '🚗'),
  education('Education', '🎓'),
  travel('Travel', '✈️'),
  babyFamily('Baby / Family', '👶'),
  business('Business', '💼'),
  emergencyFund('Emergency Fund', '🆘'),
  laptop('Laptop', '💻'),
  phone('Phone', '📱'),
  event('Event', '🎉'),
  custom('Custom Goal', '🎯');

  final String label;
  final String emoji;
  const GoalType(this.label, this.emoji);
}
