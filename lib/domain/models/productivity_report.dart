import 'member.dart';
import 'task.dart';

enum ReportPeriod {
  last30Days,
  quarter,
  year;

  /// Início do período que termina em [now].
  DateTime startFrom(DateTime now) => switch (this) {
    ReportPeriod.last30Days => DateTime(now.year, now.month, now.day - 30),
    ReportPeriod.quarter => DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1),
    ReportPeriod.year => DateTime(now.year),
  };
}

class WeeklyThroughput {
  const WeeklyThroughput({
    required this.label,
    required this.completed,
    required this.created,
  });

  final String label;
  final int completed;
  final int created;
}

enum WorkloadLevel { stable, balanced, optimized, overloaded, validating }

class MemberPerformance {
  const MemberPerformance({
    required this.name,
    required this.subtitle,
    required this.assigned,
    required this.completed,
    required this.inProgress,
    required this.efficiency,
    required this.workload,
    required this.workloadLevel,
    this.isClient = false,
    this.workloadNote,
  });

  final String name;
  final String subtitle;
  final int assigned;
  final int completed;
  final int inProgress;

  /// Percentual de entregas no prazo (0..1); `null` sem entregas com prazo.
  final double? efficiency;

  /// Carga de trabalho (0..1).
  final double workload;
  final WorkloadLevel workloadLevel;
  final bool isClient;
  final String? workloadNote;

  String get initials => initialsOf(name);
}

class ProductivityReport {
  const ProductivityReport({
    required this.period,
    required this.onTimeRate,
    required this.slaTarget,
    required this.previousOnTimeRate,
    required this.averageResolutionDays,
    required this.resolutionDeltaDays,
    required this.finishedTasks,
    required this.activeTasks,
    required this.sprintName,
    required this.sprintProgress,
    required this.criticalOverdue,
    required this.weeklyThroughput,
    required this.statusDistribution,
    required this.priorityDistribution,
    required this.members,
    required this.totalMembers,
    required this.netThroughput,
  });

  final ReportPeriod period;

  /// Concluídas no prazo no período; `null` quando nenhuma tinha prazo.
  final double? onTimeRate;
  final double slaTarget;
  final double? previousOnTimeRate;

  /// Dias entre a criação e a conclusão; `null` sem conclusões no período.
  final double? averageResolutionDays;
  final double? resolutionDeltaDays;
  final int finishedTasks;
  final int activeTasks;
  final String sprintName;

  /// Progresso da sprint ativa; `null` quando ela não tem tarefas.
  final double? sprintProgress;

  /// Tarefas urgentes ou de alta prioridade atrasadas há mais de 48h.
  final int criticalOverdue;
  final List<WeeklyThroughput> weeklyThroughput;
  final Map<TaskStatus, int> statusDistribution;
  final Map<TaskPriority, int> priorityDistribution;
  final List<MemberPerformance> members;
  final int totalMembers;

  /// Concluídas menos criadas no período (positivo = backlog diminuindo).
  final int netThroughput;

  int get remainingTasks => activeTasks - finishedTasks;

  int get statusTotal => statusDistribution.values.fold(0, (a, b) => a + b);

  int get priorityTotal => priorityDistribution.values.fold(0, (a, b) => a + b);
}
