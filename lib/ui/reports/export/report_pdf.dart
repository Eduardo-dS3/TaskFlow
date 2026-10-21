import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/models/productivity_report.dart';
import '../../../domain/models/task.dart';
import '../../core/localization/formatters.dart';
import 'report_insights.dart';

const _primary = PdfColor.fromInt(0xFF3D33D6);
const _muted = PdfColor.fromInt(0xFF5E6075);
const _soft = PdfColor.fromInt(0xFFE8E7FB);

/// Documento executivo em PDF: indicadores, distribuições, vazão semanal,
/// desempenho da equipe e análise de risco automática.
Future<List<int>> reportPdf(
  ProductivityReport report, {
  required String scope,
  required String organization,
  required DateTime generatedAt,
}) {
  final document = pw.Document(
    title: 'Relatório de Produtividade',
    author: 'TaskFlow',
  );
  final generated = DateFormat(
    "dd/MM/yyyy 'às' HH:mm",
    'pt_BR',
  ).format(generatedAt);
  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      header: (context) => _header(organization, scope, report.period),
      footer: (context) => _footer(context, generated),
      build: (context) => [
        _section('Indicadores principais'),
        _kpiTable(report),
        _section('Análise de risco'),
        ..._insights(report),
        _section('Distribuição das tarefas ativas'),
        _distributionTables(report),
        _section('Vazão semanal'),
        _throughputTable(report),
        _section('Desempenho por pessoa'),
        _membersTable(report),
      ],
    ),
  );
  return document.save();
}

pw.Widget _header(String organization, String scope, ReportPeriod period) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 12),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _primary, width: 2)),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                organization.isEmpty ? 'TaskFlow' : 'TaskFlow • $organization',
                style: const pw.TextStyle(color: _muted, fontSize: 10),
              ),
              pw.Text(
                'Relatório de Produtividade',
                style: const pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '$scope • ${Formatters.reportPeriod(period)}',
                style: const pw.TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: _soft,
          child: pw.Text(
            'CONFIDENCIAL',
            style: const pw.TextStyle(
              color: _primary,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _footer(pw.Context context, String generated) => pw.Row(
  children: [
    pw.Text(
      'Gerado em $generated • Uso interno',
      style: const pw.TextStyle(color: _muted, fontSize: 8),
    ),
    pw.Spacer(),
    pw.Text(
      'Página ${context.pageNumber} de ${context.pagesCount}',
      style: const pw.TextStyle(color: _muted, fontSize: 8),
    ),
  ],
);

pw.Widget _section(String title) => pw.Padding(
  padding: const pw.EdgeInsets.only(top: 18, bottom: 8),
  child: pw.Text(
    title,
    style: const pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
      color: _primary,
    ),
  ),
);

pw.Widget _table(List<String> headers, List<List<Object?>> rows) =>
    pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: const pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: _primary),
      cellStyle: const pw.TextStyle(fontSize: 9),
      oddRowDecoration: const pw.BoxDecoration(color: _soft),
      cellAlignment: pw.Alignment.centerLeft,
    );

pw.Widget _kpiTable(ProductivityReport report) {
  final days = report.averageResolutionDays;
  final sprint = report.sprintProgress;
  return _table(
    ['Indicador', 'Valor'],
    [
      [
        'Entregas no prazo (meta ${Formatters.percent(report.slaTarget)})',
        Formatters.optionalPercent(report.onTimeRate, decimals: 1),
      ],
      [
        'Tempo médio de resolução',
        days == null ? '—' : '${days.toStringAsFixed(1)} dias',
      ],
      [
        'Tarefas finalizadas / ativas',
        '${report.finishedTasks} de ${report.activeTasks}',
      ],
      [
        'Sprint ativa${report.sprintName.isEmpty ? '' : ' (${report.sprintName})'}',
        sprint == null ? '—' : '${Formatters.percent(sprint)} concluída',
      ],
      ['Tarefas críticas atrasadas (> 48h)', '${report.criticalOverdue}'],
      ['Vazão líquida (concluídas - criadas)', '${report.netThroughput}'],
    ],
  );
}

List<pw.Widget> _insights(ProductivityReport report) => [
  for (final insight in reportInsights(report))
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            switch (insight.level) {
              InsightLevel.ok => 'OK',
              InsightLevel.warning => 'ATENÇÃO',
              InsightLevel.critical => 'CRÍTICO',
            },
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: switch (insight.level) {
                InsightLevel.ok => PdfColors.green700,
                InsightLevel.warning => PdfColors.orange700,
                InsightLevel.critical => PdfColors.red700,
              },
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              insight.text,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    ),
];

pw.Widget _distributionTables(ProductivityReport report) => pw.Row(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.Expanded(
      child: _table(
        ['Status', 'Tarefas'],
        [
          for (final s in TaskStatus.values)
            [Formatters.taskStatus(s), report.statusDistribution[s] ?? 0],
        ],
      ),
    ),
    pw.SizedBox(width: 16),
    pw.Expanded(
      child: _table(
        ['Prioridade', 'Tarefas'],
        [
          for (final p in TaskPriority.values)
            [Formatters.priority(p), report.priorityDistribution[p] ?? 0],
        ],
      ),
    ),
  ],
);

pw.Widget _throughputTable(ProductivityReport report) => _table(
  ['Semana', 'Concluídas', 'Criadas'],
  [
    for (final w in report.weeklyThroughput) [w.label, w.completed, w.created],
  ],
);

pw.Widget _membersTable(ProductivityReport report) {
  if (report.members.isEmpty) {
    return pw.Text('Nenhuma pessoa ativa na equipe.');
  }
  return _table(
    ['Pessoa', 'Atribuídas', 'Concluídas', 'Em andamento', 'No prazo', 'Carga'],
    [
      for (final m in report.members)
        [
          m.name,
          m.assigned,
          m.completed,
          m.inProgress,
          Formatters.optionalPercent(m.efficiency, decimals: 1),
          '${Formatters.workload(m.workloadLevel)} '
              '(${Formatters.percent(m.workload)})',
        ],
    ],
  );
}
