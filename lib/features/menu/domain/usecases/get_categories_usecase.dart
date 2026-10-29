import '../entities/menu_category_entity.dart';
import '../repositories/menu_repositories.dart';

class GetCategoriesUsecase {
  final MenuDataRepository repository;
  const GetCategoriesUsecase(this.repository);

  Future<List<MenuCategoryEntity>> call({bool refresh = false}) =>
      repository.getCategories(refresh: refresh);
}
