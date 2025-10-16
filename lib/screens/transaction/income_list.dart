import 'package:flutter/material.dart';
import 'package:mybudget/core/database_helper.dart';
import 'package:mybudget/core/finance_group.dart';
import 'package:mybudget/widgets/app_drawer.dart';

class IncomeListPage extends StatefulWidget {
  const IncomeListPage({super.key});

  @override
  State<IncomeListPage> createState() => _IncomeListPageState();
}

class _IncomeListPageState extends State<IncomeListPage> {
  DateTimeRange? selectedRange;
  List<Map<String, dynamic>> incomes = [];

  Future<void> _loadIncomes() async {
    final db = await DatabaseHelper().db;
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = DateTime(now.year, now.month + 1, 0);

    final range = selectedRange;
    final result = await db.query(
      'transactions',
      where: 'type = ? AND date BETWEEN ? AND ?',
      whereArgs: [
        'gelir',
        (range?.start ?? currentMonthStart).toIso8601String(),
        (range?.end ?? currentMonthEnd).toIso8601String(),
      ],
      orderBy: 'date DESC',
    );

    setState(() {
      incomes = result;
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
      await _loadIncomes();
    }
  }

  String getCategoryLabel(int categoryId, int subCategoryId) {
    final category = categoryList.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => Category(
        id: 0,
        name: 'Tanımsız',
        type: CategoryType.gelir,
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
    _loadIncomes();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, double>{};

    for (var tx in incomes) {
      final label = getCategoryLabel(tx['category_id'], tx['subcategory_id']);
      final amount = (tx['amount'] as num).toDouble();
      grouped[label] = (grouped[label] ?? 0) + amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelir Listesi'),
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
                  ? 'Bu ayın gelirleri'
                  : '${selectedRange!.start.day}/${selectedRange!.start.month} - ${selectedRange!.end.day}/${selectedRange!.end.month} tarihleri arasındaki gelirler',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: grouped.isEmpty
                  ? const Center(child: Text('Gelir bulunamadı'))
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
