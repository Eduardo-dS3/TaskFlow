import 'package:flutter/material.dart';

import '../../../domain/models/productivity_report.dart';
import '../../../utils/result.dart';
import '../../core/localization/formatters.dart';
import '../../core/platform/file_actions.dart';
import '../../core/themes/colors.dart';
import '../../core/themes/dimens.dart';
import '../../core/ui/command_view.dart';
import '../../core/ui/feedback.dart';
import '../../core/ui/kpi_card.dart';
import '../../core/ui/pill.dart';
import '../view_models/reports_viewmodel.dart';
import 'distribution_cards.dart';
import 'executive_banner.dart';
import 'members_table.dart';
import 'throughput_chart.dart';

/// Exportações do relatório (CSV e PDF), que dependem do navegador.
class ReportExports {
  ReportExports(this.viewModel);

  final ReportsViewModel viewModel;

  String get _baseName {
    final date = DateTime.now().toIso8601String().substring(0, 10);
    return 'relatorio-produtividade-$date';
  }

  Future<void> csv() async {
    await viewModel.exportCsv.execute();
    if (viewModel.exportCsv.result case Ok(:final value)) {
      saveFile(value, '$_baseName.csv', 'text/csv');
    }
  }

  Future<void> pdf({required bool preview}) async {
    await viewModel.exportPdf.execute();
    if (viewModel.exportPdf.result case Ok(:final value)) {
      preview
          ? openBytes(value, 'application/pdf')
          : saveFile(value, '$_baseName.pdf', 'application/pdf');
    }
  }
}

/// Tela "Produtividade & Relatórios".
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key, required this.viewModel});

  final ReportsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final exports = ReportExports(viewModel);
    return CommandErrorListener(
      commands: [viewModel.exportCsv, viewModel.exportPdf],
      child: ListenableBuilder(
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
            builder: (context, constraints) => _ReportContent(
              viewModel: viewModel,
              report: report,
              exports: exports,
              maxWidth: constraints.maxWidth,
            ),
          );
        },
      ),
    );
  }
}

class _ReportContent extends StatelessWidget {
  const _ReportContent({
    required this.viewModel,
    required this.report,
    required this.exports,
    required this.maxWidth,
  });

  final ReportsViewModel viewModel;
  final ProductivityReport report;
  final ReportExports exports;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final wide = maxWidth >= Dimens.breakpointWide;
    final padding = maxWidth < 600
        ? Dimens.paddingPageCompact
        : Dimens.paddingPage;
    final distributions = Column(
      children: [
        StatusDistributionCard(report: report),
        const SizedBox(height: 20),
        PriorityDistributionCard(report: report),
      ],
    );
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(viewModel: viewModel, onExportCsv: exports.csv),
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
                    Expanded(flex: 2, child: distributions),
                  ],
                )
              else ...[
                ThroughputChartCard(report: report),
                const SizedBox(height: 20),
                distributions,
              ],
              const SizedBox(height: 20),
              MembersTable(viewModel: viewModel, onExportCsv: exports.csv),
              const SizedBox(height: 20),
              ExecutiveBanner(viewModel: viewModel, exports: exports),
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
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.viewModel, required this.onExportCsv});

  final ReportsViewModel viewModel;
  final VoidCallback onExportCsv;

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
            Text(
              'ANALYTICS & BI • PRODUTIVIDADE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Relatórios de Produtividade',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(width: 240, child: _ProjectSelect(viewModel: viewModel)),
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
                  ),
              ],
              selected: {viewModel.period},
              onSelectionChanged: (s) => viewModel.selectPeriod(s.first),
            ),
            FilledButton.icon(
              onPressed: onExportCsv,
              icon: const Icon(Icons.ios_share, size: 18),
              label: const Text('Exportar CSV'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProjectSelect extends StatelessWidget {
  const _ProjectSelect({required this.viewModel});

  final ReportsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final known = viewModel.projects.any((p) => p.id == viewModel.projectId);
    return DropdownButtonFormField<String?>(
      initialValue: known ? viewModel.projectId : null,
      isExpanded: true,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.folder_outlined, size: 18),
      ),
      items: [
        const DropdownMenuItem<String?>(child: Text('Todos os projetos')),
        for (final project in viewModel.projects)
          DropdownMenuItem(value: project.id, child: Text(project.name)),
      ],
      onChanged: viewModel.selectProject,
    );
  }
}

class _Kpis extends StatelessWidget {
  const _Kpis({required this.report});

  final ProductivityReport report;

  @override
  Widget build(BuildContext context) {
    final days = report.averageResolutionDays;
    final sprint = report.sprintProgress;
    return ResponsiveGrid(
      children: [
        _OnTimeCard(report: report),
        KpiCard(
          title: 'Tempo Médio de Resolução',
          value: days == null ? '—' : days.toStringAsFixed(1),
          unit: 'dias',
          icon: Icons.timer_outlined,
          iconColor: AppColors.info,
          iconBackground: AppColors.infoSoft,
          footer: Text(_resolutionTrend(report.resolutionDeltaDays)),
        ),
        KpiCard(
          title: 'Tarefas Finalizadas',
          value: '${report.finishedTasks}',
          unit: 'de ${report.activeTasks} ativas',
          icon: Icons.task_alt,
          footer: Row(
            children: [
              Expanded(
                child: Text(
                  sprint == null
                      ? 'Sem tarefas na sprint ativa'
                      : 'Sprint ativa ${Formatters.percent(sprint)} concluída',
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
          title: 'Atrasos Críticos',
          titleColor: AppColors.danger,
          value: '${report.criticalOverdue}',
          valueColor: AppColors.danger,
          unit: 'tarefas',
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.danger,
          iconBackground: AppColors.dangerSoft,
          footer: const Text('Urgentes ou de alta prioridade, atraso > 48h'),
        ),
      ],
    );
  }

  static String _resolutionTrend(double? delta) {
    if (delta == null) return 'Sem comparação com o período anterior';
    final value = delta.abs().toStringAsFixed(1);
    return delta <= 0
        ? '$value dias mais rápido que o período anterior'
        : '$value dias mais lento que o período anterior';
  }
}

class _OnTimeCard extends StatelessWidget {
  const _OnTimeCard({required this.report});

  final ProductivityReport report;

  @override
  Widget build(BuildContext context) {
    final rate = report.onTimeRate;
    final previous = report.previousOnTimeRate;
    return KpiCard(
      title: 'Entregas no Prazo',
      value: Formatters.optionalPercent(rate, decimals: 1),
      unit: '/ meta ${Formatters.percent(report.slaTarget)}',
      icon: Icons.verified_outlined,
      footer: Row(
        children: [
          if (rate != null && previous != null) ...[
            Pill(
              label: Formatters.signedPercent(rate - previous),
              icon: rate >= previous ? Icons.trending_up : Icons.trending_down,
              foreground: AppColors.primaryDark,
              background: AppColors.primarySoft,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              previous == null
                  ? 'Sem dados do período anterior'
                  : 'Anterior: ${Formatters.percent(previous, decimals: 1)}',
            ),
          ),
        ],
      ),
    );
  }
}
