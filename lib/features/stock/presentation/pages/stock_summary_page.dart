import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/routes/name_route.dart';

import '../provider/category_provider.dart';
import '../provider/stock_provider.dart';
import '../provider/unit_provider.dart';

class StockSummaryPage extends StatefulWidget {
  const StockSummaryPage({super.key});
  @override
  State<StockSummaryPage> createState() => _StockSummaryPageState();
}

class _StockSummaryPageState extends State<StockSummaryPage> {
  String _q = '';
  int? _catId, _unitId;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<StockProvider>()..load()),
        ChangeNotifierProvider(create: (_) => sl<CategoryProvider>()..load()),
        ChangeNotifierProvider(create: (_) => sl<UnitProvider>()..load()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ringkasan Stock'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () =>
                  Navigator.pushNamed(context, NameRoute.stockList),
            ),
          ],
        ),
        body: Consumer3<StockProvider, CategoryProvider, UnitProvider>(
          builder: (context, sProv, cProv, uProv, _) {
            if (sProv.status != StockStatus.loaded) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = sProv.items.where((i) {
              final m = i.name.toLowerCase().contains(_q.toLowerCase());
              return m &&
                  (_catId == null || i.categoryId == _catId) &&
                  (_unitId == null || i.unitId == _unitId);
            }).toList();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    _card('Total', '${items.length}', Colors.blue),
                    const SizedBox(width: 8),
                    _card(
                      'Rendah',
                      '${items.where((i) => i.currentStock <= i.minimumStock).length}',
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Cari..',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => setState(() => _q = v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<int?>(
                        initialValue: _catId,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Kategori'),
                          ),
                          ...cProv.categories.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _catId = v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<int?>(
                        initialValue: _unitId,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Unit'),
                          ),
                          ...uProv.units.map(
                            (u) => DropdownMenuItem(
                              value: u.id,
                              child: Text(u.name),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _unitId = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('List Stok:'),
                const SizedBox(height: 10),
                ...items.map(
                  (i) => Card(
                    child: ListTile(
                      title: Text(i.name),
                      subtitle: Text('Stok: ${i.currentStock}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          NameRoute.stockAddForm,
                          arguments: i,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _card(String t, String v, Color c) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(t),
          Text(
            v,
            style: TextStyle(fontWeight: FontWeight.bold, color: c),
          ),
        ],
      ),
    ),
  );
}
