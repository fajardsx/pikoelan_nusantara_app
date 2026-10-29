import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/section_card.dart';
import 'package:restauran_menu/shared/utils/show_custom_snack_bar.dart';

import '../../domain/entities/role_permissions_entity.dart';
import '../provider/permission_provider.dart';
import '../widgets/permission_matrix_table.dart';

/// Halaman konfigurasi privilege per role.
/// Sumber data: `GET/PUT/DELETE api/permissions`.
class PermissionConfigScreen extends StatelessWidget {
  const PermissionConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<PermissionProvider>()..load(),
      child: const _PermissionConfigView(),
    );
  }
}

class _PermissionConfigView extends StatelessWidget {
  const _PermissionConfigView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PermissionProvider>();

    return Scaffold(
      backgroundColor: RestaurantColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(provider),
              const SizedBox(height: 18),
              Expanded(child: _buildBody(context, provider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(PermissionProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privilege & Hak Akses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: RestaurantColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Atur aksi apa saja yang boleh dilakukan setiap peran pada tiap menu.',
                style: TextStyle(color: RestaurantColors.textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Muat ulang',
          onPressed: provider.isSaving
              ? null
              : () => provider.load(forceRefresh: true),
          icon: const Icon(
            Icons.refresh_rounded,
            color: RestaurantColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, PermissionProvider provider) {
    switch (provider.status) {
      case PermissionStatus.initial:
      case PermissionStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case PermissionStatus.error:
        return _buildErrorState(context, provider);
      case PermissionStatus.loaded:
        return _buildContent(context, provider);
    }
  }


  Widget _buildErrorState(BuildContext context, PermissionProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 40,
              color: RestaurantColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage ?? 'Gagal memuat data privilege',
              textAlign: TextAlign.center,
              style: const TextStyle(color: RestaurantColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.load(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PermissionProvider provider) {
    final role = provider.activeRole;
    if (role == null) {
      return const Center(
        child: Text(
          'Tidak ada role yang bisa diatur.',
          style: TextStyle(color: RestaurantColors.textSecondary),
        ),
      );
    }

    final dirty = provider.hasChanges(role.role);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRoleChips(provider, role.role),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Hak akses ${role.label}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Centang aksi yang boleh dilakukan role ini.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: RestaurantColors.textSecondary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: provider.isSaving
                          ? null
                          : () => provider.setAllPermissions(
                              role: role.role,
                              value: true,
                            ),
                      child: const Text('Beri semua'),
                    ),
                    TextButton(
                      onPressed: provider.isSaving
                          ? null
                          : () => provider.setAllPermissions(
                              role: role.role,
                              value: false,
                            ),
                      child: const Text('Cabut semua'),
                    ),
                  ],
                ),
                PermissionMatrixTable(
                  menus: provider.menus,
                  actions: provider.actions,
                  permissions: role.permissions,
                  enabled: !provider.isSaving,
                  onToggle: (menuKey, action, value) =>
                      provider.togglePermission(
                        role: role.role,
                        menuKey: menuKey,
                        action: action,
                        value: value,
                      ),
                ),
                if (provider.submitError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    provider.submitError!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: RestaurantColors.danger,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          _buildFooter(context, provider, role, dirty),
        ],
      ),
    );
  }

  Widget _buildRoleChips(PermissionProvider provider, String selectedRole) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: provider.roles.map((role) {
        final selected = role.role == selectedRole;
        final dirty = provider.hasChanges(role.role);

        return ChoiceChip(
          selected: selected,
          showCheckmark: false,
          backgroundColor: RestaurantColors.surface,
          selectedColor: RestaurantColors.warningBg,
          side: BorderSide(
            color: selected
                ? RestaurantColors.accentOrange
                : RestaurantColors.cardBorder,
          ),
          label: Text(dirty ? '${role.label} *' : role.label),
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected
                ? RestaurantColors.accentOrange
                : RestaurantColors.textThird,
          ),
          onSelected: provider.isSaving
              ? null
              : (_) => provider.selectRole(role.role),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    PermissionProvider provider,
    RolePermissionsEntity role,
    bool dirty,
  ) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        Text(
          dirty
              ? 'Perubahan ${role.label} belum disimpan'
              : 'Hak akses ${role.label} sudah sesuai server',
          style: TextStyle(
            fontSize: 12.5,
            color: dirty
                ? RestaurantColors.warning
                : RestaurantColors.textSecondary,
          ),
        ),
        OutlinedButton.icon(
          onPressed: provider.isSaving
              ? null
              : () => _confirmReset(context, provider, role),
          icon: const Icon(Icons.restore_rounded, size: 18),
          label: const Text('Reset ke Default'),
          style: OutlinedButton.styleFrom(
            foregroundColor: RestaurantColors.textThird,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: (!dirty || provider.isSaving)
              ? null
              : () => _save(context, provider, role),
          icon: provider.isSaving
              ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_rounded, size: 18),
          label: Text(provider.isSaving ? 'Menyimpan...' : 'Simpan Perubahan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: RestaurantColors.primaryBrown,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save(
    BuildContext context,
    PermissionProvider provider,
    RolePermissionsEntity role,
  ) async {
    final success = await provider.saveRole(role.role);
    if (!context.mounted) return;

    showCustomSnackBar(
      context,
      success
          ? 'Hak akses ${role.label} berhasil disimpan'
          : provider.submitError ?? 'Gagal menyimpan hak akses',
      taskSuccess: success,
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    PermissionProvider provider,
    RolePermissionsEntity role,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset hak akses'),
        content: Text(
          'Kembalikan hak akses "${role.label}" ke pengaturan default? '
          'Perubahan yang belum disimpan akan hilang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: RestaurantColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await provider.resetRole(role.role);
    if (!context.mounted) return;

    showCustomSnackBar(
      context,
      success
          ? 'Hak akses ${role.label} dikembalikan ke default'
          : provider.submitError ?? 'Gagal reset hak akses',
      taskSuccess: success,
    );
  }
}
