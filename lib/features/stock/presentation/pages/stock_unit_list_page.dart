import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/themes/app_fonts.dart';
import 'package:restauran_menu/routes/name_route.dart';

import '../provider/unit_provider.dart';

class StockUnitListPage extends StatefulWidget {
  const StockUnitListPage({super.key});

  @override
  _StockUnitListPageState createState() => _StockUnitListPageState();
}

class _StockUnitListPageState extends State<StockUnitListPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<UnitProvider>()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Unit'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Tambah Unit',
              onPressed: () async {
                await Navigator.of(context).pushNamed(NameRoute.unitAddForm);
                await sl<UnitProvider>().load();
              },
            ),
          ],
        ),
        body: Consumer<UnitProvider>(
          builder: (context, provider, _) {
            switch (provider.status) {
              case UnitStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case UnitStatus.error:
                return const Center(child: Text('Error: '));
              case UnitStatus.loaded:
                final filtered = provider.units
                    .where(
                      (u) =>
                          _search.isEmpty ||
                          u.name.toLowerCase().contains(_search.toLowerCase()),
                    )
                    .toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('Tidak ada unit yang cocok'));
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
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemCount: filtered.length,
                        itemBuilder: (c, i) {
                          final unit = filtered[i];
                          return ListTile(
                            title: Text(
                              unit.name,
                              style: appFonts.medium.bodyLarge.ts,
                            ),
                            subtitle: Text(
                              'UOM: ${unit.symbol}',
                              style: appFonts.ts,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      Navigator.of(context).pushNamed(
                                        NameRoute.unitAddForm,
                                        arguments: unit,
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
                                        title: const Text('Hapus Unit'),
                                        content: Text(
                                          'Yakin ingin menghapus ${unit.name}?',
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
                                      await provider.removeUnit(unit.id);
                                      await sl<UnitProvider>().load();
                                    }
                                  },
                                ),
                                // isActive toggle
                                Switch(
                                  value: unit.isActive!,
                                  onChanged: (val) async {
                                    await provider.toggleActive(unit.id, val);
                                    await provider.load();
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
