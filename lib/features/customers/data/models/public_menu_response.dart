import 'package:restauran_menu/core/network/models/app_base_response.dart';
import 'package:restauran_menu/features/admin/domain/entities/tenant_entity.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_category_entity.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';

class PublicMenuData {
  final TenantEntity? tenant;
  final List<MenuCategoryEntity> categories;
  final List<MenuItemEntity> items;
  const PublicMenuData({
    this.tenant,
    this.categories = const [],
    this.items = const [],
  });
}

class PublicMenuResponse extends AppBaseResponse<PublicMenuData> {
  PublicMenuResponse({
    required super.code,
    required super.message,
    required super.data,
    required super.success,
  });
  factory PublicMenuResponse.fromJson(dynamic json) {
    // Handle case where the API returns a raw list of menu items.

    if (json is List) {
      final items = json
          .whereType<Map>()
          .map(
            (e) =>
                MenuItemEntity.fromJson(normMenu(Map<String, dynamic>.from(e))),
          )
          .toList();
      return PublicMenuResponse(
        code: null,
        success: null,
        message: null,
        data: PublicMenuData(items: items),
      );
    }
    // Expect a map/object response.
    final Map<String, dynamic> map = json is Map<String, dynamic>
        ? json
        : Map<String, dynamic>.from(json);
    final raw = map['data'];
    if (raw is List) {
      return PublicMenuResponse(
        code: map['code'] as int?,
        success: map['success'] as bool?,
        message: map['message'] as String?,
        data: PublicMenuData(
          items: raw
              .whereType<Map>()
              .map(
                (e) => MenuItemEntity.fromJson(
                  normMenu(Map<String, dynamic>.from(e)),
                ),
              )
              .toList(),
        ),
      );
    }
    final Map<String, dynamic> data = raw is Map
        ? Map<String, dynamic>.from(raw)
        : map;
    final root = pickMap(data, const ['menu', 'result']) ?? data;
    final tenantJson = pickMap(root, const [
      'tenant',
      'restaurant',
      'store',
      'merchant',
    ]);
    final catList = pickList(root, const [
      'categories',
      'menuCategories',
      'menu_categories',
    ]);
    final itemList = pickList(root, const [
      'items',
      'menus',
      'menuItems',
      'products',
      'menu_items',
      'data',
    ]);
    return PublicMenuResponse(
      code: map['code'] as int?,
      success: map['success'] as bool?,
      message: map['message'] as String?,
      data: PublicMenuData(
        tenant: tenantJson == null
            ? null
            : TenantEntity.fromJson(normTenant(tenantJson)),
        categories: catList
            .map(
              (e) => MenuCategoryEntity.fromJson(
                normCat(Map<String, dynamic>.from(e as Map)),
              ),
            )
            .toList(),
        items: itemList
            .map(
              (e) => MenuItemEntity.fromJson(
                normMenu(Map<String, dynamic>.from(e as Map)),
              ),
            )
            .toList(),
      ),
    );
  }
  static Map<String, dynamic>? pickMap(
    Map<String, dynamic> r,
    List<String> keys,
  ) {
    for (final k in keys) {
      final v = r[k];
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return Map<String, dynamic>.from(v);
    }
    return null;
  }

  static List pickList(Map<String, dynamic> r, List<String> keys) {
    for (final k in keys) {
      if (r[k] is List) return r[k] as List;
    }
    for (final v in r.values) {
      if (v is Map<String, dynamic>) {
        for (final k in keys) {
          if (v[k] is List) return v[k] as List;
        }
      }
    }
    return const [];
  }
}

int toIntOf(dynamic v) => toIntOrNull(v) ?? 0;
int? toIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

bool toBoolOf(dynamic v, {bool fallback = false}) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.toLowerCase().trim();
    if (s == 'true' || s == '1' || s == 'aktif') return true;
    if (s == 'false' || s == '0') return false;
  }
  return fallback;
}

Map<String, dynamic> normMenu(Map<String, dynamic> j) => {
  'id': toIntOf(j['id'] ?? j['menuId'] ?? j['menu_id'] ?? 0),
  'categoryId': toIntOrNull(j['categoryId'] ?? j['category_id']),
  'name': (j['name'] ?? j['menuName'] ?? j['title'] ?? '').toString(),
  'description': (j['description'] ?? j['desc'])?.toString(),
  'price': j['price'] ?? j['harga'] ?? 0,
  'originalPrice': j['originalPrice'] ?? j['original_price'],
  'imageUrl': j['imageUrl'] ?? j['image_url'] ?? j['image'] ?? j['photo'],
  'isAvailable': toBoolOf(
    j['isAvailable'] ?? j['is_available'] ?? j['available'] ?? true,
    fallback: true,
  ),
  'isFavorite': toBoolOf(
    j['isFavorite'] ?? j['is_favorite'] ?? j['favorite'] ?? false,
  ),
  'isBanner': toBoolOf(j['isBanner'] ?? j['is_banner'] ?? false),
  'sortOrder': toIntOf(j['sortOrder'] ?? j['sort_order'] ?? 0),
};
Map<String, dynamic> normCat(Map<String, dynamic> j) => {
  'id': toIntOf(j['id'] ?? 0),
  'name': (j['name'] ?? '').toString(),
  'categoriesPicture': j['categoriesPicture'] ?? j['image'] ?? j['icon'],
  'sortOrder': toIntOf(j['sortOrder'] ?? j['sort_order'] ?? 0),
  'isActive': toBoolOf(j['isActive'] ?? j['is_active'] ?? true, fallback: true),
};
Map<String, dynamic> normTenant(Map<String, dynamic> j) => {
  'id': toIntOf(j['id'] ?? 0),
  'name': (j['name'] ?? j['restaurantName'] ?? '').toString(),
  'slug': (j['slug'] ?? '').toString(),
  'isActive': toBoolOf(j['isActive'] ?? j['is_active'] ?? true, fallback: true),
  'address': (j['address'] ?? j['alamat'])?.toString(),
  'phone': (j['phone'] ?? j['phoneNumber'])?.toString(),
  'email': (j['email'])?.toString(),
  'logo_url': (j['logo_url'] ?? j['logoUrl'] ?? j['logo'])?.toString(),
  'qris_url': (j['qris_url'] ?? j['qrisUrl'] ?? j['qris'])?.toString(),
  'rekening': (j['rekening'] ?? j['rekening'] ?? j['rekening'])?.toString(),
  'payments': (() {
    final raw = j['payments'] ?? j['payment'];
    if (raw == null) return <dynamic>[];
    if (raw is List) return raw;
    // Jika yang diterima berupa objek tunggal, ubah menjadi list satu item
    return [raw];
  })(),
};
