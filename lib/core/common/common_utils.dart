import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:restauran_menu/core/services/shared_pref_services.dart';
import 'package:restauran_menu/features/admin/domain/entities/tenant_entity.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';

String getErrorMessage(List<dynamic> messageerror) {
  var errormsg = "";
  for (var i = 0; i < messageerror.length; i++) {
    final item = messageerror[i];
    if (item is Map) {
      var msg = item['message'] as String;
      errormsg += "$msg ";
    } else if (item is List<String>) {
      errormsg += "${item.join(" ")} ";
    } else if (item is String) {
      errormsg += "$item ";
    }
  }
  return errormsg.trim();
}

String getFailedMessage(Map<String, dynamic> messageerror) {
  var errormsg = "";

  for (final key in messageerror.keys) {
    final value = messageerror[key];
    if (value is List) {
      errormsg += value.join(" ");
    }
  }
  return errormsg.trim();
}

Widget alertError({BuildContext? context, String alert = ""}) {
  return Container(
    padding: EdgeInsets.only(left: 10.sp, top: 5.sp),
    child: Text(
      alert,
      style: TextStyle(
        fontSize: 13.sp,
        color: const Color.fromARGB(255, 253, 0, 0),
      ),
    ),
  );
}

bool validateEmail({String email = ""}) {
  String p =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  final patternEmailValid = RegExp(p); //.hasMatch(email);
  return patternEmailValid.hasMatch(email);
}

String maskEmail(String email) {
  if (email.isNotEmpty) {
    var splitword = email.split("@");
    return "${splitword[0].replaceRange(splitword[0].length > 3 ? 3 : 0, splitword[0].length - 1, "******")}@${splitword[1]}";
  }
  return "";
}

String formattedTime({required int timeInSecond}) {
  if (timeInSecond > 0) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  } else {
    return "00:00";
  }
}

String formatCurrency(int amount, {String symbolCur = 'Rp'}) {
  // final currency = NumberFormat.currency(
  //   locale: 'id',
  //   symbol: symbolCur,
  //   decimalDigits: 0,
  // );
  // return currency.format(
  //   price,
  // ); // NumberFormat.currency(locale: 'en_US', symbol: '\').format(price);
  // Round to nearest whole number for standard Rupiah
  int rounded = amount.round();

  // Use regex to insert dots every 3 digits from the right
  String digits = rounded.toString();
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String formatted = digits.replaceAllMapped(
    reg,
    (Match match) => '${match[1]}.',
  );

  return '$symbolCur$formatted';
}

Future<String> getVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  String build = packageInfo.buildNumber;
  String showversion = "${version}_$build";
  debugPrint("ver : $showversion");
  return showversion;
  // return Text(
  //   "version $showversion",
  //   textAlign: TextAlign.center,
  //   // style: appFonts.caption.white.ts,
  // );
}

void transparentStatusBar() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
}

bool isMobileView(BuildContext context) {
  // Use MediaQuery to detect orientation and screen width
  final double screenWidth = MediaQuery.of(context).size.width;
  final Orientation orientation = MediaQuery.of(context).orientation;

  // Disable if it is mobile portrait mode
  bool useExpanded = screenWidth > 600 && orientation != Orientation.portrait;

  return useExpanded;
}

String getSaveSharedPref({required String key, String defaultValue = ""}) {
  final prefs = SharedPrefServices.pref;
  return prefs.getString(key) ?? defaultValue;
}

bool getEnablePPN() {
  final prefs = SharedPrefServices.pref;
  return prefs.getBool(SettingsKeys.enablePPN) ?? false;
}

double getPPN({bool calculate = false}) {
  final prefs = SharedPrefServices.pref;
  final ppn = prefs.getDouble(SettingsKeys.ppnValue) ?? 0.0;
  if (calculate) {
    return ppn / 100;
  } else {
    return ppn;
  }
}

String getLogo() {
  final prefs = SharedPrefServices.pref;
  return prefs.getString(SettingsKeys.restaurantLogo) ?? "";
}

bool isToday(DateTime date) {
  final now = DateTime.now();
  final local = date;
  //debugPrint("now $now , order date $local");
  return local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
}

bool isSameDate(DateTime date, DateTime targetDate) {
  final now = targetDate;
  final local = date;
  //debugPrint("now $now , order date $local");
  return local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
}

Future<void> initLocalMyTenant(TenantEntity tenant) async {
  debugPrint("tenant : $tenant");
  final prefs = SharedPrefServices.pref;
  await prefs.setString(SettingsKeys.restaurantName, tenant.name.trim());
  await prefs.setString(SettingsKeys.restaurantAddress, tenant.address!.trim());
  await prefs.setString(SettingsKeys.restaurantPhone, tenant.phone!.trim());
  await prefs.setString(SettingsKeys.restaurantLogo, tenant.logoUrl ?? "");
  await prefs.setString(SettingsKeys.restaurantQris, tenant.qrisUrl ?? "");

  if (tenant.tenantPayment != null) {
    await prefs.setString(
      SettingsKeys.bankAccountName,
      tenant.tenantPayment!.bankAccountName ?? "",
    );
    await prefs.setString(
      SettingsKeys.phoneConfirmation,
      tenant.tenantPayment!.phoneConfirmation ?? "",
    );
    await prefs.setString(
      SettingsKeys.deliveryDescription,
      tenant.tenantPayment!.deliveryDescription ?? "",
    );
    await prefs.setString(
      SettingsKeys.restaurantRekening,
      tenant.tenantPayment!.bankAccountNumber ?? "",
    );
  }
}

double toDouble(dynamic value, {double fallback = 0.0}) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback; // tipe tak dikenali
}
