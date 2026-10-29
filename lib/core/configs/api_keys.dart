class ApiKeys {
  // home
  static const String getAllUser = "api/users";
  static const String getUserById = "api/users/"; // id

  // Profile
  static const String getMyProfile = "api/auth/profile";
  static const String editMyProfile = "api/users/";
  static const String changePassword = "api/auth/change-password";
  static const String uploadPhotoProfile = "api/upload/profile-picture";

  // AUTH
  static const String authLogin = 'api/auth/login';
  static const String authProfile = 'api/auth/profile';
  static const String resendVerification = 'api/auth/resend-verification';

  // TENANT (restoran)
  static const String tenantMe = 'api/tenants/me';
  static const String inviteStaff = 'api/tenants/staff';
  static String deleteStaff(int id) => 'api/tenants/staff/$id';

  // STAFF
  static const String users = 'api/users';

  // ORDERS
  static const String orders = 'api/orders';
  static String orderStatus(int id) => 'api/orders/$id/status';

  // MENU
  static const String menuCategories = 'api/menu/categories';
  static String menuCategory(int id) => 'api/menu/categories/$id';
  static const String menuItems = 'api/menu/items';
  static String menuItem(int id) => 'api/menu/items/$id';

  // PUBLIC
  static String menuPublic(String slug) => 'api/public/menu/$slug';
  static String menuPublicOrder(String slug) => 'api/public/menu/$slug/order';
  static String menuPublicMyOrder(String slug) =>
      'api/public/menu/$slug/my_orders';

  // NOTIFICATION STREAM
  static String orderStream(String jwt) =>
      '/api/notifications/orders/stream?token=$jwt';
  static String streamStats = '/api/notifications/stats';

  // PERMISSIONS (privilege per role)
  static const String permissions = 'api/permission';
  static const String myPermissions = 'api/permission/me';
  static String rolePermissions(String role) => 'api/permission/$role';

  // TENANT PAYMENT
  static const String tenantPayment = 'api/payments';
  static String tenantPaymentById(String id) => 'api/payments/$id';
}
