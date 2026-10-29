import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';

class CartItem {
  final MenuItemEntity menuItem;
  final int quantity;
  final String? note;

  const CartItem({required this.menuItem, this.quantity = 1, this.note});

  int get subtotal => (menuItem.price * quantity).round();

  CartItem copyWith({int? quantity, String? note}) {
    return CartItem(
      menuItem: menuItem,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.menuItem == menuItem &&
        other.quantity == quantity &&
        other.note == note;
  }

  @override
  int get hashCode => menuItem.hashCode ^ quantity.hashCode ^ note.hashCode;
}
