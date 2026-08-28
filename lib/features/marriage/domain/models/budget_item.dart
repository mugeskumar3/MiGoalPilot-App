class BudgetItem {
  final String id;
  final String category;
  final double estimatedCost;
  final double actualSpent;

  BudgetItem({
    required this.id,
    required this.category,
    required this.estimatedCost,
    required this.actualSpent,
  });

  BudgetItem copyWith({
    String? id,
    String? category,
    double? estimatedCost,
    double? actualSpent,
  }) {
    return BudgetItem(
      id: id ?? this.id,
      category: category ?? this.category,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualSpent: actualSpent ?? this.actualSpent,
    );
  }

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      id: json['id'] as String,
      category: json['category'] as String,
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      actualSpent: (json['actualSpent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'estimatedCost': estimatedCost,
        'actualSpent': actualSpent,
      };
}
