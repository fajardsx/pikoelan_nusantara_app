import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';
import 'package:restauran_menu/features/kasir/presentation/provider/kasir_provider.dart';
import 'package:restauran_menu/features/menu/presentation/provider/menu_provider.dart';
import 'package:restauran_menu/features/notifications/domain/entities/order_stream_role.dart';
import 'package:restauran_menu/features/notifications/presentation/provider/order_stream_provider.dart';
import 'package:restauran_menu/features/permissions/presentation/provider/permission_provider.dart';
import 'package:restauran_menu/features/sidemenu/presentation/widgets/menu_key.dart';
import 'package:restauran_menu/features/sidemenu/presentation/widgets/menu_pages.dart';
import 'package:restauran_menu/features/sidemenu/presentation/widgets/menu_side_bar.dart';
import 'package:restauran_menu/shared/utils/logout_helper.dart';

import '../../../../core/themes/restaurant_colors.dart';

class WaitersMenuShellScreen extends StatefulWidget {
  const WaitersMenuShellScreen({super.key});

  @override
  State<WaitersMenuShellScreen> createState() => _WaitersMenuShellScreenState();
}

class _WaitersMenuShellScreenState extends State<WaitersMenuShellScreen> {
  String _selectedIndex = MenuKeys.waitersDisplay;
  bool _sidebarCollapsed = true;

  @override
  void initState() {
    super.initState();
    sl<MenuProvider>().load();
  }

  Future<void> _confirmLogout() => confirmAndLogout(
    context,
    title: 'Keluar dari Mode Waiters?',
    message: 'Sesi login akan dihapus dan kamu kembali ke halaman login.',
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => sl<KasirProvider>()..load(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              sl<OrderStreamProvider>()..start(role: OrderStreamRole.waiter),
        ),
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
