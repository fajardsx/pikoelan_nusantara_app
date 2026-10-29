import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_constant.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/database/menu_repository.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/customers/data/menu_query_helpers.dart';
import 'package:restauran_menu/features/customers/presentation/provider/cart_provider.dart';
import 'package:restauran_menu/features/customers/presentation/provider/public_menu_provider.dart';
import 'package:restauran_menu/features/customers/presentation/widgets/category_tabs.dart';
import 'package:restauran_menu/features/customers/presentation/widgets/menu_item_tile.dart';
import 'package:restauran_menu/features/kasir/presentation/provider/kasir_provider.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';
import 'package:restauran_menu/features/menu/presentation/provider/menu_provider.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';
import 'package:restauran_menu/shared/utils/currency_formatter.dart';

import '../../../notifications/presentation/widgets/order_stream_status_badge.dart';

/// Screen membuat pesanan, kiri daftar menu, kanan keranjang.
class KasirCreateOrderScreen extends StatelessWidget {
  const KasirCreateOrderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(sl()),
      child: const _KasirCreateOrderView(),
    );
  }
}

class _KasirCreateOrderView extends StatefulWidget {
  const _KasirCreateOrderView();
  @override
  State<_KasirCreateOrderView> createState() => _KasirCreateOrderViewState();
}

class _KasirCreateOrderViewState extends State<_KasirCreateOrderView> {
  int? _categoryId;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _orderType;
  final TextEditingController _tableController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false; // loading state for create order
  static const _options = [
    (type: OrderEntity.typeDineIn, label: 'Dine In'),
    (type: OrderEntity.typeTakeaway, label: 'Take Away'),
    (type: OrderEntity.typeDelivery, label: 'Delivery'),
  ];

  @override
  void initState() {
    super.initState();
    _maybeLoad();
  }

  void _maybeLoad() {
    final incoming = (Consts.appSlug).trim();
    final menu = context.read<PublicMenuProvider>();
    if (incoming.isNotEmpty) {
      menu.silentLoad(incoming, forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MenuItemEntity>>(
      stream: sl<MenuRepository>().watchAll(),
      builder: (c, snap) {
        final items = (snap.data ?? []).byCategory(
          _categoryId,
        ); //.search(_query);
        return Scaffold(
          backgroundColor: RestaurantColors.background,
          appBar: AppBar(
            backgroundColor: RestaurantColors.background,
            elevation: 0,
            automaticallyImplyLeading: false,
            iconTheme: const IconThemeData(color: RestaurantColors.textPrimary),
            title: const Text(
              'Buat Pesanan',
              style: TextStyle(
                color: RestaurantColors.textPrimary,
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: OrderStreamStatusBadge(),
              ),
            ],
          ),
          body: isMobileView(context)
              ? orderPanel(items, context)
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: orderPanel(items, context),
                ),
        );
      },
    );
  }

  Row orderPanel(List<MenuItemEntity> items, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Tipe Order',
                          border: OutlineInputBorder(),
                        ),
                        items: _options
                            .map(
                              (type) => DropdownMenuItem(
                                value: type.type,
                                child: Text(type.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _orderType = value),
                        validator: (value) =>
                            value == null ? 'Pilih tipe order' : null,
                      ),
                      const SizedBox(height: 8),
                      if (_orderType == OrderEntity.typeDineIn)
                        TextFormField(
                          controller: _tableController,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Meja',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Masukkan nomor meja'
                              : null,
                        ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Customer',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Masukkan nama customer'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'Catatan',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1, color: RestaurantColors.cardBorder),
        SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryTabs(
                  selectedId: _categoryId,
                  onSelected: (id) => setState(() => _categoryId = id),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: RefreshIndicator(
                    // Refresh menu‑item list
                    onRefresh: () async {
                      // PublicMenuProvider sudah di‑import di atas
                      //await context.read<PublicMenuProvider>().refresh();
                      sl<MenuProvider>().refresh();
                    },
                    // ListView menampilkan item menu
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (c, i) => MenuItemTile(
                        item: items[i],
                        onAdd: () =>
                            context.read<CartProvider>().addItem(items[i]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1, color: RestaurantColors.cardBorder),
        // Cart right
        Expanded(
          child: Consumer<CartProvider>(
            builder: (c, cart, _) {
              final cartItems = cart.items;
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Keranjang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: RestaurantColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: cartItems.isEmpty
                        ? const Center(
                            child: Text(
                              'Keranjang kosong',
                              style: TextStyle(
                                color: RestaurantColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: cartItems.length,
                            itemBuilder: (c, i) {
                              final it = cartItems[i];
                              return ListTile(
                                title: Text(it.menuItem.name),
                                subtitle: Text('x${it.quantity}'),
                                trailing: Text(
                                  formatRupiah(it.menuItem.price * it.quantity),
                                ),
                                onTap: () => cart.removeItem(it.menuItem.id),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: RestaurantColors.textPrimary,
                          ),
                        ),
                        Text(
                          formatRupiah(
                            cartItems.fold<int>(
                              0,
                              (sum, it) =>
                                  sum +
                                  (it.menuItem.price.toInt() * it.quantity),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: RestaurantColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: (cartItems.isEmpty || _isLoading)
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              try {
                                // Validate form fields before creating order
                                if (!(_formKey.currentState?.validate() ??
                                    false)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Harap isi semua bidang yang diperlukan',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                await sl<KasirProvider>().createOrderFromCart(
                                  cart,
                                );
                                final customerName = _nameController.text
                                    .trim();
                                final notes = _noteController.text.trim();
                                final result = await cart.submit(
                                  orderType: _orderType!,
                                  tableNumber:
                                      _orderType == OrderEntity.typeDineIn
                                      ? _tableController.text.trim()
                                      : null,
                                  items: cart.items,
                                  customerName: customerName.isEmpty
                                      ? null
                                      : customerName,
                                  notes: notes.isEmpty ? "" : notes,
                                );

                                if (result != null) {
                                  await sl<KasirProvider>().load(refresh: true);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Pesanan ${result.orderNumber} dibuat',
                                      ),
                                    ),
                                  );
                                }
                                cart.clear();
                                setState(() {
                                  _orderType = null;
                                });
                                _tableController.clear();
                                _noteController.clear();
                                _nameController.clear();
                              } finally {
                                setState(() => _isLoading = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RestaurantColors.primaryBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 10.0,
                        ),
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: RestaurantColors.primaryBrown,
                              ),
                            )
                          : const Text('Buat Pesanan'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
