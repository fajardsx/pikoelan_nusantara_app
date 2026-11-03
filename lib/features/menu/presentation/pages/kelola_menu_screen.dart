import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/database/category_repository.dart';
import 'package:restauran_menu/core/database/menu_repository.dart';
import 'package:restauran_menu/core/services/app_log.dart';
import 'package:restauran_menu/core/themes/app_colors.dart';
import 'package:restauran_menu/features/menu/data/models/menu_item_payload.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_category_entity.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';
import 'package:restauran_menu/features/menu/presentation/pages/kelola_kategori_screen.dart';
import 'package:restauran_menu/features/menu/presentation/provider/menu_provider.dart';
import 'package:restauran_menu/shared/utils/currency_formatter.dart';
import 'package:restauran_menu/shared/widgets/app_image_loader.dart';
import 'package:restauran_menu/web/html_stub.dart'
    if (dart.library.html) 'package:restauran_menu/web/html_real.dart'
    as html;
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/themes/restaurant_colors.dart';
import 'menu_form_screen.dart';

class KelolaMenuScreen extends StatelessWidget {
  const KelolaMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<MenuProvider>(),
      child: const MenuDashboard(),
    );
  }
}

class MenuDashboard extends StatefulWidget {
  const MenuDashboard({super.key});

  @override
  State<MenuDashboard> createState() => _MenuDashboardState();
}

