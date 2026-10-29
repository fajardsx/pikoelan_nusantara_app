import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restauran_menu/core/database/category_repository.dart';
import 'package:restauran_menu/features/menu/data/models/menu_item_payload.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_category_entity.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';
import 'package:restauran_menu/features/menu/presentation/provider/menu_provider.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/themes/restaurant_colors.dart';

/// Add/edit screen for a single menu item. Pass [existingItem] to edit;
/// omit it to create a new item.
class MenuFormScreen extends StatefulWidget {
  final MenuItemEntity? existingItem;
  const MenuFormScreen({super.key, this.existingItem});

  @override
  State<MenuFormScreen> createState() => _MenuFormScreenState();
}

class _MenuFormScreenState extends State<MenuFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _originalPriceController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _descriptionController;

  int? _categoryId;
  late bool _isFavorite;
  late bool _isAvailable;
  late bool _isBanner;
  bool _saving = false;

  bool get _isEditing => widget.existingItem != null;
  XFile? _pickedImage; // file terpilih (Web & Android)
  Uint8List? _pickedImageBytes; // bytes untuk preview (wajib untuk Web)
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _priceController = TextEditingController(
      text: item != null ? item.price.toString() : '',
    );
    _originalPriceController = TextEditingController(
      text: item?.originalPrice?.toString() ?? '',
    );
    _imageUrlController = TextEditingController(text: item?.imageUrl ?? '');
    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    _categoryId = item?.categoryId;
    _isFavorite = item?.isFavorite ?? false;
    _isAvailable = item?.isAvailable ?? true;
    _isBanner = item?.isBanner ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Helper pilih gambar — 2 MODE: Web & Android.
  // Web: upload file via browser (gallery saja, tanpa kamera),
  //      preview pakai bytes (Image.memory), path = blob URL jangan disimpan.
  // Android: galeri (+ kamera), preview juga pakai bytes agar tanpa dart:io.
  Future<void> _selectImage() async {
    final bool isWeb = kIsWeb;

    // Web langsung buka file picker, Android tampilkan pilihan sumber dulu.
    ImageSource? source;
    if (isWeb) {
      source = ImageSource.gallery;
    } else {
      source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pilih Sumber Gambar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Galeri'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: const Text('Kamera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          ),
        ),
      );
      if (source == null) return;
    }

    try {
      final XFile? image = await _pickImageForPlatform(source);

      if (image != null) {
        // readAsBytes jalan di Web & Android — jadi preview selalu pakai bytes.
        final Uint8List bytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() {
          _pickedImage = image;
          _pickedImageBytes = bytes;
          // Web: image.path = blob URL (blob:http://...) → tampilkan nama file saja.
          // Android: path file asli masih berguna untuk info.
          _imageUrlController.text = isWeb ? image.name : image.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
    }
  }

  /// Line 110: 2 mode pickImage — Web (upload file browser) vs Android (galeri/kamera).
  Future<XFile?> _pickImageForPlatform(ImageSource source) {
    if (kIsWeb) {
      // MODE FLUTTER WEB: file upload via <input type=file> browser.
      // source dipaksa gallery, kamera tidak didukung image_picker web.
      return _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
    } else {
      // MODE FLUTTER ANDROID: galeri / kamera device.
      return _picker.pickImage(source: source, maxWidth: 800, imageQuality: 85);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = MenuItemEntity(
      id: widget.existingItem?.id ?? -1,
      sortOrder: widget.existingItem?.sortOrder ?? -1,
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      originalPrice: _originalPriceController.text.trim().isEmpty
          ? null
          : double.tryParse(_originalPriceController.text.trim()),
      categoryId: _categoryId,
      imageUrl: _pickedImage == null
          ? (_imageUrlController.text.trim().isEmpty
                ? null
                : _imageUrlController.text.trim())
          : null,
      isFavorite: _isFavorite,
      isAvailable: _isAvailable,
      isBanner: _isBanner,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );
    final provider = sl<MenuProvider>();
    final payload = MenuItemPayload(
      name: item.name,
      price: item.price,
      originalPrice: item.originalPrice,
      categoryId: item.categoryId,
      imagePath: _pickedImage,
      isFavorite: item.isFavorite,
      isAvailable: item.isAvailable,
      isBanner: item.isBanner,
      description: item.description,
    );

    //final repo = sl<MenuRepository>();
    try {
      final success = _isEditing
          ? await provider.updateMenuItem(widget.existingItem!.id, payload)
          : await provider.createMenuItem(payload);
      // if (_isEditing) {
      //   await repo.updateItem(item);
      // } else {
      //   await repo.addItem(item);
      // }
      //debugPrint("Success : $success");
      if (!success) return;
      if (!mounted) return;
      setState(() => _saving = false);
      Navigator.pop(context);
      //}
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: RestaurantColors.danger,
        ),
      );
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
        title: Text(
          _isEditing ? 'Edit Menu' : 'Tambah Menu',
          style: const TextStyle(color: RestaurantColors.textPrimary),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _FieldLabel('Nama Menu'),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Contoh: Nasi Goreng Spesial'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Harga'),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _inputDecoration('0'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Wajib diisi';
                          }
                          if (int.tryParse(v.trim()) == null) {
                            return 'Angka tidak valid';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Harga Coret (opsional)'),
                      TextFormField(
                        controller: _originalPriceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _inputDecoration('0'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _FieldLabel('Kategori'),
            StreamBuilder<List<MenuCategoryEntity>>(
              stream: sl<CategoryRepository>().watchAll(),
              builder: (context, snapshot) {
                final categories = snapshot.data ?? [];
                final validIds = categories.map((c) => c.id).toSet();
                final current = validIds.contains(_categoryId)
                    ? _categoryId
                    : null;
                return DropdownButtonFormField<int>(
                  initialValue: current,
                  decoration: _inputDecoration(
                    categories.isEmpty
                        ? 'Belum ada kategori'
                        : 'Pilih kategori',
                  ),
                  items: categories
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: categories.isEmpty
                      ? null
                      : (v) {
                          //debugPrint("select : $v");
                          setState(() => _categoryId = v);
                        },
                );
              },
            ),
            const SizedBox(height: 16),
            const _FieldLabel('Foto Menu (opsional)'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _imageUrlController,
                    decoration: _inputDecoration(
                      'https://... (jika pakai URL)',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _selectImage,
                  icon: const Icon(Icons.image_search_rounded, size: 18),
                  label: const Text('Pilih Gambar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RestaurantColors.primaryBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            if (_pickedImage != null && _pickedImageBytes != null) ...[
              const SizedBox(height: 12),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // Dual-mode: pakai bytes agar jalan di Web & Android.
                    // Jangan pakai Image.file / dart:io (crash di Web).
                    child: Image.memory(
                      _pickedImageBytes!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _pickedImage = null;
                          _pickedImageBytes = null;
                          _imageUrlController.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const _FieldLabel('Deskripsi (opsional)'),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: _inputDecoration('Deskripsi singkat menu'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Menu Favorit'),
              subtitle: const Text('Tampilkan di beranda pelanggan'),
              value: _isFavorite,
              activeThumbColor: RestaurantColors.primaryBrown,
              onChanged: (v) => setState(() => _isFavorite = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tampilkan di Banner'),
              subtitle: const Text('Tampilkan di banner promo beranda'),
              value: _isBanner,
              activeThumbColor: RestaurantColors.primaryBrown,
              onChanged: (v) => setState(() => _isBanner = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tersedia'),
              subtitle: const Text('Nonaktifkan jika stok/menu habis'),
              value: _isAvailable,
              activeThumbColor: RestaurantColors.primaryBrown,
              onChanged: (v) => setState(() => _isAvailable = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: RestaurantColors.primaryBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _saving
                    ? 'Menyimpan...'
                    : (_isEditing ? 'Simpan Perubahan' : 'Tambah Menu'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: RestaurantColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RestaurantColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RestaurantColors.cardBorder),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: RestaurantColors.textSecondary,
        ),
      ),
    );
  }
}
