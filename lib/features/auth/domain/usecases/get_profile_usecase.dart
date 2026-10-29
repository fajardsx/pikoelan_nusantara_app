import 'package:restauran_menu/features/auth/domain/entities/user_entities.dart';

import '../repositories/auth_repositories.dart';

class GetProfileUsecase {
  final AuthRepository repository;

  GetProfileUsecase(this.repository);

  Future<User?> call() async {
    return repository.getDetailUser();
  }
}
