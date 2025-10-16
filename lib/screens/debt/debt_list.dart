import 'package:flutter/material.dart';
import 'package:mybudget/core/database_helper.dart';
import 'package:mybudget/widgets/app_drawer.dart';

class DebtListPage extends StatefulWidget {
  const DebtListPage({super.key});

  @override
  State<DebtListPage> createState() => _DebtListPageState();
}

class _DebtListPageState extends State<DebtListPage> {
  List<Map<String, dynamic>> debts = [];

  Future<void> _loadDebts() async {
    final db = await DatabaseHelper().db;
    final result = await db.query('debts', orderBy: 'first_due ASC');
    setState(() {
      debts = result;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Borç Listesi')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: debts.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Henüz borç eklenmedi'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final res = await Navigator.pushNamed(
                          context,
                          '/debt_add',
                        );
                        if (res == true) _loadDebts();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('Borç Ekle'),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: debts.length,
                itemBuilder: (context, index) {
                  final debt = debts[index];
                  final amount = (debt['amount'] as num).toDouble();
                  final installments = debt['installments'] as int;
                  final firstDue = DateTime.parse(debt['first_due']);
                  final formattedDate =
                      '${firstDue.day}/${firstDue.month}/${firstDue.year}';

                  return ListTile(
                    title: Text('${debt['name']} (${debt['type']})'),
                    subtitle: Text(
                      'Tutar: ${amount.toStringAsFixed(2)} TL\nTaksit: $installments\nİlk Ödeme: $formattedDate',
                    ),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      onPressed: () => _showSchedule(debt['id'] as int),
                      child: const Text('Detay'),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.pushNamed(context, '/debt_add');
          if (res == true) _loadDebts();
        },
        tooltip: 'Borç Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showSchedule(int debtId) async {
    final db = await DatabaseHelper().db;
    final schedules = await db.query(
      'debt_schedule',
      where: 'debt_id = ?',
      whereArgs: [debtId],
      orderBy: 'due ASC',
    );

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Taksitler', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...schedules.map((s) {
                final due = DateTime.parse(s['due'] as String);
                final paid = (s['is_paid'] as int) == 1;
                final amount = (s['amount'] as num).toDouble();
                return ListTile(
                  title: Text('${amount.toStringAsFixed(2)} TL'),
                  subtitle: Text('${due.day}/${due.month}/${due.year}'),
                  trailing: TextButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final newVal = paid ? 0 : 1;
                      await db.update(
                        'debt_schedule',
                        {'is_paid': newVal},
                        where: 'id = ?',
                        whereArgs: [s['id']],
                      );
                      if (!mounted) return;
                      navigator.pop();
                      await _loadDebts();
                    },
                    child: Text(paid ? 'Ödenmiş' : 'Öde'),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
