class TransactionModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String type; // income | expense
  final String category;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      amount: double.parse(map['amount'].toString()),
      type: map['type'],
      category: map['category'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
    };
  }
}
