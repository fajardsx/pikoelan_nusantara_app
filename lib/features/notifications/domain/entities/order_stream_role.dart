/// Peran dashboard staf yang menerima stream order realtime.
enum OrderStreamRole {
  kasir('kasir'),
  kitchen('kitchen'),
  waiter('waiter');

  const OrderStreamRole(this.value);

  final String value;

  /// Mapping dari label role user (backend) ke role stream.
  static OrderStreamRole? fromUserRole(String? role) {
    switch ((role ?? '').trim().toLowerCase()) {
      case 'kasir':
      case 'cashier':
        return OrderStreamRole.kasir;
      case 'kitchen':
      case 'dapur':
      case 'chef':
        return OrderStreamRole.kitchen;
      case 'waiter':
      case 'waiters':
      case 'pelayan':
        return OrderStreamRole.waiter;
      default:
        return null;
    }
  }
}
