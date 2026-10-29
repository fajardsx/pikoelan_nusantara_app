import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../provider/order_stream_provider.dart';

/// Indikator koneksi SSE (realtime order) untuk dashboard staf.
///
/// Menampilkan [OrderStreamProvider.statusLabel] + titik status, dan bisa
/// diketuk untuk memaksa [OrderStreamProvider.restart] bila koneksi macet.
class OrderStreamStatusBadge extends StatelessWidget {
  const OrderStreamStatusBadge({
    super.key,
    this.compact = false,
    this.onDark = false,
  });

  /// Hanya menampilkan titik status (untuk sidebar yang diciutkan).
  final bool compact;

  /// Gaya kontras untuk latar gelap, mis. sidebar kasir.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderStreamProvider>(
      builder: (context, stream, _) {
        final status = stream.connectionStatus;
        final label = stream.statusLabel;
        final dotColor = _dotColor(status, onDark);
        final pending =
            status == OrderStreamConnectionStatus.connecting ||
            status == OrderStreamConnectionStatus.reconnecting;

        final content = Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: onDark
                ? Colors.white.withValues(alpha: 0.08)
                : RestaurantColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: onDark ? Colors.white24 : RestaurantColors.cardBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 10,
                height: 10,
                child: pending
                    ? CircularProgressIndicator(
                        strokeWidth: 1.6,
                        valueColor: AlwaysStoppedAnimation<Color>(dotColor),
                      )
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
              if (!compact) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: onDark
                          ? Colors.white
                          : RestaurantColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );

        return Tooltip(
          message: _tooltip(stream),
          child: Semantics(
            button: true,
            label: 'Status realtime: $label',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: stream.restart,
                borderRadius: BorderRadius.circular(10),
                child: content,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _dotColor(OrderStreamConnectionStatus status, bool onDark) {
    switch (status) {
      case OrderStreamConnectionStatus.connected:
        return RestaurantColors.success;
      case OrderStreamConnectionStatus.connecting:
        return RestaurantColors.info;
      case OrderStreamConnectionStatus.reconnecting:
        return RestaurantColors.warning;
      case OrderStreamConnectionStatus.failed:
        return RestaurantColors.danger;
      case OrderStreamConnectionStatus.idle:
      case OrderStreamConnectionStatus.stopped:
        return onDark ? Colors.white38 : RestaurantColors.textMuted;
    }
  }

  String _tooltip(OrderStreamProvider stream) {
    final buffer = StringBuffer(stream.statusLabel);
    if (stream.reconnectAttempt > 0) {
      buffer.write(' · percobaan ${stream.reconnectAttempt}');
    }
    final error = stream.errorMessage;
    if (error != null && error.trim().isNotEmpty) {
      buffer.write('\n$error');
    }
    buffer.write('\nKetuk untuk menyambung ulang');
    return buffer.toString();
  }
}
