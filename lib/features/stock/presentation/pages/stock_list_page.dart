import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/routes/name_route.dart';

import '../provider/stock_provider.dart';

class StockListPage extends StatelessWidget {
  const StockListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<StockProvider>()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Stok'),
          actions: [
            IconButton(
              icon: const Icon(Icons.straighten),
              tooltip: 'Tambah Unit',
              onPressed: () =>
                  Navigator.of(context).pushNamed(NameRoute.unitAddForm),
            ),
            IconButton(
              icon: const Icon(Icons.category),
              tooltip: 'Tambah Kategori',
              onPressed: () =>
                  Navigator.of(context).pushNamed(NameRoute.categoryAddForm),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () =>
              Navigator.of(context).pushNamed(NameRoute.stockAddForm),
        ),
        body: Consumer<StockProvider>(
          builder: (context, provider, _) {
            switch (provider.status) {
              case StockStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case StockStatus.error:
                return Center(child: Text('Error: ${provider.errorMessage}'));
              case StockStatus.loaded:
                return provider.items.isEmpty
                    ? const Center(child: Text("Belum ada Stock yang dibuat"))
                    : ListView.builder(
                        itemCount: provider.items.length,
                        itemBuilder: (c, i) => ListTile(
                          title: Text(provider.items[i].name),
                          subtitle: Text(
                            'Stok: ${provider.items[i].currentStock} (Min: ${provider.items[i].minimumStock})',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    Navigator.of(context).pushNamed(
                                      NameRoute.stockAddForm,
                                      arguments: provider.items[i],
                                    ),
                              ),
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
                                        'Yakin ingin menghapus ${provider.items[i].name}?',
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
                                      provider.items[i].id != null) {
                                    await provider.removeItem(
                                      provider.items[i].id!,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
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
