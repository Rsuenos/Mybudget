import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:mybudget/core/database_helper.dart';

class CreditCardAddPage extends StatefulWidget {
  const CreditCardAddPage({super.key});

  @override
  State<CreditCardAddPage> createState() => _CreditCardAddPageState();
}

class _CreditCardAddPageState extends State<CreditCardAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _bankController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _limitController = TextEditingController();
  final _currentBalanceController = TextEditingController();
  final _upcomingAmountController = TextEditingController();
  DateTime? _statementDate;
  DateTime? _dueDate;
  String _selectedType = 'VISA';

  @override
  void dispose() {
    _bankController.dispose();
    _cardNameController.dispose();
    _limitController.dispose();
    _currentBalanceController.dispose();
    _upcomingAmountController.dispose();
    super.dispose();
  }

  Future<void> _submitCard() async {
    if (!_formKey.currentState!.validate()) return;
    if (_statementDate == null || _dueDate == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen tarihleri seçin')));
      return;
    }

    final uuid = const Uuid().v4();
    final card = {
      'id': uuid,
      'bank': _bankController.text.trim(),
      'name': _cardNameController.text.trim(),
      'type': _selectedType,
      'card_limit': double.tryParse(_limitController.text) ?? 0.0,
      'current_balance': double.tryParse(_currentBalanceController.text) ?? 0.0,
      'upcoming_amount': double.tryParse(_upcomingAmountController.text) ?? 0.0,
      'statement_date': _statementDate!.toIso8601String(),
      'due_date': _dueDate!.toIso8601String(),
    };

    await DatabaseHelper().insertCreditCard(card);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Kart başarıyla eklendi')));

    // clear fields and close
    _bankController.clear();
    _cardNameController.clear();
    _limitController.clear();
    _currentBalanceController.clear();
    _upcomingAmountController.clear();
    setState(() {
      _statementDate = null;
      _dueDate = null;
    });

    Navigator.of(context).pop(true);
  }

  Future<void> _pickStatementDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (!mounted) return;
    if (picked != null) setState(() => _statementDate = picked);
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (!mounted) return;
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kredi Kartı Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _cardNameController,
                decoration: const InputDecoration(labelText: 'Kart Adı'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bankController,
                decoration: const InputDecoration(labelText: 'Banka Adı'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                items: ['VISA', 'MASTERCARD', 'TROY']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
                decoration: const InputDecoration(labelText: 'Kart Türü'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _limitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kart Limiti'),
                validator: (val) {
                  final num = double.tryParse(val ?? '');
                  if (num == null || num <= 0) return 'Pozitif değer girin';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _currentBalanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Güncel Borç (opsiyonel)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _upcomingAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Gelecek Taksitler Toplamı (opsiyonel)',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickStatementDate,
                      child: Text(
                        _statementDate == null
                            ? 'Hesap Kesim Tarihi Seç'
                            : '${_statementDate!.day}/${_statementDate!.month}/${_statementDate!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickDueDate,
                      child: Text(
                        _dueDate == null
                            ? 'Son Ödeme Tarihi Seç'
                            : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitCard,
                child: const Text('Kartı Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
