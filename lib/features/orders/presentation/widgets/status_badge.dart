import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const StatusBadge({super.key, required this.status, required this.label});

  Color _bgFor(String status) {
    switch (status) {
      case 'new':
        return AppColors.accentSoft;
      case 'proses':
        return const Color(0xFFF3EBC9);
      case 'ready':
        return AppColors.primarySoft;
      case 'deliver':
        return const Color(0xFFDCEAF5);
      case 'cancelled':
        return AppColors.dangerSoft;
      default:
        return const Color(0xFFEDEAE0);
    }
  }

  Color _fgFor(String status) {
    switch (status) {
      case 'new':
        return AppColors.accent;
      case 'proses':
        return const Color(0xFF6B5B14);
      case 'ready':
        return AppColors.primarySoft;
      case 'deliver':
        return const Color(0xFF2E5F8A);
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.inkSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: _bgFor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: _fgFor(status),
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
