import 'package:flutter/material.dart';
import 'package:mybudget/core/database_helper.dart';

class DebtSchedulePage extends StatefulWidget {
  final int debtId;
  final String debtName;

  const DebtSchedulePage({
    super.key,
    required this.debtId,
    required this.debtName,
  });

  @override
  State<DebtSchedulePage> createState() => _DebtSchedulePageState();
}

class _DebtSchedulePageState extends State<DebtSchedulePage> {
  List<Map<String, dynamic>> schedule = [];

  Future<void> _loadSchedule() async {
    final db = await DatabaseHelper().db;
    final result = await db.query(
      'debt_schedule',
      where: 'debt_id = ?',
      whereArgs: [widget.debtId],
      orderBy: 'due ASC',
    );
    setState(() {
      schedule = result;
    });
  }

  Future<void> _togglePaid(int id, int currentStatus) async {
    final db = await DatabaseHelper().db;
    await db.update(
      'debt_schedule',
      {'is_paid': currentStatus == 1 ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    await _loadSchedule();
  }

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.debtName} Taksitleri')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: schedule.isEmpty
            ? const Center(child: Text('Henüz taksit yok'))
            : ListView.builder(
                itemCount: schedule.length,
                itemBuilder: (context, index) {
                  final item = schedule[index];
                  final dueDate = DateTime.parse(item['due']);
                  final formattedDate =
                      '${dueDate.day}/${dueDate.month}/${dueDate.year}';
                  final isPaid = item['is_paid'] == 1;

                  return ListTile(
                    title: Text(
                      '${(item['amount'] as num).toStringAsFixed(2)} TL',
                      style: TextStyle(
                        color: isPaid ? Colors.grey : Colors.black,
                        decoration: isPaid ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text('Vade: $formattedDate'),
                    trailing: IconButton(
                      icon: Icon(
                        isPaid
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isPaid ? Colors.green : Colors.grey,
                      ),
                      onPressed: () => _togglePaid(item['id'], item['is_paid']),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
