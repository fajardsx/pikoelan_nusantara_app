import 'package:flutter/material.dart';

class MenuKeys {
  static const String buatPesanan = 'buat pesanan';
  static const String daftarPesanan = 'daftar pesanan';
  static const String kitchenDisplay = 'kitchen display';
  static const String waitersDisplay = 'waiters display';
  static const String laporan = 'reports';
  static const String dashboard = 'dashboard';
  static const String transaksi = 'transactions';
  static const String stock = 'stock';
  static const String promosi = 'promos';
  static const String membership = 'memberships';
  static const String kelolaMenu = 'menu';
  static const String staf = 'staff';
  static const String permission = 'permission';
  static const String pengaturanKasir = 'pengaturan kasir';
  static const String pengaturan = 'settings';
  static const String notification = 'notifications';
  static const String print = 'print';
}

class MenuTree {
  // Menu
  static final menuitems = [
    (
      icon: Icons.dashboard_rounded,
      label: 'Laporan',
      menuKey: MenuKeys.laporan,
    ), // Khusus Admin
    (
      icon: Icons.receipt,
      label: 'Buat Pesanan',
      menuKey: MenuKeys.buatPesanan,
    ), // Khusus Kasir
    (
      icon: Icons.receipt_long_rounded,
      label: 'Daftar Pesanan',
      menuKey: MenuKeys.daftarPesanan,
    ), // Khusus kasir
    (
      icon: Icons.soup_kitchen_outlined,
      label: 'Kitchen',
      menuKey: MenuKeys.kitchenDisplay,
    ), // Khusus kitchen
    (
      icon: Icons.room_service,
      label: 'Waiters',
      menuKey: MenuKeys.waitersDisplay,
    ), // Khusus kitchen
    (icon: Icons.menu_book_rounded, label: 'Menu', menuKey: "menu"),
    (
      icon: Icons.swap_horiz_rounded,
      label: 'Transaksi',
      menuKey: MenuKeys.transaksi,
    ),
    (icon: Icons.store_rounded, label: 'Stock', menuKey: MenuKeys.stock),
    (
      icon: Icons.local_offer_rounded,
      label: 'Promosi',
      menuKey: MenuKeys.promosi,
    ),
    (
      icon: Icons.card_membership_rounded,
      label: 'Member',
      menuKey: MenuKeys.membership,
    ),
    (icon: Icons.people_alt_rounded, label: 'Staf', menuKey: MenuKeys.staf),
    (
      icon: Icons.verified_user_rounded,
      label: 'Hak Akses',
      menuKey: MenuKeys.permission,
    ), // khusus admin
    (icon: Icons.print, label: 'Print Setup', menuKey: MenuKeys.print),
    (
      icon: Icons.settings_rounded,
      label: 'Kasir Pengaturan',
      menuKey: MenuKeys.pengaturanKasir,
    ), // khusus kasir
    (
      icon: Icons.settings_rounded,
      label: 'Pengaturan',
      menuKey: MenuKeys.pengaturan,
    ), // khusus admin
  ];
}
