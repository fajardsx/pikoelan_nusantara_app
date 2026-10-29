import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';

class ReportDateFilter extends StatelessWidget {
  final String startLabel;
  final String endLabel;
  final bool isLoading;
  final bool hasFilter;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onApply;
  final VoidCallback onReset;

  const ReportDateFilter({
    super.key,
    required this.startLabel,
    required this.endLabel,
    required this.isLoading,
    required this.hasFilter,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onApply,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                Icons.date_range_rounded,
                size: 16,
                color: RestaurantColors.primaryBrown,
              ),
              SizedBox(width: 8),
              Text(
                'Filter Tanggal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: RestaurantColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 520;
              final s = _DateField(
                label: 'Dari',
                valueLabel: startLabel,
                filled: startLabel != 'Pilih tanggal',
                onTap: onPickStart,
              );
              final e = _DateField(
                label: 'Sampai',
                valueLabel: endLabel,
                filled: endLabel != 'Pilih tanggal',
                onTap: onPickEnd,
              );
              if (isNarrow) {
                return Column(children: [s, const SizedBox(height: 12), e]);
              }
              return Row(
                children: [
                  Expanded(child: s),
                  const SizedBox(width: 12),
                  Expanded(child: e),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: isLoading ? null : onApply,
                icon: const Icon(Icons.filter_alt_rounded, size: 16),
                label: Text(isLoading ? 'Memuat...' : 'Terapkan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RestaurantColors.primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              if (hasFilter)
                OutlinedButton.icon(
                  onPressed: isLoading ? null : onReset,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    foregroundColor: RestaurantColors.textPrimary,
                    side: const BorderSide(color: RestaurantColors.cardBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String valueLabel;
  final bool filled;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.valueLabel,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: RestaurantColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: RestaurantColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: RestaurantColors.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: RestaurantColors.primaryBrown,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    valueLabel,
                    style: TextStyle(
                      fontSize: 13,
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
