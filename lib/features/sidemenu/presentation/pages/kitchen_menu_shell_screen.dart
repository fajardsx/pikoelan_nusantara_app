import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';
import 'package:restauran_menu/features/menu/presentation/provider/menu_provider.dart';
import 'package:restauran_menu/features/permissions/presentation/provider/permission_provider.dart';
import 'package:restauran_menu/features/sidemenu/presentation/widgets/menu_key.dart';
import 'package:restauran_menu/features/sidemenu/presentation/widgets/menu_pages.dart';
import 'package:restauran_menu/features/sidemenu/presentation/widgets/menu_side_bar.dart';
import 'package:restauran_menu/shared/utils/logout_helper.dart';

import '../../../../core/themes/restaurant_colors.dart';

class KitchenMenuShellScreen extends StatefulWidget {
  const KitchenMenuShellScreen({super.key});

  @override
  State<KitchenMenuShellScreen> createState() => _KitchenMenuShellScreenState();
}

class _KitchenMenuShellScreenState extends State<KitchenMenuShellScreen> {
  String _selectedIndex = MenuKeys.kitchenDisplay;
  bool _sidebarCollapsed = true;

  @override
  void initState() {
    super.initState();
    sl<MenuProvider>().load();
  }

  Future<void> _confirmLogout() => confirmAndLogout(
    context,
    title: 'Keluar Dari POS?',
    message: 'Sesi login akan dihapus dan kamu kembali ke halaman login.',
  );

  @override
  Widget build(BuildContext context) {
    // Satu-satunya KasirProvider di seluruh Shell. Langsung load() di sini
    // supaya OrderListPanel / Detail / Payment / Laporan / Riwayat
    // semuanya membaca instance + activeOrders yang sama.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              sl<PermissionProvider>()..loadMyPermission(forceRefresh: true),
        ),
      ],
      child: Scaffold(
        backgroundColor: RestaurantColors.background,
        body: Row(
          children: [
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return MenuSideBar(
                  roleName: auth.user!.roleLabel,
                  selectedIndex: _selectedIndex,
                  onSelect: (index) => setState(() => _selectedIndex = index),
                  onLogout: _confirmLogout,
                  collapsed: _sidebarCollapsed,
                  onToggleCollapse: () =>
                      setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                );
              },
            ),

            Expanded(
              child: MenuPages(context: context, selectedIndex: _selectedIndex),
            ),
          ],
        ),
      ),
    );
  }
}
