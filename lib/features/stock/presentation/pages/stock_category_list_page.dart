import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/themes/app_fonts.dart';
import 'package:restauran_menu/routes/name_route.dart';

import '../provider/category_provider.dart';

class StockCategoryListPage extends StatefulWidget {
  const StockCategoryListPage({super.key});

  @override
  _StockCategoryListPageState createState() => _StockCategoryListPageState();
}

class _StockCategoryListPageState extends State<StockCategoryListPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<CategoryProvider>()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Kategori'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Tambah Kategori',
              onPressed: () async {
                await Navigator.of(
                  context,
                ).pushNamed(NameRoute.categoryAddForm);
                await sl<CategoryProvider>().load();
              },
            ),
          ],
        ),
        body: Consumer<CategoryProvider>(
          builder: (context, provider, _) {
            switch (provider.status) {
              case CategoryStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case CategoryStatus.error:
                return const Center(child: Text('Error: '));
              case CategoryStatus.loaded:
                final filtered = provider.categories
                    .where(
                      (c) =>
                          _search.isEmpty ||
                          c.name.toLowerCase().contains(_search.toLowerCase()),
                    )
                    .toList();
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada kategori yang cocok'),
                  );
                }
                return Column(
                  children: [
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
                        onChanged: (v) => setState(() => _search = v),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (c, i) {
                          final cat = filtered[i];
                          return ListTile(
                            title: Text(
                              cat.name,
                              style: appFonts.medium.bodyLarge.ts,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // EDIT
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      Navigator.of(context).pushNamed(
                                        NameRoute.categoryAddForm,
                                        arguments: cat,
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
                                        title: const Text('Hapus Kategori'),
                                        content: Text(
                                          'Yakin ingin menghapus ${provider.categories[i].name}?',
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
                                    if (confirm == true) {
                                      await provider.removeCategory(
                                        provider.categories[i].id,
                                      );
                                    }
                                  },
                                ),
                                // isActive toggle
                                Switch(
                                  value: cat.isActive,
                                  onChanged: (val) async {
                                    await provider.toggleActive(cat.id, val);
                                    await sl<CategoryProvider>().load();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
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
