import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../provider/cart_provider.dart';

class CustomerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;
    final items = [
      (_NavItem(icon: Icons.home_rounded, label: 'Beranda')),
      (_NavItem(icon: Icons.menu_book_rounded, label: 'Menu')),
      (_NavItem(
        icon: Icons.shopping_cart_rounded,
        label: 'Keranjang',
        badge: cartCount,
      )),
      (_NavItem(icon: Icons.receipt_long_rounded, label: 'Pesanan Saya')),
    ];

    // Fix: di Android edge-to-edge (Android 15+) bottomNavigationBar
    // akan berada di bawah soft navigation bar / gesture bar.
    // viewPadding.bottom = tinggi inset navigation bar.
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: RestaurantColors.surface,
        border: Border(top: BorderSide(color: RestaurantColors.cardBorder)),
      ),
      padding: EdgeInsets.only(top: 8, bottom: 8 + bottomInset),
      child: SafeArea(
        top: false,
        bottom: false,
        left: true,
        right: true,
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = index == currentIndex;
            final color = selected
                ? RestaurantColors.primaryBrown
                : RestaurantColors.textMuted;
            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(item.icon, color: color, size: 24),
                        if (item.badge != null && item.badge! > 0)
                          Positioned(
                            right: -6,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: const BoxDecoration(
                                color: RestaurantColors.accentOrange,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${item.badge}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int? badge;
  _NavItem({required this.icon, required this.label, this.badge});
}
