import '../../../../domain/models/productivity_report.dart';
import '../../../../domain/models/task.dart';

/// Relatório de produtividade do [period] informado.
///
/// Os volumes são escalados por período apenas para diferenciar as
/// visões na simulação; percentuais e indicadores individuais não mudam.
ProductivityReport seedReport(ReportPeriod period) {
  final factor = _periodFactor(period);
  int scale(int value) => (value * factor).round();

  return ProductivityReport(
    period: period,
    onTimeRate: 0.942,
    slaTarget: 0.90,
    previousOnTimeRate: 0.907,
    averageResolutionDays: 2.8,
    resolutionDeltaDays: -0.4,
    finishedTasks: scale(148),
    activeTasks: scale(192),
    sprintProgress: 0.77,
    criticalBlockers: 3,
    netThroughputAboveGoal: scale(18),
    weeklyThroughput: _weeklyThroughput,
    statusDistribution: {
      TaskStatus.done: scale(71),
      TaskStatus.inProgress: scale(73),
      TaskStatus.pending: scale(48),
    },
    priorityDistribution: {
      TaskPriority.urgent: scale(14),
      TaskPriority.high: scale(58),
      TaskPriority.medium: scale(86),
      TaskPriority.low: scale(34),
    },
    totalMembers: 18,
    members: _members,
  );
}

double _periodFactor(ReportPeriod period) => switch (period) {
  ReportPeriod.last30Days => 1.0,
  ReportPeriod.quarter => 2.6,
  ReportPeriod.year => 9.4,
  ReportPeriod.custom => 1.0,
};

const _weeklyThroughput = [
  WeeklyThroughput(label: 'Semana 01', completed: 22, created: 14),
  WeeklyThroughput(label: 'Semana 02', completed: 29, created: 18),
  WeeklyThroughput(label: 'Semana 03', completed: 33, created: 24),
  WeeklyThroughput(label: 'Semana 04', completed: 34, created: 30),
  WeeklyThroughput(label: 'Semana 05 (Atual)', completed: 39, created: 35),
];

const _members = [
  MemberPerformance(
    name: 'Rodrigo Nogueira',
    subtitle: 'Tech Lead • Core Flutter',
    assigned: 42,
    completed: 39,
    inProgress: 3,
    efficiency: 0.975,
    workload: 0.75,
    workloadLevel: WorkloadLevel.optimized,
  ),
  MemberPerformance(
    name: 'Beatriz Ramos',
    subtitle: 'Lead Product Designer',
    assigned: 36,
    completed: 32,
    inProgress: 4,
    efficiency: 0.941,
    workload: 0.68,
    workloadLevel: WorkloadLevel.balanced,
  ),
  MemberPerformance(
    name: 'Lucas Farias',
    subtitle: 'Senior Backend • API Integrations',
    assigned: 51,
    completed: 38,
    inProgress: 13,
    efficiency: 0.863,
    workload: 0.94,
    workloadLevel: WorkloadLevel.overloaded,
  ),
  MemberPerformance(
    name: 'Camila Duarte',
    subtitle: 'QA Automation Engineer',
    assigned: 28,
    completed: 25,
    inProgress: 3,
    efficiency: 0.96,
    workload: 0.52,
    workloadLevel: WorkloadLevel.stable,
  ),
  MemberPerformance(
    name: 'OmniBank Financials',
    subtitle: 'Cliente Estratégico • Squad Alfa',
    assigned: 35,
    completed: 14,
    inProgress: 21,
    efficiency: 0.792,
    workload: 0,
    workloadLevel: WorkloadLevel.validating,
    workloadNote: 'Atraso 2d',
    isClient: true,
  ),
];
