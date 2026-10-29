import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';
import 'package:restauran_menu/features/admin/presentation/provider/admin_provider.dart';
import 'package:restauran_menu/features/admin/presentation/widgets/admin_sidebar.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/kasir_laporan_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/transaction_history_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/provider/kasir_provider.dart';
import 'package:restauran_menu/features/menu/presentation/pages/kelola_menu_screen.dart';
import 'package:restauran_menu/features/permissions/presentation/pages/permission_config_screen.dart';
import 'package:restauran_menu/features/staff/presentation/pages/staff_screen.dart';
import 'package:restauran_menu/shared/utils/logout_helper.dart';

import '../../../../core/themes/restaurant_colors.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _selectedIndex = 0;
  bool _sidebarCollapsed = true;

  @override
  void initState() {
    super.initState();
    sl<AdminProvider>().load();
    sl<KasirProvider>().load();
  }

  Future<void> _confirmLogout() => confirmAndLogout(
    context,
    title: 'Keluar dari Admin?',
    message: 'Sesi login akan dihapus dan kamu kembali ke halaman login.',
  );

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const KasirDashboardView(); // Use as dashboard statistics
      case 1:
        return const KelolaMenuScreen();
      case 2:
        //return const StaffManagementScreen();
        return const StaffScreen();
      case 3:
        return const PermissionConfigScreen();
      case 4:
        return const TransactionHistoryScreen();
      case 5:
        return const AdminPengaturanScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provide KasirProvider because KasirLaporanScreen needs it to compute reports
    return ChangeNotifierProvider.value(
      value: sl<KasirProvider>(),
      child: Scaffold(
        backgroundColor: RestaurantColors.background,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminSidebar(
              selectedIndex: _selectedIndex,
              onSelect: (index) => setState(() => _selectedIndex = index),
              onLogout: _confirmLogout,
              collapsed: _sidebarCollapsed,
              onToggleCollapse: () =>
                  setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }
}
