import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_utils.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/utils/date_time_formatter.dart';
import '../../../customers/presentation/widgets/order_status_badge.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../provider/kasir_provider.dart';
import '../widgets/history_filter_bar.dart';
import 'export_csv_stub.dart'
    if (dart.library.io) 'export_csv_mobile.dart'
    if (dart.library.html) 'export_csv_web.dart';

export 'export_csv_stub.dart'
    if (dart.library.io) 'export_csv_mobile.dart'
    if (dart.library.html) 'export_csv_web.dart';

// Fixed column widths used only in the mobile horizontal-scroll layout.
const double _kColOrder = 130;
const double _kColDate = 110;
const double _kColTime = 70;
const double _kColType = 100;
const double _kColMethod = 80;
const double _kColTotal = 110;
const double _kColStatus = 100;
const double _kTableContentWidth =
    _kColOrder +
    _kColDate +
    _kColTime +
    _kColType +
    _kColMethod +
    _kColTotal +
    _kColStatus;

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  // Filter lokal (client-side) — tidak mengubah query API.
  // null = Semua.
  String? _orderTypeFilter;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    // Selaraskan pilihan lokal dengan filter aktif di provider (kalau ada).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final kasir = context.read<KasirProvider>();
      if (!mounted) return;
      setState(() {
        _startDate = kasir.startDateFilter;
        _endDate = kasir.endDateFilter;
      });
    });
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'Pilih tanggal';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? _endDate ?? now)
        : (_endDate ?? _startDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: isStart ? 'Tanggal mulai' : 'Tanggal akhir',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked == null) return;
    setState(() {
      final normalized = DateTime(picked.year, picked.month, picked.day);
      if (isStart) {
        _startDate = normalized;
        // Jaga konsistensi: mulai tidak boleh lewat akhir.
        if (_endDate != null && _startDate!.isAfter(_endDate!)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = normalized;
        if (_startDate != null && _endDate!.isBefore(_startDate!)) {
          _startDate = _endDate;
        }
      }
    });
  }

  void _applyFilter() {
    final messenger = ScaffoldMessenger.of(context);
    if (_startDate == null && _endDate == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai/akhir dulu')),
      );
      return;
    }
    context.read<KasirProvider>().load(
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  void _resetFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _orderTypeFilter = null;
      _statusFilter = null;
    });
    context.read<KasirProvider>().load();
  }

  bool get _hasAnyFilter =>
      _startDate != null ||
      _endDate != null ||
      _orderTypeFilter != null ||
      _statusFilter != null;

  String _orderTypeLabel(String? value) {
    switch (value) {
      case OrderEntity.typeDineIn:
        return 'Dine In';
      case OrderEntity.typeTakeaway:
        return 'Take Away';
      case OrderEntity.typeDelivery:
        return 'Delivery';
      default:
        return 'Semua Tipe';
    }
  }

  String _statusLabel(String? value) {
    if (value == null) return 'Semua Status';
    switch (value) {
      case OrderEntity.statusNew:
        return 'Baru';
      case OrderEntity.statusProses:
      case OrderEntity.statusPreparing:
        return 'Diproses';
      case OrderEntity.statusReady:
        return 'Siap';
      case OrderEntity.statusDeliver:
        return 'Diantar';
      case OrderEntity.statusCompleted:
        return 'Selesai';
      case OrderEntity.statusCancelled:
        return 'Batal';
      default:
        return value;
    }
  }

  /// Filter client-side untuk tipe & status (tidak mengubah query API tanggal).
  /// Tanggal tetap di-filter server-side via [KasirProvider.load].
  List<OrderEntity> _filteredHistory(List<OrderEntity> source) {
    return source.where((o) {
      if (_orderTypeFilter != null && o.orderType != _orderTypeFilter) {
        return false;
      }
      if (_statusFilter != null && o.status != _statusFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _exportCsv(BuildContext context) async {
    final provider = context.read<KasirProvider>();
    final history = provider.history;
    await exportCsv(context, history);
  }

  @override
  Widget build(BuildContext context) {
    final useExpanded = isMobileView(context);

    return Container(
      color: RestaurantColors.background,
      padding: const EdgeInsets.all(24),
      child: Consumer<KasirProvider>(
        builder: (context, kasir, _) {
          // Filter client-side untuk tipe & status; tanggal tetap server-side.
          final history = _filteredHistory(kasir.history);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    children: [
                      Text(
                        'Riwayat Transaksi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: RestaurantColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Daftar riwayat transaksi',
                        style: TextStyle(color: RestaurantColors.textSecondary),
                      ),
                    ],
                  ),
                  // Export button
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: const Icon(Icons.file_download),
                      tooltip: 'Export ke CSV',
                      onPressed: () => _exportCsv(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              HistoryFilterBar(
                startLabel: _fmt(_startDate),
                endLabel: _fmt(_endDate),
                isLoading: kasir.status == DashboardStatus.loading,
                hasFilter: _hasAnyFilter,
                onPickStart: () => _pickDate(isStart: true),
                onPickEnd: () => _pickDate(isStart: false),
                onApply: _applyFilter,
                onReset: _resetFilter,
                orderTypeValue: _orderTypeFilter,
                statusValue: _statusFilter,
                onOrderTypeChanged: (v) => setState(() => _orderTypeFilter = v),
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                resultCount: history.length,
                activeInfo: [
                  if (kasir.hasDateFilter)
                    '${_fmt(kasir.startDateFilter)}–${_fmt(kasir.endDateFilter)}',
                  if (_orderTypeFilter != null)
                    _orderTypeLabel(_orderTypeFilter),
                  if (_statusFilter != null) _statusLabel(_statusFilter),
                ].join(' • '),
              ),
              const SizedBox(height: 12),
              if (kasir.status == DashboardStatus.loading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: LinearProgressIndicator(),
                ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: RestaurantColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: RestaurantColors.cardBorder),
                  ),
                  child: useExpanded
                      ? _FullWidthTable(history: history)
                      : _ScrollableTable(history: history),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Tablet/desktop layout: flex-based columns filling the available width.
class _FullWidthTable extends StatelessWidget {
  final List<OrderEntity> history;
  const _FullWidthTable({required this.history});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _HistoryHeaderRow(),
        const Divider(height: 1, color: RestaurantColors.cardBorder),
        Expanded(
          child: history.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    color: RestaurantColors.cardBorder,
                  ),
                  itemBuilder: (context, index) =>
                      _HistoryRow(order: history[index]),
                ),
        ),
      ],
    );
  }
}

class _ScrollableTable extends StatelessWidget {
  final List<OrderEntity> history;
  const _ScrollableTable({required this.history});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: _kTableContentWidth + 36,
        child: Column(
          children: [
            const _HistoryHeaderRowFixed(),
            const Divider(height: 1, color: RestaurantColors.cardBorder),
            Expanded(
              child: history.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      itemCount: history.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        color: RestaurantColors.cardBorder,
                      ),
                      itemBuilder: (context, index) =>
                          _HistoryRowFixed(order: history[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Belum ada transaksi',
        style: TextStyle(color: RestaurantColors.textSecondary),
      ),
    );
  }
}

const _headerStyle = TextStyle(
  fontSize: 12.5,
  fontWeight: FontWeight.w600,
  color: RestaurantColors.textSecondary,
);

class _HistoryHeaderRow extends StatelessWidget {
  const _HistoryHeaderRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('No. Pesanan', style: _headerStyle)),
          Expanded(flex: 2, child: Text('Tanggal', style: _headerStyle)),
          Expanded(child: Text('Waktu', style: _headerStyle)),
          Expanded(child: Text('Tipe', style: _headerStyle)),
          Expanded(child: Text('Metode', style: _headerStyle)),
          Expanded(child: Text('Total', style: _headerStyle)),
          Expanded(child: Text('Status', style: _headerStyle)),
        ],
      ),
    );
  }
}

