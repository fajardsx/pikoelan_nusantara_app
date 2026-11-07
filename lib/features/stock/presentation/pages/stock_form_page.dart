import 'package:flutter/material.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/services/app_log.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';

import '../../data/models/stock_item_dto.dart';
import '../../domain/entities/stock_item.dart';
import '../provider/stock_provider.dart';

class StockFormPage extends StatefulWidget {
  final StockItem? item;
  const StockFormPage({super.key, this.item});

  @override
  _StockFormPageState createState() => _StockFormPageState();
}

class _StockFormPageState extends State<StockFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  int? _categoryId;
  late int _unitId;
  String? _sku;
  String? _description;
  double _currentStock = 0;
  double _minimumStock = 0;
  double? _costPrice;
  String? _supplier;
  String? _notes;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _name = widget.item!.name;
      _categoryId = widget.item!.categoryId;
      _unitId = widget.item!.unitId;
      _sku = widget.item!.sku;
      _description = widget.item!.description;
      _currentStock = widget.item!.currentStock;
      _minimumStock = widget.item!.minimumStock;
      _costPrice = widget.item!.costPrice;
      _supplier = widget.item!.supplier;
      _notes = widget.item!.notes;
    } else {
      _name = '';
      _unitId = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = sl<StockProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Tambah Stok' : 'Ubah Stok'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                onSaved: (v) => _name = v!.trim(),
              ),
              TextFormField(
                initialValue: _unitId > 0 ? _unitId.toString() : '',
                decoration: const InputDecoration(labelText: 'Unit ID'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null
                    ? 'Nomor unit wajib'
                    : null,
                onSaved: (v) => _unitId = int.parse(v!),
              ),
              TextFormField(
                initialValue: _currentStock.toString(),
                decoration: const InputDecoration(labelText: 'Stok Saat Ini'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onSaved: (v) => _currentStock = double.parse(v!),
              ),
              TextFormField(
                initialValue: _minimumStock.toString(),
                decoration: const InputDecoration(labelText: 'Stok Minimum'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onSaved: (v) => _minimumStock = double.parse(v!),
              ),
              TextFormField(
                initialValue: _categoryId?.toString() ?? '',
                decoration: const InputDecoration(labelText: 'Kategori ID'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _categoryId = v != null && v.isNotEmpty ? int.tryParse(v) : null,
              ),
              TextFormField(
                initialValue: _sku ?? '',
                decoration: const InputDecoration(labelText: 'SKU'),
                onSaved: (v) => _sku = v?.trim().isEmpty ?? true ? null : v!.trim(),
              ),
              TextFormField(
                initialValue: _description ?? '',
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                onSaved: (v) => _description = v?.trim().isEmpty ?? true ? null : v!.trim(),
              ),
              TextFormField(
                initialValue: _costPrice?.toString() ?? '',
                decoration: const InputDecoration(labelText: 'Harga Pokok'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onSaved: (v) => _costPrice = v != null && v.isNotEmpty ? double.tryParse(v) : null,
              ),
              TextFormField(
                initialValue: _supplier ?? '',
                decoration: const InputDecoration(labelText: 'Supplier'),
                onSaved: (v) => _supplier = v?.trim().isEmpty ?? true ? null : v!.trim(),
              ),
              TextFormField(
                initialValue: _notes ?? '',
                decoration: const InputDecoration(labelText: 'Catatan'),
                onSaved: (v) => _notes = v?.trim().isEmpty ?? true ? null : v!.trim(),
              ),

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
    try {
      final user = sl<AuthProvider>().user;
      final dto = StockItemDto(
        tenantId: user!.tenantId!,
        categoryId: _categoryId,
        unitId: _unitId,
        sku: _sku,
        name: _name,
        description: _description,
        currentStock: _currentStock,
        minimumStock: _minimumStock,
        costPrice: _costPrice,
        supplier: _supplier,
        notes: _notes,
        isActive: true,
      );
      final provider = sl<StockProvider>();
      bool success;
      if (widget.item == null) {
        success = await provider.addItem(dto);
      } else {
        success = await provider.editItem(widget.item!.id!, dto);
      }
      if (success) Navigator.of(context).pop();
    } catch (e, s) {
      AppLog.instance.logError("Gagal buat stok", e, s);
    }
  }
}
