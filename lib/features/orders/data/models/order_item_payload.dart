class OrderItemPayload {
  final int menuItemId;
  final int quantity;
  final String? notes;

  OrderItemPayload({required this.menuItemId, required this.quantity, this.notes});

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'quantity': quantity,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}
