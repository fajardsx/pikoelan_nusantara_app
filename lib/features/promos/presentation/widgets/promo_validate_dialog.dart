import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/promos/presentation/provider/promo_provider.dart';

class PromoValidateDialog extends StatefulWidget {
  final PromoProvider provider;

  const PromoValidateDialog({super.key, required this.provider});

  static Future<void> show(BuildContext context, PromoProvider provider) {
    return showDialog(
      context: context,
      builder: (context) => PromoValidateDialog(provider: provider),
    );
  }

  @override
  State<PromoValidateDialog> createState() => _PromoValidateDialogState();
}

class _PromoValidateDialogState extends State<PromoValidateDialog> {
  final _codeController = TextEditingController();
  final _amountController = TextEditingController(text: '100000');
  final _memberIdController = TextEditingController();

  bool _loading = false;
  bool? _isValid;
  String? _resultMessage;

  @override
  void dispose() {
    _codeController.dispose();
    _amountController.dispose();
    _memberIdController.dispose();
    super.dispose();
  }

  Future<void> _checkPromo() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final memberId = int.tryParse(_memberIdController.text.trim());

    setState(() {
      _loading = true;
      _isValid = null;
      _resultMessage = null;
    });

    final ok = await widget.provider.validate(code, amount, memberId: memberId);

    if (mounted) {
      setState(() {
        _loading = false;
        _isValid = ok;
        _resultMessage = ok
            ? 'Kode promo "$code" VALID dan siap digunakan!'
            : 'Kode promo "$code" TIDAK VALID atau syarat belum terpenuhi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: RestaurantColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.verified_outlined,
                      color: RestaurantColors.info,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cek Validasi Promo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: RestaurantColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Uji apakah kode promo dapat diaplikasikan',
                          style: TextStyle(
                            fontSize: 12,
                            color: RestaurantColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Kode Promo',
                  hintText: 'cth: HEMAT10',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nominal Pesanan (Rp)',
                  hintText: 'cth: 100000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _memberIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ID Member (Opsional)',
                  hintText: 'Kosongkan jika bukan member',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              if (_resultMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isValid == true
                        ? RestaurantColors.successBg
                        : RestaurantColors.dangerBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isValid == true
                          ? RestaurantColors.success.withValues(alpha: 0.3)
                          : RestaurantColors.danger.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isValid == true
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: _isValid == true
                            ? RestaurantColors.success
                            : RestaurantColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _resultMessage!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isValid == true
                                ? RestaurantColors.success
                                : RestaurantColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _checkPromo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RestaurantColors.accentOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Cek Sekarang'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