class _HistoryHeaderRowFixed extends StatelessWidget {
  const _HistoryHeaderRowFixed();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: _kColOrder,
            child: Text('No. Pesanan', style: _headerStyle),
          ),
          SizedBox(
            width: _kColDate,
            child: Text('Tanggal', style: _headerStyle),
          ),
          SizedBox(
            width: _kColTime,
            child: Text('Waktu', style: _headerStyle),
          ),
          SizedBox(
            width: _kColType,
            child: Text('Tipe', style: _headerStyle),
          ),
          SizedBox(
            width: _kColMethod,
            child: Text('Metode', style: _headerStyle),
          ),
          SizedBox(
            width: _kColTotal,
            child: Text('Total', style: _headerStyle),
          ),
          SizedBox(
            width: _kColStatus,
            child: Text('Status', style: _headerStyle),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final OrderEntity order;
  const _HistoryRow({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              order.orderNumber,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: RestaurantColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatDate(order.createdAt),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: RestaurantColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              formatTime(order.createdAt),
              style: const TextStyle(color: RestaurantColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              order.orderTypeLabel,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: RestaurantColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              order.isQris ? 'QRIS' : 'Cash',
              style: const TextStyle(color: RestaurantColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              formatRupiah(order.totalAmount),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: RestaurantColors.textPrimary,
              ),
            ),
          ),
          Expanded(child: OrderStatusBadge(status: order.status)),
        ],
      ),
    );
  }
}

class _HistoryRowFixed extends StatelessWidget {
  final OrderEntity order;
  const _HistoryRowFixed({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: _kColOrder,
            child: Text(
              order.orderNumber,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: RestaurantColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: _kColDate,
            child: Text(
              formatDate(order.createdAt),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: RestaurantColors.textSecondary),
            ),
          ),
          SizedBox(
            width: _kColTime,
            child: Text(
              formatTime(order.createdAt),
              style: const TextStyle(color: RestaurantColors.textSecondary),
            ),
          ),
          SizedBox(
            width: _kColType,
            child: Text(
              order.orderTypeLabel,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: RestaurantColors.textSecondary),
            ),
          ),
          SizedBox(
            width: _kColMethod,
            child: Text(
              order.isQris ? 'QRIS' : 'Cash',
              style: const TextStyle(color: RestaurantColors.textSecondary),
            ),
          ),
          SizedBox(
            width: _kColTotal,
            child: Text(
              formatRupiah(order.totalAmount),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: RestaurantColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: _kColStatus,
            child: OrderStatusBadge(status: order.status),
          ),
        ],
      ),
    );
  }
}
