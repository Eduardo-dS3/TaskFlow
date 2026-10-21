import '../models/member.dart';
import '../models/task.dart';

/// Regras de prazo e esforço compartilhadas pelos indicadores.

/// Indica se [date] está no intervalo [start, end).
bool isBetween(DateTime? date, DateTime start, DateTime end) =>
    date != null && !date.isBefore(start) && date.isBefore(end);

/// Início do dia de [date].
DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

/// A tarefa foi concluída até o fim do dia do prazo.
bool completedOnTime(Task task) {
  final due = task.dueDate;
  final completed = task.completedAt;
  if (due == null || completed == null) return false;
  return completed.isBefore(DateTime(due.year, due.month, due.day + 1));
}

/// Fração das tarefas concluídas (com prazo) que foram entregues no prazo.
///
/// Retorna `null` quando nenhuma tarefa concluída tinha prazo.
double? onTimeRate(Iterable<Task> tasks) {
  final measurable = tasks
      .where((t) => t.status == TaskStatus.done && t.dueDate != null)
      .where((t) => t.completedAt != null)
      .toList();
  if (measurable.isEmpty) return null;
  return measurable.where(completedOnTime).length / measurable.length;
}

/// Horas estimadas que ainda faltam na tarefa.
double remainingHours(Task task) {
  final remaining = task.estimatedHours - task.loggedHours;
  return remaining > 0 ? remaining : 0;
}

/// A pessoa é responsável ou participante da tarefa.
bool involves(Task task, Member member) => task.links.people.contains(member);

/// Contagem de tarefas por status, incluindo status sem tarefas.
Map<TaskStatus, int> countByStatus(Iterable<Task> tasks) => {
  for (final status in TaskStatus.values)
    status: tasks.where((t) => t.status == status).length,
};

/// Contagem de tarefas por prioridade, incluindo prioridades sem tarefas.
Map<TaskPriority, int> countByPriority(Iterable<Task> tasks) => {
  for (final priority in TaskPriority.values)
    priority: tasks.where((t) => t.priority == priority).length,
};
