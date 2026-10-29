import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class CategoryPayload {
  final String name;
  final int? sortOrder;
  final bool? isActive;
  final XFile? imageFile;

  CategoryPayload({
    required this.name,
    this.sortOrder,
    this.isActive,
    this.imageFile,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'name': name,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (isActive != null) 'isActive': isActive,
      if (imageFile != null)
        'image': MultipartFile.fromBytes(
          await imageFile!.readAsBytes(),
          filename: 'image.jpg',
        ),
    });
  }
}
