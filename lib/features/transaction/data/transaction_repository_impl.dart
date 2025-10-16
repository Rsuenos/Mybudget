import '../domain/transaction_model.dart';
import 'transaction_repository.dart';
import '../../../core/database_helper.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final DatabaseHelper _dbHelper;

  TransactionRepositoryImpl([DatabaseHelper? dbHelper])
    : _dbHelper = dbHelper ?? DatabaseHelper();

  @override
  Future<int> createTransaction(TransactionModel tx) async {
    final map = tx.toMap();
    return await _dbHelper.insertTransaction(map);
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
  }

  @override
  Future<List<TransactionModel>> fetchTransactions({
    int? limit,
    int? offset,
  }) async {
    final dbClient = await _dbHelper.db;
    final maps = await dbClient.query(
      'transactions',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  @override
  Future<void> updateTransaction(TransactionModel tx) async {
    if (tx.id == null) throw ArgumentError('Transaction id is null');
    await _dbHelper.updateTransaction(tx.id!, tx.toMap());
  }
}
