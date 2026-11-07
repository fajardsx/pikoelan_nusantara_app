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
    return ChangeNotifierProvider(
      create: (_) => sl<UnitProvider>()..load(),
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
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (c, i) {
                          final unit = filtered[i];
                          return ListTile(
                            title: Text(
                              'Name Unit: ${unit.name}',
                              style: appFonts.medium.bodyLarge.ts,
                            ),
                            subtitle: Text(
                              'UOM: ${unit.symbol}',
                              style: appFonts.ts,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => Navigator.of(context).pushNamed(
                                NameRoute.unitAddForm,
                                arguments: unit,
                              ),
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
