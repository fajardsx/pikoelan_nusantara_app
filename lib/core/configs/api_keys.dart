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
  static String menuPublicPromoValidate(String slug) =>
      'api/public/menu/$slug/promo/validate';
  static String menuPublicMember(String slug) =>
      'api/public/menu/$slug/member/lookup';

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

  // PROMO
  static const String promos = 'api/promos/';
  static const String statPromo = 'api/promos/stats';
  static const String validatePromo = 'api/promos/validate';
  static String promoById(String id) => 'api/promos/$id';
  static String toggleStatusPromoById(String id) => 'api/promos/$id/toggle';

  // MEMBER
  static const String member = 'api/members';
  static const String statsMember = 'api/members/stats';
  static const String lookupMember = 'api/members/lookup';
  static const String validateMemberByPhone = 'api/members/validate-phone';
  static String memberById(String id) => 'api/members/$id';
  static String memberPointById(String id) => 'api/members/$id/points';
  static String memberHistoryById(String id) => 'api/members/$id/history';
}
