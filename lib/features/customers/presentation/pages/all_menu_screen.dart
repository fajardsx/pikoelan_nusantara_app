import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/features/customers/presentation/provider/public_menu_provider.dart';
import 'package:restauran_menu/features/customers/presentation/widgets/menu_item_tile_grid.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../provider/cart_provider.dart';
import '../widgets/category_tabs.dart';

/// "Semua Menu" screen.
class AllMenuScreen extends StatefulWidget {
  final bool embedded;
  const AllMenuScreen({super.key, this.embedded = false});

  @override
  State<AllMenuScreen> createState() => _AllMenuScreenState();
}

class _AllMenuScreenState extends State<AllMenuScreen> {
  int? _categoryId;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<PublicMenuProvider>();
    final q = _query.toLowerCase().trim();
    final items = menu.byCategory(_categoryId).where((e) {
      if (q.isEmpty) return true;
      return e.name.toLowerCase().contains(q);
    }).toList();
    bool useExpanded = isMobileView(context);
    if (menu.status == PublicMenuStatus.loading ||
        menu.status == PublicMenuStatus.initial) {
      return const Scaffold(
        backgroundColor: RestaurantColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (menu.status == PublicMenuStatus.error) {
      return Scaffold(
        backgroundColor: RestaurantColors.background,
        appBar: widget.embedded
            ? null
            : AppBar(
                backgroundColor: RestaurantColors.background,
                elevation: 0,
                title: const Text(
                  'Semua Menu',
                  style: TextStyle(color: RestaurantColors.textPrimary),
                ),
              ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  menu.errorMessage ?? 'Gagal memuat menu.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: RestaurantColors.textSecondary),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => menu.refresh(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => menu.refresh(),
      color: RestaurantColors.primaryBrown,
      child: _buildScaffold(context, items, useExpanded),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    List<MenuItemEntity> items,
    bool useExpanded,
  ) {
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
                'Semua Menu',
                style: TextStyle(color: RestaurantColors.textPrimary),
              ),
            ),
      body: SafeArea(
        top: widget.embedded,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.embedded)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Daftar Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: RestaurantColors.textPrimary,
                    ),
                  ),
                ),
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
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
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
              // All Daftar Menu
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
                    return MasonryGridView.builder(
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: useExpanded ? 4 : 2,
                          ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final qty = cart.quantityOf(item.id);
                        return MenuItemTileGrid(
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
            ],
          ),
        ),
      ),
    );
  }
}