class _MenuDashboardState extends State<MenuDashboard> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().load(refresh: true);
    });
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDeleteItem(
    BuildContext context,
    MenuProvider provider,
    int itemId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus item menu?'),
        content: const Text('Item ini akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = await provider.deleteMenuItem(itemId);
      if (!context.mounted) return;
      if (ok) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item menu dihapus')));
      } else if (provider.submitError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.submitError!),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    MenuProvider provider,
    int categoryId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus kategori?'),
        content: const Text(
          'Item yang masih pakai kategori ini akan dipindah ke "Tanpa kategori", bukan ikut terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await provider.deleteCategory(categoryId);
  }

  Future<void> exportMenu(
    BuildContext context,
    List<MenuItemEntity> items,
  ) async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data menu untuk diekspor')),
      );
      return;
    }
    final buffer = StringBuffer();
    buffer.writeln(
      'id,categoryId,name,price,originalPrice,imageUrl,isAvailable,isFavorite,isBanner,sortOrder,description',
    );
    for (final i in items) {
      final row = [
        i.id,
        i.categoryId?.toString() ?? '',
        i.name,
        i.price,
        i.originalPrice?.toString() ?? '',
        i.imageUrl ?? '',
        i.isAvailable,
        i.isFavorite,
        i.isBanner,
        i.sortOrder,
        i.description ?? '',
      ];
      final escaped = row
          .map((e) => '"${e.toString().replaceAll('"', '""')}"')
          .join(',');
      buffer.writeln(escaped);
    }
    final csv = buffer.toString();
    if (kIsWeb) {
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute(
          'download',
          'menu_${DateTime.now().millisecondsSinceEpoch}.csv',
        )
        ..click();
      html.Url.revokeObjectUrl(url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV menu berhasil diunduh')),
      );
    } else {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/menu_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      await file.writeAsString(csv);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: "Riwayat Transaksi"),
      );
      //await Share.shareFiles([file.path], text: 'Export data menu');
    }
  }

  Future<void> importMenu(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv,xlsx'],
    );
    if (result == null) return;
    final file = result.files.first;
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final content = utf8.decode(bytes);
    final lines = const LineSplitter().convert(content);
    if (lines.length <= 1) return;
    final items = <MenuItemEntity>[];
    for (final line in lines.skip(1)) {
      // simple split on commas not considering escaped commas for brevity
      final parts = line.split(',');
      if (parts.length < 11) continue;
      String unquote(String s) => s.replaceAll('"', '').trim();
      final id = int.tryParse(unquote(parts[0])) ?? 0;
      final catStr = unquote(parts[1]);
      final categoryId = catStr.isEmpty ? null : int.tryParse(catStr);
      final name = unquote(parts[2]);
      final price = double.tryParse(unquote(parts[3])) ?? 0.0;
      final oriStr = unquote(parts[4]);
      final originalPrice = oriStr.isEmpty ? null : double.tryParse(oriStr);
      final imageUrl = unquote(parts[5]);
      final isAvailable = unquote(parts[6]).toLowerCase() == 'true';
      final isFavorite = unquote(parts[7]).toLowerCase() == 'true';
      final isBanner = unquote(parts[8]).toLowerCase() == 'true';
      final sortOrder = int.tryParse(unquote(parts[9])) ?? -1;
      final description = unquote(parts[10]);
      items.add(
        MenuItemEntity(
          id: id,
          categoryId: categoryId,
          name: name,
          description: description.isEmpty ? null : description,
          price: price,
          originalPrice: originalPrice,
          imageUrl: imageUrl.isEmpty ? null : imageUrl,
          isAvailable: isAvailable,
          isFavorite: isFavorite,
          isBanner: isBanner,
          sortOrder: sortOrder,
        ),
      );

      final provider = sl<MenuProvider>();
      final payload = MenuItemPayload(
        name: name,
        price: price,
        originalPrice: originalPrice,
        categoryId: categoryId,
        imagePath: XFile(imageUrl),
        isFavorite: isFavorite,
        isAvailable: isAvailable,
        isBanner: isBanner,
        description: description,
      );

      try {
        final success = id > 0
            ? await provider.updateMenuItem(id, payload)
            : await provider.createMenuItem(payload);

        //debugPrint("Success : $success");
        if (!success) return;
        if (!mounted) return;
        //}
      } catch (e, s) {
        AppLog.instance.logError("import menu error $e", e, s);
      }
    }
    await sl<MenuRepository>().addAll(items);

    AppLog.instance.logInfo('Import menu selesai');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MenuProvider>();
    if (provider.status == MenuStatus.loading ||
        provider.status == MenuStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    //final items = provider.filteredItems;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MenuFormScreen()),
          );
          // Refresh after returning from form
          if (mounted) {
            context.read<MenuProvider>().refresh();
          }
        },
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Tambah Menu'),
        backgroundColor: RestaurantColors.primaryBrown,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: RestaurantColors.background,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola Menu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: RestaurantColors.textPrimary,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final provider = context.read<MenuProvider>();
                        await exportMenu(context, provider.items);
                      },
                      icon: const Icon(Icons.file_download, size: 18),
                      label: const Text('Export'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RestaurantColors.primaryBrown,
                        side: const BorderSide(
                          color: RestaurantColors.cardBorder,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await importMenu(context);
                      },
                      icon: const Icon(Icons.file_upload, size: 18),
                      label: const Text('Import'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RestaurantColors.primaryBrown,
                        side: const BorderSide(
                          color: RestaurantColors.cardBorder,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KelolaKategoriScreen(),
                          ),
                        );
                        // Refresh after returning from form
                        if (mounted) {
                          context.read<MenuProvider>().refresh();
                        }
                      },
                      icon: const Icon(Icons.category_outlined, size: 18),
                      label: const Text('Kelola Kategori'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RestaurantColors.primaryBrown,
                        side: const BorderSide(
                          color: RestaurantColors.cardBorder,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Search bar untuk filter menu berdasarkan nama
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari menu...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            if (provider.categories.isNotEmpty)
              SizedBox(
                height: 46,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 6,
                  ),
                  children: [
                    _CategoryChip(
                      label: 'Semua',
                      isActive: provider.selectedCategoryId == null,
                      onTap: () => provider.selectCategory(null),
                    ),
                    ...provider.categories.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _CategoryChip(
                          label: c.name,
                          isActive: provider.selectedCategoryId == c.id,
                          onTap: () => provider.selectCategory(c.id),
                          // onLongPress: canManage
                          //     ? () => _showCategoryActions(
                          //         context,
                          //         provider,
                          //         c.id,
                          //         c.name,
                          //       )
                          //     : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => provider.refresh(),
                child: StreamBuilder<List<MenuCategoryEntity>>(
                  stream: sl<CategoryRepository>().watchAll(),
                  builder: (context, catSnapshot) {
                    final categoryNames = {
                      for (final c
                          in catSnapshot.data ?? <MenuCategoryEntity>[])
                        c.id: c.name,
                    };

                    return StreamBuilder<List<MenuItemEntity>>(
                      stream: sl<MenuRepository>().watchAll(
                        categoryId: provider.selectedCategoryId,
                      ),
                      builder: (context, snapshot) {
                        final items = snapshot.data ?? [];
                        // Apply search filter on menu name
                        final filteredItems = _searchQuery.isEmpty
                            ? items
                            : items
                                  .where(
                                    (i) => i.name.toLowerCase().contains(
                                      _searchQuery.toLowerCase(),
                                    ),
                                  )
                                  .toList();
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (filteredItems.isEmpty) {
                          return const Center(
                            child: Text(
                              'Tidak ada menu yang cocok.',
                              style: TextStyle(
                                color: RestaurantColors.textSecondary,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: filteredItems.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) => _MenuRow(
                            item: filteredItems[index],
                            categoryName:
                                categoryNames[filteredItems[index].categoryId],
                            showAction: true,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            // RefreshIndicator(
            //   onRefresh: () => provider.load(),
            //   child:
            // SingleChildScrollView(
            //   child: Column(
            //     children: [
            //       if (provider.categories.isNotEmpty)
            //         SizedBox(
            //           height: 46,
            //           child: ListView(
            //             scrollDirection: Axis.horizontal,
            //             padding: const EdgeInsets.symmetric(
            //               horizontal: 16,
            //               vertical: 6,
            //             ),
            //             children: [
            //               _CategoryChip(
            //                 label: 'Semua',
            //                 isActive: provider.selectedCategoryId == null,
            //                 onTap: () => provider.selectCategory(null),
            //               ),
            //               ...provider.categories.map(
            //                 (c) => Padding(
            //                   padding: const EdgeInsets.only(left: 8),
            //                   child: _CategoryChip(
            //                     label: c.name,
            //                     isActive: provider.selectedCategoryId == c.id,
            //                     onTap: () => provider.selectCategory(c.id),
            //                     // onLongPress: canManage
            //                     //     ? () => _showCategoryActions(
            //                     //         context,
            //                     //         provider,
            //                     //         c.id,
            //                     //         c.name,
            //                     //       )
            //                     //     : null,
            //                   ),
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       if (items.isEmpty)
            //         const Center(
            //           child: Padding(
            //             padding: EdgeInsets.all(24),
            //             child: Text(
            //               'Belum ada item menu.',
            //               style: TextStyle(color: AppColors.inkSoft),
            //             ),
            //           ),
            //         )
            //       else
            //         ListView.separated(
            //           itemCount: items.length,
            //           separatorBuilder: (_, _) => const SizedBox(height: 10),
            //           itemBuilder: (context, index) => MenuItemCard(
            //             item: items[index],
            //             canManage: canManage,
            //             // onEdit: () => Navigator.of(context).push(
            //             //   MaterialPageRoute(
            //             //     builder: (_) => MenuItemFormScreen(item: item),
            //             //   ),
            //             // ),
            //             // onDelete: () =>
            //             //     _confirmDeleteItem(context, provider, item.id),
            //           ),
            //         ),
            //     ],
            //   ),
            // ),
            //       CustomScrollView(
            //         slivers: [
            //           if (provider.categories.isNotEmpty)
            //             SliverToBoxAdapter(
            //               child: SizedBox(
            //                 height: 46,
            //                 child: ListView(
            //                   scrollDirection: Axis.horizontal,
            //                   padding: const EdgeInsets.symmetric(
            //                     horizontal: 16,
            //                     vertical: 6,
            //                   ),
            //                   children: [
            //                     _CategoryChip(
            //                       label: 'Semua',
            //                       isActive: provider.selectedCategoryId == null,
            //                       onTap: () => provider.selectCategory(null),
            //                     ),
            //                     ...provider.categories.map(
            //                       (c) => Padding(
            //                         padding: const EdgeInsets.only(left: 8),
            //                         child: _CategoryChip(
            //                           label: c.name,
            //                           isActive:
            //                               provider.selectedCategoryId == c.id,
            //                           onTap: () =>
            //                               provider.selectCategory(c.id),
            //                           // onLongPress: canManage
            //                           //     ? () => _showCategoryActions(
            //                           //         context,
            //                           //         provider,
            //                           //         c.id,
            //                           //         c.name,
            //                           //       )
            //                           //     : null,
            //                         ),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ),
            //           if (items.isEmpty)
            //             const SliverFillRemaining(
            //               hasScrollBody: false,
            //               child: Center(
            //                 child: Padding(
            //                   padding: EdgeInsets.all(24),
            //                   child: Text(
            //                     'Belum ada item menu.',
            //                     style: TextStyle(color: AppColors.inkSoft),
            //                   ),
            //                 ),
            //               ),
            //             )
            //           else
            //             SliverPadding(
            //               padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            //               sliver: SliverGrid(
            //                 gridDelegate:
            //                     const SliverGridDelegateWithFixedCrossAxisCount(
            //                       crossAxisCount: 2,
            //                       mainAxisSpacing: 12,
            //                       crossAxisSpacing: 12,
            //                       childAspectRatio: 0.72,
            //                     ),
            //                 delegate: SliverChildBuilderDelegate((
            //                   context,
            //                   index,
            //                 ) {
            //                   final item = items[index];
            //                   return MenuItemCard(
            //                     item: item,
            //                     canManage: canManage,
            //                     // onEdit: () => Navigator.of(context).push(
            //                     //   MaterialPageRoute(
            //                     //     builder: (_) => MenuItemFormScreen(item: item),
            //                     //   ),
            //                     // ),
            //                     // onDelete: () =>
            //                     //     _confirmDeleteItem(context, provider, item.id),
            //                   );
            //                 }, childCount: items.length),
            //               ),
            //             ),
            //         ],
            //       ),
            // ),
          ],
        ),
      ),
    );
  }

  // void _showCategoryActions(
  //   BuildContext context,
  //   MenuProvider provider,
  //   int categoryId,
  //   String name,
  // ) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => SafeArea(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: const Icon(Icons.edit_outlined),
  //             title: Text('Ubah "$name"'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               final category = provider.categories.firstWhere(
  //                 (c) => c.id == categoryId,
  //               );
  //               KelolaKategoriScreen(category: category);
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(
  //               Icons.delete_outline,
  //               color: AppColors.danger,
  //             ),
  //             title: const Text(
  //               'Hapus kategori',
  //               style: TextStyle(color: AppColors.danger),
  //             ),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _confirmDeleteCategory(context, provider, categoryId);
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ChoiceChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primarySoft,
        labelStyle: TextStyle(
          color: isActive ? Colors.white : AppColors.ink,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: isActive ? AppColors.primarySoft : AppColors.line,
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final MenuItemEntity item;
  final String? categoryName;
  bool showAction;

  _MenuRow({
    required this.item,
    required this.categoryName,
    this.showAction = false,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus menu ini?'),
        content: Text('"${item.name}" akan dihapus permanen dari menu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: RestaurantColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await sl<MenuRepository>().deleteItem(item);
      await sl<MenuProvider>().deleteMenuItem(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RestaurantColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RestaurantColors.cardBorder),
      ),
      child: Row(
        children: [
          item.imageUrl != null
              ? Container(
                  width: 52,
                  height: 52,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppImageLoader().load(
                    item.imageUrl ?? "",
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: RestaurantColors.accentOrange.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: RestaurantColors.accentOrange,
                  ),
                ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: RestaurantColors.textPrimary,
                        ),
                      ),
                    ),
                    if (!item.isAvailable) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: RestaurantColors.dangerBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Nonaktif',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: RestaurantColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (item.isFavorite) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: RestaurantColors.accentOrange,
                      ),
                    ],
                    if (item.isBanner) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.slideshow,
                        size: 16,
                        color: RestaurantColors.accentOrange,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${categoryName ?? 'Tanpa kategori'} · ${formatRupiah(item.price)}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: RestaurantColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Edit',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MenuFormScreen(existingItem: item),
              ),
            ),
            icon: const Icon(
              Icons.edit_outlined,
              color: RestaurantColors.textSecondary,
            ),
          ),
          if (showAction)
            IconButton(
              tooltip: 'Hapus',
              onPressed: () => _confirmDelete(context),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: RestaurantColors.danger,
              ),
            ),
        ],
      ),
    );
  }
}
