import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_constant.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/services/shared_pref_services.dart';
import 'package:restauran_menu/features/admin/presentation/provider/admin_provider.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/field_label.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/info_row.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/section_card.dart';

import '../../../../core/themes/restaurant_colors.dart';

/// Simple key wrapper around [SharedPrefServices] so all Kasir settings
/// keys live in one place.
class SettingsKeys {
  static const bankAccountName = 'settings_bank_account_name';
  static const phoneConfirmation = 'settings_phone_confirmation';
  static const deliveryDescription = 'settings_delivery_description';
  static const restaurantName = 'settings_restaurant_name';
  static const restaurantAddress = 'settings_restaurant_address';
  static const restaurantPhone = 'settings_restaurant_phone';
  static const autoPrint = 'settings_auto_print';
  static const newOrderNotif = 'settings_new_order_notif';
  static const confirmCancel = 'settings_confirm_cancel';
  static const restaurantLogo = 'settings_restaurant_logo';
  static const restaurantQris = 'settings_restaurant_qris';
  static const primaryColor = 'settings_primary_color';
  static const accentColor = 'settings_accent_color';
  static const enablePPN = 'settings_enable_ppn';
  static const ppnValue = 'settings_ppn_value'; // Tambahkan key untuk nilai PPN
  static const restaurantRekening =
      'settings_restaurant_rekening'; // Tambahkan key untuk No Rekening
  static const printerMac =
      'settings_printer_mac'; // MAC address of Bluetooth printer
  static const paperSize = 'settings_printer_papersize'; // "58" or "80"
}

class AdminPengaturanScreen extends StatefulWidget {
  const AdminPengaturanScreen({super.key});

  @override
  State<AdminPengaturanScreen> createState() => _AdminPengaturanScreenState();
}

