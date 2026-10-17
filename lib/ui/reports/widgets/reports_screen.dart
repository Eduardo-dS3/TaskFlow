import 'package:flutter/material.dart';

import '../../../domain/models/productivity_report.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/themes/dimens.dart';
import '../../core/ui/command_view.dart';
import '../../core/ui/kpi_card.dart';
import '../../core/ui/pill.dart';
import '../view_models/reports_viewmodel.dart';
import 'distribution_cards.dart';
import 'executive_banner.dart';
import 'members_table.dart';
import 'throughput_chart.dart';

/// Tela "Produtividade & Relatórios".
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key, required this.viewModel});

  final ReportsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final report = viewModel.report;
        if (report == null) {
          if (viewModel.load.error) {
            return ErrorIndicator(
              title: 'Não foi possível carregar o relatório',
              onRetry: viewModel.retry,
            );
          }
          return const Center(child: CircularProgressIndicator());
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= Dimens.breakpointWide;
            final padding = constraints.maxWidth < 600
                ? Dimens.paddingPageCompact
                : Dimens.paddingPage;
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(viewModel: viewModel),
                      const SizedBox(height: 20),
                      _Kpis(report: report),
                      const SizedBox(height: 20),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: ThroughputChartCard(report: report),
                            ),
                            const SizedBox(width: 20),
                            Expanded(flex: 2, child: _distributions(report)),
                          ],
                        )
                      else ...[
                        ThroughputChartCard(report: report),
                        const SizedBox(height: 20),
                        _distributions(report),
                      ],
                      const SizedBox(height: 20),
                      MembersTable(viewModel: viewModel),
                      const SizedBox(height: 20),
                      ExecutiveBanner(viewModel: viewModel),
                    ],
                  ),
                ),
                if (viewModel.load.running)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _distributions(ProductivityReport report) => Column(
    children: [
      StatusDistributionCard(report: report),
      const SizedBox(height: 20),
      PriorityDistributionCard(report: report),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.viewModel});

  final ReportsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 16,
      runSpacing: 16,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
                SizedBox(width: 4),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      text: 'ANALYTICS & BI WORKSPACE / ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'PRODUTIVIDADE EXECUTIVA',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              children: [
                Text(
                  'Relatórios de Produtividade',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                Pill(
                  label: 'Dados consolidados em tempo real',
                  dot: true,
                  foreground: AppColors.primaryDark,
                  background: AppColors.primarySoft,
                ),
              ],
            ),
          ],
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const _StaticSelect(label: 'Todos os Projetos & Clientes'),
            SegmentedButton<ReportPeriod>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                selectedBackgroundColor: AppColors.surface,
                backgroundColor: AppColors.surfaceMuted,
              ),
              segments: [
                for (final p in ReportPeriod.values)
                  ButtonSegment(
                    value: p,
                    label: Text(Formatters.reportPeriod(p)),
                    icon: p == ReportPeriod.custom
                        ? const Icon(Icons.calendar_today_outlined, size: 14)
                        : null,
                  ),
              ],
              selected: {viewModel.period},
              onSelectionChanged: (s) => viewModel.selectPeriod(s.first),
            ),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.ios_share, size: 18),
              label: const Text('Exportar Relatório'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StaticSelect extends StatelessWidget {
  const _StaticSelect({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.folder_outlined, size: 18),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }
}

class _Kpis extends StatelessWidget {
  const _Kpis({required this.report});

  final ProductivityReport report;

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      children: [
        KpiCard(
          title: 'Taxa de Conclusão no Prazo',
          value: Formatters.percent(report.onTimeRate, decimals: 1),
          unit: '/ SLA ${Formatters.percent(report.slaTarget)}',
          icon: Icons.verified_outlined,
          footer: Row(
            children: [
              Pill(
                label: Formatters.signedPercent(
                  report.onTimeRate - report.previousOnTimeRate,
                ),
                icon: Icons.trending_up,
                foreground: AppColors.primaryDark,
                background: AppColors.primarySoft,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'vs mês anterior '
                  '(${Formatters.percent(report.previousOnTimeRate, decimals: 1)})',
                ),
              ),
            ],
          ),
        ),
        KpiCard(
          title: 'Tempo Médio de Resolução',
          value: report.averageResolutionDays.toStringAsFixed(1),
          unit: 'dias',
          icon: Icons.timer_outlined,
          iconColor: AppColors.info,
          iconBackground: AppColors.infoSoft,
          footer: Row(
            children: [
              Pill(
                label: '${report.resolutionDeltaDays.toStringAsFixed(1)} dias',
                icon: Icons.arrow_downward,
                foreground: AppColors.info,
                background: AppColors.infoSoft,
              ),
              const SizedBox(width: 6),
              const Flexible(child: Text('ganho de agilidade')),
            ],
          ),
        ),
        KpiCard(
          title: 'Total Tarefas Finalizadas',
          value: '${report.finishedTasks}',
          unit: 'de ${report.activeTasks} ativas',
          icon: Icons.task_alt,
          footer: Row(
            children: [
              Expanded(
                child: Text(
                  'Sprint atual ${Formatters.percent(report.sprintProgress)} '
                  'completo',
                ),
              ),
              Text(
                '${report.remainingTasks} restantes',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        KpiCard(
          title: 'Gargalos Identificados',
          titleColor: AppColors.danger,
          value: report.criticalBlockers.toString().padLeft(2, '0'),
          valueColor: AppColors.danger,
          unit: 'bloqueios críticos',
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.danger,
          iconBackground: AppColors.dangerSoft,
          footer: const Row(
            children: [
              Pill(
                label: 'Atraso > 48h',
                foreground: AppColors.danger,
                background: AppColors.dangerSoft,
              ),
              SizedBox(width: 6),
              Flexible(child: Text('Requer intervenção tech lead')),
            ],
          ),
        ),
      ],
    );
  }
}
