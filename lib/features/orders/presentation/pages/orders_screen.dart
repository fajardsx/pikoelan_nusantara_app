import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/themes/app_colors.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_ticket_card.dart';
import 'create_order_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<OrdersProvider>()..load(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatefulWidget {
  const _OrdersView();

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  String? _lastShownError;

  static const _filters = [
    ('', 'Semua'),
    ('new', 'Baru'),
    ('proses', 'Diproses'),
    ('ready', 'Siap'),
    ('deliver', 'Diantar'),
  ];

  void _maybeShowError(OrdersProvider provider) {
    final message = provider.errorMessage;
    if (message != null && message != _lastShownError) {
      _lastShownError = message;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.danger),
        );
      });
    }
  }

  Future<void> _confirmCancel(
    BuildContext context,
    OrdersProvider provider,
    int orderId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan pesanan?'),
        content: const Text(
          'Pesanan ini akan ditandai batal dan tidak bisa diproses lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await provider.cancelOrder(orderId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    _maybeShowError(provider);

    return Scaffold(
      appBar: null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
          );
          if (created == true) await provider.load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Pesanan Baru'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesanan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: RestaurantColors.textPrimary,
                      ),
                    ),
                    // SizedBox(height: 4),
                    // Text(
                    //   'Atur akun dan peran untuk karyawan restoran',
                    //   style: TextStyle(color: RestaurantColors.textSecondary),
                    // ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final (value, label) = _filters[index];
                final isActive = provider.currentFilter == value;
                return ChoiceChip(
                  label: Text(label),
                  selected: isActive,
                  onSelected: (_) => provider.load(status: value),
                  selectedColor: AppColors.primarySoft,
                  labelStyle: TextStyle(
                    color: isActive ? Colors.white : AppColors.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: isActive ? AppColors.primarySoft : AppColors.line,
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.line),
          Expanded(child: _buildBody(context, provider)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrdersProvider provider) {
    if (provider.status == OrdersStatus.loading ||
        provider.status == OrdersStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.status == OrdersStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 40, color: AppColors.inkFaint),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage ?? 'Terjadi kesalahan',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.load(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final orders = provider.orders;
    if (orders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Tidak ada pesanan.',
            style: TextStyle(color: AppColors.inkSoft),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.load(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderTicketCard(
            order: order,
            onAdvance: order.nextStatus != null
                ? () => provider.advanceStatus(
                    order.id,
                    order.nextStatus!,
                    order.paymentMethod!,
                    order.isPaid,
                  )
                : null,
            onCancel: order.canCancel
                ? () => _confirmCancel(context, provider, order.id)
                : null,
          );
        },
      ),
    );
  }
}
