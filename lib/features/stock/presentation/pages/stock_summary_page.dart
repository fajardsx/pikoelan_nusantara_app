import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/themes/app_fonts.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/stock/domain/entities/category.dart';
import 'package:restauran_menu/features/stock/domain/entities/unit.dart';
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
              tooltip: 'Stock List',
              onPressed: () async {
                await Navigator.pushNamed(context, NameRoute.stockList);
                await sl<StockProvider>().load();
              },
            ),
            IconButton(
              icon: const Icon(Icons.straighten),
              tooltip: 'Unit List',
              onPressed: () async {
                await Navigator.of(context).pushNamed(NameRoute.stockUnitsList);
                await sl<UnitProvider>().load();
              },
            ),
            IconButton(
              icon: const Icon(Icons.category),
              tooltip: 'Kategori List',
              onPressed: () async {
                await Navigator.of(
                  context,
                ).pushNamed(NameRoute.stockCategoryList);
                await sl<CategoryProvider>().load();
              },
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
                // Row(
                //   children: [
                //     _card('Total', '${items.length}', Colors.blue),
                //     const SizedBox(width: 8),
                //     _card(
                //       'Rendah',
                //       '${items.where((i) => i.currentStock <= i.minimumStock).length}',
                //       Colors.orange,
                //     ),
                //   ],
                // ),
                const SizedBox(height: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Cari..',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _q = v),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
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
                Text('Daftar Stok :', style: appFonts.bodyLarge.bold.ts),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Table(
                      border: TableBorder.all(),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(),
                        2: FlexColumnWidth(),
                        3: FlexColumnWidth(),
                        4: FlexColumnWidth(),
                        5: FlexColumnWidth(),
                      },
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(
                            color: RestaurantColors.primaryBrown,
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'ID',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Nama',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Kategori',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'UOM',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Stok',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Active',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (sProv.status == StockStatus.loaded)
                          ...items.map((i) {
                            final unitName = uProv.units.firstWhere(
                              (u) => u.id == i.unitId,
                              orElse: () => Unit(id: 0, name: '-'),
                            );
                            final categoryName = cProv.categories
                                .firstWhere(
                                  (u) => u.id == i.categoryId,
                                  orElse: () => Category(id: 0, name: '-'),
                                )
                                .name;
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(i.id?.toString() ?? '-'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(i.name),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(categoryName),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(unitName.name),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    i.currentStock.toString(),
                                    style: TextStyle(
                                      color: i.currentStock > i.minimumStock
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    i.isActive
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: i.isActive
                                        ? Colors.green
                                        : Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ],
                            );
                          }),
                      ],
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
