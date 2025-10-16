class TransactionModel {
  final int? id;
  final int amount;
  final String note;
  final int walletId;
  final int categoryId;
  final DateTime date;

  TransactionModel({
    this.id,
    required this.amount,
    required this.note,
    required this.walletId,
    required this.categoryId,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'note': note,
    'wallet_id': walletId,
    'category_id': categoryId,
    'date': date.toIso8601String(),
  };

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
    id: m['id'] as int?,
    amount: m['amount'] as int,
    note: m['note'] as String,
    walletId: m['wallet_id'] as int,
    categoryId: m['category_id'] as int,
    date: DateTime.parse(m['date'] as String),
  );
}
