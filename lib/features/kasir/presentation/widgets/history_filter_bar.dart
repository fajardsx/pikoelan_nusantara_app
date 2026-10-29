import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';

/// Satu bar filter kompak: tanggal + tipe + status + aksi.
/// Hemat tempat: 1 card, tanpa judul besar, field rapat, responsif.
class HistoryFilterBar extends StatelessWidget {
  final String startLabel;
  final String endLabel;
  final bool isLoading;
  final bool hasFilter;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onApply;
  final VoidCallback onReset;
  final String? orderTypeValue;
  final String? statusValue;
  final ValueChanged<String?> onOrderTypeChanged;
  final ValueChanged<String?> onStatusChanged;
  final int resultCount;
  final String activeInfo;

  const HistoryFilterBar({
    super.key,
    required this.startLabel,
    required this.endLabel,
    required this.isLoading,
    required this.hasFilter,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onApply,
    required this.onReset,
    required this.orderTypeValue,
    required this.statusValue,
    required this.onOrderTypeChanged,
    required this.onStatusChanged,
    required this.resultCount,
    required this.activeInfo,
  });

  @override
  Widget build(BuildContext context) {
    final dateStart = _MiniDate(
      label: 'Dari',
      valueLabel: startLabel,
      filled: startLabel != 'Pilih tanggal',
      onTap: onPickStart,
    );
    final dateEnd = _MiniDate(
      label: 'Sampai',
      valueLabel: endLabel,
      filled: endLabel != 'Pilih tanggal',
      onTap: onPickEnd,
    );
    final typeField = _MiniDropdown<String?>(
      label: 'Tipe',
      value: orderTypeValue,
      items: const [
        DropdownMenuItem<String?>(value: null, child: Text('Semua')),
        DropdownMenuItem<String?>(
          value: OrderEntity.typeDineIn,
          child: Text('Dine In'),
        ),
        DropdownMenuItem<String?>(
          value: OrderEntity.typeTakeaway,
          child: Text('Take Away'),
        ),
        DropdownMenuItem<String?>(
          value: OrderEntity.typeDelivery,
          child: Text('Delivery'),
        ),
      ],
      onChanged: onOrderTypeChanged,
    );
    final statusField = _MiniDropdown<String?>(
      label: 'Status',
      value: statusValue,
      items: const [
        DropdownMenuItem<String?>(value: null, child: Text('Semua')),
        DropdownMenuItem<String?>(
          value: OrderEntity.statusNew,
          child: Text('Baru'),
        ),
        DropdownMenuItem<String?>(
          value: OrderEntity.statusProses,
          child: Text('Diproses'),
        ),
        DropdownMenuItem<String?>(
          value: OrderEntity.statusReady,
          child: Text('Siap'),
        ),
        DropdownMenuItem<String?>(
          value: OrderEntity.statusDeliver,
          child: Text('Diantar'),
        ),
        DropdownMenuItem<String?>(
          value: OrderEntity.statusCompleted,
          child: Text('Selesai'),
        ),
        DropdownMenuItem<String?>(
          value: OrderEntity.statusCancelled,
          child: Text('Batal'),
        ),
      ],
      onChanged: onStatusChanged,
    );
    final applyBtn = SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onApply,
        icon: const Icon(Icons.filter_alt_rounded, size: 15),
        label: Text(isLoading ? '...' : 'Filter'),
        style: ElevatedButton.styleFrom(
          backgroundColor: RestaurantColors.primaryBrown,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
      ),
    );
    final resetBtn = SizedBox(
      height: 36,
      width: 36,
      child: IconButton(
        tooltip: 'Reset',
        onPressed: isLoading ? null : onReset,
        icon: const Icon(Icons.refresh_rounded, size: 17),
        color: RestaurantColors.textSecondary,
        style: IconButton.styleFrom(
          side: const BorderSide(color: RestaurantColors.cardBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
      ),
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: RestaurantColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RestaurantColors.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, c) {
              const gap = 8.0;
              if (c.maxWidth >= 860) {
                return Row(
                  children: [
                    Expanded(child: dateStart),
                    const SizedBox(width: gap),
                    Expanded(child: dateEnd),
                    const SizedBox(width: gap),
                    Expanded(child: typeField),
                    const SizedBox(width: gap),
                    Expanded(child: statusField),
                    const SizedBox(width: gap),
                    // applyBtn,
                    // if (hasFilter) ...[const SizedBox(width: gap), resetBtn],
                  ],
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: dateStart),
                      const SizedBox(width: gap),
                      Expanded(child: dateEnd),
                    ],
                  ),
                  const SizedBox(height: gap),
                  Row(
                    children: [
                      Expanded(child: typeField),
                      const SizedBox(width: gap),
                      Expanded(child: statusField),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  hasFilter
                      ? (activeInfo.isEmpty
                            ? '$resultCount transaksi'
                            : '$activeInfo • $resultCount transaksi')
                      : '$resultCount transaksi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: RestaurantColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              //if (MediaQuery.sizeOf(context).width < 860)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasFilter) ...[resetBtn, const SizedBox(width: 8)],
                  applyBtn,
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniDate extends StatelessWidget {
  final String label;
  final String valueLabel;
  final bool filled;
  final VoidCallback onTap;
  const _MiniDate({
    required this.label,
    required this.valueLabel,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: RestaurantColors.textSecondary,
          ),
        ),
        const SizedBox(height: 3),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: RestaurantColors.background,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: RestaurantColors.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: RestaurantColors.primaryBrown,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    valueLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: filled ? FontWeight.w600 : FontWeight.normal,
                      color: filled
                          ? RestaurantColors.textPrimary
                          : RestaurantColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _MiniDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: RestaurantColors.textSecondary,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: RestaurantColors.background,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: RestaurantColors.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              isDense: true,
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                size: 18,
                color: RestaurantColors.primaryBrown,
              ),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: RestaurantColors.textPrimary,
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
