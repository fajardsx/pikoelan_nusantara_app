import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/promos/data/models/promo_payload.dart';
import 'package:restauran_menu/features/promos/domain/entities/promo_entity.dart';
import 'package:restauran_menu/shared/utils/date_time_formatter.dart';

class PromoFormDialog extends StatefulWidget {
  final PromoEntity? promo;
  final Future<bool> Function(PromoPayload payload) onSave;

  const PromoFormDialog({super.key, this.promo, required this.onSave});

  static Future<bool?> show(
    BuildContext context, {
    PromoEntity? promo,
    required Future<bool> Function(PromoPayload payload) onSave,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PromoFormDialog(promo: promo, onSave: onSave),
    );
  }

  @override
  State<PromoFormDialog> createState() => _PromoFormDialogState();
}

class _PromoFormDialogState extends State<PromoFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _discountValController;
  late final TextEditingController _minOrderController;
  late final TextEditingController _maxDiscountController;
  late final TextEditingController _usageLimitController;

  String _discountType = 'percentage';
  String _applicableTier = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.promo;
    _codeController = TextEditingController(text: p?.code ?? '');
    _titleController = TextEditingController(text: p?.title ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _discountValController = TextEditingController(
      text: p != null
          ? (p.discountValue.truncateToDouble() == p.discountValue
                ? p.discountValue.toInt().toString()
                : p.discountValue.toString())
          : '',
    );
    _minOrderController = TextEditingController(
      text: p?.minOrderAmount != null
          ? p!.minOrderAmount!.toInt().toString()
          : '',
    );
    _maxDiscountController = TextEditingController(
      text: p?.maxDiscountAmount != null
          ? p!.maxDiscountAmount!.toInt().toString()
          : '',
    );
    _usageLimitController = TextEditingController(
      text: p?.usageLimit != null ? p!.usageLimit.toString() : '',
    );

    if (p != null) {
      _discountType = p.discountType;
      _applicableTier = p.applicableTier;
      _startDate = p.startDate;
      _endDate = p.endDate;
      _isActive = p.isActive;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _discountValController.dispose();
    _minOrderController.dispose();
    _maxDiscountController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: RestaurantColors.accentOrange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: RestaurantColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final discountVal =
        double.tryParse(_discountValController.text.trim()) ?? 0.0;
    final minOrder = _minOrderController.text.trim().isNotEmpty
        ? double.tryParse(_minOrderController.text.trim())
        : null;
    final maxDiscount = _maxDiscountController.text.trim().isNotEmpty
        ? double.tryParse(_maxDiscountController.text.trim())
        : null;
    final usageLimit = _usageLimitController.text.trim().isNotEmpty
        ? int.tryParse(_usageLimitController.text.trim())
        : null;

    final payload = PromoPayload(
      code: _codeController.text.trim().toUpperCase(),
      title: _titleController.text.trim(),
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : null,
      discountType: _discountType,
      discountValue: discountVal,
      minOrderAmount: minOrder,
      maxDiscountAmount: maxDiscount,
      usageLimit: usageLimit,
      startDate: _startDate,
      endDate: _endDate,
      applicableTier: _applicableTier,
      isActive: _isActive,
    );

    final success = await widget.onSave(payload);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan promo. Silakan coba lagi.'),
            backgroundColor: RestaurantColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.promo != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: RestaurantColors.accentOrange.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.discount_rounded,
                      color: RestaurantColors.accentOrange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Edit Promo' : 'Tambah Promo Baru',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: RestaurantColors.textPrimary,
                          ),
                        ),
                        Text(
                          isEdit
                              ? 'Perbarui detail diskon dan ketentuan promo'
                              : 'Buat kode voucher promo untuk pelanggan restoran',
                          style: const TextStyle(
                            fontSize: 12,
                            color: RestaurantColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: RestaurantColors.cardBorder),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kode & Judul
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: _buildTextField(
                              controller: _codeController,
                              label: 'Kode Promo *',
                              hint: 'cth: HEMAT10',
                              capitalization: TextCapitalization.characters,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Kode wajib diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 6,
                            child: _buildTextField(
                              controller: _titleController,
                              label: 'Judul Promo *',
                              hint: 'cth: Promo Akhir Pekan',
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Judul wajib diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      _buildTextField(
                        controller: _descController,
                        label: 'Deskripsi Promo (Opsional)',
                        hint: 'Jelaskan syarat dan ketentuan promo...',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Tipe Diskon & Nilai
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tipe Diskon *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: RestaurantColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: RestaurantColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: RestaurantColors.cardBorder,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _discountType,
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'percentage',
                                          child: Text('Persentase (%)'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'fixed',
                                          child: Text('Nominal Tetap (Rp)'),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _discountType = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 5,
                            child: _buildTextField(
                              controller: _discountValController,
                              label: _discountType == 'percentage'
                                  ? 'Nilai Diskon (%) *'
                                  : 'Nominal Potongan (Rp) *',
                              hint: _discountType == 'percentage'
                                  ? 'cth: 15'
                                  : 'cth: 20000',
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Nilai wajib diisi';
                                }
                                final num = double.tryParse(val.trim());
                                if (num == null || num <= 0) {
                                  return 'Harus lebih dari 0';
                                }
                                if (_discountType == 'percentage' &&
                                    num > 100) {
                                  return 'Maksimal 100%';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Minimum Pembelian & Maksimal Potongan
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _minOrderController,
                              label: 'Min. Pembelian (Rp)',
                              hint: 'cth: 50000',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildTextField(
                              controller: _maxDiscountController,
                              label: 'Maks. Diskon (Rp)',
                              hint: 'cth: 25000',
                              keyboardType: TextInputType.number,
                              enabled: _discountType == 'percentage',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Batas Kuota & Target Tier
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildTextField(
                              controller: _usageLimitController,
                              label: 'Batas Kuota Pemakaian',
                              hint: 'Kosongkan jika tanpa batas',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Berlaku Untuk Tier',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: RestaurantColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: RestaurantColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: RestaurantColors.cardBorder,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _applicableTier,
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'all',
                                          child: Text('Semua Pelanggan'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'bronze',
                                          child: Text('Khusus Bronze'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'silver',
                                          child: Text('Khusus Silver'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'gold',
                                          child: Text('Khusus Gold'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'platinum',
                                          child: Text('Khusus Platinum'),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _applicableTier = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tanggal Mulai & Berakhir
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal Mulai',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: RestaurantColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () => _pickDate(true),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: RestaurantColors.background,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: RestaurantColors.cardBorder,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_rounded,
                                          size: 16,
                                          color: RestaurantColors.textSecondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _startDate != null
                                              ? formatDate(_startDate!)
                                              : 'Pilih tanggal',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: _startDate != null
                                                ? RestaurantColors.textPrimary
                                                : RestaurantColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal Berakhir',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: RestaurantColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () => _pickDate(false),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: RestaurantColors.background,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: RestaurantColors.cardBorder,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_rounded,
                                          size: 16,
                                          color: RestaurantColors.textSecondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _endDate != null
                                              ? formatDate(_endDate!)
                                              : 'Pilih tanggal',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: _endDate != null
                                                ? RestaurantColors.textPrimary
                                                : RestaurantColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Status Aktif Switch
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: RestaurantColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: RestaurantColors.cardBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status Aktifkan Promo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: RestaurantColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Promo dapat langsung digunakan pelanggan',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: RestaurantColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _isActive,
                              activeThumbColor: RestaurantColors.accentOrange,
                              onChanged: (val) =>
                                  setState(() => _isActive = val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1, color: RestaurantColors.cardBorder),

            // Footer action buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(
                        color: RestaurantColors.cardBorder,
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RestaurantColors.accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isEdit ? 'Simpan Perubahan' : 'Buat Promo'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: enabled
                ? RestaurantColors.textPrimary
                : RestaurantColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: capitalization,
          validator: validator,
          enabled: enabled,
          style: TextStyle(
            fontSize: 14,
            color: enabled
                ? RestaurantColors.textPrimary
                : RestaurantColors.textMuted,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: RestaurantColors.textMuted,
            ),
            filled: true,
            fillColor: enabled
                ? RestaurantColors.background
                : const Color(0xFFF0EBE5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: RestaurantColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: RestaurantColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: RestaurantColors.accentOrange,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
