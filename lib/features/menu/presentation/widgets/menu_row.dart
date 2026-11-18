import 'package:flutter/material.dart';
import 'package:restauran_menu/core/database/menu_repository.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';
import 'package:restauran_menu/features/menu/presentation/pages/menu_form_screen.dart';
import 'package:restauran_menu/features/menu/presentation/provider/menu_provider.dart';
import 'package:restauran_menu/shared/utils/currency_formatter.dart';
import 'package:restauran_menu/shared/widgets/app_image_loader.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/themes/restaurant_colors.dart';

class MenuRow extends StatelessWidget {
  final MenuItemEntity item;
  final String? categoryName;

  final bool canEdit;
  final bool canDel;

  const MenuRow({
    super.key,
    required this.item,
    required this.categoryName,
    required this.canEdit,
    required this.canDel,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus menu ini?'),
        content: Text('"${item.name}" akan dihapus permanen dari menu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: RestaurantColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await sl<MenuRepository>().deleteItem(item);
      await sl<MenuProvider>().deleteMenuItem(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RestaurantColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RestaurantColors.cardBorder),
      ),
      child: Row(
        children: [
          item.imageUrl != null
              ? Container(
                  width: 52,
                  height: 52,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppImageLoader().load(
                    item.imageUrl ?? "",
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: RestaurantColors.accentOrange.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: RestaurantColors.accentOrange,
                  ),
                ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: RestaurantColors.textPrimary,
                        ),
                      ),
                    ),
                    if (!item.isAvailable) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: RestaurantColors.dangerBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Nonaktif',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: RestaurantColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (item.isFavorite) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: RestaurantColors.accentOrange,
                      ),
                    ],
                    if (item.isBanner) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.slideshow,
                        size: 16,
                        color: RestaurantColors.accentOrange,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${categoryName ?? 'Tanpa kategori'} · ${formatRupiah(item.price)}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: RestaurantColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (canEdit)
            IconButton(
              tooltip: 'Edit',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MenuFormScreen(existingItem: item),
                ),
              ),
              icon: const Icon(
                Icons.edit_outlined,
                color: RestaurantColors.textSecondary,
              ),
            ),
          if (canDel)
            IconButton(
              tooltip: 'Hapus',
              onPressed: () => _confirmDelete(context),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: RestaurantColors.danger,
              ),
            ),
        ],
      ),
    );
  }
}
