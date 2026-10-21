import '../models/member.dart';
import '../models/productivity_report.dart';
import '../models/task.dart';
import 'task_metrics.dart';

/// Meta de entregas no prazo exibida no relatório.
const defaultSlaTarget = 0.9;

/// Quantidade de semanas do gráfico de vazão.
const throughputWeeks = 5;

/// Intervalo [start, end) de um período do relatório.
class ReportWindow {
  ReportWindow(this.start, this.end);

  /// Período que vai de `period.startFrom(now)` até o fim de hoje.
  factory ReportWindow.of(ReportPeriod period, DateTime now) =>
      ReportWindow(period.startFrom(now), startOfDay(now).add(_oneDay));

  final DateTime start;
  final DateTime end;

  /// Período imediatamente anterior, com a mesma duração.
  ReportWindow get previous =>
      ReportWindow(start.subtract(end.difference(start)), start);

  bool contains(DateTime? date) => isBetween(date, start, end);

  /// Tarefas concluídas dentro do período.
  List<Task> finished(Iterable<Task> tasks) => tasks
      .where((t) => t.status == TaskStatus.done && contains(t.completedAt))
      .toList();

  /// Tarefas que estiveram abertas em algum momento do período.
  List<Task> active(Iterable<Task> tasks) => tasks.where((t) {
    final created = t.createdAt;
    if (created != null && !created.isBefore(end)) return false;
    final completed = t.completedAt;
    return t.status != TaskStatus.done ||
        completed == null ||
        !completed.isBefore(start);
  }).toList();
}

const _oneDay = Duration(days: 1);

/// Relatório de produtividade do período, opcionalmente de um só projeto.
ProductivityReport computeReport({
  required List<Task> tasks,
  required List<Member> members,
  required ReportPeriod period,
  required String activeSprint,
  required DateTime now,
  String? projectId,
}) {
  final scoped = projectId == null
      ? tasks
      : tasks.where((t) => t.projectId == projectId).toList();
  final window = ReportWindow.of(period, now);
  final previous = window.previous;
  final finished = window.finished(scoped);
  final previousFinished = previous.finished(scoped);
  final active = window.active(scoped);
  final activeMembers = members.where((m) => m.active).toList();

  return ProductivityReport(
    period: period,
    onTimeRate: onTimeRate(finished),
    slaTarget: defaultSlaTarget,
    previousOnTimeRate: onTimeRate(previousFinished),
    averageResolutionDays: averageResolutionDays(finished),
    resolutionDeltaDays: _delta(
      averageResolutionDays(finished),
      averageResolutionDays(previousFinished),
    ),
    finishedTasks: finished.length,
    activeTasks: active.length,
    sprintName: activeSprint,
    sprintProgress: sprintProgress(scoped, activeSprint),
    criticalOverdue: criticalOverdue(scoped, now),
    weeklyThroughput: weeklyThroughput(scoped, now),
    statusDistribution: countByStatus(active),
    priorityDistribution: countByPriority(active),
    members: memberPerformance(
      scopedTasks: scoped,
      active: active,
      finished: finished,
      members: activeMembers,
    ),
    totalMembers: activeMembers.length,
    netThroughput:
        finished.length -
        scoped.where((t) => window.contains(t.createdAt)).length,
  );
}

double? _delta(double? current, double? previous) =>
    current == null || previous == null ? null : current - previous;

/// Média de dias entre a criação e a conclusão das tarefas.
double? averageResolutionDays(Iterable<Task> finished) {
  final durations = [
    for (final t in finished)
      if (t.createdAt != null && t.completedAt != null)
        t.completedAt!.difference(t.createdAt!).inMinutes / (60 * 24),
  ];
  if (durations.isEmpty) return null;
  return durations.reduce((a, b) => a + b) / durations.length;
}

/// Fração concluída das tarefas da sprint ativa.
double? sprintProgress(Iterable<Task> tasks, String activeSprint) {
  if (activeSprint.isEmpty) return null;
  final sprintTasks = tasks.where((t) => t.sprint == activeSprint).toList();
  if (sprintTasks.isEmpty) return null;
  final done = sprintTasks.where((t) => t.status == TaskStatus.done).length;
  return done / sprintTasks.length;
}

/// Tarefas urgentes ou de alta prioridade atrasadas há mais de 48h.
int criticalOverdue(Iterable<Task> tasks, DateTime now) {
  final limit = startOfDay(now).subtract(const Duration(days: 2));
  return tasks.where((t) {
    final due = t.dueDate;
    final critical =
        t.priority == TaskPriority.urgent || t.priority == TaskPriority.high;
    return critical && t.isOverdue(now) && due != null && due.isBefore(limit);
  }).length;
}

/// Tarefas criadas e concluídas em cada uma das últimas semanas.
List<WeeklyThroughput> weeklyThroughput(Iterable<Task> tasks, DateTime now) {
  final today = startOfDay(now);
  final currentWeek = today.subtract(Duration(days: today.weekday - 1));
  return [
    for (var i = throughputWeeks - 1; i >= 0; i--)
      _week(
        tasks,
        currentWeek.subtract(Duration(days: 7 * i)),
        isCurrent: i == 0,
      ),
  ];
}

WeeklyThroughput _week(
  Iterable<Task> tasks,
  DateTime start, {
  required bool isCurrent,
}) {
  final end = start.add(const Duration(days: 7));
  final day = start.day.toString().padLeft(2, '0');
  final month = start.month.toString().padLeft(2, '0');
  return WeeklyThroughput(
    label: isCurrent ? 'Semana atual' : 'Semana $day/$month',
    completed: tasks
        .where((t) => t.status == TaskStatus.done)
        .where((t) => isBetween(t.completedAt, start, end))
        .length,
    created: tasks.where((t) => isBetween(t.createdAt, start, end)).length,
  );
}

/// Indicadores individuais de cada pessoa ativa da equipe.
List<MemberPerformance> memberPerformance({
  required List<Task> scopedTasks,
  required List<Task> active,
  required List<Task> finished,
  required List<Member> members,
}) {
  final rows = [
    for (final member in members)
      _performanceOf(member, scopedTasks, active, finished),
  ];
  return rows..sort((a, b) => b.assigned.compareTo(a.assigned));
}

MemberPerformance _performanceOf(
  Member member,
  List<Task> scopedTasks,
  List<Task> active,
  List<Task> finished,
) {
  final inProgress = scopedTasks
      .where((t) => t.status == TaskStatus.inProgress)
      .where((t) => involves(t, member))
      .toList();
  final completed = finished.where((t) => involves(t, member)).toList();
  final workload = _workload(member, inProgress);
  return MemberPerformance(
    name: member.name,
    subtitle: member.role,
    assigned: active.where((t) => involves(t, member)).length,
    completed: completed.length,
    inProgress: inProgress.length,
    efficiency: onTimeRate(completed),
    workload: workload,
    workloadLevel: workloadLevelFor(workload),
  );
}

/// Horas restantes da pessoa (dividindo tarefas compartilhadas) sobre a
/// capacidade semanal.
double _workload(Member member, List<Task> inProgress) {
  if (member.weeklyCapacity <= 0) return 0;
  final hours = inProgress.fold<double>(
    0,
    (sum, t) => sum + remainingHours(t) / t.links.people.length,
  );
  return hours / member.weeklyCapacity;
}

WorkloadLevel workloadLevelFor(double workload) {
  if (workload > 0.9) return WorkloadLevel.overloaded;
  if (workload >= 0.7) return WorkloadLevel.optimized;
  if (workload >= 0.6) return WorkloadLevel.balanced;
  return WorkloadLevel.stable;
}
