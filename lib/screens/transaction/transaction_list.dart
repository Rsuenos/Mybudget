import 'package:flutter/material.dart';
import 'package:mybudget/core/database_helper.dart';
import 'package:mybudget/core/finance_group.dart';
import 'package:mybudget/widgets/app_drawer.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  DateTimeRange? selectedRange;
  List<Map<String, dynamic>> transactions = [];

  Future<void> _loadTransactions() async {
    final db = await DatabaseHelper().db;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final range = selectedRange;
    final result = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        (range?.start ?? startOfMonth).toIso8601String(),
        (range?.end ?? endOfMonth).toIso8601String(),
      ],
      orderBy: 'date DESC',
    );

    setState(() {
      transactions = result;
    });
  }

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: DateTime(DateTime.now().year, DateTime.now().month, 1),
        end: DateTime(DateTime.now().year, DateTime.now().month, 30),
      ),
    );
    if (picked != null) {
      setState(() => selectedRange = picked);
      await _loadTransactions();
    }
  }

  String getCategoryLabel(int categoryId, int subCategoryId) {
    final category = categoryList.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => Category(
        id: 0,
        name: 'Tanımsız',
        type: CategoryType.gider,
        subcategories: [],
      ),
    );
    final sub = category.subcategories.firstWhere(
      (s) => s.subId == subCategoryId,
      orElse: () => SubCategory(subId: 0, name: 'Tanımsız'),
    );
    return '${category.name} > ${sub.name}';
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, double>{};

    for (var tx in transactions) {
      final label = getCategoryLabel(tx['category_id'], tx['subcategory_id']);
      final amount = (tx['amount'] as num).toDouble();
      grouped[label] = (grouped[label] ?? 0) + amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('İşlem Listesi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedRange == null
                  ? 'İçinde bulunduğumuz ayın işlemleri'
                  : '${selectedRange!.start.day}/${selectedRange!.start.month} - ${selectedRange!.end.day}/${selectedRange!.end.month}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: grouped.isEmpty
                  ? const Center(child: Text('İşlem bulunamadı'))
                  : ListView(
                      children: grouped.entries.map((entry) {
                        return ListTile(
                          title: Text(entry.key),
                          trailing: Text(
                            '${entry.value.toStringAsFixed(2)} TL',
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
