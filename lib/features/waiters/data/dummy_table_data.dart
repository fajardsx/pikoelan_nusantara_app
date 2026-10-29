import '../domain/entities/table.dart';

/// Static dummy floor layout so the Waiter module can be demoed without a
/// backend. Occupied tables line up with [DummyOrderData.activeOrders].
class DummyTableData {
  DummyTableData._();

  static List<RestaurantTable> tables = [
    const RestaurantTable(
      number: 1,
      status: TableStatus.terisi,
      orderNumber: '#0024',
      guestCount: 2,
    ),
    const RestaurantTable(number: 2, status: TableStatus.kosong),
    const RestaurantTable(
      number: 3,
      status: TableStatus.terisi,
      orderNumber: '#0025',
      guestCount: 4,
    ),
    const RestaurantTable(number: 4, status: TableStatus.kosong),
    const RestaurantTable(
      number: 5,
      status: TableStatus.terisi,
      orderNumber: '#0023',
      guestCount: 1,
    ),
    const RestaurantTable(number: 6, status: TableStatus.kosong),
    const RestaurantTable(number: 7, status: TableStatus.kosong),
    const RestaurantTable(number: 8, status: TableStatus.kosong),
  ];
}
