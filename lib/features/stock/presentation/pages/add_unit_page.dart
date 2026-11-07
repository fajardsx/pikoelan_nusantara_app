import 'package:flutter/material.dart';
import 'package:restauran_menu/core/di/injector.dart';

import '../../data/models/stock_unit_dto.dart';
import '../provider/unit_provider.dart';

class AddUnitPage extends StatefulWidget {
  const AddUnitPage({super.key});

  @override
  State<AddUnitPage> createState() => _AddUnitPageState();
}

class _AddUnitPageState extends State<AddUnitPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String? _symbol;
  double? _conversionFactor;
  String? _baseUnit;
  String? _description;

  @override
  Widget build(BuildContext context) {
    final provider = sl<UnitProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Unit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nama Unit'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                onSaved: (v) => _name = v!.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Simbol'),
                onSaved: (v) => _symbol = v?.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Faktor Konversi'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onSaved: (v) => _conversionFactor = v != null ? double.tryParse(v) : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Unit Dasar'),
                onSaved: (v) => _baseUnit = v?.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                onSaved: (v) => _description = v?.trim(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: provider.isSubmitting ? null : _submit,
                child: const Text('Simpan'),
              ),
              if (provider.submitError != null)
                Text(
                  provider.submitError!,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final provider = sl<UnitProvider>();
    final dto = StockUnitDto(
      name: _name,
      symbol: _symbol,
      conversionFactor: _conversionFactor,
      baseUnit: _baseUnit,
      description: _description,
    );
    final success = await provider.addUnit(dto);
    if (success && mounted) Navigator.of(context).pop();
  }
}

