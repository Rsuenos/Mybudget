import 'package:flutter/material.dart';
import 'package:mybudget/screens/transaction/transaction_list.dart';
import 'package:mybudget/screens/transaction/income_list.dart';
import 'package:mybudget/screens/transaction/expense_list.dart';
import 'package:mybudget/screens/transaction/input_finances.dart';
import 'package:mybudget/screens/credit_card/credit_card_list.dart';
import 'package:mybudget/screens/debt/debt_list.dart';
import 'package:mybudget/screens/wallets/wallets_page.dart';
import 'package:mybudget/screens/report/summary_report.dart';
import 'package:mybudget/screens/report/spending_distribution_report.dart';
import 'package:mybudget/screens/settings/settings_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {
        'title': 'İşlem Listesi',
        'page': const TransactionListPage(),
        'group': '💸 İşlemler',
      },
      {
        'title': 'Gelirler',
        'page': const IncomeListPage(),
        'group': '💸 İşlemler',
      },
      {
        'title': 'Giderler',
        'page': const ExpenseListPage(),
        'group': '💸 İşlemler',
      },
      {
        'title': 'İşlem Ekle',
        'page': const InputFinancesPage(),
        'group': '💸 İşlemler',
      },
      {
        'title': 'Özet Rapor',
        'page': const SummaryReportPage(),
        'group': '📊 Raporlar',
      },
      {
        'title': 'Harcama Dağılımı',
        'page': const SpendingDistributionReportPage(),
        'group': '📊 Raporlar',
      },
      {
        'title': 'Kartlar',
        'page': const CreditCardListPage(),
        'group': '💳 Kredi Kartları',
      },
      {'title': 'Borçlar', 'page': const DebtListPage(), 'group': '📆 Borçlar'},
      {'title': 'Kasalar', 'page': const WalletsPage(), 'group': '🏦 Kasa'},
      {'title': 'Ayarlar', 'page': const SettingsPage(), 'group': '⚙️ Ayarlar'},
    ];

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var item in menuItems) {
      final String group = item['group'] as String;
      grouped.putIfAbsent(group, () => []).add(item);
    }

    return Drawer(
      child: Column(
        children: [
          // Compact header: reduce vertical space while keeping branding
          Container(
            height: 80,
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Menü',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 0, bottom: 80),
              children: [
                ...grouped.entries.expand(
                  (entry) => [
                    ListTile(
                      title: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...entry.value.map(
                      (item) => ListTile(
                        title: Text(item['title']),
                        onTap: () {
                          Navigator.pop(context);
                          if (item['title'] == 'Ayarlar') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsPage(),
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => item['page']),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: const [
                Text(
                  'Created by Bünyamin',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
