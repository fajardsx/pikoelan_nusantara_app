import 'package:flutter/material.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/stock/domain/entities/unit.dart';

import '../../data/models/stock_unit_dto.dart';
import '../provider/unit_provider.dart';

class AddUnitPage extends StatefulWidget {
  final Unit? unit;
  const AddUnitPage({super.key, this.unit});

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
  void initState() {
    super.initState();
    if (widget.unit != null) {
      _name = widget.unit!.name;
      _symbol = widget.unit!.symbol;
      _conversionFactor = widget.unit!.conversionFactor;
      _baseUnit = widget.unit!.baseUnit;
      _description = widget.unit!.description;
    } else {
      _name = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = sl<UnitProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unit == null ? 'Tambah Unit' : 'Ubah Unit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nama Unit'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                onSaved: (v) => _name = v!.trim(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _symbol,
                decoration: const InputDecoration(labelText: 'Simbol'),
                onSaved: (v) => _symbol = v?.trim(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _conversionFactor.toString(),
                decoration: const InputDecoration(labelText: 'Faktor Konversi'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onSaved: (v) =>
                    _conversionFactor = v != null ? double.tryParse(v) : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _baseUnit,
                decoration: const InputDecoration(labelText: 'Unit Dasar'),
                onSaved: (v) => _baseUnit = v?.trim(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _description,
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
