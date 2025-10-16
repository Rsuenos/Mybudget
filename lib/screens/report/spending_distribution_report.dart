import 'package:flutter/material.dart';
import 'package:mybudget/core/database_helper.dart';
import 'package:mybudget/core/finance_group.dart';

class SpendingDistributionReportPage extends StatefulWidget {
  const SpendingDistributionReportPage({super.key});

  @override
  State<SpendingDistributionReportPage> createState() =>
      _SpendingDistributionReportPageState();
}

class _SpendingDistributionReportPageState
    extends State<SpendingDistributionReportPage>
    with SingleTickerProviderStateMixin {
  DateTimeRange? selectedRange;
  late TabController _tabController;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final db = await DatabaseHelper().db;
    final result = await db.query('transactions');
    setState(() {
      transactions = result;
    });
  }

  List<Map<String, dynamic>> get filtered {
    final range = selectedRange;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return transactions.where((tx) {
      final date = DateTime.parse(tx['date']);
      if (range != null) {
        return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
            date.isBefore(range.end.add(const Duration(days: 1)));
      } else {
        return date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            date.isBefore(endOfMonth.add(const Duration(days: 1)));
      }
    }).toList();
  }

  Map<String, double> get categoryTotals {
    final Map<String, double> grouped = {};
    for (var tx in filtered.where((tx) => tx['type'] == 'gider')) {
      final label = getCategoryLabel(tx['category_id'], tx['subcategory_id']);
      final amount = (tx['amount'] as num).toDouble();
      grouped[label] = (grouped[label] ?? 0) + amount;
    }
    return grouped;
  }

  Map<String, double> get methodTotals {
    final Map<String, double> grouped = {};
    for (var tx in filtered.where((tx) => tx['type'] == 'gider')) {
      final method = tx['method'];
      final amount = (tx['amount'] as num).toDouble();
      grouped[method] = (grouped[method] ?? 0) + amount;
    }
    return grouped;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harcama Dağılımı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ödeme Yöntemi'),
            Tab(text: 'Harcama Kategorisi'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              selectedRange == null
                  ? 'İçinde bulunduğumuz ayın harcama dağılımı'
                  : '${selectedRange!.start.day}/${selectedRange!.start.month} - ${selectedRange!.end.day}/${selectedRange!.end.month} arası',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildReport(methodTotals),
                  _buildReport(categoryTotals),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReport(Map<String, double> data) {
    final entries = data.entries.toList();

    return ListView(
      children: entries.map((entry) {
        return ListTile(
          title: Text(entry.key),
          trailing: Text('${entry.value.toStringAsFixed(2)} TL'),
        );
      }).toList(),
    );
  }
}
