import 'dart:convert';

import 'package:restauran_menu/core/configs/api_keys.dart';
import 'package:restauran_menu/core/network/dio_client.dart';
import 'package:restauran_menu/features/stock/data/models/stock_movement_dto.dart';
import 'package:restauran_menu/features/stock/domain/entities/stock_movement.dart';

class StockMovementRemoteDataSource {
  Future<List<StockMovement>> fetchStockMovements({
    int? stockItemId,
    String? startDate,
    String? endDate,
  }) async {
    final baseUrl = stockItemId != null
        ? ApiKeys.stockMovementsByItemId(stockItemId)
        : ApiKeys.stockMovements;
    
    final queryParams = <String, dynamic>{};
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }

    final response = await DioClient.instance.get(
      baseUrl,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      forceRefresh: true,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load stock movements');
    }
    final List data =
        response.data['data']['stockMovements'] ??
        response.data['data']['movements'] ??
        response.data['data'] ??
        [];
    return data.map((e) => StockMovement.fromJson(e)).toList();
  }

  Future<StockMovement> createStockMovement(StockMovementDto dto) async {
    final uri = ApiKeys.stockMovements;
    final response = await DioClient.instance.post(
      uri,
      data: json.encode(dto.toJson()),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Create stock movement failed');
    }
    final e =
        response.data['data']['stockMovement'] ??
        response.data['data']['movement'] ??
        response.data['data'];
    return StockMovement.fromJson(e);
  }

  Future<void> deleteStockMovement(int id) async {
    final uri = '${ApiKeys.stockMovements}/$id';
    final response = await DioClient.instance.delete(uri);
    if (response.statusCode != 200) {
      throw Exception('Delete stock movement failed');
    }
  }
}
