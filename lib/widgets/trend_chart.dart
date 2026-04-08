import 'package:flutter/material.dart';

class TrendChart extends StatelessWidget {
  const TrendChart({super.key, required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final max = values.fold<double>(
      0.01,
      (acc, v) => v > acc ? v : acc,
    );
    return Container(
      height: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final v in values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Container(
                  height: (v / max) * 60 < 4 ? 4 : (v / max) * 60,
                  decoration: BoxDecoration(
                    color: v > 0.8
                        ? const Color(0xFFF26565)
                        : v > 0.5
                            ? const Color(0xFFF5C242)
                            : const Color(0xFF4CD080),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
