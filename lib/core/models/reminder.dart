class Reminder {
  final String id;
  final String title;
  final DateTime triggerTime;
  final String goalId;
  final bool isEnabled;

  Reminder({
    required this.id,
    required this.title,
    required this.triggerTime,
    required this.goalId,
    this.isEnabled = true,
  });
}
