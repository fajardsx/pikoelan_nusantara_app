import 'package:flutter/material.dart';

import '../../../../core/network/envi_services.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../domain/entities/menu_item_entity.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemEntity item;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.canManage,
    this.onEdit,
    this.onDelete,
  });

  /// imageUrl dari backend biasanya sudah URL penuh (Supabase Storage),
  /// tapi jaga-jaga kalau masih path relatif (data lama).
  String? _resolveImageUrl(String? url) {
    if (url == null) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${EnviServices.baseUrl}/$url';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(item.imageUrl);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.4,
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _NoImagePlaceholder(),
                  )
                : const _NoImagePlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.isFavorite || item.isBanner)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Wrap(
                      spacing: 4,
                      children: [
                        if (item.isFavorite)
                          const _MiniTag(
                            label: 'FAVORIT',
                            color: AppColors.accent,
                            bg: AppColors.accentSoft,
                          ),
                        if (item.isBanner)
                          const _MiniTag(
                            label: 'BANNER',
                            color: Color(0xFF2E5F8A),
                            bg: Color(0xFFDCEAF5),
                          ),
                      ],
                    ),
                  ),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      formatRupiah(item.price),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    if (item.hasDiscount) ...[
                      const SizedBox(width: 6),
                      Text(
                        formatRupiah(item.originalPrice!),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10.5,
                          color: AppColors.inkFaint,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                if (!item.isAvailable)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'TIDAK TERSEDIA',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                if (canManage) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onEdit,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            minimumSize: Size.zero,
                            textStyle: const TextStyle(fontSize: 11.5),
                          ),
                          child: const Text('Ubah'),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onDelete,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.dangerSoft),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            minimumSize: Size.zero,
                            textStyle: const TextStyle(fontSize: 11.5),
                          ),
                          child: const Text('Hapus'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoImagePlaceholder extends StatelessWidget {
  const _NoImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarySoft,
      alignment: Alignment.center,
      child: const Text(
        'TANPA FOTO',
        style: TextStyle(
          fontSize: 10,
          fontFamily: 'monospace',
          color: AppColors.primarySoft,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _MiniTag({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
