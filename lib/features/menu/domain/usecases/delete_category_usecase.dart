import '../repositories/menu_repositories.dart';

class DeleteCategoryUsecase {
  final MenuDataRepository repository;
  const DeleteCategoryUsecase(this.repository);

  Future<void> call(int id) => repository.deleteCategory(id);
}
