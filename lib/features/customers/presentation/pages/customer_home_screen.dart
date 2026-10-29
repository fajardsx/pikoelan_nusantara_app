import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';
import 'package:restauran_menu/features/customers/presentation/provider/public_menu_provider.dart';
import 'package:restauran_menu/features/customers/presentation/widgets/slide_banner.dart';
import 'package:restauran_menu/shared/widgets/app_image_loader.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../provider/cart_provider.dart';
import '../widgets/customer_bottom_nav.dart';
import '../widgets/favorite_menu_card.dart';
import 'all_menu_screen.dart';
import 'cart_screen.dart';
import 'orders_history_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  final String? slug;
  const CustomerHomeScreen({super.key, this.slug});

  @override
  State<CustomerHomeScreen> createState() => CustomerHomeScreenState();
}

class CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _index = 0;
  String? webSlug;
  String? webTable;
  bool? webIsDelivery;
  @override
  void initState() {
    super.initState();
    // Load sekali saat dibuka (post-frame supaya context provider siap).
    // Jika route tanpa slug (mis. kembali dari OrderSuccess), pertahankan
    // slug/data yang sudah ada di provider global.
    // Uri.base hanya dibaca di Web; di Mobile langsung pakai widget.slug
    // supaya tidak crash karena package:web tidak tersedia di Android/iOS.

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (kIsWeb) {
        try {
          webSlug = Uri.base.queryParameters['slug'];
          webTable = Uri.base.queryParameters['meja'];
          webIsDelivery = Uri.base.queryParameters['is_delivery'] != null
              ? true
              : true;
        } catch (_) {
          webSlug = null;
          webTable = null;
        }
      }
      _maybeLoad();
    });
  }

  @override
  void didUpdateWidget(covariant CustomerHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug || oldWidget.slug != webSlug) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _maybeLoad();
      });
    }
  }

  void _maybeLoad() {
    final incoming = (widget.slug ?? webSlug ?? '').trim();
    final menu = context.read<PublicMenuProvider>();
    if (incoming.isNotEmpty) {
      // Hindari refetch saat kembali ke tab yang sama dan sudah loaded.
      if (menu.slug == incoming && menu.status == PublicMenuStatus.loaded) {
        return;
      }
      menu.load(incoming, forceRefresh: true);
      return;
    }
    // Route tanpa slug: jangan timpa data resto yang sudah loaded.
    if ((menu.slug ?? '').isEmpty) {
      menu.load(null);
    }
  }

  void setIndex(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _BerandaTab(),
      const AllMenuScreen(embedded: true),
      CartScreen(embedded: true, table: webTable, isDelivery: webIsDelivery),
      const OrdersHistoryScreen(embedded: true),
    ];
    return Scaffold(
      backgroundColor: RestaurantColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: pages[_index],
              ),
            ),
          ),
          // Hidden button for admin login (tap area 50x50 at top-left, fully transparent)
          Positioned(
            top: 0,
            left: 0,
            width: 50,
            height: 50,
            child: Opacity(
              opacity: 0.5,
              child: TextButton(
                onPressed: () {
                  //Navigator.of(context).pushNamed(NameRoute.adminLogin);
                },
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomerBottomNav(
        currentIndex: _index,
        onTap: setIndex,
      ),
    );
  }
}

