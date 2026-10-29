import '../../data/models/category_payload.dart';
import '../entities/menu_category_entity.dart';
import '../repositories/menu_repositories.dart';

class CreateCategoryUsecase {
  final MenuDataRepository repository;
  const CreateCategoryUsecase(this.repository);

  Future<MenuCategoryEntity?> call(CategoryPayload payload) =>
      repository.createCategory(payload);
}
