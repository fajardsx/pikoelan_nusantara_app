class Consts {
  // version
  static String appVersion = "1.0.2";
  // GET STORAGE NAME
  static const String storageNameKey = 'wisma';
  static const String loginDataKey = 'login_data';
  static const String accessTokenKey = 'access_token';
  static const String rememberMeKey = 'remember_me';
  static const String keyFcm = 'fcm_data';

  // GETX STATE TAG
  static const String keyUserController = 'key_user_controller';
  static const String keyIncompleteFormController =
      'key_incomplete_form_controller';

  // BOX Key Name
  static const String keyIsFirst = 'isfirst';

  // DEMO TO CLIENT
  static const bool clientMode = false;

  // API DISABLE
  static const bool demoMode = false; // CHANGE MODE FOR DEMO TO CLIENT
  static const bool showMonitor =
      true; // SHOW LOG MONITORING AT RELEASE APPS IN DEVICES
  static const bool enableTopup = true; // SHOW BUTTON TOPUP

  // IMAGE URL
  static const String urlPhoto = "";
  static const String urlApps = "";

  static const double textScaleValue = 1.0;
  static int minFinancial = 100000000;
  static int reqReadMsg = 5;

  static String appName = "Warung Nasi Uduk";
  static String appSlug = "warung-nasi-uduk";
  static String appIcon = "";

  // cache
  static Map<String, dynamic> cachePictureSize = {
    "cacheHeigth": 600,
    "cacheWidth": null,
  };

  // META
  static int metaPerPage = 10;

  // INJECTOR TAG
  static const String syncProviderTag = 'sync_provider_tag';
  static const String connectivityServiceTag = 'connectivity_service_tag';
  static const String optionsTag = 'options_tag';

  // ROLE
  static const roleOptions = [
    ('staff', 'Staf'),
    ('kasir', 'Kasir'),
    ('waiters', 'Pelayan'),
    ('kitchen', 'Dapur'),
    ('manager', 'Manajer'),
  ];
}
