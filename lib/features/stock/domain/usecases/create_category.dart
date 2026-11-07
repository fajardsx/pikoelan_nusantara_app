import 'package:restauran_menu/features/stock/data/models/stock_category_dto.dart';
import 'package:restauran_menu/features/stock/domain/entities/category.dart';
import 'package:restauran_menu/features/stock/domain/repositories/stock_repository.dart';

class CreateCategory {
  final StockRepository repository;
  CreateCategory(this.repository);

  Future<Category> call(StockCategoryDto dto) => repository.createCategory(dto);
}
