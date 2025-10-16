import 'package:flutter/material.dart';
import 'package:mybudget/core/database_helper.dart';
import 'package:mybudget/core/finance_group.dart';

class IncomeListPage extends StatefulWidget {
  const IncomeListPage({super.key});

  @override
  State<IncomeListPage> createState() => _IncomeListPageState();
}

class _IncomeListPageState extends State<IncomeListPage> {
  List<Map<String, dynamic>> incomes = [];

  Future<void> _loadIncomes() async {
    final db = await DatabaseHelper().db;
    final result = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: ['gelir'],
      orderBy: 'date DESC',
    );

    setState(() {
      incomes = result;
    });
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
    return Scaffold(
      appBar: AppBar(title: const Text('Gelir Listesi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: incomes.isEmpty
            ? const Center(child: Text('Henüz gelir eklenmedi'))
            : ListView.builder(
                itemCount: incomes.length,
                itemBuilder: (context, index) {
                  final income = incomes[index];
                  final date = DateTime.parse(income['date']);
                  final formattedDate =
                      '${date.day}/${date.month}/${date.year}';
                  final label = getCategoryLabel(
                    income['category_id'],
                    income['subcategory_id'],
                  );

                  return ListTile(
                    title: Text(
                      '+ ${income['amount'].toStringAsFixed(2)} TL',
                      style: const TextStyle(color: Colors.green),
                    ),
                    subtitle: Text('$formattedDate • $label'),
                  );
                },
              ),
      ),
    );
  }
}
