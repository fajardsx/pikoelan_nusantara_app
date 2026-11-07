import 'package:restauran_menu/features/stock/domain/entities/category.dart';
import 'package:restauran_menu/features/stock/domain/repositories/stock_repository.dart';

class GetCategories {
  final StockRepository repository;
  GetCategories(this.repository);

  Future<List<Category>> call() => repository.getCategories();
}
