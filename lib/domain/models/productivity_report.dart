import 'task.dart';

enum ReportPeriod { last30Days, quarter, year, custom }

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

  /// Percentual de entregas no prazo (0..1).
  final double efficiency;

  /// Carga de trabalho (0..1).
  final double workload;
  final WorkloadLevel workloadLevel;
  final bool isClient;
  final String? workloadNote;

  String get initials {
    final parts = name.split(' ');
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
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
    required this.sprintProgress,
    required this.criticalBlockers,
    required this.weeklyThroughput,
    required this.statusDistribution,
    required this.priorityDistribution,
    required this.members,
    required this.totalMembers,
    required this.netThroughputAboveGoal,
  });

  final ReportPeriod period;
  final double onTimeRate;
  final double slaTarget;
  final double previousOnTimeRate;
  final double averageResolutionDays;
  final double resolutionDeltaDays;
  final int finishedTasks;
  final int activeTasks;
  final double sprintProgress;
  final int criticalBlockers;
  final List<WeeklyThroughput> weeklyThroughput;
  final Map<TaskStatus, int> statusDistribution;
  final Map<TaskPriority, int> priorityDistribution;
  final List<MemberPerformance> members;
  final int totalMembers;
  final int netThroughputAboveGoal;

  int get remainingTasks => activeTasks - finishedTasks;

  int get statusTotal => statusDistribution.values.fold(0, (a, b) => a + b);

  int get priorityTotal => priorityDistribution.values.fold(0, (a, b) => a + b);
}
