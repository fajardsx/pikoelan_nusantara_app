import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/app_fonts.dart';
import 'package:restauran_menu/features/auth/domain/entities/user_entities.dart';

Widget userCard({required User user}) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.name, style: appFonts.ts),
          Text(user.email, style: appFonts.ts),
        ],
      ),
    ),
  );
}
