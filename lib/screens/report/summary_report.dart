import 'package:flutter/material.dart';
import 'package:mybudget/core/database_helper.dart';
import 'package:mybudget/core/finance_group.dart';

class SummaryReportPage extends StatefulWidget {
  const SummaryReportPage({super.key});

  @override
  State<SummaryReportPage> createState() => _SummaryReportPageState();
}

class _SummaryReportPageState extends State<SummaryReportPage> {
  DateTimeRange? selectedRange;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final db = await DatabaseHelper().db;
    final result = await db.query('transactions');
    setState(() {
      transactions = result;
    });
  }

  List<Map<String, dynamic>> get filteredTransactions {
    final range = selectedRange;
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    return transactions.where((tx) {
      final txDate = DateTime.parse(tx['date']);
      if (range != null) {
        return txDate.isAfter(range.start.subtract(const Duration(days: 1))) &&
            txDate.isBefore(range.end.add(const Duration(days: 1)));
      } else {
        return txDate.year == currentMonth.year &&
            txDate.month == currentMonth.month;
      }
    }).toList();
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
    if (picked != null) setState(() => selectedRange = picked);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, double>{};

    for (var tx in filteredTransactions) {
      final label = getCategoryLabel(tx['category_id'], tx['subcategory_id']);
      final amount = (tx['amount'] as num).toDouble();
      grouped[label] = (grouped[label] ?? 0) + amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Özet Rapor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedRange == null
                  ? 'İçinde bulunduğumuz ayın işlem özeti'
                  : '${selectedRange!.start.day}/${selectedRange!.start.month} - ${selectedRange!.end.day}/${selectedRange!.end.month} arası',
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
