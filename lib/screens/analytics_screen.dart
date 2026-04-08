import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/parking_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lots = ref.watch(parkingProvider).lots;
    final totalSpaces = lots.fold<int>(0, (a, l) => a + l.total);
    final totalOccupied = lots.fold<int>(0, (a, l) => a + l.occupied);
    final utilization =
        totalSpaces == 0 ? 0.0 : (totalOccupied / totalSpaces) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin analytics')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Campus-wide utilization dashboard',
            style: TextStyle(color: Color(0xFF8C93A6), fontSize: 13),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF131B2E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current utilization',
                  style: TextStyle(color: Color(0xFF8C93A6), fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '${utilization.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalOccupied of $totalSpaces spaces occupied',
                  style: const TextStyle(color: Color(0xFFCFD6E5), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Lot level',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final l in lots)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${l.occupied}/${l.total} occupied',
                            style: const TextStyle(
                              color: Color(0xFF8C93A6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${((l.occupied / l.total) * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Color(0xFF5A9EFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Peak hours (last 7 days)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF131B2E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PeakRow(day: 'Mon', hours: '08:00, 17:00'),
                _PeakRow(day: 'Tue', hours: '09:00, 17:00'),
                _PeakRow(day: 'Wed', hours: '08:00, 16:00'),
                _PeakRow(day: 'Thu', hours: '09:00, 17:00'),
                _PeakRow(day: 'Fri', hours: '10:00, 15:00'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeakRow extends StatelessWidget {
  const _PeakRow({required this.day, required this.hours});
  final String day;
  final String hours;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              day,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            hours,
            style: const TextStyle(color: Color(0xFFCFD6E5), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
