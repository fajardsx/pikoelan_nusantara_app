import 'package:restauran_menu/features/customers/data/models/public_menu_response.dart';
import 'package:restauran_menu/features/customers/domain/repositories/public_menu_repository.dart';

class GetPublicMenuUsecase {
  final PublicMenuRepository repository;
  const GetPublicMenuUsecase(this.repository);
  Future<PublicMenuData> call(String slug, {bool forceRefresh = false}) =>
      repository.getPublicMenu(slug, forceRefresh: forceRefresh);
}
