import 'package:flutter/material.dart';
import 'package:mybudget/core/database_helper.dart';
import 'package:mybudget/core/finance_group.dart';
import 'package:mybudget/screens/transaction/input_finances.dart';

class CreditCardDetailPage extends StatefulWidget {
  final String cardId;
  final String cardName;
  final String bankName;
  final double totalLimit;

  const CreditCardDetailPage({
    super.key,
    required this.cardId,
    required this.cardName,
    required this.bankName,
    required this.totalLimit,
  });

  @override
  State<CreditCardDetailPage> createState() => _CreditCardDetailPageState();
}

class _CreditCardDetailPageState extends State<CreditCardDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  double usedAmount = 0;
  double availableLimit = 0;
  double futureInstallments = 0;

  List<Map<String, dynamic>> currentMonthTransactions = [];
  List<Map<String, dynamic>> futureInstallmentList = [];

  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCardData();
  }

  String getCategoryName(int id) {
    return categoryList
        .firstWhere(
          (c) => c.id == id,
          orElse: () => Category(
            id: 0,
            name: 'Tanımsız',
            type: CategoryType.gider,
            subcategories: [],
          ),
        )
        .name;
  }

  String getSubCategoryName(int subId) {
    for (final cat in categoryList) {
      for (final sub in cat.subcategories) {
        if (sub.subId == subId) return sub.name;
      }
    }
    return 'Tanımsız';
  }

  Future<void> _loadCardData() async {
    final db = await DatabaseHelper().db;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final txs = await db.query(
      'transactions',
      where: 'method = ? AND date BETWEEN ? AND ?',
      whereArgs: [
        widget.cardName,
        startOfMonth.toIso8601String(),
        endOfMonth.toIso8601String(),
      ],
    );

    final futureTaksitler = await db.query(
      'debt_schedule',
      where: 'is_paid = 0 AND due > ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );

    // Load card meta (current_balance, upcoming_amount)
    final cardRows = await db.query(
      'credit_cards',
      where: 'id = ?',
      whereArgs: [widget.cardId],
    );
    double cardCurrentBalance = 0.0;
    double cardUpcoming = 0.0;
    if (cardRows.isNotEmpty) {
      final row = cardRows.first;
      cardCurrentBalance = (row['current_balance'] as num?)?.toDouble() ?? 0.0;
      cardUpcoming = (row['upcoming_amount'] as num?)?.toDouble() ?? 0.0;
    }

    double used = 0;
    double future = 0;

    for (var tx in txs) {
      final amount = tx['amount'] as double;
      final type = tx['type'];
      used += type == 'gider' ? amount : -amount;
    }

    for (var taksit in futureTaksitler) {
      future += taksit['amount'] as double;
    }

    setState(() {
      currentMonthTransactions = txs;
      futureInstallmentList = futureTaksitler;
      usedAmount = used;
      futureInstallments = future;
      availableLimit = widget.totalLimit - used - future;
      // If DB contains explicit fields, prefer them for display
      if (cardRows.isNotEmpty) {
        usedAmount = cardCurrentBalance;
        futureInstallments = cardUpcoming;
        availableLimit = widget.totalLimit - usedAmount - futureInstallments;
      }
    });
  }

  void _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Ay Seç (Gün seçme)',
      selectableDayPredicate: (day) => day.day == 1,
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final calculatedLimit = availableLimit + usedAmount + futureInstallments;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.cardName} - ${widget.bankName}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kart Limiti: ${widget.totalLimit.toStringAsFixed(2)} TL',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (widget.totalLimit > 0)
                          ? ((widget.totalLimit - availableLimit) /
                                    widget.totalLimit)
                                .clamp(0.0, 1.0)
                          : 0.0,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(
                            'Kullanılan: ${usedAmount.toStringAsFixed(2)} TL',
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Gelecek: ${futureInstallments.toStringAsFixed(2)} TL',
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Kullanılabilir: ${availableLimit.toStringAsFixed(2)} TL',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Formül: Limit = Kullanılabilir + Borç + Taksit → ${calculatedLimit.toStringAsFixed(2)} TL',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Dönem İçi'),
                Tab(text: 'Gelecek Taksitler'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Dönem İçi İşlemler
                  ListView.builder(
                    itemCount: currentMonthTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = currentMonthTransactions[index];
                      final isIncome = tx['type'] == 'gelir';
                      final color = isIncome ? Colors.green : Colors.red;
                      final prefix = isIncome ? '+' : '-';

                      final categoryName = getCategoryName(tx['category_id']);
                      final subCategoryName = getSubCategoryName(
                        tx['subcategory_id'],
                      );

                      return ListTile(
                        title: Text(
                          '$prefix ${tx['amount']} TL',
                          style: TextStyle(color: color),
                        ),
                        subtitle: Text('$categoryName > $subCategoryName'),
                      );
                    },
                  ),
                  // Gelecek Taksitler
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _pickMonth,
                        child: Text(
                          '${selectedMonth.month}/${selectedMonth.year} Ayını Seç',
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: futureInstallmentList
                              .where((tx) {
                                final date = DateTime.parse(tx['due']);
                                return date.month == selectedMonth.month &&
                                    date.year == selectedMonth.year;
                              })
                              .map((tx) {
                                final date = DateTime.parse(tx['due']);
                                return ListTile(
                                  title: Text('Taksit - ${tx['amount']} TL'),
                                  subtitle: Text(
                                    '${date.day}/${date.month}/${date.year}',
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Navigate to transaction input page so user can add a transaction linked to this card
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InputFinancesPage()),
                );
              },
              child: const Text('İşlem Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
