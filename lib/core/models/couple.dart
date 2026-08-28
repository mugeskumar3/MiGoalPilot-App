class Couple {
  final String id;
  final String user1Id;
  final String user2Id;
  final String partnerName;
  final Map<String, double> contributions;

  Couple({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.partnerName,
    required this.contributions,
  });
}
