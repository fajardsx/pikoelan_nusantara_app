import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/services/app_log.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../routes/name_route.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../provider/cart_provider.dart';
import '../widgets/menu_item_tile.dart';

class CartScreen extends StatefulWidget {
  final bool embedded;
  final String? table;
  final bool? isDelivery;
  const CartScreen({
    super.key,
    this.table,
    this.embedded = false,
    this.isDelivery,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final TextEditingController _tableController;
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneDeliveryController;
  late final TextEditingController _promoCodeController;
  late final TextEditingController _memberController;
  late final TextEditingController _redeemPointsController;

  late String _orderType;

  @override
  void initState() {
    super.initState();
    final cart = context.read<CartProvider>();
    _tableController = TextEditingController(text: cart.tableNumber ?? '');
    _nameController = TextEditingController(text: cart.customerName ?? '');
    _notesController = TextEditingController(text: cart.notes ?? '');
    _addressController = TextEditingController(text: cart.address ?? '');
    _phoneDeliveryController = TextEditingController(text: cart.phone ?? '');
    _promoCodeController = TextEditingController();
    _memberController = TextEditingController();
    _redeemPointsController = TextEditingController();
    if (widget.table != null) {
      _tableController.text = widget.table ?? "";
      _orderType = cart.orderType;
    } else {
      _orderType = OrderEntity.typeDelivery;
    }
  }

  @override
  void dispose() {
    _tableController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    _phoneDeliveryController.dispose();
    _memberController.dispose();
    _redeemPointsController.dispose();
    super.dispose();
  }

  Future<bool> validatePromoCode(String code) async {
    // TODO: replace with real backend validation
    await Future.delayed(const Duration(milliseconds: 200));
    return code.isNotEmpty && code.length >= 4;
  }

  // void _showPromoDialog() {
  //   final TextEditingController dialogController = TextEditingController();
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Pilih Promo'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: dialogController,
  //               decoration: const InputDecoration(
  //                 hintText: 'Masukkan kode promo',
  //               ),
  //             ),
  //             const SizedBox(height: 12),
  //             // -------------------------------------------------------
  //             //  Fixed‑height list of promo codes
  //             // -------------------------------------------------------
  //             SizedBox(
  //               height: 200,
  //               child: SingleChildScrollView(
  //                 child: Column(
  //                   children: context
  //                       .read<CartProvider>()
  //                       .availablePromos
  //                       .map(
  //                         (promo) => ListTile(
  //                           title: Text(promo),
  //                           trailing: IconButton(
  //                             icon: const Icon(Icons.copy),
  //                             onPressed: () {
  //                               Clipboard.setData(ClipboardData(text: promo));
  //                               ScaffoldMessenger.of(context).showSnackBar(
  //                                 const SnackBar(content: Text('Promo copied')),
  //                               );
  //                             },
  //                           ),
  //                           onTap: () {
  //                             _promoCodeController.text = promo;
  //                             Navigator.of(context).pop();
  //                           },
  //                         ),
  //                       )
  //                       .toList(),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Batal'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               _promoCodeController.text = dialogController.text;
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Gunakan'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _proceedToPayment() async {
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Keranjang masih kosong.')));
      return;
    }

    final table = _tableController.text.trim();
    final name = _nameController.text.trim();
    final notes = _notesController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneDeliveryController.text.trim();

    if (_orderType == OrderEntity.typeDineIn && table.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan nomor meja untuk pesanan di tempat.'),
          backgroundColor: RestaurantColors.warning,
        ),
      );
      return;
    }
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan nama Anda.'),
          backgroundColor: RestaurantColors.warning,
        ),
      );
      return;
    }

    if (_orderType == OrderEntity.typeDelivery) {
      if (address.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan masukkan alamat pengiriman.'),
            backgroundColor: RestaurantColors.warning,
          ),
        );
        return;
      }
      if (phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan masukkan nomor telepon untuk pengiriman.'),
            backgroundColor: RestaurantColors.warning,
          ),
        );
        return;
      }
    }

    final promo = _promoCodeController.text.trim();
    if (promo.isNotEmpty) {
      final ok = await validatePromoCode(promo);
      if (!ok) {
        AppLog.instance.logWarning('Promo code tidak valid.');
        return;
      }
    }

    cart.setCustomerInfo(
      tableNumber: table.isNotEmpty ? table : null,
      customerName: name.isNotEmpty ? name : null,
      notes: notes.isNotEmpty ? notes : null,
      address: _orderType == OrderEntity.typeDelivery && address.isNotEmpty
          ? address
          : null,
      phone: _orderType == OrderEntity.typeDelivery && phone.isNotEmpty
          ? phone
          : null,
      orderType: _orderType,
      promoCode: promo.isNotEmpty ? promo : null,
      redeemPoints: _redeemPointsController.text.isNotEmpty
          ? int.tryParse(_redeemPointsController.text)
          : null,
    );

    Navigator.pushNamed(context, NameRoute.paymentMethod);
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
                'Keranjang',
                style: TextStyle(
                  color: RestaurantColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: RestaurantColors.danger,
                  ),
                  tooltip: 'Kosongkan Keranjang',
                  onPressed: () {
                    context.read<CartProvider>().clear();
                    _tableController.clear();
                    _nameController.clear();
                    _notesController.clear();
                    _addressController.clear();
                    _phoneDeliveryController.clear();
                    _redeemPointsController.clear();
                  },
                ),
              ],
            ),
      body: SafeArea(
        top: widget.embedded,
        child: Consumer<CartProvider>(
          builder: (context, cart, _) {
            if (cart.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.embedded)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Keranjang',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: RestaurantColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: RestaurantColors.textMuted,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Keranjang masih kosong',
                            style: TextStyle(
                              color: RestaurantColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                if (widget.embedded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Keranjang',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: RestaurantColors.textPrimary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            cart.clear();
                            _tableController.clear();
                            _nameController.clear();
                            _notesController.clear();
                            _addressController.clear();
                            _phoneDeliveryController.clear();
                            _redeemPointsController.clear();
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: RestaurantColors.danger,
                          ),
                          label: const Text(
                            'Hapus Semua',
                            style: TextStyle(
                              color: RestaurantColors.danger,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      // ── Menu Items ──
                      const Text(
                        'Item Pesanan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: RestaurantColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...cart.items.map((cartItem) {
                        return MenuItemTile(
                          item: cartItem.menuItem,
                          quantity: cartItem.quantity,
                          onAdd: () => cart.addItem(cartItem.menuItem),
                          onIncrement: () =>
                              cart.incrementQuantity(cartItem.menuItem.id),
                          onDecrement: () =>
                              cart.decrementQuantity(cartItem.menuItem.id),
                        );
                      }),

                      const SizedBox(height: 16),

                      // ── Customer & Order Info Form ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: RestaurantColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: RestaurantColors.cardBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.assignment_ind_outlined,
                                  size: 20,
                                  color: RestaurantColors.primaryBrown,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Informasi Pemesanan',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: RestaurantColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Tipe Pesanan
                            const Text(
                              'Tipe Pesanan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: RestaurantColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (widget.table != null)
                                  Expanded(
                                    child: _OrderTypeOption(
                                      label: 'Makan di Tempat',
                                      icon: Icons.restaurant_rounded,
                                      selected:
                                          _orderType == OrderEntity.typeDineIn,
                                      onTap: () {
                                        setState(
                                          () => _orderType =
                                              OrderEntity.typeDineIn,
                                        );
                                      },
                                    ),
                                  ),
                                if (widget.table != null)
                                  const SizedBox(width: 10),
                                if (widget.table != null)
                                  Expanded(
                                    child: _OrderTypeOption(
                                      label: 'Bawa Pulang',
                                      icon: Icons.takeout_dining_rounded,
                                      selected:
                                          _orderType ==
                                          OrderEntity.typeTakeaway,
                                      onTap: () {
                                        setState(
                                          () => _orderType =
                                              OrderEntity.typeTakeaway,
                                        );
                                      },
                                    ),
                                  ),
                                if (widget.table == null &&
                                    widget.isDelivery == true)
                                  const SizedBox(width: 10),
                                if (widget.table == null &&
                                    widget.isDelivery == true)
                                  Expanded(
                                    child: _OrderTypeOption(
                                      label: 'Delivery',
                                      icon: Icons.delivery_dining,
                                      selected:
                                          _orderType ==
                                          OrderEntity.typeDelivery,
                                      onTap: () {
                                        setState(
                                          () => _orderType =
                                              OrderEntity.typeDelivery,
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Nomor Meja
                            if (_orderType == OrderEntity.typeDineIn)
                              Row(
                                children: [
                                  const Text(
                                    'Nomor Meja',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: RestaurantColors.textSecondary,
                                    ),
                                  ),
                                  if (_orderType == OrderEntity.typeDineIn)
                                    const Text(
                                      ' *',
                                      style: TextStyle(
                                        color: RestaurantColors.danger,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            if (_orderType == OrderEntity.typeDineIn)
                              const SizedBox(height: 6),
                            if (_orderType == OrderEntity.typeDineIn)
                              TextField(
                                controller: _tableController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Contoh: 05, A2, VIP-1',
                                  prefixIcon: const Icon(
                                    Icons.table_restaurant_outlined,
                                    size: 20,
                                    color: RestaurantColors.textSecondary,
                                  ),
                                  filled: true,
                                  fillColor: RestaurantColors.background,
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
                              ),
                            if (_orderType == OrderEntity.typeDineIn)
                              const SizedBox(height: 14),

                            // Nama Pemesan
                            const Row(
                              children: [
                                Text(
                                  'Nama Customer / Pemesan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: RestaurantColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  ' *',
                                  style: TextStyle(
                                    color: RestaurantColors.danger,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: 'Nama Anda',
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                  size: 20,
                                  color: RestaurantColors.textSecondary,
                                ),
                                filled: true,
                                fillColor: RestaurantColors.background,
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
                            ),

                            // ── Delivery Fields ──
                            if (widget.isDelivery == true &&
                                _orderType == OrderEntity.typeDelivery) ...[
                              const SizedBox(height: 14),
                              const Row(
                                children: [
                                  Text(
                                    'Alamat Pengiriman',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: RestaurantColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    ' *',
                                    style: TextStyle(
                                      color: RestaurantColors.danger,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _addressController,
                                maxLines: 2,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  hintText:
                                      'Contoh: Jl. Merdeka No. 10, RT 01/RW 02 / Tower, No Unit',
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(bottom: 24),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      size: 20,
                                      color: RestaurantColors.textSecondary,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: RestaurantColors.background,
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
                              ),
                              const SizedBox(height: 14),
                              const Row(
                                children: [
                                  Text(
                                    'Nomor Telepon',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: RestaurantColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    ' *',
                                    style: TextStyle(
                                      color: RestaurantColors.danger,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _phoneDeliveryController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: 'Contoh: 08123456789',
                                  prefixIcon: const Icon(
                                    Icons.phone_outlined,
                                    size: 20,
                                    color: RestaurantColors.textSecondary,
                                  ),
                                  filled: true,
                                  fillColor: RestaurantColors.background,
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
                              ),
                            ],
                            const SizedBox(height: 14),

                            // Catatan Pesanan
                            const Text(
                              'Catatan Pesanan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: RestaurantColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _notesController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText:
                                    'Contoh: Es dipisah, sambal sedikit (opsional)',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 24),
                                  child: Icon(
                                    Icons.edit_note_rounded,
                                    size: 22,
                                    color: RestaurantColors.textSecondary,
                                  ),
                                ),
                                filled: true,
                                fillColor: RestaurantColors.background,
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
                            ),

                            if (_orderType == OrderEntity.typeDelivery ||
                                widget.isDelivery == true ||
                                widget.table != null)
                              ...[],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      promosCard(),
                      const SizedBox(height: 14),
                      memberCard(),
                    ],
                  ),
                ),
                if (widget.isDelivery == true || widget.table != null)
                  _CartSummary(cart: cart, onProceed: _proceedToPayment),
              ],
            );
          },
        ),
      ),
    );
  }

  Container promosCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RestaurantColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RestaurantColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: 20,
                color: RestaurantColors.primaryBrown,
              ),
              SizedBox(width: 8),
              Text(
                'Informasi Promo',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: RestaurantColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Kode Promo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: RestaurantColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _promoCodeController,
            decoration: InputDecoration(
              hintText: 'Masukkan kode promo',
              prefixIcon: const Icon(
                Icons.local_offer_outlined,
                size: 20,
                color: RestaurantColors.textSecondary,
              ),
              // suffixIcon: IconButton(
              //   icon: const Icon(Icons.list),
              //   onPressed: _showPromoDialog,
              // ),
              filled: true,
              fillColor: RestaurantColors.background,
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
          ),
        ],
      ),
    );
  }

  Container memberCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RestaurantColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RestaurantColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.perm_identity,
                size: 20,
                color: RestaurantColors.primaryBrown,
              ),
              SizedBox(width: 8),
              Text(
                'Informasi Member',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: RestaurantColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Member ID',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: RestaurantColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _memberController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Masukkan Nomor Telepon Member',
              prefixIcon: const Icon(
                Icons.perm_identity,
                size: 20,
                color: RestaurantColors.textSecondary,
              ),
              filled: true,
              fillColor: RestaurantColors.background,
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
          ),
          const SizedBox(height: 14),
          const Text(
            'Redeem Points',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: RestaurantColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _redeemPointsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Jumlah poin yang ingin ditebus',
              prefixIcon: const Icon(
                Icons.star,
                size: 20,
                color: RestaurantColors.textSecondary,
              ),
              filled: true,
              fillColor: RestaurantColors.background,
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
          ),
        ],
      ),
    );
  }
}

class _OrderTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _OrderTypeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? RestaurantColors.primaryBrown
              : RestaurantColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? RestaurantColors.primaryBrown
                : RestaurantColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : RestaurantColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected ? Colors.white : RestaurantColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final CartProvider cart;
  final VoidCallback onProceed;

  const _CartSummary({required this.cart, required this.onProceed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
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
          _SummaryRow(label: 'Subtotal', value: formatRupiah(cart.subtotal)),
          const SizedBox(height: 6),
          const Divider(height: 24, color: RestaurantColors.cardBorder),
          _SummaryRow(
            label: 'Total',
            value: formatRupiah(cart.total),
            emphasize: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onProceed,
            style: ElevatedButton.styleFrom(
              backgroundColor: RestaurantColors.primaryBrown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Lanjut ke Pembayaran',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: emphasize ? 17 : 14,
      fontWeight: emphasize ? FontWeight.bold : FontWeight.normal,
      color: RestaurantColors.textPrimary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: style.copyWith(
            color: emphasize
                ? RestaurantColors.textPrimary
                : RestaurantColors.textSecondary,
          ),
        ),
        Text(value, style: style),
      ],
    );
  }
}
