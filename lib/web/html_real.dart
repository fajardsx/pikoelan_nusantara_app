// Real implementations for web platforms using dart:html.
// Mirrors the stub API used in OrderSuccessScreen.

import 'dart:html' as dom;

class Blob {
  final dom.Blob _blob;
  Blob(List<dynamic> data, String type) : _blob = dom.Blob(data, type);
  dom.Blob get raw => _blob;
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) =>
      dom.Url.createObjectUrlFromBlob(blob.raw);
  static void revokeObjectUrl(String url) => dom.Url.revokeObjectUrl(url);
}

class AnchorElement {
  final dom.AnchorElement _element;
  AnchorElement({required String href})
    : _element = dom.AnchorElement(href: href);
  void setAttribute(String name, String value) =>
      _element.setAttribute(name, value);
  void click() => _element.click();
  // Expose href getter/setter if needed.
  String? get href => _element.href;
  set href(String value) => _element.href = value;
}
