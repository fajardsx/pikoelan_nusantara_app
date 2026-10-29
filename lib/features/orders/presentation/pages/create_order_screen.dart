import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../providers/create_order_provider.dart';

class CreateOrderScreen extends StatelessWidget {
  const CreateOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<CreateOrderProvider>()..loadMenuItems(),
      child: const _CreateOrderView(),
    );
  }
}

class _CreateOrderView extends StatefulWidget {
  const _CreateOrderView();

  @override
  State<_CreateOrderView> createState() => _CreateOrderViewState();
}

class _CreateOrderViewState extends State<_CreateOrderView> {
  final _tableController = TextEditingController();
  final _customerController = TextEditingController();
  final _notesController = TextEditingController();
  String _orderType = 'dine_in';

  String? _lastShownSubmitError;
  bool _handledSuccess = false;

  @override
  void dispose() {
    _tableController.dispose();
    _customerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<CreateOrderProvider>().submit(
      orderType: _orderType,
      tableNumber: _tableController.text.trim(),
      customerName: _customerController.text.trim(),
      notes: _notesController.text.trim(),
    );
  }

  void _handleSideEffects(CreateOrderProvider provider) {
    final submitError = provider.submitError;
    if (submitError != null && submitError != _lastShownSubmitError) {
      _lastShownSubmitError = submitError;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(submitError),
            backgroundColor: AppColors.danger,
          ),
        );
      });
    }

    if (provider.createdOrder != null && !_handledSuccess) {
      _handledSuccess = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pesanan # ${provider.createdOrder!.orderNumber} berhasil dibuat',
            ),
          ),
        );
        Navigator.of(context).pop(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateOrderProvider>();
    _handleSideEffects(provider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Baru')),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, CreateOrderProvider provider) {
    if (provider.status == CreateOrderStatus.loading ||
        provider.status == CreateOrderStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.status == CreateOrderStatus.error &&
        provider.menuItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 40, color: AppColors.inkFaint),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage ?? 'Terjadi kesalahan',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.loadMenuItems(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                initialValue: _orderType,
                decoration: const InputDecoration(labelText: 'Tipe pesanan'),
                items: const [
                  DropdownMenuItem(
                    value: 'dine_in',
                    child: Text('Makan di tempat'),
                  ),
                  DropdownMenuItem(
                    value: 'takeaway',
                    child: Text('Bawa pulang'),
                  ),
                  DropdownMenuItem(value: 'delivery', child: Text('Antar')),
                ],
                onChanged: (v) => setState(() => _orderType = v ?? 'dine_in'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tableController,
                decoration: const InputDecoration(
                  labelText: 'No. meja (opsional)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _customerController,
                decoration: const InputDecoration(
                  labelText: 'Nama pelanggan (opsional)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilih menu',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (provider.menuItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Belum ada item menu yang tersedia. Tambahkan menu dulu lewat dasbor web.',
                    style: TextStyle(color: AppColors.inkSoft),
                  ),
                )
              else
                ...provider.menuItems.map((item) {
                  final qty = provider.cart[item.id] ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.5,
                                ),
                              ),
                              Text(
                                formatRupiah(item.price),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: AppColors.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: qty > 0
                              ? () => provider.decrementQuantity(item.id)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppColors.primarySoft,
                        ),
                        SizedBox(
                          width: 22,
                          child: Text(
                            '$qty',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                        IconButton(
                          onPressed: () => provider.incrementQuantity(item.id),
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppColors.primarySoft,
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),

        // ringkasan + tombol submit
        Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${provider.cartCount} item',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    Text(
                      formatRupiah(provider.cartTotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: provider.isSubmitting ? null : _submit,
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
                    EdgeInsets.all(20.0),
                  ),
                ),
                child: provider.isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kirim Pesanan'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
