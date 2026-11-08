import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/themes/app_fonts.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/stock/domain/entities/category.dart';
import 'package:restauran_menu/features/stock/domain/entities/stock_item.dart';
import 'package:restauran_menu/features/stock/domain/entities/stock_movement.dart';
import 'package:restauran_menu/features/stock/domain/entities/unit.dart';
import 'package:restauran_menu/routes/name_route.dart';
import 'package:restauran_menu/shared/utils/date_time_formatter.dart';

import '../provider/category_provider.dart';
import '../provider/stock_movement_provider.dart';
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

  // late StockProvider _sProvider;
  // late CategoryProvider _cProvider;
  // late UnitProvider _uProvider;

  @override
  void initState() {
    super.initState();
    // initial load handled by providers in MultiProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().load();
      context.read<CategoryProvider>().load();
      context.read<UnitProvider>().load();
      context.read<StockMovementProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<StockProvider>()..load()),
        ChangeNotifierProvider(create: (_) => sl<CategoryProvider>()..load()),
        ChangeNotifierProvider(create: (_) => sl<UnitProvider>()..load()),
        ChangeNotifierProvider(
          create: (_) => sl<StockMovementProvider>()..load(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stock'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Stock Refresh',
              onPressed: () async {
                //await Navigator.pushNamed(context, NameRoute.stockMovementList);
                await sl<StockProvider>().load();
                await sl<CategoryProvider>().load();
                await sl<UnitProvider>().load();
              },
            ),
            IconButton(
              icon: const Icon(Icons.moving),
              tooltip: 'Stock Movement',
              onPressed: () async {
                await Navigator.pushNamed(context, NameRoute.stockMovementList);
                //await context.read<StockProvider>().load();
              },
            ),
            IconButton(
              icon: const Icon(Icons.list),
              tooltip: 'Stock List',
              onPressed: () async {
                await Navigator.pushNamed(context, NameRoute.stockList);
                //await sl<StockProvider>().load();
              },
            ),
            IconButton(
              icon: const Icon(Icons.straighten),
              tooltip: 'Unit List',
              onPressed: () async {
                await Navigator.of(context).pushNamed(NameRoute.stockUnitsList);
                //await sl<UnitProvider>().load();
              },
            ),
            IconButton(
              icon: const Icon(Icons.category),
              tooltip: 'Kategori List',
              onPressed: () async {
                await Navigator.of(
                  context,
                ).pushNamed(NameRoute.stockCategoryList);
                //await sl<CategoryProvider>().load();
              },
            ),
          ],
        ),
        body:
            Consumer4<
              StockProvider,
              CategoryProvider,
              UnitProvider,
              StockMovementProvider
            >(
              builder: (context, sProv, cProv, uProv, smProv, _) {
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
                    Text('Stok :', style: appFonts.bodyLarge.bold.ts),
                    const SizedBox(height: 10),
                    buildStockTable(sProv, items, uProv, cProv),
                    const SizedBox(height: 20),
                    Text(
                      'Pergerakan Stok :',
                      style: appFonts.bodyLarge.bold.ts,
                    ),
                    const SizedBox(height: 10),
                    buildStockMovementTable(smProv),
                  ],
                );
              },
            ),
      ),
    );
  }

  Widget buildStockTable(
    StockProvider sProv,
    List<StockItem> items,
    UnitProvider uProv,
    CategoryProvider cProv,
  ) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Table(
          border: TableBorder.all(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
            3: IntrinsicColumnWidth(),
            4: IntrinsicColumnWidth(),
            5: IntrinsicColumnWidth(),
            6: FlexColumnWidth(),
            7: IntrinsicColumnWidth(),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: RestaurantColors.primaryBrown),
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
                    textAlign: TextAlign.center,
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
                    textAlign: TextAlign.center,
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
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Min Stok',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Last Update',
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
                    textAlign: TextAlign.center,
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
                      child: Text(categoryName, textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(unitName.name, textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '${i.currentStock.toString()} (${unitName.symbol})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: i.currentStock > i.minimumStock
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '${i.minimumStock.toString()} (${unitName.symbol})',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(formatDateTime(i.updatedAt!.toLocal())),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        i.isActive ? Icons.check_circle : Icons.cancel,
                        color: i.isActive ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget buildStockMovementTable(StockMovementProvider smProv) {
    if (smProv.status == StockMovementStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (smProv.filteredMovements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Belum ada data pergerakan stok'),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Table(
          border: TableBorder.all(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
            2: IntrinsicColumnWidth(),
            3: IntrinsicColumnWidth(),
            4: IntrinsicColumnWidth(),
            5: FlexColumnWidth(),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: RestaurantColors.primaryBrown),
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
                    'Item',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Tipe',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Alasan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Tanggal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            ...smProv.filteredMovements.map((m) {
              final isIn = m.type == StockMovementType.stockIn;
              final isOut = m.type == StockMovementType.stockOut;
              final color = isIn
                  ? Colors.green
                  : (isOut ? Colors.red : Colors.orange);
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(m.id?.toString() ?? '-'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(m.stockItemName ?? 'Item #${m.stockItemId}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      m.type.value.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      m.reason.value.toUpperCase(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '${isIn ? '+' : (isOut ? '-' : '')}${m.quantity}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      m.createdAt != null
                          ? formatDateTime(m.createdAt!.toLocal())
                          : '-',
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
