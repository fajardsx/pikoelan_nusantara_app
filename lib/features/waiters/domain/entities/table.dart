enum TableStatus { kosong, terisi }

extension TableStatusLabel on TableStatus {
  String get label => this == TableStatus.kosong ? 'Kosong' : 'Terisi';
}

class RestaurantTable {
  final int number;
  final TableStatus status;
  final String? orderNumber;
  final int? guestCount;

  const RestaurantTable({
    required this.number,
    required this.status,
    this.orderNumber,
    this.guestCount,
  });

  RestaurantTable copyWith({
    TableStatus? status,
    String? orderNumber,
    bool clearOrderNumber = false,
    int? guestCount,
    bool clearGuestCount = false,
  }) {
    return RestaurantTable(
      number: number,
      status: status ?? this.status,
      orderNumber: clearOrderNumber ? null : (orderNumber ?? this.orderNumber),
      guestCount: clearGuestCount ? null : (guestCount ?? this.guestCount),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RestaurantTable &&
        other.number == number &&
        other.status == status &&
        other.orderNumber == orderNumber &&
        other.guestCount == guestCount;
  }

  @override
  int get hashCode {
    return number.hashCode ^
        status.hashCode ^
        orderNumber.hashCode ^
        guestCount.hashCode;
  }
}
