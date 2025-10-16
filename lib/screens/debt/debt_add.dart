import 'package:flutter/material.dart';
import 'package:mybudget/core/database_helper.dart';

class DebtAddPage extends StatefulWidget {
  const DebtAddPage({super.key});

  @override
  State<DebtAddPage> createState() => _DebtAddPageState();
}

class _DebtAddPageState extends State<DebtAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _installmentController = TextEditingController();
  final _paidInstallmentsController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'Kredi';
  DateTime? _firstDueDate;

  void _submitDebt() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_firstDueDate == null) {
      return;
    }

    final totalAmount = double.parse(_amountController.text);
    final installmentCount = int.parse(_installmentController.text);
    final monthlyAmount = double.parse(
      (totalAmount / installmentCount).toStringAsFixed(2),
    );

    final debt = {
      'name': _nameController.text.trim(),
      'type': _selectedType,
      'amount': totalAmount,
      'installments': installmentCount,
      'description': _descriptionController.text.trim(),
      'first_due': _firstDueDate!.toIso8601String(),
    };

    final db = DatabaseHelper();
    final debtId = await db.insertDebt(debt);

    final paidCount = int.tryParse(_paidInstallmentsController.text) ?? 0;
    final schedule = <Map<String, dynamic>>[];
    DateTime due = _firstDueDate!;

    for (int i = 0; i < installmentCount; i++) {
      final isPaid = i < paidCount ? 1 : 0;
      schedule.add({
        'debt_id': debtId,
        'due': due.toIso8601String(),
        'amount': monthlyAmount,
        'is_paid': isPaid,
      });
      due = DateTime(due.year, due.month + 1, due.day);
    }

    await db.insertDebtSchedule(schedule);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Borç başarıyla eklendi')));

    _nameController.clear();
    _amountController.clear();
    _installmentController.clear();
    _paidInstallmentsController.clear();
    _descriptionController.clear();
    setState(() => _firstDueDate = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Borç Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Borç Adı'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                items: ['Kredi', 'Nakit', 'Kredi Kartı']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
                decoration: const InputDecoration(labelText: 'Borç Türü'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Toplam Tutar (TL)',
                ),
                validator: (val) {
                  final num = double.tryParse(val ?? '');
                  if (num == null || num <= 0) return 'Pozitif değer girin';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _installmentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Taksit Sayısı'),
                validator: (val) {
                  final num = int.tryParse(val ?? '');
                  if (num == null || num <= 0) return 'Geçerli sayı girin';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _paidInstallmentsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ödenmiş Taksit Sayısı (geçmiş)',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return null;
                  final num = int.tryParse(val);
                  final total = int.tryParse(_installmentController.text) ?? 0;
                  if (num == null || num < 0) return 'Geçerli sayı girin';
                  if (total > 0 && num > total) {
                    return 'Ödenmiş taksit sayısı toplamdan büyük olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (!mounted) return;
                  if (picked != null) {
                    setState(() => _firstDueDate = picked);
                  }
                },
                child: Text(
                  _firstDueDate == null
                      ? 'İlk Taksit Tarihi Seç'
                      : '${_firstDueDate!.day}/${_firstDueDate!.month}/${_firstDueDate!.year}',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (opsiyonel)',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitDebt,
                child: const Text('Borcu Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
