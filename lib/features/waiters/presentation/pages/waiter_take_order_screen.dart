import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/database/menu_repository.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/customers/data/menu_query_helpers.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';
import 'package:restauran_menu/features/waiters/presentation/provider/waiter_provider.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../customers/presentation/provider/cart_provider.dart';
import '../../../customers/presentation/widgets/category_tabs.dart';
import '../../../customers/presentation/widgets/menu_item_tile.dart';

/// Lets a waiter browse the menu and record a new order. With a
/// [tableNumber] it records a dine-in order for that table, without one it
/// records a takeaway order. Uses the global [CartProvider] but is scoped
/// locally so it never interferes with a customer's own self-order cart.
class WaiterTakeOrderScreen extends StatelessWidget {
  final int? tableNumber;
  const WaiterTakeOrderScreen({super.key, this.tableNumber});

  @override
  Widget build(BuildContext context) {
    return _WaiterTakeOrderView(tableNumber: tableNumber);
  }
}

class _WaiterTakeOrderView extends StatefulWidget {
  final int? tableNumber;
  const _WaiterTakeOrderView({this.tableNumber});

  @override
  State<_WaiterTakeOrderView> createState() => _WaiterTakeOrderViewState();
}

class _WaiterTakeOrderViewState extends State<_WaiterTakeOrderView> {
  int? _categoryId;
  String _query = '';
  int _guestCount = 1;
  final _customerNameController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _customerNameController.dispose();
    _noteController.dispose();
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
        return _buildScaffold(context, items);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, List<MenuItemEntity> items) {
    final tableNumber = widget.tableNumber;
    final isTakeaway = tableNumber == null;
    return Scaffold(
      backgroundColor: RestaurantColors.background,
      appBar: AppBar(
        backgroundColor: RestaurantColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: RestaurantColors.textPrimary),
        title: const Text(
          'Catat Pesanan',
          //isTakeaway
          //? 'Catat Pesanan · Take Away'
          // : 'Catat Pesanan · Meja $tableNumber',
          style: TextStyle(color: RestaurantColors.textPrimary, fontSize: 16.5),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isTakeaway)
                _GuestCountRow(
                  count: _guestCount,
                  onChanged: (v) => setState(() => _guestCount = v),
                ),
              if (!isTakeaway) const SizedBox(height: 12),
              _CustomerInfoFields(
                nameController: _customerNameController,
                noteController: _noteController,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: RestaurantColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: RestaurantColors.cardBorder),
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
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
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
                          onIncrement: () => cart.incrementQuantity(item.id),
                          onDecrement: () => cart.decrementQuantity(item.id),
                        );
                      },
                    );
                  },
                ),
              ),
              _SubmitBar(
                tableNumber: widget.tableNumber,
                guestCount: _guestCount,
                customerNameController: _customerNameController,
                noteController: _noteController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerInfoFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController noteController;
  const _CustomerInfoFields({
    required this.nameController,
    required this.noteController,
  });

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: RestaurantColors.textMuted,
        fontSize: 13.5,
      ),
      prefixIcon: Icon(icon, color: RestaurantColors.textMuted, size: 20),
      filled: true,
      fillColor: RestaurantColors.surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: RestaurantColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: RestaurantColors.primaryBrown),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: _decoration(
            'Nama customer (opsional)',
            Icons.person_outline,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: noteController,
          maxLines: 2,
          minLines: 1,
          decoration: _decoration(
            'Catatan pesanan (opsional)',
            Icons.sticky_note_2_outlined,
          ),
        ),
      ],
    );
  }
}

class _GuestCountRow extends StatelessWidget {
  final int count;
  final ValueChanged<int> onChanged;
  const _GuestCountRow({required this.count, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Jumlah Tamu',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: RestaurantColors.textPrimary,
          ),
        ),
        QuantityStepper(
          quantity: count,
          onIncrement: () => onChanged(count + 1),
          onDecrement: () => onChanged(count > 1 ? count - 1 : 1),
        ),
      ],
    );
  }
}

class _SubmitBar extends StatelessWidget {
  final int? tableNumber;
  final int guestCount;
  final TextEditingController customerNameController;
  final TextEditingController noteController;
  const _SubmitBar({
    required this.tableNumber,
    required this.guestCount,
    required this.customerNameController,
    required this.noteController,
  });

  @override
  Widget build(BuildContext context) {
    //final isTakeaway = tableNumber == null;
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
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
                    //isTakeaway
                    // ? '${cart.itemCount} item · Take Away'
                    //: '${cart.itemCount} item · Meja $tableNumber',
                    '${cart.itemCount} item · Dine In',
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
                onPressed: cart.isEmpty
                    ? null
                    : () async {
                        final customerName = customerNameController.text.trim();
                        final notes = noteController.text.trim();
                        // if (isTakeaway) {
                        //   await sl<WaiterProvider>().takeTakeawayOrder(
                        //     items: cart.items,
                        //     customerName: customerName.isEmpty
                        //         ? null
                        //         : customerName,
                        //     notes: notes.isEmpty ? null : notes,
                        //   );
                        // } else {
                        //   await sl<WaiterProvider>().takeOrder(
                        //     tableNumber: tableNumber!,
                        //     items: cart.items,
                        //     guestCount: guestCount,
                        //     customerName: customerName.isEmpty
                        //         ? null
                        //         : customerName,
                        //     notes: notes.isEmpty ? null : notes,
                        //   );
                        // }
                        final result = await cart.submit(
                          orderType: OrderEntity.typeDineIn,
                          tableNumber: null,
                          items: cart.items,
                          customerName: customerName.isEmpty
                              ? null
                              : customerName,
                          notes: notes.isEmpty ? null : notes,
                          sources: "waiter",
                        );
                        if (result != null) {
                          await sl<WaiterProvider>().load(refresh: true);
                          cart.clear();
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                // isTakeaway
                                ///? 'Pesanan Take Away dicatat'
                                //: 'Pesanan untuk Meja $tableNumber dicatat',
                                'Pesanan sudah dicatat',
                              ),
                            ),
                          );
                        }
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
