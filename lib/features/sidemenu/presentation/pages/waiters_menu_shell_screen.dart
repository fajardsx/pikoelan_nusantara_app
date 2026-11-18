import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';
import 'package:restauran_menu/features/kasir/presentation/provider/kasir_provider.dart';
import 'package:restauran_menu/features/menu/presentation/provider/menu_provider.dart';
import 'package:restauran_menu/features/notifications/domain/entities/order_stream_role.dart';
import 'package:restauran_menu/features/notifications/presentation/provider/order_stream_provider.dart';
import 'package:restauran_menu/features/permissions/presentation/provider/permission_provider.dart';
import 'package:restauran_menu/features/sidemenu/presentation/widgets/menu_bar.dart';
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
  bool _sidebarCollapsed = false;

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
    bool useExpanded = isMobileView(context);
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
        body: !useExpanded
            ? Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: RestaurantColors.primaryBrown,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                onPressed: () => setState(
                                  () => _sidebarCollapsed = !_sidebarCollapsed,
                                ),
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(
                                    50,
                                    50,
                                  ), // Equal width and height
                                  padding:
                                      EdgeInsets.zero, // Prevents text clipping
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ), // Use BorderRadius.zero for sharp edges
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.menu,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getSaveSharedPref(
                                        key: SettingsKeys.restaurantName,
                                        defaultValue: "MenuMaju",
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const Text(
                                      'Waiter',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: MenuPages(
                          context: context,
                          selectedIndex: _selectedIndex,
                        ),
                      ),
                    ],
                  ),
                  if (_sidebarCollapsed) ...[
                    Positioned.fill(
                      child: Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return MenuListBar(
                            roleName: auth.user!.roleLabel,
                            selectedIndex: _selectedIndex,
                            onSelect: (index) => setState(() {
                              _selectedIndex = index;
                              _sidebarCollapsed = !_sidebarCollapsed;
                            }),
                            onLogout: _confirmLogout,
                            collapsed: _sidebarCollapsed,
                            onToggleCollapse: () => setState(
                              () => _sidebarCollapsed = !_sidebarCollapsed,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              )
            : Row(
                children: [
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return MenuSideBar(
                        roleName: auth.user!.roleLabel,
                        selectedIndex: _selectedIndex,
                        onSelect: (index) =>
                            setState(() => _selectedIndex = index),
                        onLogout: _confirmLogout,
                        collapsed: _sidebarCollapsed,
                        onToggleCollapse: () => setState(
                          () => _sidebarCollapsed = !_sidebarCollapsed,
                        ),
                      );
                    },
                  ),

                  Expanded(
                    child: MenuPages(
                      context: context,
                      selectedIndex: _selectedIndex,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
