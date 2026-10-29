abstract class AppBaseResponse<T> {
  final int? code;
  final bool? success;
  final String? message;
  final T? data;
  final List<ErrorResponse>? error;
  final AppBaseResponseMeta? pagination;

  AppBaseResponse({
    required this.code,
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
    this.error,
  });
}

class ErrorResponse {
  final String? code;
  final String? field;
  final String? message;

  ErrorResponse({required this.code, required this.field, required this.message});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      code: json['code'] as String?,
      field: json['field'] as String?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'field': field, 'message': message};
  }
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

abstract class AppBaseFaqResponse<T> {
  final int? code;
  final bool? success;
  final String? message;
  final String? contactEmail;
  final T? data;

  AppBaseFaqResponse({
    required this.code,
    required this.success,
    required this.message,
    required this.contactEmail,
    required this.data,
  });
}

abstract class AppBaseVisitResponse<T> {
  final int? code;
  final int? currentPage;
  final int? lastPage;
  final bool? success;
  final String? message;
  final T? data;

  AppBaseVisitResponse({
    required this.code,
    required this.currentPage,
    required this.lastPage,
    required this.success,
    required this.message,
    required this.data,
  });
}

abstract class AppFilterResponse<T> {
  final int? code;
  final bool? success;
  final bool? enable;
  final String? message;
  final T? data;
  final List<ErrorResponse>? error;

  AppFilterResponse({
    required this.code,
    required this.success,
    required this.enable,
    required this.message,
    required this.data,
    this.error,
  });
}
