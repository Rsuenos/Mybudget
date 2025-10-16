import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration to version 2: rename 'limit' -> 'card_limit'
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE credit_cards_new (
          id TEXT PRIMARY KEY,
          bank TEXT NOT NULL,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          card_limit REAL NOT NULL,
          statement_date TEXT NOT NULL,
          due_date TEXT NOT NULL
        )
      ''');

      await db.execute('''
        INSERT INTO credit_cards_new (id, bank, name, type, card_limit, statement_date, due_date)
        SELECT id, bank, name, type, limit, statement_date, due_date FROM credit_cards;
      ''');

      await db.execute('DROP TABLE credit_cards');
      await db.execute('ALTER TABLE credit_cards_new RENAME TO credit_cards');
    }

    // Migration to version 3: add current_balance & upcoming_amount to credit_cards,
    // create wallets table and add wallet_id to transactions
    if (oldVersion < 3) {
      // Recreate credit_cards with new columns
      await db.execute('''
        CREATE TABLE credit_cards_new (
          id TEXT PRIMARY KEY,
          bank TEXT NOT NULL,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          card_limit REAL NOT NULL,
          current_balance REAL NOT NULL DEFAULT 0.0,
          upcoming_amount REAL NOT NULL DEFAULT 0.0,
          statement_date TEXT NOT NULL,
          due_date TEXT NOT NULL
        )
      ''');

      // Copy existing data, set new columns to 0.0
      await db.execute('''
        INSERT INTO credit_cards_new (id, bank, name, type, card_limit, current_balance, upcoming_amount, statement_date, due_date)
        SELECT id, bank, name, type, card_limit, 0.0, 0.0, statement_date, due_date FROM credit_cards;
      ''');

      await db.execute('DROP TABLE credit_cards');
      await db.execute('ALTER TABLE credit_cards_new RENAME TO credit_cards');

      // Create wallets table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS wallets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          balance REAL NOT NULL
        )
      ''');

      // Add wallet_id column to transactions (if not exists) - ALTER TABLE for SQLite
      try {
        await db.execute(
          'ALTER TABLE transactions ADD COLUMN wallet_id INTEGER',
        );
      } catch (e) {
        // If column exists or ALTER fails, ignore to keep migration idempotent
      }

      // Create index for wallet_id
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transactions_wallet_id ON transactions(wallet_id)',
      );
    }
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mybudget.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ✅ Transaction tablosu: ID tabanlı, enum uyumlu
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        method TEXT NOT NULL,
        type TEXT NOT NULL,             -- 'gelir' veya 'gider'
        category_id INTEGER NOT NULL,   -- örn: 201
        subcategory_id INTEGER NOT NULL, -- örn: 20101
        wallet_id INTEGER
      )
    ''');

    // ✅ Kredi kartı tablosu
    await db.execute('''
      CREATE TABLE credit_cards (
        id TEXT PRIMARY KEY,
        bank TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        card_limit REAL NOT NULL,
        current_balance REAL NOT NULL DEFAULT 0.0,
        upcoming_amount REAL NOT NULL DEFAULT 0.0,
        statement_date TEXT NOT NULL,
        due_date TEXT NOT NULL
      )
    ''');

    // ✅ Borç tablosu
    await db.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        installments INTEGER NOT NULL,
        description TEXT,
        first_due TEXT NOT NULL
      )
    ''');

    // ✅ Borç takvimi tablosu
    await db.execute('''
      CREATE TABLE debt_schedule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        debt_id INTEGER NOT NULL,
        due TEXT NOT NULL,
        amount REAL NOT NULL,
        is_paid INTEGER NOT NULL
      )
    ''');

    // ✅ Wallets (kasa/bakiye)
    await db.execute('''
      CREATE TABLE wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL
      )
    ''');
  }

  // ✅ Kredi kartı ekleme
  Future<int> insertCreditCard(Map<String, dynamic> card) async {
    final dbClient = await db;
    return await dbClient.insert('credit_cards', card);
  }

  // Wallet CRUD
  Future<int> insertWallet(Map<String, dynamic> wallet) async {
    final dbClient = await db;
    return await dbClient.insert('wallets', wallet);
  }

  Future<List<Map<String, dynamic>>> getWallets() async {
    final dbClient = await db;
    return await dbClient.query('wallets');
  }

  Future<int> updateWallet(int id, Map<String, dynamic> values) async {
    final dbClient = await db;
    return await dbClient.update(
      'wallets',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✅ Transaction ekleme (ID tabanlı)
  Future<int> insertTransaction(Map<String, dynamic> tx) async {
    final dbClient = await db;
    final id = await dbClient.insert('transactions', tx);

    // Otomatik olarak ilgili kasanın bakiyesini güncelle
    try {
      if (tx.containsKey('wallet_id') && tx['wallet_id'] != null) {
        final walletId = tx['wallet_id'] as int;
        final amount = (tx['amount'] as num).toDouble();
        final type = (tx['type'] as String?) ?? '';
        // 'gelir' pozitif, diğerleri ('gider') negatif
        final delta = type == 'gelir' ? amount : -amount;

        final wallets = await dbClient.query(
          'wallets',
          where: 'id = ?',
          whereArgs: [walletId],
        );
        if (wallets.isNotEmpty) {
          final current = (wallets.first['balance'] as num).toDouble();
          final newBal = current + delta;
          await dbClient.update(
            'wallets',
            {'balance': newBal},
            where: 'id = ?',
            whereArgs: [walletId],
          );
        }
      }
    } catch (e) {
      // Migration/DB edge-case'lerinde uygulamanın çökmesini istemiyoruz; loglayabilirsiniz
    }

    return id;
  }

  // Delete transaction by id
  Future<int> deleteTransaction(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update transaction by id
  Future<int> updateTransaction(int id, Map<String, dynamic> values) async {
    final dbClient = await db;
    return await dbClient.update(
      'transactions',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✅ Borç ekleme
  Future<int> insertDebt(Map<String, dynamic> debt) async {
    final dbClient = await db;
    return await dbClient.insert('debts', debt);
  }

  // ✅ Borç takvimi ekleme (batch)
  Future<void> insertDebtSchedule(List<Map<String, dynamic>> schedule) async {
    final dbClient = await db;
    final batch = dbClient.batch();
    for (var item in schedule) {
      batch.insert('debt_schedule', item);
    }
    await batch.commit(noResult: true);
  }
}
