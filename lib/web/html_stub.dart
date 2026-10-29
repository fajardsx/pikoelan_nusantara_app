// Stub implementations for non-web platforms to satisfy compiler.
// Provides minimal API used in OrderSuccessScreen.

class Blob {
  Blob(List<dynamic> data, String type);
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) => '';
  static void revokeObjectUrl(String url) {}
}

class AnchorElement {
  String href;
  AnchorElement({required this.href});
  void setAttribute(String name, String value) {}
  void click() {}
}
