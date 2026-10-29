import 'package:flutter/material.dart';
import 'package:restauran_menu/core/common/common_constant.dart';
import 'package:restauran_menu/core/services/shared_pref_services.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/info_row.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/preference_switch.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/section_card.dart';

import '../../../../core/themes/restaurant_colors.dart';

/// Simple key wrapper around [SharedPrefServices] so all Kasir settings
/// keys live in one place.

class KasirPengaturanScreen extends StatefulWidget {
  const KasirPengaturanScreen({super.key});

  @override
  State<KasirPengaturanScreen> createState() => _KasirPengaturanScreenState();
}

class _KasirPengaturanScreenState extends State<KasirPengaturanScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController
  _ppnController; // Tambahkan controller untuk PPN

  late bool _autoPrint;
  late bool _newOrderNotif;
  late bool _confirmCancel;
  //late bool _enablePPN;
  late double _ppnValue; // Tambahkan variabel untuk nilai PPN
  //late String _logoPath;
  //late Color _primaryColor;
  //late Color _accentColor;
  //Uint8List? _webImageBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final prefs = SharedPrefServices.pref;
    _nameController = TextEditingController(
      text: prefs.getString(SettingsKeys.restaurantName) ?? "D'KITCHEN",
    );
    _addressController = TextEditingController(
      text: prefs.getString(SettingsKeys.restaurantAddress) ?? '',
    );
    _phoneController = TextEditingController(
      text: prefs.getString(SettingsKeys.restaurantPhone) ?? '',
    );
    _ppnController = TextEditingController(); // Inisialisasi controller PPN
    _autoPrint = prefs.getBool(SettingsKeys.autoPrint) ?? true;
    _newOrderNotif = prefs.getBool(SettingsKeys.newOrderNotif) ?? true;
    _confirmCancel = prefs.getBool(SettingsKeys.confirmCancel) ?? true;
    //_enablePPN = prefs.getBool(SettingsKeys.enablePPN) ?? false;
    _ppnValue =
        prefs.getDouble(SettingsKeys.ppnValue) ??
        10.0; // Inisialisasi nilai PPN
    _ppnController.text = _ppnValue.toStringAsFixed(1); // Set teks controller
    //_logoPath = prefs.getString(SettingsKeys.restaurantLogo) ?? '';
    //_primaryColor = colorFromHex(
    // prefs.getString(SettingsKeys.primaryColor) ?? '#8B4513',
    //);
    //_accentColor = colorFromHex(
    //  prefs.getString(SettingsKeys.accentColor) ?? '#FF8C00',
    //);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
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

  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     if (kIsWeb) {
  //       final bytes = await pickedFile.readAsBytes();
  //       setState(() {
  //         _webImageBytes = bytes;
  //         _logoPath = pickedFile.path;
  //       });
  //     } else {
  //       setState(() {
  //         _logoPath = pickedFile.path;
  //       });
  //     }
  //     await SharedPrefServices.pref.setString(
  //       SettingsKeys.restaurantLogo,
  //       pickedFile.path,
  //     );
  //   }
  // }

  Future<void> _saveRestaurantInfo() async {
    setState(() => _saving = true);
    final prefs = SharedPrefServices.pref;
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
    //await prefs.setString(SettingsKeys.restaurantLogo, _logoPath);
    //await prefs.setString(SettingsKeys.primaryColor, colorToHex(_primaryColor));
    //await prefs.setString(SettingsKeys.accentColor, colorToHex(_accentColor));
    //await prefs.setBool(SettingsKeys.enablePPN, _enablePPN);

    // Simpan nilai PPN
    double ppnValue = double.tryParse(_ppnController.text) ?? 10.0;
    await prefs.setDouble(SettingsKeys.ppnValue, ppnValue);

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informasi restoran disimpan')),
    );
  }

  Future<void> _togglePreference(
    String key,
    bool value,
    VoidCallback apply,
  ) async {
    setState(apply);
    await SharedPrefServices.pref.setBool(key, value);
  }

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
              title: 'Preferensi Kasir',
              child: Column(
                children: [
                  PreferenceSwitch(
                    title: 'Cetak Struk Otomatis',
                    subtitle: 'Cetak struk begitu pembayaran berhasil diproses',
                    value: _autoPrint,
                    onChanged: (v) => _togglePreference(
                      SettingsKeys.autoPrint,
                      v,
                      () => _autoPrint = v,
                    ),
                  ),
                  // const Divider(color: RestaurantColors.cardBorder),
                  // PreferenceSwitch(
                  //   title: 'Notifikasi Pesanan Baru',
                  //   subtitle: 'Tampilkan notifikasi saat ada pesanan masuk',
                  //   value: _newOrderNotif,
                  //   onChanged: (v) => _togglePreference(
                  //     SettingsKeys.newOrderNotif,
                  //     v,
                  //     () => _newOrderNotif = v,
                  //   ),
                  // ),
                  const Divider(color: RestaurantColors.cardBorder),
                  PreferenceSwitch(
                    title: 'Konfirmasi Sebelum Batalkan Pesanan',
                    subtitle:
                        'Munculkan dialog konfirmasi sebelum membatalkan pesanan',
                    value: _confirmCancel,
                    onChanged: (v) => _togglePreference(
                      SettingsKeys.confirmCancel,
                      v,
                      () => _confirmCancel = v,
                    ),
                  ),
                  // const Divider(color: RestaurantColors.cardBorder),
                  // // Pengaturan PPN dengan toggle dan input nilai
                  // PreferenceSwitch(
                  //   title: 'Aktifkan PPN',
                  //   subtitle: 'Tambahkan PPN pada setiap transaksi',
                  //   value: _enablePPN,
                  //   onChanged: (v) => _togglePreference(
                  //     SettingsKeys.enablePPN,
                  //     v,
                  //     () => _enablePPN = v,
                  //   ),
                  // ),
                  // if (_enablePPN) ...[
                  //   const Divider(color: RestaurantColors.cardBorder),
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 16),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         const FieldLabel('Nilai PPN (%)'),
                  //         const SizedBox(height: 8),
                  //         TextField(
                  //           controller: _ppnController,
                  //           keyboardType: const TextInputType.numberWithOptions(
                  //             decimal: true,
                  //           ),
                  //           decoration: _inputDecoration('10.0'),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ],
                ],
              ),
            ),
            const SizedBox(height: 18),
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

  // InputDecoration _inputDecoration(String hint) {
  //   return InputDecoration(
  //     hintText: hint,
  //     filled: true,
  //     fillColor: RestaurantColors.background,
  //     contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  //     border: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(12),
  //       borderSide: const BorderSide(color: RestaurantColors.cardBorder),
  //     ),
  //     enabledBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(12),
  //       borderSide: const BorderSide(color: RestaurantColors.cardBorder),
  //     ),
  //   );
  // }
}
