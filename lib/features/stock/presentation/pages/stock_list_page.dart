import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/stock/presentation/provider/category_provider.dart';
import 'package:restauran_menu/features/stock/presentation/provider/unit_provider.dart';
import 'package:restauran_menu/routes/name_route.dart';

import '../provider/stock_provider.dart';

class StockListPage extends StatelessWidget {
  const StockListPage({super.key});

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
          title: const Text('Daftar Stok'),
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.straighten),
          //     tooltip: 'Tambah Unit',
          //     onPressed: () =>
          //         Navigator.of(context).pushNamed(NameRoute.unitAddForm),
          //   ),
          //   IconButton(
          //     icon: const Icon(Icons.category),
          //     tooltip: 'Tambah Kategori',
          //     onPressed: () =>
          //         Navigator.of(context).pushNamed(NameRoute.categoryAddForm),
          //   ),
          // ],
        ),

        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () =>
              Navigator.of(context).pushNamed(NameRoute.stockAddForm),
        ),

        // ---------- BODY ----------
        body: Consumer3<StockProvider, CategoryProvider, UnitProvider>(
          builder: (context, provider, cProv, uProv, _) {
            switch (provider.status) {
              case StockStatus.loading:
                return const Center(child: CircularProgressIndicator());

              case StockStatus.error:
                return Center(child: Text('Error: ${provider.errorMessage}'));

              case StockStatus.loaded:
                // No data after applying filters
                if (provider.filteredItems.isEmpty) {
                  return const Center(child: Text('Tidak ada data yang cocok'));
                }

                // Search + Filter UI + List
                return Column(
                  children: [
                    // ----- SEARCH BAR -----
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (v) => provider.setSearch(v),
                      ),
                    ),

                    // ----- FILTER ROW (Category & Unit) -----
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Category filter (placeholder – replace with real data later)
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Kategori',
                              ),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('Semua'),
                                ),
                                ...cProv.categories.map(
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  ),
                                ),
                              ],
                              initialValue: provider.selectedCategoryId,
                              onChanged: (v) => provider.setCategory(v),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Unit filter (placeholder – replace with real data later)
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                              ),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('Semua'),
                                ),
                                ...uProv.units.map(
                                  (u) => DropdownMenuItem(
                                    value: u.id,
                                    child: Text(u.name),
                                  ),
                                ),
                              ],
                              initialValue: provider.selectedUnitId,
                              onChanged: (v) => provider.setUnit(v),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ----- LIST OF STOCKS -----
                    Expanded(
                      child: ListView.builder(
                        itemCount: provider.filteredItems.length,
                        itemBuilder: (c, i) => ListTile(
                          title: Text(
                            '#${provider.filteredItems[i].id ?? '-'} – ${provider.filteredItems[i].name}',
                          ),
                          subtitle: Text(
                            'Category: ${cProv.getCategoriById(provider.filteredItems[i].categoryId!)!.name}, '
                            'UOM: ${uProv.getUnitById(provider.filteredItems[i].unitId)!.name}, '
                            'Stok: ${provider.filteredItems[i].currentStock} '
                            '(Min: ${provider.filteredItems[i].minimumStock})',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // EDIT
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    Navigator.of(context).pushNamed(
                                      NameRoute.stockAddForm,
                                      arguments: provider.filteredItems[i],
                                    ),
                              ),
                              // DELETE
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('Hapus Stok'),
                                      content: Text(
                                        'Yakin ingin menghapus ${provider.filteredItems[i].name}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(c, false),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(c, true),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true &&
                                      provider.filteredItems[i].id != null) {
                                    await provider.removeItem(
                                      provider.filteredItems[i].id!,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );

              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
