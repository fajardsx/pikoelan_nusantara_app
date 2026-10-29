import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/database/menu_repository.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/customers/data/menu_query_helpers.dart';
import 'package:restauran_menu/features/kasir/presentation/provider/kasir_provider.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../customers/presentation/provider/cart_provider.dart';
import '../../../customers/presentation/widgets/category_tabs.dart';
import '../../../customers/presentation/widgets/menu_item_tile.dart';
import '../../../orders/domain/entities/order_entity.dart';

/// Lets a cashier browse the menu and record a new order on behalf of a
/// customer (Dine In / Take Away / Delivery). Uses a fresh, screen-scoped
/// [CartProvider] so it never interferes with a customer's own self-order cart.
class KasirTakeOrderScreen extends StatelessWidget {
  const KasirTakeOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(sl()),
      child: const _KasirTakeOrderView(),
    );
  }
}

class _KasirTakeOrderView extends StatefulWidget {
  const _KasirTakeOrderView();

  @override
  State<_KasirTakeOrderView> createState() => _KasirTakeOrderViewState();
}

class _KasirTakeOrderViewState extends State<_KasirTakeOrderView> {
  int? _categoryId;
  String _query = '';
  String _orderType = OrderEntity.typeDineIn;
  int? _tableNumber;
  final _customerNameController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _customerNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MenuItemEntity>>(
      stream: sl<MenuRepository>().watchAll(),
      builder: (context, snapshot) {
        final items = (snapshot.data ?? [])
            .byCategory(_categoryId)
            .search(_query);
        return Scaffold(
          backgroundColor: RestaurantColors.background,
          appBar: AppBar(
            backgroundColor: RestaurantColors.background,
            elevation: 0,
            iconTheme: const IconThemeData(color: RestaurantColors.textPrimary),
            title: const Text(
              'Pesanan Baru',
              style: TextStyle(
                color: RestaurantColors.textPrimary,
                fontSize: 16.5,
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _OrderTypeSelector(
                          selected: _orderType,
                          onSelected: (t) => setState(() => _orderType = t),
                        ),
                        if (_orderType == OrderEntity.typeDineIn) ...[
                          const SizedBox(height: 12),
                          _TableField(
                            value: _tableNumber,
                            onChanged: (v) => setState(() => _tableNumber = v),
                          ),
                        ],
                        const SizedBox(height: 12),
                        _OptionalTextField(
                          controller: _customerNameController,
                          labelText: 'Nama Customer (opsional)',
                          hintText: 'Contoh: Budi',
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        _OptionalTextField(
                          controller: _notesController,
                          labelText: 'Catatan (opsional)',
                          hintText: 'Contoh: Es sedikit, sambal pisah',
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: RestaurantColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: RestaurantColors.cardBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: RestaurantColors.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: (v) => setState(() => _query = v),
                                  decoration: const InputDecoration(
                                    hintText: 'Cari menu...',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        CategoryTabs(
                          selectedId: _categoryId,
                          onSelected: (c) => setState(() => _categoryId = c),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: Consumer<CartProvider>(
                            builder: (context, cart, _) {
                              if (items.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'Menu tidak ditemukan',
                                    style: TextStyle(
                                      color: RestaurantColors.textSecondary,
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  final qty = cart.quantityOf(item.id);
                                  return MenuItemTile(
                                    item: item,
                                    quantity: qty,
                                    onAdd: () => cart.addItem(item),
                                    onIncrement: () =>
                                        cart.incrementQuantity(item.id),
                                    onDecrement: () =>
                                        cart.decrementQuantity(item.id),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        _SubmitBar(
                          orderType: _orderType,
                          tableNumber: _tableNumber,
                          customerNameController: _customerNameController,
                          notesController: _notesController,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OrderTypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  final bool vertical;
  const _OrderTypeSelector({required this.selected, required this.onSelected})
    : vertical = false;

  static const _options = [
    (type: OrderEntity.typeDineIn, label: 'Dine In'),
    (type: OrderEntity.typeTakeaway, label: 'Take Away'),
    (type: OrderEntity.typeDelivery, label: 'Delivery'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((o) {
        final isSelected = o.type == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onSelected(o.type),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? RestaurantColors.primaryBrown
                      : RestaurantColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? RestaurantColors.primaryBrown
                        : RestaurantColors.cardBorder,
                  ),
                ),
                child: Text(
                  o.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : RestaurantColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TableField extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  const _TableField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Nomor Meja',
        hintText: 'Contoh: 4',
        filled: true,
        fillColor: RestaurantColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RestaurantColors.cardBorder),
        ),
      ),
      onChanged: (v) => onChanged(int.tryParse(v)),
    );
  }
}

class _OptionalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final int maxLines;
  final TextCapitalization textCapitalization;
  const _OptionalTextField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: RestaurantColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RestaurantColors.cardBorder),
        ),
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  final String orderType;
  final int? tableNumber;
  final TextEditingController customerNameController;
  final TextEditingController notesController;
  const _SubmitBar({
    required this.orderType,
    required this.tableNumber,
    required this.customerNameController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final canSubmit =
            !cart.isEmpty &&
            (orderType != OrderEntity.typeDineIn || tableNumber != null);
        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: RestaurantColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${cart.itemCount} item',
                    style: const TextStyle(
                      color: RestaurantColors.textSecondary,
                    ),
                  ),
                  Text(
                    formatRupiah(cart.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: RestaurantColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: !canSubmit
                    ? null
                    : () async {
                        final customerName = customerNameController.text.trim();
                        final notes = notesController.text.trim();
                        final result = await cart.submit(
                          orderType: orderType,
                          tableNumber: orderType == OrderEntity.typeDineIn
                              ? tableNumber.toString()
                              : null,
                          items: cart.items,
                          customerName: customerName.isEmpty
                              ? null
                              : customerName,
                          notes: notes.isEmpty ? null : notes,
                        );

                        if (result != null) {
                          await sl<KasirProvider>().load(refresh: true);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Pesanan ${result.orderNumber} dibuat',
                              ),
                            ),
                          );
                        }
                        // final orderNumber = await sl<OrderRepository>()
                        //     .createOrder(
                        //       tableNumber: orderType == OrderEntity.typeDineIn
                        //           ? tableNumber
                        //           : null,
                        //       orderType: orderType,
                        //       items: cart.items,
                        //     );
                        // if (orderType == OrderEntity.typeDineIn &&
                        //     tableNumber != null) {
                        //   await sl<TableRepository>().occupyTable(
                        //     tableNumber!,
                        //     orderNumber: orderNumber,
                        //   );
                        // }
                        // if (!context.mounted) return;
                        // Navigator.pop(context);
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text('Pesanan $orderNumber dibuat'),
                        //   ),
                        // );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: RestaurantColors.primaryBrown,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: RestaurantColors.cardBorder,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Buat Pesanan',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
