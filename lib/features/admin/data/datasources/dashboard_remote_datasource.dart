import 'package:flutter/material.dart';

import '../../../../core/configs/api_keys.dart';
import '../../../../core/network/dio_client.dart';
import '../models/menu_items_response.dart';
import '../models/orders_response.dart';
import '../models/tenant_payload.dart';
import '../models/tenant_response.dart';

abstract class DashboardRemoteDataSource {
  Future<TenantResponse> getMyTenant();
  Future<TenantResponse> updateMyTenant(TenantPayload payload);
  Future<OrdersResponse> getOrders({DateTime? startDate, DateTime? endDate});
  Future<MenuItemsResponse> getMenuItems({bool? available});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  @override
  Future<TenantResponse> getMyTenant() async {
    final res = await DioClient.instance.get(
      ApiKeys.tenantMe,
      forceRefresh: true,
    );
    return TenantResponse.fromJson(res.data);
  }

  @override
  Future<TenantResponse> updateMyTenant(TenantPayload payload) async {
    // Kalau ada file logo baru dari _pickImage -> kirim multipart/form-data
    // (pola sama seperti MenuItemPayload.toFormData).
    // Kalau tidak ada file -> kirim JSON biasa (logo_url saja).
    final data = payload.hasFile || payload.hasQrisFile
        ? await payload.toFormData()
        : payload.toJson();
    debugPrint(
      "has File : ${payload.hasFile} , has qris file ${payload.hasQrisFile}",
    );
    debugPrint("data : $data");
    final res = await DioClient.instance.put(ApiKeys.tenantMe, data: data);
    return TenantResponse.fromJson(res.data);
  }

  @override
  Future<OrdersResponse> getOrders({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final query = <String, dynamic>{
      if (startDate != null) 'startDate': fmt(startDate),
      if (endDate != null) 'endDate': fmt(endDate),
    };
    final res = await DioClient.instance.get(
      ApiKeys.orders,
      queryParameters: query.isEmpty ? null : query,
      forceRefresh: true,
    );
    return OrdersResponse.fromJson(res.data);
  }

  @override
  Future<MenuItemsResponse> getMenuItems({bool? available}) async {
    final res = await DioClient.instance.get(
      ApiKeys.menuItems,
      queryParameters: available == null ? null : {'available': available},
    );
    return MenuItemsResponse.fromJson(res.data);
  }
}
