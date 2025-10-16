import 'package:flutter/material.dart';
import 'package:mybudget/widgets/app_drawer.dart';
import 'package:mybudget/core/finance_group.dart';
import 'package:mybudget/core/database_helper.dart';

class Transaction {
  final int? id;
  final DateTime date;
  final double amount;
  final CategoryType type;
  final String method;
  final int categoryId;
  final int subCategoryId;

  Transaction({
    this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.method,
    required this.categoryId,
    required this.subCategoryId,
  });
}

class InputFinancesPage extends StatefulWidget {
  const InputFinancesPage({super.key});

  @override
  State<InputFinancesPage> createState() => _InputFinancesPageState();
}

class _InputFinancesPageState extends State<InputFinancesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Transaction> transactions = [];

  final _amountController = TextEditingController();
  DateTime? selectedDate;
  String selectedMethod = 'nakit';

  // Use primitive ids for category/subcategory to avoid object equality issues
  int selectedCategoryId = categoryList
      .firstWhere((c) => c.type == CategoryType.gelir)
      .id;
  int selectedSubCategoryId = categoryList
      .firstWhere((c) => c.type == CategoryType.gelir)
      .subcategories
      .first
      .subId;

  final List<String> paymentMethods = [
    'nakit',
    'kredi kartı',
    'kredi',
    'havale/eft',
  ];

  List<Category> get currentCategoryOptions => _tabController.index == 0
      ? categoryList.where((c) => c.type == CategoryType.gelir).toList()
      : categoryList.where((c) => c.type == CategoryType.gider).toList();

  List<Map<String, dynamic>> wallets = [];
  Map<String, dynamic>? selectedWallet;
  int? selectedWalletId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWallets();
  }

  void _onTransactionLongPress(Transaction tx, int index) async {
    if (tx.id == null) return; // safety

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Düzenle'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _showEditTransactionDialog(tx, index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Sil', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirmed =
                      await showDialog<bool>(
                        context: context,
                        builder: (dctx) => AlertDialog(
                          title: const Text('İşlemi sil'),
                          content: const Text(
                            'Bu işlemi silmek istediğinize emin misiniz?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dctx).pop(false),
                              child: const Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(dctx).pop(true),
                              child: const Text('Sil'),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (confirmed) {
                    await DatabaseHelper().deleteTransaction(tx.id!);
                    if (!mounted) return;
                    setState(() {
                      transactions.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('İşlem silindi')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditTransactionDialog(Transaction tx, int index) async {
    final amountController = TextEditingController(text: tx.amount.toString());
    String method = tx.method;

    final res = await showDialog<bool>(
      context: context,
      builder: (dctx) {
        return AlertDialog(
          title: const Text('İşlemi düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tutar'),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: method,
                items: paymentMethods
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => method = v ?? method,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dctx).pop(true);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );

    if (res == true) {
      final normalized = amountController.text.trim().replaceAll(',', '.');
      final newAmount = double.tryParse(normalized);
      if (newAmount == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Geçersiz tutar')));
        return;
      }

      final values = {'amount': newAmount, 'method': method};

      await DatabaseHelper().updateTransaction(tx.id!, values);
      if (!mounted) return;
      setState(() {
        transactions[index] = Transaction(
          id: tx.id,
          date: tx.date,
          amount: newAmount,
          type: tx.type,
          method: method,
          categoryId: tx.categoryId,
          subCategoryId: tx.subCategoryId,
        );
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('İşlem güncellendi')));
    }
  }

  Future<void> _loadWallets() async {
    wallets = await DatabaseHelper().getWallets();
    if (!mounted) return;
    setState(() {
      if (wallets.isNotEmpty) {
        selectedWallet = wallets.first;
        selectedWalletId = (wallets.first['id'] as num?)?.toInt();
      } else {
        selectedWallet = null;
        selectedWalletId = null;
      }
    });
  }

  Future<void> addTransaction() async {
    if (selectedDate == null || _amountController.text.isEmpty) return;

    final txMap = {
      'date': selectedDate!.toIso8601String(),
      'amount': double.parse(_amountController.text),
      'type': _tabController.index == 0 ? 'gelir' : 'gider',
      'method': selectedMethod,
      'category_id': selectedCategoryId,
      'subcategory_id': selectedSubCategoryId,
    };

    final newId = await DatabaseHelper().insertTransaction(txMap);
    if (!mounted) return;
    setState(() {
      transactions.insert(
        0,
        Transaction(
          id: newId,
          date: selectedDate!,
          amount: txMap['amount'] as double,
          type: _tabController.index == 0
              ? CategoryType.gelir
              : CategoryType.gider,
          method: selectedMethod,
          categoryId: selectedCategoryId,
          subCategoryId: selectedSubCategoryId,
        ),
      );
      _amountController.clear();
      selectedDate = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('İşlem başarıyla kaydedildi.')),
    );
  }

  // New method to handle transaction addition with error handling
  Future<void> addTransactionWithValidation() async {
    if (selectedDate == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tarih ve tutar girin.')),
      );
      return;
    }

    // Güvenli parse: kullanıcı virgül girerse nokta ile değiştir
    final raw = _amountController.text.trim();
    final normalized = raw.replaceAll(',', '.');
    final amount = double.tryParse(normalized);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tutar geçersiz. Lütfen sayısal bir değer girin.'),
        ),
      );
      return;
    }

    final txMap = {
      'date': selectedDate!.toIso8601String(),
      'amount': amount,
      'type': _tabController.index == 0 ? 'gelir' : 'gider',
      'method': selectedMethod,
      'category_id': selectedCategoryId,
      'subcategory_id': selectedSubCategoryId,
      'wallet_id': selectedWalletId,
    };

    try {
      final newId = await DatabaseHelper().insertTransaction(txMap);

      if (!mounted) return;
      setState(() {
        transactions.insert(
          0,
          Transaction(
            id: newId,
            date: selectedDate!,
            amount: amount,
            type: _tabController.index == 0
                ? CategoryType.gelir
                : CategoryType.gider,
            method: selectedMethod,
            categoryId: selectedCategoryId,
            subCategoryId: selectedSubCategoryId,
          ),
        );
        _amountController.clear();
        selectedDate = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşlem başarıyla kaydedildi.')),
      );
    } catch (e, st) {
      // Hata olursa kullanıcıyı bilgilendir ve logla
      debugPrint('DB insert error: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kaydedilemedi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelir / Gider Ekle'),
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
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(12),
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
                    if (!mounted) return;
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                  child: Text(
                    selectedDate == null
                        ? 'Tarih Seç'
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Yöntem, Kategori, Alt Kategori - responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 700;
                final children = [
                  // Payment method
                  DropdownButton<String>(
                    value: selectedMethod,
                    isExpanded: true,
                    items: paymentMethods
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedMethod = val!),
                  ),
                  const SizedBox(width: 12, height: 12),
                  // Wallet selector - use id (int) as value to avoid Map equality issues
                  DropdownButtonFormField<int>(
                    initialValue: selectedWalletId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      hintText: 'Kasa seç (opsiyonel)',
                    ),
                    items: wallets
                        .map(
                          (w) => DropdownMenuItem<int>(
                            value: (w['id'] as num).toInt(),
                            child: Text(w['name'] ?? 'Kasa'),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedWalletId = val;
                        selectedWallet = val != null
                            ? wallets.firstWhere(
                                (w) => (w['id'] as num).toInt() == val,
                              )
                            : null;
                      });
                    },
                  ),
                  const SizedBox(width: 12, height: 12),
                  // Category (use id values)
                  DropdownButton<int>(
                    value: selectedCategoryId,
                    isExpanded: true,
                    items: currentCategoryOptions
                        .map(
                          (cat) => DropdownMenuItem<int>(
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
                  const SizedBox(width: 12, height: 12),
                  DropdownButton<int>(
                    value: selectedSubCategoryId,
                    isExpanded: true,
                    items:
                        (categoryList
                                .firstWhere((c) => c.id == selectedCategoryId)
                                .subcategories)
                            .map(
                              (sub) => DropdownMenuItem<int>(
                                value: sub.subId,
                                child: Text(sub.name),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(
                      () =>
                          selectedSubCategoryId = val ?? selectedSubCategoryId,
                    ),
                  ),
                  const SizedBox(width: 12, height: 12),
                  ElevatedButton(
                    onPressed: addTransactionWithValidation,
                    child: const Text('Ekle'),
                  ),
                ];

                if (isNarrow) {
                  // stack vertically with spacing
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children
                        .map(
                          (w) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: w,
                          ),
                        )
                        .toList(),
                  );
                }

                // wide: put them in a row with Expanded wrappers where appropriate
                return Row(
                  children: [
                    Expanded(child: children[0]),
                    const SizedBox(width: 12),
                    Expanded(child: children[2]),
                    const SizedBox(width: 12),
                    Expanded(child: children[4]),
                    const SizedBox(width: 12),
                    Expanded(child: children[6]),
                    const SizedBox(width: 12),
                    children[8],
                  ],
                );
              },
            ),
            const Divider(),
            // Son 5 İşlem
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length > 5 ? 5 : transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final color = tx.type == CategoryType.gelir
                      ? Colors.green
                      : Colors.red;
                  final prefix = tx.type == CategoryType.gelir ? '+' : '-';

                  final categoryName = categoryList
                      .firstWhere(
                        (c) => c.id == tx.categoryId,
                        orElse: () => Category(
                          id: 0,
                          name: 'Tanımsız',
                          type: tx.type,
                          subcategories: [],
                        ),
                      )
                      .name;
                  final subCategoryName = categoryList
                      .expand((c) => c.subcategories)
                      .firstWhere(
                        (s) => s.subId == tx.subCategoryId,
                        orElse: () => SubCategory(subId: 0, name: 'Tanımsız'),
                      )
                      .name;

                  // Wrap with GestureDetector to ensure onLongPress fires even if ListTile internal areas consume gestures
                  return GestureDetector(
                    key: ValueKey('tx_${tx.id ?? index}'),
                    behavior: HitTestBehavior.opaque,
                    onLongPress: () => _onTransactionLongPress(tx, index),
                    child: ListTile(
                      title: Text(
                        '$prefix ${tx.amount.toStringAsFixed(2)} TL (${tx.method})',
                        style: TextStyle(color: color),
                      ),
                      subtitle: Text(
                        '${tx.date.day}/${tx.date.month}/${tx.date.year} • $categoryName > $subCategoryName',
                      ),
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
