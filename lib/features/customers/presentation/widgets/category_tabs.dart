import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/features/customers/presentation/provider/public_menu_provider.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_category_entity.dart';

import '../../../../core/themes/restaurant_colors.dart';

/// [selectedId] is `null` for "Semua".
/// Sumber kategori: [PublicMenuProvider] dari GET `api/menu/:slug`.
/// [categoriesOverride] opsional untuk preview/test tanpa provider.
class CategoryTabs extends StatelessWidget {
  final int? selectedId;
  final ValueChanged<int?> onSelected;
  final List<MenuCategoryEntity>? categoriesOverride;

  const CategoryTabs({
    super.key,
    required this.selectedId,
    required this.onSelected,
    this.categoriesOverride,
  });

  @override
  Widget build(BuildContext context) {
    List<MenuCategoryEntity> categories = categoriesOverride ?? [];
    if (categoriesOverride == null) {
      try {
        categories = context.watch<PublicMenuProvider>().categories;
      } catch (_) {
        categories = [];
      }
    }
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final label = isAll ? 'Semua' : categories[index - 1].name;
          final id = isAll ? null : categories[index - 1].id;
          final isSelected =
              selectedId == id || (isAll && selectedId == null);
          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onSelected(id),
            showCheckmark: false,
            selectedColor: RestaurantColors.primaryBrown,
            backgroundColor: RestaurantColors.background,
            side: BorderSide(
              color: isSelected
                  ? RestaurantColors.primaryBrown
                  : RestaurantColors.cardBorder,
            ),
            labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : RestaurantColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          );
        },
      ),
    );
  }
}
