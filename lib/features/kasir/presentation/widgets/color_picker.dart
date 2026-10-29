import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';

class ColorPicker extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.label,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: RestaurantColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: () async {
            // In a real implementation, you would show a color picker dialog
            // For now, we'll just show a simple color selection
            final selectedColor = await showDialog<Color>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Pilih $label'),
                  content: SizedBox(
                    width: 300,
                    child: GridView.count(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: [
                        ..._getStandardColors().map(
                          (c) => _ColorOption(
                            color: c,
                            selected: c.toARGB32() == color.toARGB32(),
                            onTap: () => Navigator.pop(context, c),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
            if (selectedColor != null) {
              onColorChanged(selectedColor);
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: RestaurantColors.cardBorder),
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _getStandardColors() {
    return [
      const Color(0xFF8B4513), // Brown
      const Color(0xFFD2691E), // Chocolate
      const Color(0xFF8B0000), // Dark Red
      const Color(0xFF2F4F4F), // Dark Slate Gray
      const Color(0xFF006400), // Dark Green
      const Color(0xFF4B0082), // Indigo
      const Color(0xFF800080), // Purple
      const Color(0xFFDC143C), // Crimson
      const Color(0xFFFF8C00), // Dark Orange
      const Color(0xFF4682B4), // Steel Blue
    ];
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: selected
              ? Border.all(color: Colors.white, width: 3)
              : Border.all(color: RestaurantColors.cardBorder),
        ),
      ),
    );
  }
}
