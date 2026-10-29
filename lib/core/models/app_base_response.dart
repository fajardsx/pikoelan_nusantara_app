abstract class AppBaseResponse<T> {
  final int? code;
  final String? message;
  final T? data;
  final AppBaseResponseMeta? meta;

  AppBaseResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.meta,
    Object? success,
  });
}

class AppBaseResponseMeta {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;

  AppBaseResponseMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory AppBaseResponseMeta.fromJson(Map<String, dynamic> json) {
    return AppBaseResponseMeta(
      currentPage: json['current_page'] as int?,
      lastPage: json['last_page'] as int?,
      perPage: json['per_page'] as int?,
      total: json['total'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
    };
  }
}
