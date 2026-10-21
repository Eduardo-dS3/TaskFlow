import 'package:flutter/material.dart';

import '../../../domain/models/task.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/kpi_card.dart';
import '../../core/ui/pill.dart';

/// Cards de indicadores no topo do quadro.
class BoardSummary extends StatelessWidget {
  const BoardSummary({super.key, required this.overview});

  final SprintOverview overview;

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      children: [
        _TotalCard(overview: overview),
        _PendingCard(overview: overview),
        KpiCard(
          title: 'Em Andamento',
          value: '${overview.inProgress}',
          icon: Icons.sync,
          iconColor: AppColors.info,
          iconBackground: AppColors.infoSoft,
          badge: const Pill(
            label: 'Em execução',
            dot: true,
            foreground: AppColors.info,
            background: AppColors.infoSoft,
          ),
          footer: _Footer(
            left: '${overview.allocatedDevs} pessoas alocadas',
            right: 'Ativo',
            rightColor: AppColors.info,
          ),
        ),
        _DoneCard(overview: overview),
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.overview});

  final SprintOverview overview;

  @override
  Widget build(BuildContext context) {
    final growing = overview.monthGrowth >= 0;
    final overloaded = overview.teamCapacity > 1;
    return KpiCard(
      title: 'Total de Tarefas',
      value: '${overview.totalTasks}',
      icon: Icons.format_list_bulleted,
      badge: Pill(
        label:
            '${Formatters.signedPercent(overview.monthGrowth, decimals: 0)} '
            'no mês',
        icon: growing ? Icons.trending_up : Icons.trending_down,
        foreground: growing ? AppColors.success : AppColors.danger,
        background: growing ? AppColors.successSoft : AppColors.dangerSoft,
      ),
      footer: _Footer(
        left: 'Ocupação da equipe',
        right: Formatters.percent(overview.teamCapacity),
        rightColor: overloaded ? AppColors.danger : AppColors.textPrimary,
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.overview});

  final SprintOverview overview;

  @override
  Widget build(BuildContext context) {
    final late = overview.overdue;
    return KpiCard(
      title: 'Pendentes',
      value: '${overview.pending}',
      icon: Icons.schedule,
      iconColor: AppColors.danger,
      iconBackground: AppColors.dangerSoft,
      badge: const Pill(
        label: 'Aguardando início',
        icon: Icons.hourglass_empty,
        foreground: AppColors.danger,
        background: AppColors.dangerSoft,
      ),
      footer: _Footer(
        left: late == 1 ? '1 tarefa atrasada' : '$late tarefas atrasadas',
        right: late > 0 ? 'Atenção' : 'Em dia',
        rightColor: late > 0 ? AppColors.danger : AppColors.success,
      ),
    );
  }
}

class _DoneCard extends StatelessWidget {
  const _DoneCard({required this.overview});

  final SprintOverview overview;

  (String, Color) get _rating {
    final rate = overview.onTimeRate;
    if (rate == null) return ('Sem prazos', AppColors.textSecondary);
    if (rate >= 0.9) return ('Excelente', AppColors.success);
    if (rate >= 0.7) return ('Bom', AppColors.info);
    return ('Atenção', AppColors.danger);
  }

  @override
  Widget build(BuildContext context) {
    final rate = overview.onTimeRate;
    final (label, color) = _rating;
    return KpiCard(
      title: 'Concluídas',
      value: '${overview.done}',
      icon: Icons.check_circle_outline,
      iconColor: AppColors.success,
      iconBackground: AppColors.successSoft,
      badge: Pill(
        label: rate == null
            ? 'Sem prazos definidos'
            : '${Formatters.percent(rate)} no prazo',
        icon: Icons.check,
        foreground: AppColors.success,
        background: AppColors.successSoft,
      ),
      footer: _Footer(
        left: 'Entregas no prazo',
        right: label,
        rightColor: color,
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.left,
    required this.right,
    required this.rightColor,
  });

  final String left;
  final String right;
  final Color rightColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(left)),
        Text(
          right,
          style: TextStyle(color: rightColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
