import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/parking_provider.dart';
import '../services/iot_api.dart';
import '../widgets/status_pill.dart';
import '../widgets/trend_chart.dart';

class LotDetailScreen extends ConsumerWidget {
  const LotDetailScreen({super.key, required this.lotId});
  final String lotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parkingProvider);
    Lot? lot;
    for (final l in state.lots) {
      if (l.id == lotId) {
        lot = l;
        break;
      }
    }

    if (lot == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lot')),
        body: const Center(
          child: Text('Lot not found',
              style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final ageSeconds =
        DateTime.now().difference(lot.updatedAt).inSeconds;

    return Scaffold(
      appBar: AppBar(title: Text(lot.name)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${lot.total} spaces , updated ${ageSeconds}s ago',
              style: const TextStyle(color: Color(0xFF8C93A6), fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF131B2E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusPill(open: lot.open, total: lot.total, large: true),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _Stat(label: 'Open', value: lot.open, color: const Color(0xFF4CD080)),
                      const SizedBox(width: 10),
                      _Stat(label: 'Occupied', value: lot.occupied, color: const Color(0xFFF26565)),
                      const SizedBox(width: 10),
                      _Stat(label: 'Reserved', value: lot.reserved, color: const Color(0xFFF5C242)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Last 24 hours',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TrendChart(values: lot.history24h),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF5A9EFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Launching directions...')),
                  );
                },
                child: const Text('Navigate to lot'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF8C93A6), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
