import 'package:flutter/material.dart';

import '../../../domain/models/task.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/kpi_card.dart';
import '../../core/ui/pill.dart';

/// Cards de indicadores da sprint no topo do quadro.
class BoardSummary extends StatelessWidget {
  const BoardSummary({super.key, required this.overview});

  final SprintOverview overview;

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      children: [
        KpiCard(
          title: 'Total de Tarefas',
          value: '${overview.totalTasks}',
          icon: Icons.format_list_bulleted,
          badge: Pill(
            label:
                '${Formatters.signedPercent(overview.monthGrowth, decimals: 0)} mês',
            icon: Icons.trending_up,
            foreground: AppColors.success,
            background: AppColors.successSoft,
          ),
          footer: _Footer(
            left: 'Capacidade total do time',
            right: Formatters.percent(overview.teamCapacity),
            rightColor: AppColors.textPrimary,
          ),
        ),
        KpiCard(
          title: 'Pendentes',
          value: '${overview.pending}',
          icon: Icons.schedule,
          iconColor: AppColors.danger,
          iconBackground: AppColors.dangerSoft,
          badge: const Pill(
            label: 'Aguardando início',
            icon: Icons.warning_amber_rounded,
            foreground: AppColors.danger,
            background: AppColors.dangerSoft,
          ),
          footer: _Footer(
            left: '${overview.blockers} bloqueadores ativos',
            right: 'Atenção',
            rightColor: AppColors.danger,
          ),
        ),
        KpiCard(
          title: 'Em Andamento',
          value: '${overview.inProgress}',
          icon: Icons.sync,
          iconColor: AppColors.info,
          iconBackground: AppColors.infoSoft,
          badge: const Pill(
            label: 'Em produção',
            dot: true,
            foreground: AppColors.info,
            background: AppColors.infoSoft,
          ),
          footer: _Footer(
            left: '${overview.allocatedDevs} devs alocados',
            right: 'Ativo',
            rightColor: AppColors.info,
          ),
        ),
        KpiCard(
          title: 'Concluídas',
          value: '${overview.done}',
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
          iconBackground: AppColors.successSoft,
          badge: Pill(
            label: '${Formatters.percent(overview.onTimeRate)} no prazo',
            icon: Icons.check,
            foreground: AppColors.success,
            background: AppColors.successSoft,
          ),
          footer: const _Footer(
            left: 'Taxa de sprint',
            right: 'Excelente',
            rightColor: AppColors.success,
          ),
        ),
      ],
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
