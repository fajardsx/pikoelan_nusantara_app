import 'package:restauran_menu/core/configs/api_keys.dart';

/// Daftar tipe API yang tersedia di aplikasi.
enum ApiType {
  setLogin(0, ApiKeys.authLogin);
  // setAttend(0, ApiKeys.setAttendSync),
  // setSchedule(1, ApiKeys.setSchedule),
  // setResultSchedule(2, ApiKeys.resultSchedule),
  // setSendPhoto(
  //   3,
  //   ApiKeys.sendSchedulePhoto,
  // ); //, setSchedule, setResultSchedule, setSendPhoto

  final int id;
  final String api;

  const ApiType(this.id, this.api);
}
