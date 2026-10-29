import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class MenuItemPayload {
  final String name;
  final double price;
  final double? originalPrice;
  final int? categoryId;
  final String? description;
  final bool isAvailable;
  final bool isFavorite;
  final bool isBanner;
  final XFile? imagePath;

  MenuItemPayload({
    required this.name,
    required this.price,
    this.originalPrice,
    this.categoryId,
    this.description,
    required this.isAvailable,
    required this.isFavorite,
    required this.isBanner,
    this.imagePath,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'name': name,
      'price': price,
      if (originalPrice != null) 'originalPrice': originalPrice,
      // kirim string kosong berarti "tanpa kategori" (backend menganggap ini clear category)
      'categoryId': categoryId?.toString() ?? '',
      if (description != null) 'description': description,
      'isAvailable': isAvailable,
      'isFavorite': isFavorite,
      'isBanner': isBanner,
      // imagePath adalah XFile dari image_picker — readAsBytes() jalan
      // di Web (bytes dari browser) maupun Android (bytes dari file),
      // jadi 1 kode ini sudah dual-mode tanpa dart:io.
      if (imagePath != null)
        'image': MultipartFile.fromBytes(
          await imagePath!.readAsBytes(),
          // Penting untuk Web: pakai nama asli (image.name),
          // jangan hardcode image.jpg agar ekstensi/MIME terbaca backend.
          filename: imagePath!.name.isNotEmpty ? imagePath!.name : 'image.jpg',
        ),
    });
  }
}
