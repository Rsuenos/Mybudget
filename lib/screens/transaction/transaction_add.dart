import 'package:flutter/material.dart';
import 'package:mybudget/core/finance_group.dart';
import 'package:mybudget/screens/transaction/input_finances.dart';

class TransactionAddPage extends StatefulWidget {
  const TransactionAddPage({super.key});

  @override
  State<TransactionAddPage> createState() => _TransactionAddPageState();
}

class _TransactionAddPageState extends State<TransactionAddPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedMethod = 'nakit';

  int selectedCategoryId = categoryList
      .firstWhere((c) => c.type == CategoryType.gelir)
      .id;
  int selectedSubCategoryId = categoryList
      .firstWhere((c) => c.type == CategoryType.gelir)
      .subcategories
      .first
      .subId;

  final List<Map<String, dynamic>> mockTransactions = [];

  final List<String> paymentMethods = [
    'nakit',
    'kredi kartı',
    'kredi',
    'havale/eft',
  ];

  List<Category> get currentCategoryOptions => _tabController.index == 0
      ? categoryList.where((c) => c.type == CategoryType.gelir).toList()
      : categoryList.where((c) => c.type == CategoryType.gider).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Redirect to the canonical transaction input page to avoid duplicate UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const InputFinancesPage()),
        );
      } catch (_) {
        // If navigation fails for any reason, do nothing; user can still use this page
      }
    });
  }

  void _submitTransaction() {
    if (_selectedDate == null || _amountController.text.isEmpty) return;

    final tx = {
      'date': _selectedDate,
      'amount': double.parse(_amountController.text),
      'type': _tabController.index == 0 ? 'gelir' : 'gider',
      'method': _selectedMethod,
      'category_id': selectedCategoryId,
      'subcategory_id': selectedSubCategoryId,
    };

    setState(() {
      mockTransactions.insert(0, tx);
    });

    _amountController.clear();
    _selectedDate = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşlem Ekle'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Gelir'),
            Tab(text: 'Gider'),
          ],
          onTap: (_) {
            final filtered = currentCategoryOptions;
            setState(() {
              selectedCategoryId = filtered.first.id;
              selectedSubCategoryId = filtered.first.subcategories.first.subId;
            });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Tutar ve Tarih
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Tutar (TL)'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: Text(
                    _selectedDate == null
                        ? 'Tarih Seç'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Yöntem, Kategori, Alt Kategori
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedMethod,
                  items: paymentMethods
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedMethod = val!),
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: selectedCategoryId,
                  items: currentCategoryOptions
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    final cat = categoryList.firstWhere((c) => c.id == val);
                    setState(() {
                      selectedCategoryId = val;
                      selectedSubCategoryId = cat.subcategories.first.subId;
                    });
                  },
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: selectedSubCategoryId,
                  items:
                      (categoryList
                              .firstWhere((c) => c.id == selectedCategoryId)
                              .subcategories)
                          .map(
                            (sub) => DropdownMenuItem(
                              value: sub.subId,
                              child: Text(sub.name),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(
                    () => selectedSubCategoryId = val ?? selectedSubCategoryId,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _submitTransaction,
                  child: const Text('Ekle'),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Son İşlemler:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: mockTransactions.length,
                itemBuilder: (context, index) {
                  final tx = mockTransactions[index];
                  final isIncome = tx['type'] == 'gelir';
                  final color = isIncome ? Colors.green : Colors.red;
                  final prefix = isIncome ? '+' : '-';

                  final categoryName = categoryList
                      .firstWhere(
                        (c) => c.id == tx['category_id'],
                        orElse: () => Category(
                          id: 0,
                          name: 'Tanımsız',
                          type: CategoryType.gelir,
                          subcategories: [],
                        ),
                      )
                      .name;
                  final subCategoryName = categoryList
                      .expand((c) => c.subcategories)
                      .firstWhere(
                        (s) => s.subId == tx['subcategory_id'],
                        orElse: () => SubCategory(subId: 0, name: 'Tanımsız'),
                      )
                      .name;

                  return ListTile(
                    title: Text(
                      '$prefix ${tx['amount'].toStringAsFixed(2)} TL (${tx['method']})',
                      style: TextStyle(color: color),
                    ),
                    subtitle: Text(
                      '${tx['date'].day}/${tx['date'].month}/${tx['date'].year} • $categoryName > $subCategoryName',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
