import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/models/productivity_report.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/surface_card.dart';

/// "Desempenho ao Longo do Tempo": curvas de concluídas vs. criadas.
class ThroughputChartCard extends StatelessWidget {
  const ThroughputChartCard({super.key, required this.report});

  final ProductivityReport report;

  @override
  Widget build(BuildContext context) {
    final weeks = report.weeklyThroughput;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(
            title: 'Desempenho ao Longo do Tempo',
            subtitle: 'Vazão semanal de conclusões vs. novas demandas abertas',
            trailing: Wrap(
              spacing: 12,
              children: [
                _Legend(color: AppColors.primary, label: 'Concluídas'),
                _Legend(color: AppColors.sky, label: 'Criadas'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: CustomPaint(
              painter: _ThroughputPainter(
                completed: [for (final w in weeks) w.completed.toDouble()],
                created: [for (final w in weeks) w.created.toDouble()],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final w in weeks)
                Expanded(
                  child: Text(
                    w.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _NetThroughput(net: report.netThroughput),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _ThroughputPainter extends CustomPainter {
  _ThroughputPainter({required this.completed, required this.created});

  final List<double> completed;
  final List<double> created;

  @override
  void paint(Canvas canvas, Size size) {
    if (completed.isEmpty) return;

    final maxValue = [...completed, ...created].reduce(math.max) * 1.15;
    const minValue = 0.0;

    // Linhas de grade horizontais.
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Cada ponto fica centralizado na faixa do rótulo da semana.
    List<Offset> points(List<double> values) {
      final step = size.width / values.length;
      return [
        for (var i = 0; i < values.length; i++)
          Offset(
            step * i + step / 2,
            size.height -
                (values[i] - minValue) / (maxValue - minValue) * size.height,
          ),
      ];
    }

    Path smooth(List<Offset> pts) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 0; i < pts.length - 1; i++) {
        final p0 = pts[i];
        final p1 = pts[i + 1];
        final midX = (p0.dx + p1.dx) / 2;
        path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
      }
      return path;
    }

    final completedPts = points(completed);
    final createdPts = points(created);

    // Área sob a curva de concluídas.
    final area = smooth(completedPts)
      ..lineTo(completedPts.last.dx, size.height)
      ..lineTo(completedPts.first.dx, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.28),
            AppColors.primary.withValues(alpha: 0.02),
          ],
        ).createShader(Offset.zero & size),
    );

    void drawLine(List<Offset> pts, Color color, {bool dots = true}) {
      canvas.drawPath(
        smooth(pts),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      if (!dots) return;
      for (final p in pts.skip(1)) {
        canvas.drawCircle(p, 4.5, Paint()..color = Colors.white);
        canvas.drawCircle(p, 3.5, Paint()..color = color);
      }
    }

    drawLine(createdPts, AppColors.sky);
    drawLine(completedPts, AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant _ThroughputPainter oldDelegate) =>
      oldDelegate.completed != completed || oldDelegate.created != created;
}

/// Concluídas menos criadas no período: positivo indica backlog diminuindo.
class _NetThroughput extends StatelessWidget {
  const _NetThroughput({required this.net});

  final int net;

  @override
  Widget build(BuildContext context) {
    final positive = net >= 0;
    final color = positive ? AppColors.success : AppColors.danger;
    return Row(
      children: [
        Icon(
          positive ? Icons.check_circle_outline : Icons.trending_up,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            positive
                ? 'Vazão líquida positiva: $net tarefa(s) concluída(s) além das '
                      'criadas no período'
                : 'Backlog crescendo: ${-net} tarefa(s) criada(s) além das '
                      'concluídas no período',
            style: TextStyle(fontSize: 12, color: color),
          ),
        ),
      ],
    );
  }
}