class _BerandaTab extends StatelessWidget {
  const _BerandaTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<PublicMenuProvider>(
      builder: (context, menu, _) {
        if (menu.status == PublicMenuStatus.loading ||
            menu.status == PublicMenuStatus.initial) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 120),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (menu.status == PublicMenuStatus.error) {
          return _PublicError(
            message: menu.errorMessage,
            onRetry: () => menu.refresh(),
          );
        }
        final favorites = menu.favorites;
        final bannerItems = menu.bannerItems;
        return RefreshIndicator(
          onRefresh: () => menu.refresh(),
          color: RestaurantColors.primaryBrown,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _HomeHeader(),
                      const SizedBox(height: 18),
                      const Text(
                        'Selamat datang 👋',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: RestaurantColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        menu.tenant != null && menu.tenant!.name.isNotEmpty
                            ? 'Mau pesan apa di ${menu.tenant!.name} hari ini?'
                            : 'Mau pesan apa hari ini?',
                        style: const TextStyle(
                          color: RestaurantColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _SearchBar(),
                      const SizedBox(height: 18),
                      if (bannerItems.isNotEmpty)
                        PromoBanner(items: bannerItems),
                      const SizedBox(height: 20),
                      const Text(
                        'Menu Kategori',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: RestaurantColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _CategoryShortcuts(),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Menu Favorit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: RestaurantColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              final state = context
                                  .findAncestorStateOfType<
                                    CustomerHomeScreenState
                                  >();
                              state?.setIndex(1);
                            },
                            child: const Text(
                              'Lihat semua',
                              style: TextStyle(
                                color: RestaurantColors.accentOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
              if (favorites.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Text(
                      'Belum ada menu favorit dari resto ini.',
                      style: TextStyle(color: RestaurantColors.textSecondary),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 190,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      primary: false,
                      itemCount: favorites.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = favorites[index];
                        return FavoriteMenuCard(
                          item: item,
                          onAdd: () =>
                              context.read<CartProvider>().addItem(item),
                        );
                      },
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final tenant = context.watch<PublicMenuProvider>().tenant;
    final name = (tenant?.name.isNotEmpty == true)
        ? tenant!.name
        : getSaveSharedPref(
            key: SettingsKeys.restaurantName,
            defaultValue: 'MenuMaju',
          );
    final address = (tenant?.address?.isNotEmpty == true)
        ? tenant!.address!
        : getSaveSharedPref(
            key: SettingsKeys.restaurantAddress,
            defaultValue: ' ',
          );
    final phone = (tenant?.phone?.isNotEmpty == true)
        ? tenant!.phone!
        : getSaveSharedPref(key: SettingsKeys.restaurantPhone);
    final logo = (tenant?.logoUrl?.isNotEmpty == true)
        ? tenant!.logoUrl!
        : getSaveSharedPref(key: SettingsKeys.restaurantLogo, defaultValue: '');
    // final qris = (tenant?.qrisUrl?.isNotEmpty == true)
    //     ? tenant!.qrisUrl!
    //     : getSaveSharedPref(key: SettingsKeys.restaurantQris, defaultValue: '');
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: RestaurantColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 0.0, color: RestaurantColors.cardBorder),
          ),
          alignment: Alignment.center,
          child: logo.isNotEmpty
              ? AppImageLoader().load(
                  logo,
                  fit: BoxFit.cover,
                  width: 72,
                  height: 72,
                )
              : const Icon(
                  Icons.restaurant,
                  color: RestaurantColors.primaryBrown,
                  size: 28,
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // outline red
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = Colors.white,
                    ),
                  ),
                  // filled red
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                      color: Colors.red,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                '📍$address\n☎️ $phone',
                style: const TextStyle(
                  fontSize: 11,
                  color: RestaurantColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: RestaurantColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: RestaurantColors.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: RestaurantColors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () {
                      final state = context
                          .findAncestorStateOfType<CustomerHomeScreenState>();
                      state?.setIndex(1);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari menu...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // const SizedBox(width: 10),
        // Container(
        //   width: 44,
        //   height: 44,
        //   decoration: BoxDecoration(
        //     color: RestaurantColors.surface,
        //     borderRadius: BorderRadius.circular(14),
        //     border: Border.all(color: RestaurantColors.cardBorder),
        //   ),
        //   child: const Icon(
        //     Icons.tune_rounded,
        //     color: RestaurantColors.primaryBrown,
        //   ),
        // ),
      ],
    );
  }
}

class _CategoryShortcuts extends StatelessWidget {
  const _CategoryShortcuts();

  @override
  Widget build(BuildContext context) {
    return Consumer<PublicMenuProvider>(
      builder: (context, menu, _) {
        final labels = ['Semua', ...menu.categories.map((c) => c.name)];
        final logo = [
          'Semua',
          ...menu.categories.map((c) => c.categoriesPicture),
        ];
        if (menu.categories.isEmpty) return const SizedBox.shrink();
        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 20.0,
              children: labels.map((label) {
                final int idx = labels.indexOf(label);
                return InkWell(
                  onTap: () {
                    final state = context
                        .findAncestorStateOfType<CustomerHomeScreenState>();
                    state?.setIndex(1);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: RestaurantColors.primaryBrown,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            logo[idx] != null &&
                                logo[idx]!.isNotEmpty &&
                                logo[idx] != "Semua"
                            ? Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: AppImageLoader().load(
                                  logo[idx]!,

                                  ///fit: BoxFit.contain,
                                  // width: 10,
                                  // height: 10,
                                ),
                              )
                            : Icon(
                                label == 'Semua'
                                    ? Icons.apps_rounded
                                    : iconByName(labelCat: label),
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: RestaurantColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  IconData iconByName({String? labelCat}) {
    if (labelCat!.toLowerCase().contains("makan") ||
        labelCat.toLowerCase().contains("food")) {
      return Icons.food_bank_outlined;
    }
    if (labelCat.toLowerCase().contains("minum") ||
        labelCat.toLowerCase().contains("drink")) {
      return Icons.local_drink_sharp;
    }
    if (labelCat.toLowerCase().contains("cemilan") ||
        labelCat.toLowerCase().contains("snack")) {
      return Icons.bakery_dining;
    }
    return Icons.restaurant_menu_rounded;
  }
}

class _PublicError extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  const _PublicError({this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: RestaurantColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              message ?? 'Gagal memuat menu.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: RestaurantColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: RestaurantColors.primaryBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