class _AdminPengaturanScreenState extends State<AdminPengaturanScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _rekeningController;
  late final TextEditingController _bankAccountNameController;
  late final TextEditingController _phoneConfirmationController;
  late final TextEditingController _deliveryDescriptionController;
  late final TextEditingController
  _ppnController; // Tambahkan controller untuk PPN

  //late bool _autoPrint;
  //late bool _newOrderNotif;
  //late bool _confirmCancel;
  late bool _enablePPN;
  late double _ppnValue; // Tambahkan variabel untuk nilai PPN
  late String _logoPath;

  /// File logo baru dari [_pickImage] (XFile image_picker).
  /// Disimpan terpisah dari [_logoPath]/[_webImageBytes] supaya bisa
  /// dikirim ke [AdminProvider.updateMyTenant] sebagai `multipart/form-data`.
  /// Null = tidak ada logo baru -> update hanya kirim field teks + logoUrl lama.
  XFile? _logoFile;
  bool _logoChanged = false;
  late Color _primaryColor;
  late Color _accentColor;
  Uint8List? _webImageBytes;
  bool _saving = false;

  // ── QRIS ──────────────────────────────────────────────────────────────────
  /// Path lokal / URL QRIS yang tersimpan di SharedPreferences.
  late String _qrisPath;

  /// File QRIS baru yang dipilih via image_picker (untuk preview lokal).
  XFile? _qrisFile;
  bool _qrisChanged = false;

  /// Bytes hasil readAsBytes di Web (karena File() tidak jalan di Web).
  Uint8List? _webQrisBytes;

  @override
  void initState() {
    super.initState();
    final prefs = SharedPrefServices.pref;
    _nameController = TextEditingController(
      text: prefs.getString(SettingsKeys.restaurantName) ?? "",
    );
    _addressController = TextEditingController(
      text: prefs.getString(SettingsKeys.restaurantAddress) ?? '',
    );
    _phoneController = TextEditingController(
      text: prefs.getString(SettingsKeys.restaurantPhone) ?? '',
    );
    _rekeningController = TextEditingController(
      text: prefs.getString(SettingsKeys.restaurantRekening) ?? '',
    );
    _bankAccountNameController = TextEditingController(
      text: prefs.getString(SettingsKeys.bankAccountName) ?? '',
    );
    _phoneConfirmationController = TextEditingController(
      text: prefs.getString(SettingsKeys.phoneConfirmation) ?? '',
    );
    _deliveryDescriptionController = TextEditingController(
      text: prefs.getString(SettingsKeys.deliveryDescription) ?? '',
    );
    _ppnController = TextEditingController(); // Inisialisasi controller PPN
    //_autoPrint = prefs.getBool(SettingsKeys.autoPrint) ?? true;
    //_newOrderNotif = prefs.getBool(SettingsKeys.newOrderNotif) ?? true;
    //_confirmCancel = prefs.getBool(SettingsKeys.confirmCancel) ?? true;
    _enablePPN = prefs.getBool(SettingsKeys.enablePPN) ?? false;
    _ppnValue =
        prefs.getDouble(SettingsKeys.ppnValue) ??
        10.0; // Inisialisasi nilai PPN
    _ppnController.text = _ppnValue.toStringAsFixed(1); // Set teks controller
    _logoPath = prefs.getString(SettingsKeys.restaurantLogo) ?? '';
    _qrisPath = prefs.getString(SettingsKeys.restaurantQris) ?? '';
    _primaryColor = colorFromHex(
      prefs.getString(SettingsKeys.primaryColor) ?? '#8B4513',
    );
    _accentColor = colorFromHex(
      prefs.getString(SettingsKeys.accentColor) ?? '#FF8C00',
    );

    // Kalau AdminProvider sudah load tenant dari backend (via AdminShellScreen),
    // sinkronkan form dengan data server (lebih fresh dari cache prefs).
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFromTenant());
  }

  /// Isi form dari [AdminProvider.tenant] kalau sudah ada.
  /// Tidak menimpa logo yang baru dipilih ([_logoChanged] == true).
  void _syncFromTenant() {
    if (!mounted || _logoChanged) return;
    try {
      final tenant = sl<AdminProvider>().tenant;
      if (tenant == null) return;
      setState(() {
        if (_nameController.text.isEmpty && tenant.name.isNotEmpty) {
          _nameController.text = tenant.name;
        }
        if (_addressController.text.isEmpty &&
            (tenant.address ?? '').isNotEmpty) {
          _addressController.text = tenant.address!;
        }
        if (_phoneController.text.isEmpty && (tenant.phone ?? '').isNotEmpty) {
          _phoneController.text = tenant.phone!;
        }
        if ((tenant.logoUrl ?? '').isNotEmpty) {
          _logoPath = tenant.logoUrl!;
          // Logo dari server adalah URL -> preview network, bukan bytes lokal.
          _webImageBytes = null;
        }

        if (_rekeningController.text.isEmpty &&
            (tenant.rekening ?? '').isNotEmpty) {
          _rekeningController.text = tenant.rekening!;
        }
      });
    } catch (_) {
      // sl belum ready / provider belum load — tetap pakai cache prefs.
    }
  }

  bool get _isRemoteLogo =>
      _logoPath.startsWith('http://') || _logoPath.startsWith('https://');

  /// Preview logo: dukung bytes Web (baru dipilih), URL backend (network),
  /// dan file lokal (mobile). Semua cabang punya fallback icon agar tidak crash
  /// kalau path/URL tidak valid.
  Widget _buildLogoPreview() {
    if (_logoPath.isEmpty) {
      return const Icon(Icons.restaurant, color: Colors.grey);
    }
    // Baru dipilih di Web -> tampilkan bytes-nya langsung.
    if (kIsWeb && _webImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(_webImageBytes!, fit: BoxFit.cover),
      );
    }
    // URL dari backend (hasil updateMyTenant) -> load dari network.
    if (_isRemoteLogo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _logoPath,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.restaurant, color: Colors.grey),
        ),
      );
    }
    if (kIsWeb) {
      return const Icon(Icons.restaurant, color: Colors.grey);
    }
    // File lokal (mobile) -> Image.file dengan errorBuilder.
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(_logoPath),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.restaurant, color: Colors.grey),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _rekeningController.dispose(); // Dispose controller Rekening
    _ppnController.dispose(); // Dispose controller PPN
    super.dispose();
  }

  Color colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('FF');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Simpan XFile mentah untuk upload via AdminProvider.updateMyTenant
      // (dibaca sebagai bytes -> multipart field `logo`, jalan di Web & mobile).
      _logoFile = pickedFile;
      _logoChanged = true;
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        if (!mounted) return;
        setState(() {
          _webImageBytes = bytes;
          _logoPath = pickedFile.path;
        });
      } else {
        setState(() {
          _logoPath = pickedFile.path;
        });
      }
      // Jangan langsung persist path lokal di sini — path lokal hanya jadi
      // preview. Nilai final (URL backend / path) disimpan di _saveRestaurantInfo
      // setelah updateMyTenant berhasil.
    }
  }

  /// Buka galeri untuk memilih gambar QRIS baru.
  Future<void> _pickQris() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    _qrisFile = pickedFile;
    _qrisChanged = true;
    if (kIsWeb) {
      final bytes = await pickedFile.readAsBytes();
      if (!mounted) return;
      setState(() {
        _webQrisBytes = bytes;
        _qrisPath = pickedFile.path;
      });
    } else {
      setState(() {
        _qrisPath = pickedFile.path;
      });
    }
  }

  /// Widget preview gambar QRIS (mirip _buildLogoPreview).
  Widget _buildQrisPreview() {
    //debugPrint("_buildQrisPreview $_qrisPath");
    if (_qrisPath.isEmpty) {
      return const Icon(Icons.qr_code, color: Colors.grey, size: 40);
    }
    // Web: baru dipilih → tampilkan bytes langsung.
    if (kIsWeb && _webQrisBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(_webQrisBytes!, fit: BoxFit.contain),
      );
    }
    // URL remote (disimpan dari backend / prefs sebelumnya).
    final isRemote =
        _qrisPath.startsWith('http://') || _qrisPath.startsWith('https://');
    if (isRemote) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _qrisPath,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.qr_code, color: Colors.grey, size: 40),
        ),
      );
    }
    if (kIsWeb) {
      return const Icon(Icons.qr_code, color: Colors.grey, size: 40);
    }
    // Mobile: file lokal.
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(_qrisPath),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.qr_code, color: Colors.grey, size: 40),
      ),
    );
  }

  /// Simpan info restoran:
  /// 1. Persist lokal (SharedPreferences) — sama seperti sebelumnya.
  /// 2. Sinkron ke backend via [AdminProvider.updateMyTenant].
  ///    - Kalau ada logo baru dari [_pickImage] ([_logoFile] != null),
  ///      file ikut di-upload sebagai `multipart/form-data` (field `logo`).
  ///    - Kalau tidak ada logo baru, kirim `logoUrl` lama (atau '' kalau kosong).
  Future<void> _saveRestaurantInfo() async {
    // Validasi ringan: nama wajib diisi (backend butuh `name`).
    if (_nameController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama restoran wajib diisi')),
      );
      return;
    }

    setState(() => _saving = true);
    final prefs = SharedPrefServices.pref;
    final messenger = ScaffoldMessenger.of(context);

    // Ambil AdminProvider dari tree kalau ada (DashboardLaporanScreen pasang
    // Provider), fallback ke get_it supaya AdminPengaturanScreen tetap bisa
    // dipakai standalone di AdminShellScreen.
    AdminProvider adminProvider;
    try {
      adminProvider = context.read<AdminProvider>();
    } catch (_) {
      adminProvider = sl<AdminProvider>();
    }
    final previousLogoUrl = adminProvider.tenant?.logoUrl;

    // 1) Persist lokal dulu (agar offline-safe & UI langsung konsisten).
    await prefs.setString(
      SettingsKeys.restaurantName,
      _nameController.text.trim(),
    );
    await prefs.setString(
      SettingsKeys.restaurantAddress,
      _addressController.text.trim(),
    );
    await prefs.setString(
      SettingsKeys.restaurantPhone,
      _phoneController.text.trim(),
    );
    await prefs.setString(
      SettingsKeys.restaurantRekening,
      _rekeningController.text.trim(),
    );
    await prefs.setString(SettingsKeys.restaurantLogo, _logoPath);
    await prefs.setString(SettingsKeys.restaurantQris, _qrisPath);
    await prefs.setString(SettingsKeys.primaryColor, colorToHex(_primaryColor));
    await prefs.setString(SettingsKeys.accentColor, colorToHex(_accentColor));
    await prefs.setBool(SettingsKeys.enablePPN, _enablePPN);

    // Simpan nilai PPN
    double ppnValue = double.tryParse(_ppnController.text) ?? 10.0;
    await prefs.setDouble(SettingsKeys.ppnValue, ppnValue);

    // Simpan path/bytes QRIS lokal ke file system (mobile) bila baru dipilih.
    // Di Web, _webQrisBytes sudah tersedia untuk preview; path lokal tidak
    // bisa di-persist sebagai File di Web — cukup simpan path/key di prefs.
    if (_qrisChanged && !kIsWeb && _qrisFile != null) {
      // Path sudah di-set di _pickQris, jadi prefs sudah cukup.
      // (Untuk upload ke server di masa depan, gunakan _qrisFile di sini.)
    }

    // 2) Sinkron ke backend (PUT api/tenants/me).
    //    logoUrl lama hanya dikirim kalau TIDAK ada file baru — kalau ada
    //    file baru, backend pakai hasil upload (field `logo`).
    final isRemoteLogoUrl =
        _logoPath.startsWith('http://') || _logoPath.startsWith('https://');

    final ok = await adminProvider.updateMyTenant(
      name: _nameController.text,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      logoUrl: _logoChanged
          ? (isRemoteLogoUrl ? _logoPath : null)
          : (_logoPath.isEmpty ? previousLogoUrl : _logoPath),
      logoFile: _logoChanged ? _logoFile : null,
      qrisUrl: _qrisChanged
          ? _qrisPath
          : (_qrisPath.isEmpty ? null : _qrisPath),
      qrisFile: _qrisChanged ? _qrisFile : null,
      rekening: _rekeningController.text.isEmpty
          ? null
          : _rekeningController.text,
      bankAccountName: _bankAccountNameController.text.isEmpty
          ? null
          : _bankAccountNameController.text,
      deliveryDescription: _deliveryDescriptionController.text.isEmpty
          ? null
          : _deliveryDescriptionController.text,
      phoneConfirmation: _phoneConfirmationController.text.isEmpty
          ? null
          : _phoneConfirmationController.text,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      // Samakan cache lokal dengan hasil backend (logoUrl resmi dari server).
      final freshLogo = adminProvider.tenant?.logoUrl;
      if (freshLogo != null && freshLogo.isNotEmpty) {
        _logoPath = freshLogo;
        await prefs.setString(SettingsKeys.restaurantLogo, freshLogo);
        if (mounted) setState(() {});
      }
      final qris = (adminProvider.tenant!.qrisUrl ?? '').trim();
      if (qris.isNotEmpty) {
        await prefs.setString(SettingsKeys.restaurantQris, qris);
      }
      // File sudah ter-upload -> reset penanda agar save berikutnya
      // tidak upload ulang file yang sama.
      _logoFile = null;
      _logoChanged = false;
      _qrisFile = null;
      _qrisChanged = false;
      messenger.showSnackBar(
        const SnackBar(content: Text('Informasi restoran disimpan')),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Tersimpan lokal, tapi gagal sinkron ke server: ${adminProvider.updateTenantError ?? 'unknown error'}',
          ),
        ),
      );
    }
  }

  // Future<void> _togglePreference(
  //   String key,
  //   bool value,
  //   VoidCallback apply,
  // ) async {
  //   setState(apply);
  //   await SharedPrefServices.pref.setBool(key, value);
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RestaurantColors.background,
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengaturan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: RestaurantColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kelola informasi restoran dan preferensi kasir',
              style: TextStyle(color: RestaurantColors.textSecondary),
            ),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Informasi Restoran',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel('Logo Restoran'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: RestaurantColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: RestaurantColors.cardBorder,
                          ),
                        ),
                        child: _buildLogoPreview(),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload_rounded, size: 18),
                        label: const Text('Ganti Logo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RestaurantColors.primaryBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const FieldLabel('Nama Restoran'),
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration("Nama Restoran"),
                  ),
                  const SizedBox(height: 14),
                  const FieldLabel('Alamat'),
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: _inputDecoration('Alamat restoran'),
                  ),
                  const SizedBox(height: 14),
                  const FieldLabel('No. Telepon'),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('08xx-xxxx-xxxx'),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionCard(
              title: 'Payment Restoran',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── QRIS ──────────────────────────────────────────────
                  const FieldLabel('Foto QRIS Pembayaran'),
                  const SizedBox(height: 4),
                  const Text(
                    'Gambar QR Code untuk pembayaran QRIS',
                    style: TextStyle(
                      fontSize: 12,
                      color: RestaurantColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: RestaurantColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: RestaurantColors.cardBorder,
                          ),
                        ),
                        child: _buildQrisPreview(),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickQris,
                            icon: const Icon(Icons.upload_rounded, size: 18),
                            label: const Text('Pilih Gambar QRIS'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RestaurantColors.primaryBrown,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                          ),
                          if (_qrisPath.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => setState(() {
                                _qrisPath = '';
                                _webQrisBytes = null;
                                _qrisFile = null;
                                _qrisChanged = true;
                              }),
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'Hapus QRIS',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const FieldLabel('No Rekening'),
                  TextField(
                    controller: _rekeningController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('123-456-7890'),
                  ),
                  const SizedBox(height: 14),
                  const FieldLabel('Nama Rekening'),
                  TextField(
                    controller: _bankAccountNameController,
                    decoration: _inputDecoration('Nama Rekening'),
                  ),
                  const SizedBox(height: 14),
                  const FieldLabel('Nomor Telepon Konfirmasi'),
                  TextField(
                    controller: _phoneConfirmationController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('08xx-xxxx-xxxx'),
                  ),
                  const SizedBox(height: 14),
                  const FieldLabel('Info Keterangan Pengiriman'),
                  TextField(
                    controller: _deliveryDescriptionController,
                    maxLines: 2,
                    decoration: _inputDecoration(
                      'Contoh: Gratis Ongkos kirim sekitar sunter',
                    ),
                  ),

                  const SizedBox(height: 8),

                  // const FieldLabel('Warna Tema'),
                  // const SizedBox(height: 12),
                  // ColorPicker(
                  //   label: 'Warna Utama',
                  //   color: _primaryColor,
                  //   onColorChanged: (color) {
                  //     setState(() => _primaryColor = color);
                  //   },
                  // ),
                  // const SizedBox(height: 16),
                  // ColorPicker(
                  //   label: 'Warna Aksen',
                  //   color: _accentColor,
                  //   onColorChanged: (color) {
                  //     setState(() => _accentColor = color);
                  //   },
                  // ),
                ],
              ),
            ),
            // const SizedBox(height: 18),
            // SectionCard(
            //   title: 'Preferensi Kasir',
            //   child: Column(
            //     children: [
            //       PreferenceSwitch(
            //         title: 'Cetak Struk Otomatis',
            //         subtitle: 'Cetak struk begitu pembayaran berhasil diproses',
            //         value: _autoPrint,
            //         onChanged: (v) => _togglePreference(
            //           SettingsKeys.autoPrint,
            //           v,
            //           () => _autoPrint = v,
            //         ),
            //       ),
            //       const Divider(color: RestaurantColors.cardBorder),
            //       PreferenceSwitch(
            //         title: 'Notifikasi Pesanan Baru',
            //         subtitle: 'Tampilkan notifikasi saat ada pesanan masuk',
            //         value: _newOrderNotif,
            //         onChanged: (v) => _togglePreference(
            //           SettingsKeys.newOrderNotif,
            //           v,
            //           () => _newOrderNotif = v,
            //         ),
            //       ),
            //       const Divider(color: RestaurantColors.cardBorder),
            //       PreferenceSwitch(
            //         title: 'Konfirmasi Sebelum Batalkan Pesanan',
            //         subtitle:
            //             'Munculkan dialog konfirmasi sebelum membatalkan pesanan',
            //         value: _confirmCancel,
            //         onChanged: (v) => _togglePreference(
            //           SettingsKeys.confirmCancel,
            //           v,
            //           () => _confirmCancel = v,
            //         ),
            //       ),
            //       const Divider(color: RestaurantColors.cardBorder),
            //       // Pengaturan PPN dengan toggle dan input nilai
            //       PreferenceSwitch(
            //         title: 'Aktifkan PPN',
            //         subtitle: 'Tambahkan PPN pada setiap transaksi',
            //         value: _enablePPN,
            //         onChanged: (v) => _togglePreference(
            //           SettingsKeys.enablePPN,
            //           v,
            //           () => _enablePPN = v,
            //         ),
            //       ),
            //       if (_enablePPN) ...[
            //         const Divider(color: RestaurantColors.cardBorder),
            //         Padding(
            //           padding: const EdgeInsets.only(top: 16),
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               const FieldLabel('Nilai PPN (%)'),
            //               const SizedBox(height: 8),
            //               TextField(
            //                 controller: _ppnController,
            //                 keyboardType: const TextInputType.numberWithOptions(
            //                   decimal: true,
            //                 ),
            //                 decoration: _inputDecoration('10.0'),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ],
            //   ),
            // ),
            const SizedBox(height: 18),
            if (sl<AuthProvider>().user?.role == "owner")
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveRestaurantInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RestaurantColors.primaryBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(_saving ? 'Menyimpan...' : 'Simpan Perubahan'),
                ),
              ),
            const SizedBox(height: 18),
            SectionCard(
              title: 'Tentang Aplikasi',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  InfoRow(label: 'Versi', value: Consts.appVersion),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: RestaurantColors.background,
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
