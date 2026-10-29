import 'package:flutter/material.dart';

/// Stub Web: file image tidak didukung, tampilkan error widget.
Widget buildFileImage(
  String source, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? errorWidget,
}) {
  return SizedBox(
    width: width,
    height: height,
    child: errorWidget ?? const Icon(Icons.broken_image, color: Colors.grey),
  );
}
