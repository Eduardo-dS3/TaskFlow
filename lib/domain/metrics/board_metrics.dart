import '../models/member.dart';
import '../models/task.dart';
import 'task_metrics.dart';

/// Indicadores do topo do quadro, calculados a partir das tarefas.
SprintOverview computeSprintOverview({
  required List<Task> tasks,
  required List<Member> members,
  required String activeSprint,
  required DateTime now,
}) {
  final counts = countByStatus(tasks);
  final inProgress = tasks
      .where((t) => t.status == TaskStatus.inProgress)
      .toList();
  final activeMembers = members.where((m) => m.active).toList();

  return SprintOverview(
    sprintName: activeSprint,
    totalTasks: tasks.length,
    monthGrowth: _monthGrowth(tasks, now),
    teamCapacity: _occupancy(inProgress, activeMembers),
    pending: counts[TaskStatus.pending]!,
    overdue: tasks.where((t) => t.isOverdue(now)).length,
    inProgress: inProgress.length,
    allocatedDevs: {for (final t in inProgress) ...t.links.people}.length,
    done: counts[TaskStatus.done]!,
    onTimeRate: onTimeRate(tasks),
    onlineMembers: activeMembers.where((m) => m.isOnline(now)).toList(),
  );
}

/// Variação das tarefas criadas neste mês em relação ao mês anterior.
double _monthGrowth(List<Task> tasks, DateTime now) {
  final thisMonth = DateTime(now.year, now.month);
  final nextMonth = DateTime(now.year, now.month + 1);
  final lastMonth = DateTime(now.year, now.month - 1);
  final current = tasks
      .where((t) => isBetween(t.createdAt, thisMonth, nextMonth))
      .length;
  final previous = tasks
      .where((t) => isBetween(t.createdAt, lastMonth, thisMonth))
      .length;
  if (previous == 0) return 0;
  return (current - previous) / previous;
}

/// Horas restantes das tarefas em andamento sobre a capacidade semanal.
double _occupancy(List<Task> inProgress, List<Member> members) {
  final capacity = members.fold<double>(0, (sum, m) => sum + m.weeklyCapacity);
  if (capacity == 0) return 0;
  final hours = inProgress.fold<double>(0, (sum, t) => sum + remainingHours(t));
  return hours / capacity;
}
