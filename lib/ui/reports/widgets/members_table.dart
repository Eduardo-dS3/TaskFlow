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
  const MembersTable({
    super.key,
    required this.viewModel,
    required this.onExportCsv,
  });

  final ReportsViewModel viewModel;
  final VoidCallback onExportCsv;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: _TableHeader(onExportCsv: onExportCsv),
          ),
          _PerformanceTable(members: viewModel.visibleMembers),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _Pagination(viewModel: viewModel),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.onExportCsv});

  final VoidCallback onExportCsv;

  @override
  Widget build(BuildContext context) {
    return SectionTitle(
      title: 'Desempenho por Pessoa',
      subtitle:
          'Tarefas, entregas no prazo e carga de trabalho de cada pessoa '
          'ativa da equipe',
      trailing: OutlinedButton.icon(
        onPressed: onExportCsv,
        icon: const Icon(Icons.download_outlined, size: 18),
        label: const Text('CSV'),
      ),
    );
  }
}

class _PerformanceTable extends StatelessWidget {
  const _PerformanceTable({required this.members});

  final List<MemberPerformance> members;

  static const _columns = [
    DataColumn(label: Text('MEMBRO / RESPONSÁVEL')),
    DataColumn(label: Text('TAREFAS\nATRIBUÍDAS'), numeric: true),
    DataColumn(label: Text('CONCLUÍDAS'), numeric: true),
    DataColumn(label: Text('EM\nANDAMENTO'), numeric: true),
    DataColumn(label: Text('EFICIÊNCIA\n(NO PRAZO)')),
    DataColumn(label: Text('CARGA DE\nTRABALHO')),
  ];

  DataRow _row(MemberPerformance member) => DataRow(
    cells: [
      DataCell(_MemberCell(member: member)),
      DataCell(_Count(value: member.assigned)),
      DataCell(_Count(value: member.completed, color: AppColors.primary)),
      DataCell(Text('${member.inProgress}')),
      DataCell(_EfficiencyCell(efficiency: member.efficiency)),
      DataCell(_WorkloadPill(member: member)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 820),
        child: DataTable(
          headingRowColor: const WidgetStatePropertyAll(AppColors.primarySoft),
          headingTextStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.4,
          ),
          dataRowMinHeight: 60,
          dataRowMaxHeight: 64,
          columns: _columns,
          rows: [for (final member in members) _row(member)],
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({required this.viewModel});

  final ReportsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final page = viewModel.page;
    final lastPage = viewModel.pageCount - 1;
    return Wrap(
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
                  '${viewModel.visibleMembers.length} de '
                  '${viewModel.report!.totalMembers} membros',
              fontSize: 12,
              foreground: AppColors.textPrimary,
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: page > 0 ? () => viewModel.setPage(page - 1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            for (var i = 0; i <= lastPage; i++)
              _PageButton(
                number: i + 1,
                selected: i == page,
                onPressed: () => viewModel.setPage(i),
              ),
            IconButton(
              onPressed: page < lastPage
                  ? () => viewModel.setPage(page + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.number,
    required this.selected,
    required this.onPressed,
  });

  final int number;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: selected
          ? IconButton.filled(
              onPressed: () {},
              icon: Text(
                '$number',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : IconButton(onPressed: onPressed, icon: Text('$number')),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.value, this.color = AppColors.textPrimary});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$value',
      style: TextStyle(fontWeight: FontWeight.w600, color: color),
    );
  }
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

  /// `null` quando a pessoa não concluiu tarefas com prazo no período.
  final double? efficiency;

  /// Verde a partir de 94%, azul a partir de 85% e vermelho abaixo disso.
  static Color _colorFor(double value) {
    if (value >= 0.94) return AppColors.success;
    if (value >= 0.85) return AppColors.info;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final efficiency = this.efficiency;
    if (efficiency == null) {
      return const Text('—', style: TextStyle(color: AppColors.textSecondary));
    }
    final color = _colorFor(efficiency);
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
