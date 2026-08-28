class TimelineTask {
  final String id;
  final String title;
  final DateTime deadline;
  final bool isCompleted;
  final String category;

  TimelineTask({
    required this.id,
    required this.title,
    required this.deadline,
    this.isCompleted = false,
    required this.category,
  });

  TimelineTask copyWith({
    String? id,
    String? title,
    DateTime? deadline,
    bool? isCompleted,
    String? category,
  }) {
    return TimelineTask(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
    );
  }

  factory TimelineTask.fromJson(Map<String, dynamic> json) {
    return TimelineTask(
      id: json['id'] as String,
      title: json['title'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      isCompleted: json['isCompleted'] as bool,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'deadline': deadline.toIso8601String(),
        'isCompleted': isCompleted,
        'category': category,
      };
}
