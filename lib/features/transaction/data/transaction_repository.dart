import '../domain/transaction_model.dart';

abstract class TransactionRepository {
  Future<int> createTransaction(TransactionModel tx);
  Future<List<TransactionModel>> fetchTransactions({int? limit, int? offset});
  Future<void> updateTransaction(TransactionModel tx);
  Future<void> deleteTransaction(int id);
}
