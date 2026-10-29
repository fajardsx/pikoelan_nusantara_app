import '../../data/models/menu_item_payload.dart';
import '../entities/menu_item_entity.dart';
import '../repositories/menu_repositories.dart';

class UpdateMenuItemUsecase {
  final MenuDataRepository repository;
  const UpdateMenuItemUsecase(this.repository);

  Future<MenuItemEntity?> call(int id, MenuItemPayload payload) =>
      repository.updateMenuItem(id, payload);
}
