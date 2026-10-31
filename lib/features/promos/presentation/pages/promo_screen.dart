import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/promos/domain/entities/promo_entity.dart';
import 'package:restauran_menu/features/promos/presentation/provider/promo_provider.dart';
import 'package:restauran_menu/features/promos/presentation/widgets/promo_card.dart';
import 'package:restauran_menu/features/promos/presentation/widgets/promo_form_dialog.dart';
import 'package:restauran_menu/features/promos/presentation/widgets/promo_stats_card.dart';
import 'package:restauran_menu/features/promos/presentation/widgets/promo_validate_dialog.dart';
import 'package:restauran_menu/shared/utils/show_custom_snack_bar.dart';

class PromoScreen extends StatelessWidget {
  const PromoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<PromoProvider>()..refresh(),
      child: const _PromoView(),
    );
  }
}

class _PromoView extends StatefulWidget {
  const _PromoView();

  @override
  State<_PromoView> createState() => _PromoViewState();
}

class _PromoViewState extends State<_PromoView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, active, inactive, percentage, fixed

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PromoEntity> _getFilteredPromos(List<PromoEntity> list) {
    return list.where((p) {
      // Search text match
      final query = _searchQuery.toLowerCase();
      final matchQuery =
          query.isEmpty ||
          p.code.toLowerCase().contains(query) ||
          p.title.toLowerCase().contains(query) ||
          (p.description?.toLowerCase().contains(query) ?? false);

      if (!matchQuery) return false;

      // Filter category
      switch (_selectedFilter) {
        case 'active':
          return p.isActive;
        case 'inactive':
          return !p.isActive;
        case 'percentage':
          return p.discountType.toLowerCase() == 'percentage';
        case 'fixed':
          return p.discountType.toLowerCase() == 'fixed';
        default:
          return true;
      }
    }).toList();
  }

  Future<void> _openCreateDialog(
    BuildContext context,
    PromoProvider provider,
  ) async {
    final ok = await PromoFormDialog.show(
      context,
      onSave: (payload) => provider.addPromo(payload),
    );
    if (ok == true && context.mounted) {
      showCustomSnackBar(context, 'Promo berhasil ditambahkan');
    }
  }

  Future<void> _openEditDialog(
    BuildContext context,
    PromoProvider provider,
    PromoEntity promo,
  ) async {
    final ok = await PromoFormDialog.show(
      context,
      promo: promo,
      onSave: (payload) => provider.editPromo(promo.id, payload),
    );
    if (ok == true && context.mounted) {
      showCustomSnackBar(context, 'Promo "${promo.code}" berhasil diperbarui');
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PromoProvider provider,
    PromoEntity promo,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Promo?'),
        content: Text(
          'Kode promo "${promo.code}" (${promo.title}) akan dihapus permanen.',
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
              style: TextStyle(color: RestaurantColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.removePromo(promo.id);
      if (context.mounted) {
        if (success) {
          showCustomSnackBar(context, 'Promo berhasil dihapus');
        } else {
          showCustomSnackBar(
            context,
            'Gagal menghapus promo',
            taskSuccess: false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PromoProvider>();

    return Scaffold(
      backgroundColor: RestaurantColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateDialog(context, provider),
        backgroundColor: RestaurantColors.accentOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Promo'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar / Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelola Promosi & Diskon',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: RestaurantColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Atur kode voucher potongan harga dan penawaran khusus',
                            style: TextStyle(
                              fontSize: 13,
                              color: RestaurantColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () =>
                                PromoValidateDialog.show(context, provider),
                            icon: const Icon(Icons.verified_outlined, size: 16),
                            label: const Text('Uji Validasi Kode'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: RestaurantColors.primaryBrown,
                              side: const BorderSide(
                                color: RestaurantColors.cardBorder,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded),
                            tooltip: 'Muat ulang',
                            onPressed: () => provider.load(refresh: true),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: RestaurantColors.cardBorder),

            // Content
            Expanded(
              child: Builder(
                builder: (context) {
                  if (provider.status == PromoStatus.loading &&
                      provider.promos.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.status == PromoStatus.error &&
                      provider.promos.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: RestaurantColors.danger,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              provider.errorMessage ?? 'Gagal memuat promo',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: RestaurantColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => provider.load(refresh: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: RestaurantColors.accentOrange,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final filtered = _getFilteredPromos(provider.promos);

                  return RefreshIndicator(
                    onRefresh: () => provider.load(refresh: true),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats Cards
                          PromoStatsCard(
                            stats: provider.stats,
                            promos: provider.promos,
                          ),

                          const SizedBox(height: 20),

                          // Search & Filters bar
                          Row(
                            children: [
                              // Search input
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: RestaurantColors.cardBorder,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (val) =>
                                        setState(() => _searchQuery = val),
                                    decoration: InputDecoration(
                                      hintText: 'Cari kode atau judul promo...',
                                      hintStyle: const TextStyle(
                                        fontSize: 13,
                                        color: RestaurantColors.textMuted,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search_rounded,
                                        color: RestaurantColors.textSecondary,
                                      ),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.clear,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(
                                                  () => _searchQuery = '',
                                                );
                                              },
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Filter chips
                              Expanded(
                                flex: 5,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _filterChip('all', 'Semua'),
                                      const SizedBox(width: 8),
                                      _filterChip('active', 'Aktif'),
                                      const SizedBox(width: 8),
                                      _filterChip('inactive', 'Nonaktif'),
                                      const SizedBox(width: 8),
                                      _filterChip('percentage', 'Persentase %'),
                                      const SizedBox(width: 8),
                                      _filterChip('fixed', 'Nominal Rp'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // List / Grid
                          if (filtered.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 60,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: RestaurantColors.cardBorder
                                            .withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.local_offer_outlined,
                                        size: 40,
                                        color: RestaurantColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      _searchQuery.isNotEmpty ||
                                              _selectedFilter != 'all'
                                          ? 'Tidak ada promo yang sesuai kriteria filter'
                                          : 'Belum ada data promo tersimpan',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: RestaurantColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Buat promo diskon untuk menarik lebih banyak pembeli.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: RestaurantColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _openCreateDialog(context, provider),
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Buat Promo Pertama'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            RestaurantColors.accentOrange,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 900;
                                if (isWide) {
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          mainAxisExtent: 250,
                                        ),
                                    itemCount: filtered.length,
                                    itemBuilder: (context, i) {
                                      final promo = filtered[i];
                                      return PromoCard(
                                        promo: promo,
                                        onToggleStatus: (val) =>
                                            provider.toggleStatus(promo.id),
                                        onEdit: () => _openEditDialog(
                                          context,
                                          provider,
                                          promo,
                                        ),
                                        onDelete: () => _confirmDelete(
                                          context,
                                          provider,
                                          promo,
                                        ),
                                      );
                                    },
                                  );
                                }

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (context, i) {
                                    final promo = filtered[i];
                                    return PromoCard(
                                      promo: promo,
                                      onToggleStatus: (val) =>
                                          provider.toggleStatus(promo.id),
                                      onEdit: () => _openEditDialog(
                                        context,
                                        provider,
                                        promo,
                                      ),
                                      onDelete: () => _confirmDelete(
                                        context,
                                        provider,
                                        promo,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String key, String label) {
    final selected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        if (val) setState(() => _selectedFilter = key);
      },
      selectedColor: RestaurantColors.accentOrange,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        color: selected ? Colors.white : RestaurantColors.textPrimary,
      ),
      side: BorderSide(
        color: selected
            ? RestaurantColors.accentOrange
            : RestaurantColors.cardBorder,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
