class CacheEntry {
  final dynamic data;
  final DateTime expiredDate;

  const CacheEntry({required this.data, required this.expiredDate});

  bool get isExpired => DateTime.now().isAfter(expiredDate);

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      data: json['data'],
      expiredDate: DateTime.fromMillisecondsSinceEpoch(json['expired_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data, 'expired_date': expiredDate.millisecondsSinceEpoch};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CacheEntry &&
        other.data == data &&
        other.expiredDate == expiredDate;
  }

  @override
  int get hashCode => data.hashCode ^ expiredDate.hashCode;
}
