import '../../../domain/models/productivity_report.dart';
import '../../core/localization/formatters.dart';

/// Nível de atenção de um ponto da análise de risco.
enum InsightLevel { ok, warning, critical }

typedef ReportInsight = ({InsightLevel level, String text});

/// Análise de risco automática a partir dos indicadores do relatório.
List<ReportInsight> reportInsights(ProductivityReport report) => [
  _deadlineInsight(report),
  if (report.criticalOverdue > 0)
    (
      level: InsightLevel.critical,
      text:
          '${report.criticalOverdue} tarefa(s) urgente(s) ou de alta '
          'prioridade atrasada(s) há mais de 48h.',
    ),
  ..._workloadInsights(report),
  _throughputInsight(report),
];

ReportInsight _deadlineInsight(ProductivityReport report) {
  final rate = report.onTimeRate;
  if (rate == null) {
    return (
      level: InsightLevel.warning,
      text:
          'Nenhuma tarefa concluída no período tinha prazo: defina prazos '
          'para acompanhar o SLA.',
    );
  }
  final target = Formatters.percent(report.slaTarget);
  if (rate < report.slaTarget) {
    return (
      level: InsightLevel.critical,
      text:
          'Entregas no prazo em ${Formatters.percent(rate, decimals: 1)}, '
          'abaixo da meta de $target.',
    );
  }
  return (
    level: InsightLevel.ok,
    text:
        'Entregas no prazo em ${Formatters.percent(rate, decimals: 1)}, '
        'dentro da meta de $target.',
  );
}

List<ReportInsight> _workloadInsights(ProductivityReport report) {
  final overloaded = report.members
      .where((m) => m.workloadLevel == WorkloadLevel.overloaded)
      .map((m) => m.name)
      .toList();
  if (overloaded.isEmpty) return const [];
  return [
    (
      level: InsightLevel.warning,
      text: 'Sobrecarga de trabalho: ${overloaded.join(', ')}.',
    ),
  ];
}

ReportInsight _throughputInsight(ProductivityReport report) {
  final net = report.netThroughput;
  if (net < 0) {
    return (
      level: InsightLevel.warning,
      text:
          'O backlog cresceu: foram criadas ${-net} tarefa(s) a mais do que '
          'as concluídas no período.',
    );
  }
  return (
    level: InsightLevel.ok,
    text:
        'O backlog diminuiu ou se manteve: $net tarefa(s) concluída(s) além '
        'das criadas no período.',
  );
}
