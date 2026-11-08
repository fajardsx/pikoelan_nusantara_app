import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/routes/name_route.dart';
import 'package:restauran_menu/shared/utils/date_time_formatter.dart';

import '../../domain/entities/stock_item.dart';
import '../../domain/entities/stock_movement.dart';
import '../provider/stock_movement_provider.dart';
import '../provider/stock_provider.dart';

class StockMovementListPage extends StatelessWidget {
  final StockItem? stockItem;
  const StockMovementListPage({super.key, this.stockItem});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              sl<StockMovementProvider>()..load(stockItemId: stockItem?.id),
        ),
        ChangeNotifierProvider(create: (_) => sl<StockProvider>()..load()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            stockItem != null
                ? 'Pergerakan Stok: ${stockItem!.name}'
                : 'Daftar Pergerakan Stok',
          ),
        ),
        floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton.extended(
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Catat Pergerakan'),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final result = await nav.pushNamed(
                NameRoute.stockMovementAddForm,
                arguments: stockItem,
              );
              if (result == true && ctx.mounted) {
                await ctx.read<StockMovementProvider>().load(
                  stockItemId: stockItem?.id,
                );
              }
            },
          ),
        ),
        body: Consumer<StockMovementProvider>(
          builder: (context, provider, _) {
            if (provider.status == StockMovementStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.status == StockMovementStatus.error) {
              return Center(child: Text('Error: ${provider.errorMessage}'));
            }
            return Column(
              children: [
                _buildFilters(context, provider),
                const Divider(height: 1),
                Expanded(child: _buildList(context, provider)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, StockMovementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            DropdownButton<StockMovementType?>(
              value: provider.selectedType,
              hint: const Text('Semua Tipe'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua Tipe')),
                ...StockMovementType.values.map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(t.value.toUpperCase()),
                  ),
                ),
              ],
              onChanged: (val) => provider.filterByType(val),
            ),
            const SizedBox(width: 16),
            DropdownButton<StockMovementReason?>(
              value: provider.selectedReason,
              hint: const Text('Semua Alasan'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Semua Alasan'),
                ),
                ...StockMovementReason.values.map(
                  (r) => DropdownMenuItem(
                    value: r,
                    child: Text(r.value.toUpperCase()),
                  ),
                ),
              ],
              onChanged: (val) => provider.filterByReason(val),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.date_range, size: 18),
              label: Text(
                provider.startDate == null && provider.endDate == null
                    ? 'Filter Tanggal'
                    : '${provider.startDate != null ? provider.startDate.toString().split(' ').first : '...'} - ${provider.endDate != null ? provider.endDate.toString().split(' ').first : '...'}',
              ),
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2023),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange:
                      provider.startDate != null && provider.endDate != null
                      ? DateTimeRange(
                          start: provider.startDate!,
                          end: provider.endDate!,
                        )
                      : null,
                );
                if (picked != null) {
                  provider.filterByDateRange(picked.start, picked.end);
                }
              },
            ),
            if (provider.startDate != null || provider.endDate != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.red),
                tooltip: 'Reset Tanggal',
                onPressed: () => provider.filterByDateRange(null, null),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, StockMovementProvider provider) {
    if (provider.filteredMovements.isEmpty) {
      return const Center(child: Text('Belum ada data pergerakan stok'));
    }
    return ListView.separated(
      itemCount: provider.filteredMovements.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = provider.filteredMovements[index];
        final isIn = item.type == StockMovementType.stockIn;
        final isOut = item.type == StockMovementType.stockOut;
        final color = isIn
            ? Colors.green
            : (isOut ? Colors.red : Colors.orange);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(
              isIn ? Icons.add : (isOut ? Icons.remove : Icons.tune),
              color: color,
            ),
          ),
          title: Text(item.stockItemName ?? 'Item #${item.stockItemId}'),
          subtitle: Text(
            'Tipe: ${item.type.value} | Alasan: ${item.reason.value} | Ref: ${item.referenceNumber ?? '-'}\n Date: ${formatDateTime(item.createdAt!.toLocal())}',
          ),
          trailing: Text(
            '${isIn ? '+' : (isOut ? '-' : '')}${item.quantity}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          onLongPress: () {
            if (item.id != null) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hapus Pergerakan'),
                  content: const Text('Hapus data pergerakan stok ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await provider.removeMovement(item.id!);
                      },
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }
}
