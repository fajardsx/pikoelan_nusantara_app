import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';
import 'package:restauran_menu/shared/widgets/app_image_loader.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../shared/utils/currency_formatter.dart';

@Preview(name: "Menu Item Tile")
Widget myMenuItemTileGrid() {
  return MenuItemTileGrid(onAdd: () {}, quantity: 5);
}

/// Horizontal list-style menu tile (used in "Semua Menu").
class MenuItemTileGrid extends StatelessWidget {
  final MenuItemEntity? item;
  final int quantity;
  final bool isPromo;
  final VoidCallback onAdd;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const MenuItemTileGrid({
    super.key,
    this.item,
    required this.onAdd,
    this.quantity = 0,
    this.isPromo = true,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: RestaurantColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RestaurantColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: _Thumbnail(
              name: item!.imageUrl ?? "",
              thumbW: double.infinity,
              isFavorite: item!.isFavorite,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 7.5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  item!.name,
                  maxLines: 2,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    color: RestaurantColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                // price info etc... (keep existing code unchanged after this point)
                item!.originalPrice != null && item?.originalPrice != 0.00
                    ? RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: formatRupiah(item!.price),
                              style: const TextStyle(
                                color: RestaurantColors.accentOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '\n ${formatRupiah(item!.originalPrice ?? 0)}',
                              style: const TextStyle(
                                color: RestaurantColors.textMuted,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: RestaurantColors.textMuted,
                                decorationThickness: 3,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        formatRupiah(item!.price),
                        style: const TextStyle(
                          color: RestaurantColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: quantity > 0
                ? QuantityStepper(
                    quantity: quantity,
                    onIncrement: onIncrement ?? onAdd,
                    onDecrement: onDecrement ?? () {},
                  )
                : _AddButton(onTap: onAdd),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String name;
  final double? thumbW;
  final double? thumbH;
  final bool isFavorite;

  const _Thumbnail({
    required this.name,
    this.thumbW,
    this.thumbH,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: thumbW,
          height: thumbH,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: RestaurantColors.cardImageBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: name.isNotEmpty
              ? AppImageLoader().load(
                  name,
                  fit: BoxFit.cover,
                  width: thumbW,
                  alignment: AlignmentGeometry.center,
                )
              : const Icon(
                  Icons.restaurant_menu_rounded,
                  color: RestaurantColors.accentOrange,
                  size: 26,
                ),
        ),
        if (isFavorite)
          const Positioned(
            top: 4,
            right: 4,
            child: Icon(Icons.star, color: Colors.amber, size: 20),
          ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: RestaurantColors.primaryBrown,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 18),
      ),
    );
  }
}

/// Small +/- stepper used in the cart and menu list.
class QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: RestaurantColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RestaurantColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(icon: Icons.remove, onTap: onDecrement),
          SizedBox(
            width: 24,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: RestaurantColors.textPrimary,
              ),
            ),
          ),
          _StepperButton(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: RestaurantColors.primaryBrown),
      ),
    );
  }
}
