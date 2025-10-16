import 'package:flutter/material.dart';
import 'package:mybudget/core/database_helper.dart';
import 'credit_card_detail.dart';
import 'package:mybudget/widgets/app_drawer.dart';

class CreditCardListPage extends StatefulWidget {
  const CreditCardListPage({super.key});

  @override
  State<CreditCardListPage> createState() => _CreditCardListPageState();
}

class _CreditCardListPageState extends State<CreditCardListPage> {
  List<Map<String, dynamic>> cards = [];

  Future<void> _loadCards() async {
    final db = await DatabaseHelper().db;
    final result = await db.query('credit_cards', orderBy: 'bank ASC');
    setState(() {
      cards = result;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kredi Kartları')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: cards.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Henüz kart eklenmedi'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final res = await Navigator.pushNamed(
                          context,
                          '/credit_card_add',
                        );
                        if (res == true) _loadCards();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('Kart Ekle'),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  final limit = (card['card_limit'] as num).toDouble();

                  return ListTile(
                    title: Text('${card['name']} - ${card['bank']}'),
                    subtitle: Text('Limit: ${limit.toStringAsFixed(2)} TL'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreditCardDetailPage(
                            cardId: card['id'],
                            cardName: card['name'],
                            bankName: card['bank'],
                            totalLimit: limit,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.pushNamed(context, '/credit_card_add');
          if (res == true) _loadCards();
        },
        tooltip: 'Kart Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}
