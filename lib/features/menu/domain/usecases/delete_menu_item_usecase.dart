import '../repositories/menu_repositories.dart';

class DeleteMenuItemUsecase {
  final MenuDataRepository repository;
  const DeleteMenuItemUsecase(this.repository);

  Future<void> call(int id) => repository.deleteMenuItem(id);
}
