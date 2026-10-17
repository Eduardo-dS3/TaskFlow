import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/models/productivity_report.dart';
import '../../../domain/models/task.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/meter.dart';
import '../../core/ui/surface_card.dart';

const _statusColors = {
  TaskStatus.done: AppColors.primary,
  TaskStatus.inProgress: AppColors.sky,
  TaskStatus.pending: Color(0xFFC9C7DC),
};

/// "Distribuição por Status" com gráfico de rosca.
class StatusDistributionCard extends StatelessWidget {
  const StatusDistributionCard({super.key, required this.report});

  final ProductivityReport report;

  static const _order = [
    TaskStatus.done,
    TaskStatus.inProgress,
    TaskStatus.pending,
  ];

  @override
  Widget build(BuildContext context) {
    final total = report.statusTotal;
    final entries = [
      for (final status in _order)
        (status, report.statusDistribution[status] ?? 0),
    ];

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(
            title: 'Distribuição por Status',
            trailing: Text(
              'Total: $total',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceAround,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 24,
            runSpacing: 16,
            children: [
              _StatusDonut(entries: entries, total: total),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (status, value) in entries)
                    _StatusLegendItem(
                      status: status,
                      value: value,
                      total: total,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusDonut extends StatelessWidget {
  const _StatusDonut({required this.entries, required this.total});

  final List<(TaskStatus, int)> entries;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 120,
      child: CustomPaint(
        painter: _DonutPainter(
          values: [
            for (final (status, value) in entries)
              (value.toDouble(), _statusColors[status]!),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$total',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'TAREFAS',
                style: TextStyle(fontSize: 10, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusLegendItem extends StatelessWidget {
  const _StatusLegendItem({
    required this.status,
    required this.value,
    required this.total,
  });

  final TaskStatus status;
  final int value;
  final int total;

  @override
  Widget build(BuildContext context) {
    final share = total == 0 ? 0.0 : value / total;
    return Container(
      width: 150,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: _statusColors[status]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              Formatters.taskStatus(status),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          Text(
            ' (${Formatters.percent(share)})',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.values});

  final List<(double, Color)> values;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (a, v) => a + v.$1);
    if (total == 0) return;
    const stroke = 18.0;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - stroke / 2,
    );
    var start = -math.pi / 2;
    for (final (value, color) in values) {
      final sweep = value / total * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.values != values;
}

/// "Distribuição por Prioridade" com barras horizontais.
class PriorityDistributionCard extends StatelessWidget {
  const PriorityDistributionCard({super.key, required this.report});

  final ProductivityReport report;

  static const _labels = {
    TaskPriority.urgent: 'Urgente (Crítico)',
    TaskPriority.high: 'Alta Prioridade',
    TaskPriority.medium: 'Média Prioridade',
    TaskPriority.low: 'Baixa Prioridade',
  };

  static const _colors = {
    TaskPriority.urgent: AppColors.danger,
    TaskPriority.high: AppColors.info,
    TaskPriority.medium: AppColors.primary,
    TaskPriority.low: AppColors.neutral,
  };

  @override
  Widget build(BuildContext context) {
    final total = report.priorityTotal;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(title: 'Distribuição por Prioridade'),
          const SizedBox(height: 16),
          for (final priority in TaskPriority.values) ...[
            Row(
              children: [
                Icon(Icons.circle, size: 8, color: _colors[priority]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _labels[priority]!,
                    style: TextStyle(
                      fontSize: 12,
                      color: priority == TaskPriority.urgent
                          ? AppColors.danger
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${report.priorityDistribution[priority] ?? 0} tarefas '
                  '(${Formatters.percent(total == 0 ? 0 : (report.priorityDistribution[priority] ?? 0) / total)})',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Meter(
              value: total == 0
                  ? 0
                  : (report.priorityDistribution[priority] ?? 0) / total,
              color: _colors[priority]!,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
