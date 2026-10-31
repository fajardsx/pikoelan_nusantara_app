import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_constant.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/staff/domain/entities/staff_entity.dart';
import 'package:restauran_menu/shared/utils/date_time_formatter.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/themes/app_colors.dart';
import '../providers/staff_provider.dart';
import 'invite_staff_dialog.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<StaffProvider>()..refresh(),
      child: const _StaffView(),
    );
  }
}

class _StaffView extends StatelessWidget {
  const _StaffView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();

    return Scaffold(
      appBar: null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showInviteStaffDialog(context),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Tambah Staf'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kelola Staf',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: RestaurantColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Atur akun dan peran untuk karyawan restoran',
                      style: TextStyle(color: RestaurantColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.status == StaffStatus.loading ||
                    provider.status == StaffStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.status == StaffStatus.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            size: 40,
                            color: AppColors.inkFaint,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            provider.errorMessage ?? 'Gagal memuat',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.inkSoft),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => provider.load(forceRefresh: true),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (provider.staff.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Baru kamu sendiri. Tambahkan rekan kerja lewat tombol di bawah.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.inkSoft),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => provider.refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
                    itemCount: provider.staff.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final s = provider.staff[index];
                      return _staffCell(context, s);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _staffCell(BuildContext context, StaffEntity s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accentSoft,
            child: Text(
              s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  s.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.inkSoft,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bergabung ${formatDateTime(s.createdAt)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.inkFaint,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              s.roleLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              size: 20,
              color: AppColors.inkSoft,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditStaffDialog(context, s);
              } else if (value == 'delete') {
                _showDeleteStaffDialog(context, s);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: RestaurantColors.textPrimary,
                    ),
                    SizedBox(width: 10),
                    Text('Edit Staf', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Hapus Staf',
                      style: TextStyle(fontSize: 13, color: AppColors.danger),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditStaffDialog(BuildContext context, StaffEntity staff) {
    final nameController = TextEditingController(text: staff.name);
    String role = staff.role;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Staf'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nama Staf'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: role,
                      decoration: const InputDecoration(labelText: 'Peran'),
                      items: Consts.roleOptions
                          .map(
                            (r) => DropdownMenuItem(
                              value: r.$1,
                              child: Text(r.$2),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => role = v ?? 'staff'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    final success = await context
                        .read<StaffProvider>()
                        .updateStaff(id: staff.id, name: name, role: role);
                    if (success && dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data staf berhasil diperbarui'),
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteStaffDialog(BuildContext context, StaffEntity staff) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Staf'),
          content: Text(
            'Apakah kamu yakin ingin menghapus "${staff.name}" dari daftar staf?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              onPressed: () async {
                final success = await context.read<StaffProvider>().deleteStaff(
                  staff.id,
                );
                if (success && dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Staf berhasil dihapus')),
                  );
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
