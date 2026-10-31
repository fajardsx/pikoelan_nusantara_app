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

  // -----------------------------------------------------------------
  //  NEW: optional data yang dapat dikirim bersama order
  // -----------------------------------------------------------------
  final int? memberId; // ID anggota (jika ada)
  final String? memberPhone; // Nomor telepon anggota (opsional)
  final String? promoCode; // Kode promo yang dipakai
  final int? redeemPoints; // Poin yang ingin ditukarkan pada order

  CreateOrderPayload({
    required this.orderType,
    this.tableNumber,
    this.customerName,
    this.paymentMethod,
    this.notes,
    this.sources,
    this.address,
    this.phone,
    this.memberId,
    this.memberPhone,
    this.promoCode,
    this.redeemPoints,
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

      // -------------------------------------------------------------
      //  NEW fields – hanya ditambahkan bila tidak null / tidak kosong
      // -------------------------------------------------------------
      if (memberId != null) 'memberId': memberId,
      if (memberPhone != null && memberPhone!.isNotEmpty)
        'memberPhone': memberPhone,
      if (promoCode != null && promoCode!.isNotEmpty) 'promoCode': promoCode,
      if (redeemPoints != null) 'redeemPoints': redeemPoints,

      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
