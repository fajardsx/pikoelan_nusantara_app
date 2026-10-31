import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/members/domain/entities/member_entity.dart';
import 'package:restauran_menu/features/members/presentation/provider/member_provider.dart';
import 'package:restauran_menu/features/members/presentation/widgets/member_card.dart';
import 'package:restauran_menu/features/members/presentation/widgets/member_detail_dialog.dart';
import 'package:restauran_menu/features/members/presentation/widgets/member_form_dialog.dart';
import 'package:restauran_menu/features/members/presentation/widgets/member_stats_card.dart';
import 'package:restauran_menu/shared/utils/show_custom_snack_bar.dart';

class MemberScreen extends StatelessWidget {
  const MemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<MemberProvider>()..load(),
      child: const _MemberView(),
    );
  }
}

class _MemberView extends StatefulWidget {
  const _MemberView();

  @override
  State<_MemberView> createState() => _MemberViewState();
}

class _MemberViewState extends State<_MemberView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTier = 'all'; // all, bronze, silver, gold, platinum

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MemberEntity> _getFilteredMembers(List<MemberEntity> list) {
    return list.where((m) {
      final query = _searchQuery.toLowerCase();
      final matchQuery =
          query.isEmpty ||
          m.name.toLowerCase().contains(query) ||
          m.phone.toLowerCase().contains(query) ||
          m.memberCode.toLowerCase().contains(query) ||
          (m.email?.toLowerCase().contains(query) ?? false);

      if (!matchQuery) return false;

      if (_selectedTier != 'all') {
        return m.tier.toLowerCase() == _selectedTier.toLowerCase();
      }

      return true;
    }).toList();
  }

  Future<void> _openCreateDialog(
    BuildContext context,
    MemberProvider provider,
  ) async {
    final ok = await MemberFormDialog.show(
      context,
      onSave: (payload) => provider.addMember(payload),
    );
    if (ok == true && context.mounted) {
      showCustomSnackBar(context, 'Member baru berhasil didaftarkan');
    }
  }

  Future<void> _openEditDialog(
    BuildContext context,
    MemberProvider provider,
    MemberEntity member,
  ) async {
    final ok = await MemberFormDialog.show(
      context,
      member: member,
      onSave: (payload) => provider.editMember(member.id, payload),
    );
    if (ok == true && context.mounted) {
      showCustomSnackBar(
        context,
        'Data member "${member.name}" berhasil diperbarui',
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    MemberProvider provider,
    MemberEntity member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Member?'),
        content: Text(
          'Member "${member.name}" (${member.memberCode}) akan dihapus permanen.',
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
      final success = await provider.removeMember(member.id);
      if (context.mounted) {
        if (success) {
          showCustomSnackBar(context, 'Member berhasil dihapus');
        } else {
          showCustomSnackBar(
            context,
            'Gagal menghapus member',
            taskSuccess: false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemberProvider>();

    return Scaffold(
      backgroundColor: RestaurantColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateDialog(context, provider),
        backgroundColor: RestaurantColors.accentOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Tambah Member'),
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
                            'Kelola Member Restoran',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: RestaurantColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Data keanggotaan pelanggan, loyalitas poin, dan tingkatan (tier)',
                            style: TextStyle(
                              fontSize: 13,
                              color: RestaurantColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: 'Muat ulang',
                        onPressed: () => provider.load(refresh: true),
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
                  if (provider.status == MemberStatus.loading &&
                      provider.members.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.status == MemberStatus.error &&
                      provider.members.isEmpty) {
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
                              provider.errorMessage ??
                                  'Gagal memuat data member',
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

                  final filtered = _getFilteredMembers(provider.members);

                  return RefreshIndicator(
                    onRefresh: () => provider.load(refresh: true),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats Cards
                          MemberStatsCard(members: provider.members),

                          const SizedBox(height: 20),

                          // Search & Filter Tier Chips
                          Row(
                            children: [
                              // Search input
                              Expanded(
                                flex: 4,
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
                                      hintText:
                                          'Cari nama, kode member, no hp...',
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
                              // Tier chips
                              Expanded(
                                flex: 5,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _tierChip('all', 'Semua Tier'),
                                      const SizedBox(width: 8),
                                      _tierChip('bronze', 'Bronze'),
                                      const SizedBox(width: 8),
                                      _tierChip('silver', 'Silver'),
                                      const SizedBox(width: 8),
                                      _tierChip('gold', 'Gold'),
                                      const SizedBox(width: 8),
                                      _tierChip('platinum', 'Platinum'),
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
                                        Icons.card_membership_rounded,
                                        size: 40,
                                        color: RestaurantColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      _searchQuery.isNotEmpty ||
                                              _selectedTier != 'all'
                                          ? 'Tidak ada member yang cocok dengan pencarian'
                                          : 'Belum ada data member terdaftar',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: RestaurantColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Daftarkan pelanggan agar bisa mengumpulkan poin dan promo tier.',
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
                                      label: const Text(
                                        'Daftarkan Member Pertama',
                                      ),
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
                                          mainAxisExtent: 245,
                                        ),
                                    itemCount: filtered.length,
                                    itemBuilder: (context, i) {
                                      final member = filtered[i];
                                      return MemberCard(
                                        member: member,
                                        onTap: () => MemberDetailDialog.show(
                                          context,
                                          member: member,
                                          onEdit: () => _openEditDialog(
                                            context,
                                            provider,
                                            member,
                                          ),
                                        ),
                                        onEdit: () => _openEditDialog(
                                          context,
                                          provider,
                                          member,
                                        ),
                                        onDelete: () => _confirmDelete(
                                          context,
                                          provider,
                                          member,
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
                                    final member = filtered[i];
                                    return MemberCard(
                                      member: member,
                                      onTap: () => MemberDetailDialog.show(
                                        context,
                                        member: member,
                                        onEdit: () => _openEditDialog(
                                          context,
                                          provider,
                                          member,
                                        ),
                                      ),
                                      onEdit: () => _openEditDialog(
                                        context,
                                        provider,
                                        member,
                                      ),
                                      onDelete: () => _confirmDelete(
                                        context,
                                        provider,
                                        member,
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

  Widget _tierChip(String key, String label) {
    final selected = _selectedTier == key;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        if (val) setState(() => _selectedTier = key);
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
