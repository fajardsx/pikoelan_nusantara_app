import 'package:flutter/material.dart';

void showCustomSnackBar(
  BuildContext context,
  String msg, {
  bool taskSuccess = true,
}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor:
            taskSuccess == true
                  ? Colors.green.withValues(alpha: 0.7)
                  : Colors.red
              ..withValues(alpha: 0.7),
        width: MediaQuery.of(context).size.width * 0.7,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );
}
