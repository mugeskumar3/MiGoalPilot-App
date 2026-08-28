class SavingsTransaction {
  final String id;
  final String goalId;
  final double amount;
  final DateTime date;
  final String? note;
  final double? goldGrams;

  SavingsTransaction({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.note,
    this.goldGrams,
  });

  factory SavingsTransaction.fromJson(Map<String, dynamic> json) {
    return SavingsTransaction(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      goldGrams: json['goldGrams'] != null ? (json['goldGrams'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'goalId': goalId,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
        'goldGrams': goldGrams,
      };
}
