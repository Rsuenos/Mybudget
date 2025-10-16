import 'package:flutter/material.dart';
import 'package:mybudget/widgets/app_drawer.dart';
import 'package:mybudget/core/database_helper.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  double totalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final wallets = await DatabaseHelper().getWallets();
    final total = wallets.fold<double>(
      0.0,
      (prev, w) => prev + ((w['balance'] as num).toDouble()),
    );
    if (!mounted) return;
    setState(() => totalBalance = total);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('MYBudget')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Hoş geldin 👋', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              'Bütçeni hızlıca gör ve işlemlerini kaydetmeye başla.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Toplam Nakit', style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Text(
                          '${totalBalance.toStringAsFixed(2)} TL',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.account_balance_wallet,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Text(
                  'Sol üst menüden işlem eklemeye başlayabilirsiniz.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
