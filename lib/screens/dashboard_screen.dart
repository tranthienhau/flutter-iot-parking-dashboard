import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/parking_provider.dart';
import '../services/iot_api.dart';
import '../services/live_feed_service.dart';
import '../widgets/status_pill.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parkingProvider);
    final sorted = [...state.lots]
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    return Scaffold(
      appBar: AppBar(title: const Text('Smart parking')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ConnectionRow(
            status: state.connection,
            updatedAt: state.updatedAt,
          ),
          const SizedBox(height: 12),
          const Text(
            'Nearest parking',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          for (final lot in sorted) _LotTile(lot: lot),
          const SizedBox(height: 10),
          _AnalyticsButton(
            onTap: () => context.push('/analytics'),
          ),
        ],
      ),
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  const _ConnectionRow({required this.status, required this.updatedAt});
  final ConnectionStatus status;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      ConnectionStatus.live => const Color(0xFF4CD080),
      ConnectionStatus.polling => const Color(0xFFF5C242),
      _ => const Color(0xFFF26565),
    };
    final String label = switch (status) {
      ConnectionStatus.live => 'Live feed',
      ConnectionStatus.polling => 'Polling fallback',
      ConnectionStatus.offline => 'Offline',
      ConnectionStatus.idle => 'Connecting',
    };
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          updatedAt == null
              ? label
              : '$label , updated ${_timeAgo(updatedAt!)}',
          style: const TextStyle(color: Color(0xFF8C93A6), fontSize: 12),
        ),
      ],
    );
  }

  static String _timeAgo(DateTime ts) {
    final s = DateTime.now().difference(ts).inSeconds;
    if (s < 10) return 'just now';
    if (s < 60) return '${s}s ago';
    return '${(s / 60).floor()}m ago';
  }
}

class _LotTile extends StatelessWidget {
  const _LotTile({required this.lot});
  final Lot lot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/lot/${lot.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lot.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${lot.distanceMeters.toStringAsFixed(0)} m , ${lot.total} spaces',
                        style: const TextStyle(
                          color: Color(0xFF8C93A6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusPill(open: lot.open, total: lot.total),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalyticsButton extends StatelessWidget {
  const _AnalyticsButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF131B2E),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'View analytics dashboard',
              style: TextStyle(
                color: Color(0xFF5A9EFF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
