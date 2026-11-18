import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';
import 'package:restauran_menu/features/admin/presentation/provider/admin_provider.dart';
import 'package:restauran_menu/features/admin/presentation/widgets/admin_menubar.dart';
import 'package:restauran_menu/features/admin/presentation/widgets/admin_sidebar.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/kasir_create_order_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/kasir_laporan_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/print_setup_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/transaction_history_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/provider/kasir_provider.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/order_detail_panel.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/order_list_panel.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/payment_panel.dart';
import 'package:restauran_menu/features/members/presentation/pages/member_screen.dart';
import 'package:restauran_menu/features/menu/presentation/pages/kelola_menu_screen.dart';
import 'package:restauran_menu/features/notifications/domain/entities/order_stream_role.dart';
import 'package:restauran_menu/features/notifications/presentation/provider/order_stream_provider.dart';
import 'package:restauran_menu/features/permissions/domain/entities/permission_status_entity.dart';
import 'package:restauran_menu/features/permissions/presentation/pages/permission_config_screen.dart';
import 'package:restauran_menu/features/promos/presentation/pages/promo_screen.dart';
import 'package:restauran_menu/features/staff/presentation/pages/staff_screen.dart';
import 'package:restauran_menu/features/stock/presentation/pages/stock_summary_page.dart';
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
    bool useExpanded = isMobileView(context);
    PermissionStatusEntity permissionStatusEntity =
        const PermissionStatusEntity(canAdd: true, canDel: true, canEdit: true);
    switch (_selectedIndex) {
      case 0:
        return const KasirDashboardView(); // Use as dashboard statistics
      case 1:
        return const KasirCreateOrderScreen();
      case 2:
        //return const OrdersScreen();
        return useExpanded
            ? const Row(
                children: [
                  OrderListPanel(),
                  VerticalDivider(width: 1, color: RestaurantColors.cardBorder),
                  Expanded(child: OrderDetailPanel()),
                  VerticalDivider(width: 1, color: RestaurantColors.cardBorder),
                  PaymentPanel(),
                ],
              )
            : const SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    OrderListPanel(),
                    VerticalDivider(
                      width: 1,
                      color: RestaurantColors.cardBorder,
                    ),
                    OrderDetailPanel(),
                    VerticalDivider(
                      width: 1,
                      color: RestaurantColors.cardBorder,
                    ),
                    PaymentPanel(),
                  ],
                ),
              );
      case 3:
        return KelolaMenuScreen(permission: permissionStatusEntity);
      case 4:
        return StockSummaryPage(permission: permissionStatusEntity);
      case 5:
        return const StaffScreen();
      case 6:
        return const PermissionConfigScreen();
      case 7:
        return const TransactionHistoryScreen();
      case 8:
        return const PromoScreen();
      case 9:
        return const MemberScreen();
      case 10:
        return const PrintSetupScreen();
      case 11:
        return const AdminPengaturanScreen();
      default:
        return const SizedBox.shrink();
    }
  }

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
              sl<OrderStreamProvider>()..start(role: OrderStreamRole.kasir),
        ),
        // ChangeNotifierProvider(
        //   create: (context) =>
        //       sl<PermissionProvider>()..loadMyPermission(forceRefresh: true),
        // ),
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
                                      'Admin Panel',
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
                      Expanded(child: SafeArea(child: _buildContent())),
                    ],
                  ),
                  if (_sidebarCollapsed) ...[
                    Positioned.fill(
                      child: AdminMenuBar(
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
                      ),
                    ),
                  ],
                ],
              )
            : Row(
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
                  Expanded(child: SafeArea(child: _buildContent())),
                ],
              ),
      ),
    );
  }
}
