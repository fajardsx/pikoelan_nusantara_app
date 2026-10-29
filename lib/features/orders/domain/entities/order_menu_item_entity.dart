import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Versi milik fitur Orders sendiri - beda dengan OrderMenuItemEntity di fitur
/// Dashboard (yang cuma butuh nama & status tersedia untuk hitung jumlah).
/// Di sini perlu harga juga karena dipakai untuk membangun keranjang pesanan.
class OrderMenuItemEntity extends Equatable {
  final int id;
  final String name;
  final double price;
  final bool isAvailable;

  const OrderMenuItemEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.isAvailable,
  });

  factory OrderMenuItemEntity.fromJson(Map<String, dynamic> json) {
    final numPrice = (json['price'] is num)
        ? (json['price'] as num).toDouble()
        : double.tryParse(json['price'].toString().replaceAll(',', '.')) ?? 0.0;
    debugPrint("order price : ${json['price'] is String}");
    return OrderMenuItemEntity(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: numPrice,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, price, isAvailable];
}
