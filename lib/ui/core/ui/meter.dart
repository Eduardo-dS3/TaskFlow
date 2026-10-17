import 'package:flutter/material.dart';

import '../themes/colors.dart';

/// Barra de progresso horizontal arredondada.
class Meter extends StatelessWidget {
  const Meter({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.background = AppColors.surfaceMuted,
    this.height = 6,
  });

  /// Valor entre 0 e 1.
  final double value;
  final Color color;
  final Color background;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        color: color,
        backgroundColor: background,
      ),
    );
  }
}

/// Barra composta por vários segmentos coloridos (ex.: horas por frente).
class SegmentedMeter extends StatelessWidget {
  const SegmentedMeter({
    super.key,
    required this.segments,
    required this.total,
    this.height = 6,
  });

  final List<(double value, Color color)> segments;
  final double total;
  final double height;

  @override
  Widget build(BuildContext context) {
    final sum = segments.fold<double>(0, (a, s) => a + s.$1);
    final max = sum > total ? sum : total;
    final empty = max - sum;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            for (final (value, color) in segments)
              Expanded(
                flex: (value * 100).round(),
                child: ColoredBox(color: color),
              ),
            if (empty > 0)
              Expanded(
                flex: (empty * 100).round(),
                child: const ColoredBox(color: AppColors.surfaceMuted),
              ),
          ],
        ),
      ),
    );
  }
}
