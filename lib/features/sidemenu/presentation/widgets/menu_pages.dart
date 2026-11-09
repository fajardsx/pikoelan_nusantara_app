import 'package:flutter/material.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/kasir_create_order_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/kasir_laporan_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/kasir_pengaturan_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/print_setup_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/transaction_history_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/order_detail_panel.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/order_list_panel.dart'
    show OrderListPanel;
import 'package:restauran_menu/features/kasir/presentation/widgets/payment_panel.dart';
import 'package:restauran_menu/features/kitchen/presentation/pages/kitchen_display_screen.dart';
import 'package:restauran_menu/features/members/presentation/pages/member_screen.dart';
import 'package:restauran_menu/features/menu/presentation/pages/kelola_menu_screen.dart';
import 'package:restauran_menu/features/promos/presentation/pages/promo_screen.dart';
import 'package:restauran_menu/features/sidemenu/presentation/widgets/menu_key.dart';
import 'package:restauran_menu/features/staff/presentation/pages/staff_screen.dart';
import 'package:restauran_menu/features/stock/presentation/pages/stock_summary_page.dart';
import 'package:restauran_menu/features/waiters/presentation/pages/waiter_shell_screen.dart';

class MenuPages extends StatelessWidget {
  const MenuPages({
    super.key,
    required this.context,
    required String selectedIndex,
  }) : _selectedIndex = selectedIndex;

  final BuildContext context;
  final String _selectedIndex;

  @override
  Widget build(BuildContext context) {
    bool useExpanded = isMobileView(context);

    switch (_selectedIndex) {
      case MenuKeys.buatPesanan:
        return const KasirCreateOrderScreen();
      case MenuKeys.daftarPesanan:
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
      case MenuKeys.kitchenDisplay:
        return const KitchenDisplayScreen();
      case MenuKeys.waitersDisplay:
        return const WaiterShellScreen();
      case MenuKeys.kelolaMenu:
        return const KelolaMenuScreen();
      case MenuKeys.transaksi:
        return const TransactionHistoryScreen();
      case MenuKeys.stock:
        return const StockSummaryPage();
      case MenuKeys.laporan:
        return const KasirLaporanScreen();
      case MenuKeys.pengaturanKasir:
        return const KasirPengaturanScreen();
      case MenuKeys.staf:
        return const StaffScreen();
      case MenuKeys.membership:
        return const MemberScreen();
      case MenuKeys.promosi:
        return const PromoScreen();
      case MenuKeys.print:
        return const PrintSetupScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}
