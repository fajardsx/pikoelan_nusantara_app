import '../../data/models/menu_item_payload.dart';
import '../entities/menu_item_entity.dart';
import '../repositories/menu_repositories.dart';

class CreateMenuItemUsecase {
  final MenuDataRepository repository;
  const CreateMenuItemUsecase(this.repository);

  Future<MenuItemEntity?> call(MenuItemPayload payload) =>
      repository.createMenuItem(payload);
}
