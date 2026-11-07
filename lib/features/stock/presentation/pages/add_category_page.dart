import 'package:flutter/material.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/stock/domain/entities/category.dart';

import '../../data/models/stock_category_dto.dart';
import '../provider/category_provider.dart';

class AddCategoryPage extends StatefulWidget {
  final Category? cat;
  const AddCategoryPage({super.key, this.cat});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String? _description;

  @override
  void initState() {
    super.initState();
    if (widget.cat != null) {
      _name = widget.cat!.name;
      _description = widget.cat!.description;
    } else {
      _name = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = sl<CategoryProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kategori')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nama Kategori'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                onSaved: (v) => _name = v!.trim(),
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
    final provider = sl<CategoryProvider>();
    final dto = StockCategoryDto(name: _name, description: _description);
    final success = await provider.addCategory(dto);
    if (success && mounted) Navigator.of(context).pop();
  }
}
