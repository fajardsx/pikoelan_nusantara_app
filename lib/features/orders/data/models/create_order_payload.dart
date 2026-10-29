import 'order_item_payload.dart';

class CreateOrderPayload {
  final String orderType;
  final String? tableNumber;
  final String? customerName;
  final String? paymentMethod;
  final String? address;
  final String? phone;
  final String? notes;

  final String? sources;
  final List<OrderItemPayload> items;

  CreateOrderPayload({
    required this.orderType,
    this.tableNumber,
    this.customerName,
    this.paymentMethod,
    this.notes,
    this.sources,
    this.address,
    this.phone,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderType': orderType,
      if (tableNumber != null && tableNumber!.isNotEmpty)
        'tableNumber': tableNumber,
      if (customerName != null && customerName!.isNotEmpty)
        'customerName': customerName,
      if (paymentMethod != null && paymentMethod!.isNotEmpty)
        'paymentMethod': paymentMethod,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (sources != null && sources!.isNotEmpty) 'source': sources,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
