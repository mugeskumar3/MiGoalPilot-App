class AiInsight {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  AiInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.metadata,
  });
}
