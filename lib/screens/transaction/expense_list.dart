import 'package:flutter/material.dart';
import 'package:mybudget/core/database_helper.dart';
import 'package:mybudget/core/finance_group.dart';
import 'package:mybudget/widgets/app_drawer.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  List<Map<String, dynamic>> expenses = [];

  Future<void> _loadExpenses() async {
    final db = await DatabaseHelper().db;
    final result = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: ['gider'],
      orderBy: 'date DESC',
    );

    setState(() {
      expenses = result;
    });
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
    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gider Listesi')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: expenses.isEmpty
            ? const Center(child: Text('Henüz gider eklenmedi'))
            : ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  final date = DateTime.parse(expense['date']);
                  final formattedDate =
                      '${date.day}/${date.month}/${date.year}';
                  final label = getCategoryLabel(
                    expense['category_id'],
                    expense['subcategory_id'],
                  );

                  return ListTile(
                    title: Text(
                      '- ${expense['amount'].toStringAsFixed(2)} TL',
                      style: const TextStyle(color: Colors.red),
                    ),
                    subtitle: Text('$formattedDate • $label'),
                  );
                },
              ),
      ),
    );
  }
}
