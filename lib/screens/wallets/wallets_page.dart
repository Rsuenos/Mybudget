import 'package:flutter/material.dart';
import 'package:mybudget/core/database_helper.dart';

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  List<Map<String, dynamic>> wallets = [];

  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    wallets = await DatabaseHelper().getWallets();
    if (!mounted) return;
    setState(() {});
  }

  double get totalCash =>
      wallets.fold(0.0, (p, w) => p + (w['balance'] as num).toDouble());

  Future<void> _addWallet() async {
    final name = _nameController.text.trim();
    final bal = double.tryParse(_balanceController.text) ?? 0.0;
    if (name.isEmpty) return;
    await DatabaseHelper().insertWallet({'name': name, 'balance': bal});
    _nameController.clear();
    _balanceController.clear();
    await _loadWallets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kasalar / Bakiye')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Toplam Nakit: ${totalCash.toStringAsFixed(2)} TL',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: wallets.length,
                itemBuilder: (context, index) {
                  final w = wallets[index];
                  return ListTile(
                    title: Text(w['name']),
                    trailing: Text(
                      '${(w['balance'] as num).toDouble().toStringAsFixed(2)} TL',
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Kasa Adı'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Başlangıç Bakiye'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addWallet,
              child: const Text('Kasa Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
