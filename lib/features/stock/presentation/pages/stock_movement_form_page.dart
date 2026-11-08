import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';

import '../../data/models/stock_movement_dto.dart';
import '../../domain/entities/stock_item.dart';
import '../../domain/entities/stock_movement.dart';
import '../provider/stock_movement_provider.dart';
import '../provider/stock_provider.dart';

class StockMovementFormPage extends StatefulWidget {
  final StockItem? stockItem;
  const StockMovementFormPage({super.key, this.stockItem});

  @override
  State<StockMovementFormPage> createState() => _StockMovementFormPageState();
}

class _StockMovementFormPageState extends State<StockMovementFormPage> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedStockItemId;
  StockMovementType _selectedType = StockMovementType.stockIn;
  StockMovementReason _selectedReason = StockMovementReason.purchase;
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _refController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.stockItem != null) _selectedStockItemId = widget.stockItem!.id;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitCostController.dispose();
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<StockMovementProvider>()),
        ChangeNotifierProvider.value(value: sl<StockProvider>()..load()),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Catat Pergerakan Stok')),
        body: Consumer2<StockMovementProvider, StockProvider>(
          builder: (context, provider, stockProv, _) {
            if (_selectedStockItemId == null && stockProv.items.isNotEmpty) {
              _selectedStockItemId = stockProv.items.first.id;
            }
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (widget.stockItem == null)
                    DropdownButtonFormField<int>(
                      initialValue: _selectedStockItemId,
                      decoration: const InputDecoration(
                        labelText: 'Stock Item',
                      ),
                      items: stockProv.items
                          .map(
                            (i) => DropdownMenuItem(
                              value: i.id,
                              child: Text(i.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedStockItemId = v),
                    ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<StockMovementType>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(labelText: 'Tipe'),
                    items: StockMovementType.values
                        .map(
                          (t) =>
                              DropdownMenuItem(value: t, child: Text(t.value)),
                        )
                        .toList(),
                    onChanged: (v) =>
                        v != null ? setState(() => _selectedType = v) : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<StockMovementReason>(
                    initialValue: _selectedReason,
                    decoration: const InputDecoration(labelText: 'Alasan'),
                    items: StockMovementReason.values
                        .map(
                          (r) =>
                              DropdownMenuItem(value: r, child: Text(r.value)),
                        )
                        .toList(),
                    onChanged: (v) =>
                        v != null ? setState(() => _selectedReason = v) : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _unitCostController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Unit Cost'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _refController,
                    decoration: const InputDecoration(
                      labelText: 'Reference Number',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          _selectedStockItemId != null) {
                        final dto = StockMovementDto(
                          stockItemId: _selectedStockItemId!,
                          type: _selectedType,
                          reason: _selectedReason,
                          quantity: double.parse(_quantityController.text),
                          unitCost: double.tryParse(_unitCostController.text),
                          referenceNumber: _refController.text,
                          notes: _notesController.text,
                          movementDate: DateTime.now(),
                        );
                        if (await provider.addMovement(dto) &&
                            context.mounted) {
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
