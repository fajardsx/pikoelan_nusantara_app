import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/members/data/models/member_payload.dart';
import 'package:restauran_menu/features/members/domain/entities/member_entity.dart';
import 'package:restauran_menu/shared/utils/date_time_formatter.dart';

class MemberFormDialog extends StatefulWidget {
  final MemberEntity? member;
  final Future<bool> Function(MemberPayload payload) onSave;

  const MemberFormDialog({
    super.key,
    this.member,
    required this.onSave,
  });

  static Future<bool?> show(
    BuildContext context, {
    MemberEntity? member,
    required Future<bool> Function(MemberPayload payload) onSave,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MemberFormDialog(member: member, onSave: onSave),
    );
  }

  @override
  State<MemberFormDialog> createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends State<MemberFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  DateTime? _birthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    _nameController = TextEditingController(text: m?.name ?? '');
    _phoneController = TextEditingController(text: m?.phone ?? '');
    _emailController = TextEditingController(text: m?.email ?? '');
    _addressController = TextEditingController(text: m?.address ?? '');
    _notesController = TextEditingController(text: m?.notes ?? '');
    _birthDate = m?.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
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
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? birthDateStr;
    if (_birthDate != null) {
      final y = _birthDate!.year.toString().padLeft(4, '0');
      final m = _birthDate!.month.toString().padLeft(2, '0');
      final d = _birthDate!.day.toString().padLeft(2, '0');
      birthDateStr = '$y-$m-$d';
    }

    final payload = MemberPayload(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      birthDate: birthDateStr,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    final success = await widget.onSave(payload);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan data member. Silakan coba lagi.'),
            backgroundColor: RestaurantColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.member != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
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
                      color: RestaurantColors.accentOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
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
                          isEdit ? 'Edit Data Member' : 'Daftarkan Member Baru',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: RestaurantColors.textPrimary,
                          ),
                        ),
                        Text(
                          isEdit
                              ? 'Perbarui informasi pelanggan dan kontak'
                              : 'Tambahkan data pelanggan untuk program loyalitas',
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

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Lengkap
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nama Lengkap Pelanggan *',
                        hint: 'cth: Siti Rahma',
                        textCapitalization: TextCapitalization.words,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nama member wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Nomor Telepon & Email
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildTextField(
                              controller: _phoneController,
                              label: 'Nomor Telepon / WA *',
                              hint: 'cth: 08123456789',
                              keyboardType: TextInputType.phone,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Nomor telepon wajib diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 5,
                            child: _buildTextField(
                              controller: _emailController,
                              label: 'Email (Opsional)',
                              hint: 'cth: siti@mail.com',
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tanggal Lahir
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tanggal Lahir (Opsional)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: RestaurantColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickBirthDate,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
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
                                    Icons.cake_outlined,
                                    size: 18,
                                    color: RestaurantColors.textSecondary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _birthDate != null
                                        ? formatDate(_birthDate!)
                                        : 'Pilih tanggal lahir (untuk promo ultah)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _birthDate != null
                                          ? RestaurantColors.textPrimary
                                          : RestaurantColors.textMuted,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_birthDate != null)
                                    InkWell(
                                      onTap: () => setState(() => _birthDate = null),
                                      child: const Icon(
                                        Icons.clear_rounded,
                                        size: 16,
                                        color: RestaurantColors.textMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Alamat
                      _buildTextField(
                        controller: _addressController,
                        label: 'Alamat (Opsional)',
                        hint: 'cth: Jl. Melati No. 12, Jakarta',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Catatan Tambahan
                      _buildTextField(
                        controller: _notesController,
                        label: 'Catatan Khusus (Opsional)',
                        hint: 'cth: Pelanggan setia kopi susu gula aren',
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1, color: RestaurantColors.cardBorder),

            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: RestaurantColors.cardBorder),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RestaurantColors.accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                        : Text(isEdit ? 'Simpan Perubahan' : 'Simpan Member'),
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: RestaurantColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            color: RestaurantColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: RestaurantColors.textMuted,
            ),
            filled: true,
            fillColor: RestaurantColors.background,
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

