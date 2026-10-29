import 'dart:io';

import 'package:flutter/material.dart';

/// Mobile/Desktop: tampilkan file lokal via Image.file.
Widget buildFileImage(
  String source, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? errorWidget,
}) {
  final file = File(source.replaceFirst(RegExp(r'^file://'), ''));
  return Image.file(
    file,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, _, _) =>
        errorWidget ?? const Icon(Icons.broken_image, color: Colors.grey),
  );
}
