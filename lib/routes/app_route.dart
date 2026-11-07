import 'package:flutter/widgets.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_shell_screen.dart';
import 'package:restauran_menu/features/auth/presentation/pages/auth_page.dart';
import 'package:restauran_menu/features/auth/presentation/pages/login_screen.dart';
import 'package:restauran_menu/features/customers/presentation/pages/all_menu_screen.dart';
import 'package:restauran_menu/features/customers/presentation/pages/cart_screen.dart';
import 'package:restauran_menu/features/customers/presentation/pages/cash_payment_screen.dart';
import 'package:restauran_menu/features/customers/presentation/pages/customer_home_screen.dart';
import 'package:restauran_menu/features/customers/presentation/pages/order_success_screen.dart';
import 'package:restauran_menu/features/customers/presentation/pages/orders_history_screen.dart';
import 'package:restauran_menu/features/customers/presentation/pages/payment_method_screen.dart';
import 'package:restauran_menu/features/customers/presentation/pages/qris_payment_screen.dart';
import 'package:restauran_menu/features/customers/presentation/pages/transfer_payment_screen.dart';
import 'package:restauran_menu/features/home/presentation/pages/home_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/kasir_shell_screen.dart';
import 'package:restauran_menu/features/kitchen/presentation/pages/kitchen_display_screen.dart';
import 'package:restauran_menu/features/members/presentation/pages/member_screen.dart';
import 'package:restauran_menu/features/onBoarding/presentation/pages/splash_screen.dart';
import 'package:restauran_menu/features/promos/presentation/pages/promo_screen.dart';
import 'package:restauran_menu/features/restaurant/presentation/pages/role_selection_screen.dart';
import 'package:restauran_menu/features/stock/domain/entities/category.dart';
import 'package:restauran_menu/features/stock/domain/entities/stock_item.dart';
import 'package:restauran_menu/features/stock/domain/entities/unit.dart';
import 'package:restauran_menu/features/stock/presentation/pages/add_category_page.dart';
import 'package:restauran_menu/features/stock/presentation/pages/add_unit_page.dart';
import 'package:restauran_menu/features/stock/presentation/pages/stock_category_list_page.dart';
import 'package:restauran_menu/features/stock/presentation/pages/stock_form_page.dart';
import 'package:restauran_menu/features/stock/presentation/pages/stock_list_page.dart';
import 'package:restauran_menu/features/stock/presentation/pages/stock_summary_page.dart';
import 'package:restauran_menu/features/stock/presentation/pages/stock_unit_list_page.dart';
import 'package:restauran_menu/features/waiters/presentation/pages/waiter_shell_screen.dart';
import 'package:restauran_menu/features/waiters/presentation/pages/waiter_take_order_screen.dart';
import 'package:restauran_menu/routes/name_route.dart';
import 'package:restauran_menu/startup_gate.dart';

class AppRoute {
  var routes = {
    // NOTE: root now opens the restaurant Role Selection screen so the new
    // Self-Order / Kasir / Kitchen / Waiter module can be demoed directly.
    // Swap back to `SplashScreen()` once this is wired to real auth.
    //NameRoute.rootView: (context) => const RoleSelectionScreen(),
    NameRoute.onBoarding: (context) => const AuthPage(),
    NameRoute.login: (context) => const LoginScreen(),
    NameRoute.adminLogin: (context) => const StartupGate(),
    // NameRoute.register: (context) => const RegisterPage(),
    NameRoute.home: (context) => const HomeScreen(),
    NameRoute.splash: (context) => const SplashScreen(),

    // Restaurant module — Customer Self-Order
    NameRoute.roleSelection: (context) => const RoleSelectionScreen(),
    NameRoute.customerHome: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          {};
      return CustomerHomeScreen(slug: args['slug']);
    },
    NameRoute.allMenu: (context) => const AllMenuScreen(),
    NameRoute.cart: (context) => const CartScreen(),
    NameRoute.paymentMethod: (context) => const PaymentMethodScreen(),
    NameRoute.qrisPayment: (context) => const QrisPaymentScreen(),
    NameRoute.cashPayment: (context) => const CashPaymentScreen(),
    NameRoute.transferPayment: (context) => const TransferPaymentScreen(),
    NameRoute.orderSuccess: (context) => const OrderSuccessScreen(),
    NameRoute.ordersHistory: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          {};
      return OrdersHistoryScreen(orderNumber: args['orderNumber'] as String?);
    },
    NameRoute.adminDashboard: (context) => const AdminShellScreen(),
    NameRoute.adminPromos: (context) => const PromoScreen(),
    NameRoute.adminMembers: (context) => const MemberScreen(),
    NameRoute.kasirDashboard: (context) => const KasirShellScreen(),
    NameRoute.kitchenDisplay: (context) => const KitchenDisplayScreen(),
    NameRoute.waiterDashboard: (context) => const WaiterShellScreen(),
    NameRoute.waiterTakeOrderDashboard: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          {};
      return WaiterTakeOrderScreen(tableNumber: args['tableNumber']);
    },
    NameRoute.stockSummary: (context) => const StockSummaryPage(),
    NameRoute.stockList: (context) => const StockListPage(),
    NameRoute.stockCategoryList: (context) => const StockCategoryListPage(),
    NameRoute.stockUnitsList: (context) => const StockUnitListPage(),
    NameRoute.stockAddForm: (context) {
      final args = ModalRoute.of(context)?.settings.arguments != null
          ? ModalRoute.of(context)!.settings.arguments as StockItem
          : null;
      return StockFormPage(item: args);
    },
    NameRoute.unitAddForm: (context) {
      final args = ModalRoute.of(context)?.settings.arguments != null
          ? ModalRoute.of(context)!.settings.arguments as Unit
          : null;
      return AddUnitPage(unit: args);
    },
    NameRoute.categoryAddForm: (context) {
      final args = ModalRoute.of(context)?.settings.arguments != null
          ? ModalRoute.of(context)!.settings.arguments as Category
          : null;
      return AddCategoryPage(cat: args);
    },
  };
}
