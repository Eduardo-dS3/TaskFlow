import '../../../domain/models/productivity_report.dart';
import '../../../domain/models/task.dart';
import '../../../utils/csv.dart';
import '../../core/localization/formatters.dart';

/// Relatório em CSV: indicadores, distribuições e desempenho por pessoa.
List<int> reportCsv(ProductivityReport report, {required String scope}) {
  String days(double? value) =>
      value == null ? '—' : value.toStringAsFixed(1).replaceAll('.', ',');
  return buildCsv([
    ['Relatório de Produtividade', scope],
    ['Período', Formatters.reportPeriod(report.period)],
    [],
    ['Indicador', 'Valor'],
    ['Entregas no prazo', Formatters.optionalPercent(report.onTimeRate)],
    ['Meta de entregas no prazo', Formatters.percent(report.slaTarget)],
    ['Tempo médio de resolução (dias)', days(report.averageResolutionDays)],
    ['Tarefas finalizadas', report.finishedTasks],
    ['Tarefas ativas no período', report.activeTasks],
    ['Tarefas críticas atrasadas', report.criticalOverdue],
    ['Vazão líquida (concluídas - criadas)', report.netThroughput],
    [],
    ['Status', 'Tarefas'],
    for (final status in TaskStatus.values)
      [Formatters.taskStatus(status), report.statusDistribution[status] ?? 0],
    [],
    ['Prioridade', 'Tarefas'],
    for (final priority in TaskPriority.values)
      [
        Formatters.priority(priority),
        report.priorityDistribution[priority] ?? 0,
      ],
    [],
    [
      'Pessoa',
      'Função',
      'Atribuídas',
      'Concluídas',
      'Em andamento',
      'No prazo',
      'Carga',
    ],
    for (final m in report.members)
      [
        m.name,
        m.subtitle,
        m.assigned,
        m.completed,
        m.inProgress,
        Formatters.optionalPercent(m.efficiency, decimals: 1),
        '${Formatters.workload(m.workloadLevel)} (${Formatters.percent(m.workload)})',
      ],
  ]);
}
