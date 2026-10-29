import 'package:flutter/foundation.dart';

import '../../domain/entities/permission_matrix_entity.dart';
import '../../domain/entities/permission_menu_entity.dart';
import '../../domain/entities/role_permission_entity.dart';
import '../../domain/entities/role_permissions_entity.dart';
import '../../domain/usecases/get_my_permissions_usecase.dart';
import '../../domain/usecases/get_permission_matrix_usecase.dart';
import '../../domain/usecases/reset_role_permissions_usecase.dart';
import '../../domain/usecases/update_role_permissions_usecase.dart';

enum PermissionStatus { initial, loading, loaded, error }

/// State halaman konfigurasi privilege (`api/permissions`).
///
/// Perubahan checkbox ditahan dulu di [matrix] (draft) lalu dikirim per role
/// lewat [saveRole]. [hasChanges] membandingkan draft dengan snapshot terakhir
/// dari server supaya tombol simpan hanya aktif kalau memang ada perubahan.
class PermissionProvider extends ChangeNotifier {
  final GetPermissionMatrixUsecase getPermissionMatrixUsecase;
  final GetMyPermissionsUsecase getMyPermissionsUsecase;
  final UpdateRolePermissionsUsecase updateRolePermissionsUsecase;
  final ResetRolePermissionsUsecase resetRolePermissionsUsecase;

  PermissionProvider(
    this.getPermissionMatrixUsecase,
    this.getMyPermissionsUsecase,
    this.updateRolePermissionsUsecase,
    this.resetRolePermissionsUsecase,
  );

  PermissionStatus status = PermissionStatus.initial;
  String? errorMessage;

  PermissionMatrixEntity? matrix;
  List<RolePermissionEntity> myPermissions = [];
  String? selectedRole;

  bool isSaving = false;
  String? submitError;

  /// Snapshot privilege terakhir dari server, key = role.
  final Map<String, List<RolePermissionEntity>> _saved = {};

  List<PermissionMenuEntity> get menus => matrix?.menus ?? const [];

  List<String> get actions =>
      matrix?.actions ?? RolePermissionEntity.actionKeys;

  List<RolePermissionsEntity> get roles => matrix?.roles ?? const [];

  int? get tenantId => matrix?.tenantId;

  /// Role yang sedang diedit. Kalau [selectedRole] belum/tidak valid,
  /// fallback ke role pertama dari matrix.
  RolePermissionsEntity? get activeRole {
    final roleList = roles;
    if (roleList.isEmpty) return null;
    return matrix?.roleFor(selectedRole) ?? roleList.first;
  }

  bool get hasAnyChanges => roles.any((role) => hasChanges(role.role));

  /// Muat matriks privilege semua role.
  /// [tenantId] hanya diperlukan kalau user login sebagai superadmin.
  Future<void> load({bool forceRefresh = false, int? tenantId}) async {
    status = PermissionStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        getPermissionMatrixUsecase(
          forceRefresh: forceRefresh,
          tenantId: tenantId,
        ),
        getMyPermissionsUsecase(forceRefresh: forceRefresh),
      ]);

      final result = results[0] as PermissionMatrixEntity;
      matrix = result;
      myPermissions = results[1] as List<RolePermissionEntity>;

      _saved.clear();
      for (final role in result.roles) {
        _saved[role.role] = List<RolePermissionEntity>.from(role.permissions);
      }

      final roleNames = result.roleNames;
      if (roleNames.isNotEmpty &&
          (selectedRole == null || !roleNames.contains(selectedRole))) {
        selectedRole = roleNames.first;
      }

      status = PermissionStatus.loaded;
    } catch (e) {
      errorMessage = _message(e);
      status = PermissionStatus.error;
    }
    notifyListeners();
  }

  void selectRole(String role) {
    if (selectedRole == role) return;
    selectedRole = role;
    notifyListeners();
  }

  /// Ubah satu checkbox. Perubahan hanya di state lokal (draft).
  void togglePermission({
    required String role,
    required String menuKey,
    required String action,
    required bool value,
  }) {
    final current = matrix;
    if (current == null) return;

    matrix = current.copyWith(
      roles: current.roles
          .map(
            (item) => item.role == role
                ? item.setFlag(menuKey: menuKey, action: action, value: value)
                : item,
          )
          .toList(),
    );
    notifyListeners();
  }

  /// Beri/cabut semua aksi pada semua menu untuk satu role (draft).
  void setAllPermissions({required String role, required bool value}) {
    final current = matrix;
    if (current == null) return;

    matrix = current.copyWith(
      roles: current.roles
          .map((item) => item.role == role ? item.setAll(value) : item)
          .toList(),
    );
    notifyListeners();
  }

  bool hasChanges(String role) {
    final current = matrix?.roleFor(role);
    final baseline = _saved[role];
    if (current == null || baseline == null) return false;

    final permissions = current.permissions;
    if (permissions.length != baseline.length) return true;

    for (var i = 0; i < baseline.length; i++) {
      if (permissions[i] != baseline[i]) return true;
    }
    return false;
  }

  /// `PUT api/permissions/:role` untuk satu role.
  Future<bool> saveRole(String role) async {
    final current = matrix?.roleFor(role);
    if (current == null) return false;

    isSaving = true;
    submitError = null;
    notifyListeners();

    try {
      final permissions = await updateRolePermissionsUsecase(
        role: role,
        permissions: current.permissions,
        tenantId: matrix?.tenantId,
      );
      _applyRolePermissions(role, permissions);
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSaving = false;
      submitError = _message(e);
      notifyListeners();
      return false;
    }
  }

  /// `DELETE api/permissions/:role` -> role kembali ke privilege default.
  Future<bool> resetRole(String role) async {
    isSaving = true;
    submitError = null;
    notifyListeners();

    try {
      final permissions = await resetRolePermissionsUsecase(
        role: role,
        tenantId: matrix?.tenantId,
      );
      _applyRolePermissions(role, permissions);
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSaving = false;
      submitError = _message(e);
      notifyListeners();
      return false;
    }
  }

  /// Cek izin dari `GET api/permissions/me`.
  /// Kalau data belum dimuat, dianggap boleh (jangan sembunyikan menu
  /// hanya karena request privilege gagal).
  bool can(String menuKey, String action) {
    if (myPermissions.isEmpty) return true;
    for (final permission in myPermissions) {
      if (permission.menuKey == menuKey) return permission.flagFor(action);
    }
    return false;
  }

  void resetSubmitStatus() {
    submitError = null;
  }

  void _applyRolePermissions(
    String role,
    List<RolePermissionEntity> permissions,
  ) {
    final current = matrix;
    final normalized = permissions.isEmpty
        ? (current?.roleFor(role)?.permissions ??
              const <RolePermissionEntity>[])
        : permissions;

    if (current != null) {
      matrix = current.withRolePermissions(role, normalized);
    }
    _saved[role] = List<RolePermissionEntity>.from(normalized);
  }

  /// Buang prefix `Exception: ` supaya pesan rapi saat ditampilkan.
  String _message(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}
