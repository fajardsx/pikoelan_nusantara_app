import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/customers/domain/usecases/get_public_order_usecase.dart';
import 'package:restauran_menu/features/customers/presentation/provider/cart_provider.dart';
import 'package:restauran_menu/features/customers/presentation/provider/public_menu_provider.dart';
import 'package:restauran_menu/features/customers/presentation/widgets/order_status_badge.dart';
import 'package:restauran_menu/features/customers/presentation/widgets/order_type_badge.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';
import 'package:restauran_menu/shared/utils/currency_formatter.dart';
import 'package:restauran_menu/shared/utils/date_time_formatter.dart';

class OrdersHistoryScreen extends StatefulWidget {
  final bool embedded;
  final String? orderNumber;
  const OrdersHistoryScreen({
    super.key,
    this.embedded = false,
    this.orderNumber,
  });

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  late final GetPublicOrderUsecase _getPublicOrderUsecase;
  final TextEditingController _searchController = TextEditingController();
  List<OrderEntity> _orders = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getPublicOrderUsecase = sl<GetPublicOrderUsecase>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartOrder = context.read<CartProvider>().orderNumber;
      final initialOrderNumber = (widget.orderNumber ?? cartOrder)?.trim();
      if (initialOrderNumber != null && initialOrderNumber.isNotEmpty) {
        _searchController.text = initialOrderNumber;
      }
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    final provider = context.read<PublicMenuProvider>();
    final slug = provider.slug;
    if (slug == null || slug.isEmpty) {
      setState(() {
        _error = 'Slug restoran tidak tersedia.';
        _loading = false;
      });
      return;
    }

    final queryOrder = _searchController.text.trim();
    try {
      final orders = await _getPublicOrderUsecase(
        slug,
        orderNumber: queryOrder.isNotEmpty ? queryOrder : null,
      );
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RestaurantColors.background,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: RestaurantColors.background,
              elevation: 0,
              iconTheme: const IconThemeData(
                color: RestaurantColors.textPrimary,
              ),
              title: const Text(
                'Pesanan Saya',
                style: TextStyle(
                  color: RestaurantColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      body: SafeArea(
        top: widget.embedded,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari no. pesanan (misal ORD-...)',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: RestaurantColors.textSecondary,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadOrders();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: RestaurantColors.cardBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: RestaurantColors.cardBorder,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _loadOrders(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _loadOrders,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RestaurantColors.primaryBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cari'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: RestaurantColors.warning,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchController.text.isEmpty
                                  ? "Untuk melihat pesanan Tolong masukan No Pesanan Anda."
                                  : _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: RestaurantColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadOrders,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: RestaurantColors.primaryBrown,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.receipt_long_rounded,
                            size: 64,
                            color: RestaurantColors.textMuted,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada pesanan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: RestaurantColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Pesanan Anda akan muncul di sini',
                            style: TextStyle(
                              color: RestaurantColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _loadOrders,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Muat Ulang'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: _orders.length,
                        itemBuilder: (context, i) {
                          final order = _orders[i];
                          return MyOrderCard(order: order);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyOrderCard extends StatelessWidget {
  const MyOrderCard({super.key, required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: RestaurantColors.cardBorder),
      ),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 5.0,
              children: [
                Expanded(
                  child: Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: RestaurantColors.textPrimary,
                    ),
                  ),
                ),
                OrderTypeBadge(orderType: order.orderType),
                OrderStatusBadge(status: order.status),
              ],
            ),
            Text(
              formatDateTime(order.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: RestaurantColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              spacing: 5.0,
              children: [
                if (order.tableNumber != null && order.tableNumber!.isNotEmpty)
                  Text(
                    'Meja ${order.tableNumber} • ',
                    style: const TextStyle(
                      color: RestaurantColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),

                Text(
                  '${order.items.length} item',
                  style: const TextStyle(
                    color: RestaurantColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (order.customerName != null &&
                order.customerName!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: RestaurantColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.customerName!.trim(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: RestaurantColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (order.notes != null && order.notes!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: RestaurantColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: RestaurantColors.cardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.sticky_note_2_outlined,
                        size: 14,
                        color: RestaurantColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.notes!.trim(),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: RestaurantColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (order.notes == null || order.notes!.trim().isEmpty)
              const SizedBox(height: 12),
            ListView.separated(
              itemCount: order.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.itemName,
                        style: const TextStyle(
                          color: RestaurantColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${item.quantity}x',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: RestaurantColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        formatRupiah(item.subtotal),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: RestaurantColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    color: RestaurantColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  formatRupiah(order.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: RestaurantColors.primaryBrown,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
