import 'package:flutter/material.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';
import 'package:restauran_menu/shared/widgets/app_image_loader.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../shared/utils/currency_formatter.dart';

class FavoriteMenuCard extends StatelessWidget {
  final MenuItemEntity item;
  final VoidCallback onAdd;

  const FavoriteMenuCard({super.key, required this.item, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: RestaurantColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RestaurantColors.cardBorder),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: RestaurantColors.accentOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: item.imageUrl != null
                    ? AppImageLoader().load(
                        item.imageUrl ?? "",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 100,
                      )
                    : const Icon(
                        Icons.fastfood_rounded,
                        color: RestaurantColors.accentOrange,
                        size: 30,
                      ),
              ),

              const SizedBox(height: 8),
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  color: RestaurantColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              item.originalPrice != null && item.originalPrice != 0.00
                  ? RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: formatRupiah(item.price),
                            style: const TextStyle(
                              color: RestaurantColors.accentOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: '\n ${formatRupiah(item.originalPrice ?? 0)}',
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
                      formatRupiah(item.price),
                      style: const TextStyle(
                        fontSize: 12,
                        color: RestaurantColors.textThird,
                      ),
                    ),
            ],
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: RestaurantColors.primaryBrown,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
