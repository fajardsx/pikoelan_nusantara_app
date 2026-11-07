import 'dart:convert';

import 'package:restauran_menu/core/configs/api_keys.dart';
import 'package:restauran_menu/core/network/dio_client.dart';
import 'package:restauran_menu/features/stock/data/models/stock_category_dto.dart';
import 'package:restauran_menu/features/stock/domain/entities/category.dart';
import 'package:restauran_menu/features/stock/domain/entities/stock_item.dart';
import 'package:restauran_menu/features/stock/domain/entities/unit.dart';

import '../../models/stock_item_dto.dart';
import '../../models/stock_unit_dto.dart';

class StockRemoteDataSource {
  StockRemoteDataSource();

  Future<List<StockItem>> fetchStockItems({Map<String, String>? query}) async {
    final uri = ApiKeys.stockItems;
    final response = await DioClient.instance.get(
      uri,
      forceRefresh: true,
      queryParameters: query,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load stock items');
    }
    final List data = response.data['data']['stockItems'];
    return data.map((e) => StockItem.fromJson(e)).toList();
  }

  // New method to fetch units
  Future<List<Unit>> fetchUnits() async {
    final uri = ApiKeys.stockUnit;
    final response = await DioClient.instance.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load units');
    }
    final List data = response.data['data']['units'];
    return data.map((e) => Unit.fromJson(e)).toList();
  }

  Future<Unit> createUnit(StockUnitDto dto) async {
    final uri = ApiKeys.stockUnit;
    final response = await DioClient.instance.post(
      uri,
      data: json.encode(dto.toJson()),
    );
    if (response.statusCode != 201) throw Exception('Create unit failed');
    final e = response.data['data']['unit'];
    return Unit.fromJson(e);
  }

  // New methods for categories
  Future<List<Category>> fetchCategories() async {
    final uri = ApiKeys.stockCategory;
    final response = await DioClient.instance.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load categories');
    }
    final List data = response.data['data']['categories'];
    return data.map((e) => Category.fromJson(e)).toList();
  }

  Future<Category> createCategory(StockCategoryDto dto) async {
    final uri = ApiKeys.stockCategory;
    final response = await DioClient.instance.post(
      uri,
      data: json.encode(dto.toJson()),
    );
    if (response.statusCode != 201) throw Exception('Create category failed');
    final e = response.data['data']['category'];
    return Category.fromJson(e);
  }

  Future<StockItem> createStockItem(StockItemDto dto) async {
    final uri = ApiKeys.stockItems;
    final response = await DioClient.instance.post(
      uri,
      data: json.encode(dto.toJson()),
    );
    if (response.statusCode != 201) throw Exception('Create failed');
    final e = response.data['data']['stockItem'];
    return StockItem.fromJson(e);
  }

  Future<StockItem> updateStockItem(int id, StockItemDto dto) async {
    final uri = ApiKeys.stockItemsById(id);
    final response = await DioClient.instance.put(
      uri,
      data: json.encode(dto.toJson()),
    );
    if (response.statusCode != 200) throw Exception('Update failed');
    final e = response.data['data']['stockItem'];
    return StockItem.fromJson(e);
  }

  Future<void> deleteStockItem(int id) async {
    final uri = ApiKeys.stockItemsById(id);
    final response = await DioClient.instance.delete(uri.toString());
    if (response.statusCode != 200) throw Exception('Delete failed');
  }
}
