import '../models/member.dart';
import '../models/project.dart';
import '../models/task.dart';
import 'task_metrics.dart';

/// Frente usada para tarefas sem projeto na alocação da equipe.
const unassignedFront = 'Sem projeto';

/// Projetos com o total de tarefas e de tarefas concluídas de cada um.
List<Project> withTaskCounts(List<Project> projects, List<Task> tasks) {
  final total = <String, int>{};
  final completed = <String, int>{};
  for (final task in tasks) {
    final id = task.projectId;
    if (id == null) continue;
    total[id] = (total[id] ?? 0) + 1;
    if (task.status == TaskStatus.done) {
      completed[id] = (completed[id] ?? 0) + 1;
    }
  }
  return [
    for (final p in projects)
      p.withTaskCounts(
        total: total[p.id] ?? 0,
        completed: completed[p.id] ?? 0,
      ),
  ];
}

/// Clientes com a quantidade de projetos em andamento de cada um.
List<Client> withActiveProjects(List<Client> clients, List<Project> projects) {
  final active = <String, int>{};
  for (final project in projects) {
    final clientId = project.clientId;
    if (clientId == null || project.status != ProjectStatus.inProgress) {
      continue;
    }
    active[clientId] = (active[clientId] ?? 0) + 1;
  }
  return [for (final c in clients) c.withActiveProjects(active[c.id] ?? 0)];
}

/// Indicadores do topo da tela de projetos.
PortfolioSummary computePortfolioSummary({
  required List<Project> projects,
  required List<Task> tasks,
  required List<Member> members,
  required DateTime now,
}) {
  final active = projects
      .where((p) => p.status == ProjectStatus.inProgress)
      .toList();
  final thisMonth = DateTime(now.year, now.month);
  final nextMonth = DateTime(now.year, now.month + 1);
  final activeMembers = members.where((m) => m.active).toSet();
  final progressSum = active.fold<double>(0, (sum, p) => sum + p.progress);

  return PortfolioSummary(
    activeDemands: active.length,
    newThisMonth: projects
        .where((p) => isBetween(p.createdAt, thisMonth, nextMonth))
        .length,
    averageDeliveryRate: active.isEmpty ? 0 : progressSum / active.length,
    activeDevs: {
      for (final p in active) ...p.team,
    }.where(activeMembers.contains).length,
    totalDevs: activeMembers.length,
    onTimeRate: onTimeRate(tasks),
  );
}

/// Horas restantes das tarefas em andamento de cada pessoa, por projeto.
///
/// Tarefas com várias pessoas têm as horas divididas igualmente entre elas.
List<MemberAllocation> computeAllocations({
  required List<Task> tasks,
  required List<Member> members,
}) {
  final hoursByMember = <String, Map<String, double>>{};
  for (final task in tasks.where((t) => t.status == TaskStatus.inProgress)) {
    final people = task.links.people;
    final hours = remainingHours(task);
    if (people.isEmpty || hours == 0) continue;
    final front = task.projectName ?? unassignedFront;
    for (final person in people) {
      final byFront = hoursByMember.putIfAbsent(person.id, () => {});
      byFront[front] = (byFront[front] ?? 0) + hours / people.length;
    }
  }
  final allocations = [
    for (final m in members.where((m) => m.active))
      if (hoursByMember[m.id] case final hours?)
        MemberAllocation(
          member: m,
          hoursByFront: hours,
          capacityHours: m.weeklyCapacity,
        ),
  ];
  return allocations
    ..sort((a, b) => b.allocatedHours.compareTo(a.allocatedHours));
}
