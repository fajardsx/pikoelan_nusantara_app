import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/kasir_laporan_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/print_setup_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/order_detail_panel.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/order_list_panel.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/payment_panel.dart';
import 'package:restauran_menu/features/menu/presentation/provider/menu_provider.dart';
import 'package:restauran_menu/features/notifications/presentation/provider/order_stream_provider.dart';
import 'package:restauran_menu/features/permissions/presentation/provider/permission_provider.dart';
import 'package:restauran_menu/shared/utils/logout_helper.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../menu/presentation/pages/kelola_menu_screen.dart';
import '../../../notifications/domain/entities/order_stream_role.dart';
import '../provider/kasir_provider.dart';
import '../widgets/kasir_sidebar.dart';
import 'kasir_create_order_screen.dart';
import 'kasir_pengaturan_screen.dart';
import 'transaction_history_screen.dart';

class KasirShellScreen extends StatefulWidget {
  const KasirShellScreen({super.key});

  @override
  State<KasirShellScreen> createState() => _KasirShellScreenState();
}

class _KasirShellScreenState extends State<KasirShellScreen> {
  int _selectedIndex = 0;
  bool _sidebarCollapsed = true;

  @override
  void initState() {
    super.initState();
    sl<MenuProvider>().load();
  }

  Future<void> _confirmLogout() => confirmAndLogout(
    context,
    title: 'Keluar dari Kasir?',
    message: 'Sesi login akan dihapus dan kamu kembali ke halaman login.',
  );

  Widget _buildContent() {
    bool useExpanded = isMobileView(context);

    switch (_selectedIndex) {
      case 0:
        return const KasirCreateOrderScreen();
      case 1:
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
      case 2:
        return const KelolaMenuScreen();
      case 3:
        return const TransactionHistoryScreen();
      case 4:
        return const KasirLaporanScreen();
      case 5:
        return const KasirPengaturanScreen();
      case 6:
        return const PrintSetupScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Satu-satunya KasirProvider di seluruh Shell. Langsung load() di sini
    // supaya OrderListPanel / Detail / Payment / Laporan / Riwayat
    // semuanya membaca instance + activeOrders yang sama.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => sl<KasirProvider>()..load(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              sl<OrderStreamProvider>()..start(role: OrderStreamRole.kasir),
        ),
        ChangeNotifierProvider(
          create: (context) => sl<PermissionProvider>()..load(),
        ),
      ],
      child: Scaffold(
        backgroundColor: RestaurantColors.background,
        body: Row(
          children: [
            KasirSidebar(
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
