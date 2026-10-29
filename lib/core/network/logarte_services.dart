import 'package:logarte/logarte.dart';

class LogarteServices {
  static final LogarteServices _instance = LogarteServices._internal();
  factory LogarteServices() => _instance;
  final Logarte logarte = Logarte(disableDebugConsoleLogs: true);
  LogarteServices._internal();
}
