import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restauran_menu/features/menu/data/models/category_payload.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_category_entity.dart';
import 'package:restauran_menu/features/menu/presentation/provider/menu_provider.dart';
import 'package:restauran_menu/features/permissions/domain/entities/permission_status_entity.dart';
import 'package:restauran_menu/shared/widgets/app_image_loader.dart';
import 'package:restauran_menu/shared/widgets/photo_picker_widget.dart';

import '../../../../core/database/category_repository.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/themes/restaurant_colors.dart';

class KelolaKategoriScreen extends StatelessWidget {
  final MenuCategoryEntity? category;
  final PermissionStatusEntity permission;
  const KelolaKategoriScreen({
    super.key,
    this.category,
    required this.permission,
  });

  Future<void> _openForm(BuildContext context, {MenuCategoryEntity? category}) {
    return showDialog(
      context: context,
      builder: (_) => _CategoryFormDialog(existing: category),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    MenuCategoryEntity category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus kategori ini?'),
        content: Text(
          '"${category.name}" akan dihapus. Menu yang memakai kategori ini '
          'akan tampil sebagai "Tanpa kategori".',
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
      await sl<CategoryRepository>().deleteCategory(category.id);
      await sl<MenuProvider>().deleteCategory(category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RestaurantColors.background,
      appBar: AppBar(
        backgroundColor: RestaurantColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: RestaurantColors.textPrimary),
        title: const Text(
          'Kelola Kategori',
          style: TextStyle(color: RestaurantColors.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: permission.canAdd
                ? ElevatedButton.icon(
                    onPressed: () => _openForm(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Tambah '),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RestaurantColors.primaryBrown,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  )
                : null,
          ),
        ],
      ),
      body: StreamBuilder<List<MenuCategoryEntity>>(
        stream: sl<CategoryRepository>().watchAll(),
        builder: (context, snapshot) {
          final categories = snapshot.data ?? [];
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (categories.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada kategori. Tambahkan kategori pertamamu.',
                style: TextStyle(color: RestaurantColors.textSecondary),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: RestaurantColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: RestaurantColors.cardBorder),
                ),
                child: Row(
                  children: [
                    category.categoriesPicture != null
                        ? Container(
                            width: 40,
                            height: 40,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: AppImageLoader().load(
                              category.categoriesPicture ?? "",
                            ),
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: RestaurantColors.accentOrange.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.category_rounded,
                              color: RestaurantColors.accentOrange,
                              size: 20,
                            ),
                          ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: RestaurantColors.textPrimary,
                        ),
                      ),
                    ),
                    if (permission.canEdit)
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () => _openForm(context, category: category),
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: RestaurantColors.textSecondary,
                        ),
                      ),
                    if (permission.canDel)
                      IconButton(
                        tooltip: 'Hapus',
                        onPressed: () => _confirmDelete(context, category),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: RestaurantColors.danger,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryFormDialog extends StatefulWidget {
  final MenuCategoryEntity? existing;
  const _CategoryFormDialog({this.existing});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _formIconKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _iconController;
  XFile? _pickedImage;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _iconController = TextEditingController(
      text: widget.existing?.categoriesPicture ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await displayImagePickerDialog(context);
    if (picked != null && mounted) {
      setState(() {
        _pickedImage = picked;
        _iconController.text = picked.path;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    //final repo = sl<CategoryRepository>();
    final name = _nameController.text.trim();
    //final categoriesPicture = _pickedImage?.path ?? _iconController.text.trim();

    final provider = sl<MenuProvider>();
    final payload = CategoryPayload(name: name, imageFile: _pickedImage);
    final success = _isEditing
        ? await provider.updateCategory(widget.existing!.id, payload)
        : await provider.createCategory(payload);

    if (success) {
      // if (_isEditing) {
      //   await repo.updateCategory(
      //     MenuCategoryEntity(
      //       id: widget.existing!.id,
      //       name: name,
      //       categoriesPicture: categoriesPicture,
      //       sortOrder: widget.existing!.sortOrder,
      //       isActive: widget.existing!.isActive,
      //     ),
      //   );
      // } else {
      //   await repo.addCategory(
      //     MenuCategoryEntity(
      //       id: -1,
      //       name: name,
      //       categoriesPicture: categoriesPicture,
      //       sortOrder: -1,
      //       isActive: true,
      //     ),
      //   );
      // }
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Kategori' : 'Tambah Kategori'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(children: [Text('Nama Kategori* : ')]),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Contoh: Makanan'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
          ),
          const SizedBox(height: 10),
          const Row(children: [Text('Icon Kategori : ')]),
          Form(
            key: _formIconKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _iconController,
                    autofocus: false,
                    decoration: const InputDecoration(
                      hintText: 'Url untuk icon',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: RestaurantColors.background,
                      border: Border(
                        left: BorderSide(
                          color: RestaurantColors.primaryBrown,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: RestaurantColors.primaryBrown,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: RestaurantColors.primaryBrown,
            foregroundColor: Colors.white,
          ),
          child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
        ),
      ],
    );
  }
}
