import 'package:flutter/material.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.open,
    required this.total,
    this.large = false,
  });

  final int open;
  final int total;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : open / total;
    final Color color = ratio > 0.25
        ? const Color(0xFF4CD080)
        : ratio > 0.08
            ? const Color(0xFFF5C242)
            : const Color(0xFFF26565);
    final String label = ratio > 0.25
        ? 'Plenty'
        : ratio > 0.08
            ? 'Limited'
            : 'Full';

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: large ? 14 : 8,
        horizontal: large ? 24 : 14,
      ),
      constraints: const BoxConstraints(minWidth: 80),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$open',
            style: TextStyle(
              color: color,
              fontSize: large ? 32 : 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
