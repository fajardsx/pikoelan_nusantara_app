import '../../data/models/category_payload.dart';
import '../entities/menu_category_entity.dart';
import '../repositories/menu_repositories.dart';

class UpdateCategoryUsecase {
  final MenuDataRepository repository;
  const UpdateCategoryUsecase(this.repository);

  Future<MenuCategoryEntity?> call(int id, CategoryPayload payload) =>
      repository.updateCategory(id, payload);
}
