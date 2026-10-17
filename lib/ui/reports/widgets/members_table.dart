import 'package:flutter/material.dart';

import '../../../domain/models/productivity_report.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/avatar.dart';
import '../../core/ui/meter.dart';
import '../../core/ui/pill.dart';
import '../../core/ui/surface_card.dart';
import '../view_models/reports_viewmodel.dart';

/// "Performance por Membro da Equipe & Alocação".
class MembersTable extends StatelessWidget {
  const MembersTable({super.key, required this.viewModel});

  final ReportsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final report = viewModel.report!;
    final members = viewModel.visibleMembers;
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: SectionTitle(
              title: 'Performance por Membro da Equipe & Alocação',
              subtitle:
                  'Indicadores individuais de SLA, vazão e balanço de '
                  'carga de trabalho',
              trailing: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: const Text('Filtrar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('CSV'),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 820),
              child: LayoutBuilder(
                builder: (context, _) => DataTable(
                  headingRowColor: const WidgetStatePropertyAll(
                    AppColors.primarySoft,
                  ),
                  headingTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.4,
                  ),
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 64,
                  columns: const [
                    DataColumn(label: Text('MEMBRO / RESPONSÁVEL')),
                    DataColumn(
                      label: Text('TAREFAS\nATRIBUÍDAS'),
                      numeric: true,
                    ),
                    DataColumn(label: Text('CONCLUÍDAS'), numeric: true),
                    DataColumn(label: Text('EM\nANDAMENTO'), numeric: true),
                    DataColumn(label: Text('EFICIÊNCIA\n(NO PRAZO)')),
                    DataColumn(label: Text('CARGA DE\nTRABALHO')),
                  ],
                  rows: [
                    for (final m in members)
                      DataRow(
                        cells: [
                          DataCell(_MemberCell(member: m)),
                          DataCell(_bold('${m.assigned}')),
                          DataCell(_bold('${m.completed}', AppColors.primary)),
                          DataCell(Text('${m.inProgress}')),
                          DataCell(_EfficiencyCell(efficiency: m.efficiency)),
                          DataCell(_WorkloadPill(member: m)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Exibindo', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    Pill(
                      label:
                          '${members.length} de ${report.totalMembers} membros',
                      fontSize: 12,
                      foreground: AppColors.textPrimary,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: viewModel.page > 0
                          ? () => viewModel.setPage(viewModel.page - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    for (var i = 0; i < viewModel.pageCount; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: i == viewModel.page
                            ? IconButton.filled(
                                onPressed: () {},
                                icon: Text(
                                  '${i + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              )
                            : IconButton(
                                onPressed: () => viewModel.setPage(i),
                                icon: Text('${i + 1}'),
                              ),
                      ),
                    IconButton(
                      onPressed: viewModel.page < viewModel.pageCount - 1
                          ? () => viewModel.setPage(viewModel.page + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bold(String text, [Color color = AppColors.textPrimary]) => Text(
    text,
    style: TextStyle(fontWeight: FontWeight.w600, color: color),
  );
}

class _MemberCell extends StatelessWidget {
  const _MemberCell({required this.member});

  final MemberPerformance member;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        member.isClient
            ? Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.infoSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.apartment,
                  size: 18,
                  color: AppColors.info,
                ),
              )
            : InitialsAvatar(initials: member.initials, size: 34),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Text(
              member.subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EfficiencyCell extends StatelessWidget {
  const _EfficiencyCell({required this.efficiency});

  final double efficiency;

  @override
  Widget build(BuildContext context) {
    final color = efficiency >= 0.94
        ? AppColors.success
        : efficiency >= 0.85
        ? AppColors.info
        : AppColors.danger;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Formatters.percent(efficiency, decimals: 1),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Meter(value: efficiency, color: color, height: 4),
        ),
      ],
    );
  }
}

class _WorkloadPill extends StatelessWidget {
  const _WorkloadPill({required this.member});

  final MemberPerformance member;

  @override
  Widget build(BuildContext context) {
    final level = member.workloadLevel;
    final (fg, bg) = switch (level) {
      WorkloadLevel.overloaded => (AppColors.danger, AppColors.dangerSoft),
      WorkloadLevel.validating => (AppColors.info, AppColors.primarySoft),
      _ => (AppColors.success, AppColors.surfaceMuted),
    };
    final detail = member.workloadNote ?? Formatters.percent(member.workload);
    return Pill(
      label: '${Formatters.workload(level)} ($detail)',
      dot: true,
      foreground: level == WorkloadLevel.overloaded
          ? fg
          : AppColors.textPrimary,
      background: bg,
    );
  }
}
