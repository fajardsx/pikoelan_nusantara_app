import 'package:restauran_menu/features/stock/domain/entities/category.dart';

import '../../data/models/stock_category_dto.dart';
import '../repositories/stock_repository.dart';

class UpdateCategory {
  final StockRepository repository;
  UpdateCategory(this.repository);

  Future<Category> call(int id, StockCategoryDto dto) =>
      repository.updateCategory(id, dto);
}
