import 'package:flutter/foundation.dart';

import '../../../data/repositories/task/task_repository.dart';
import '../../../domain/metrics/board_metrics.dart';
import '../../../domain/models/member.dart';
import '../../../domain/models/task.dart';
import '../../../domain/use_cases/load_board_use_case.dart';
import '../../../utils/command.dart';
import '../../../utils/csv.dart';
import '../../../utils/result.dart';
import '../../core/localization/formatters.dart';

enum BoardViewMode { kanban, list }

/// ViewModel do quadro Kanban.
///
/// Mantém o estado da tela (tarefas, filtros, modo de exibição) e expõe
/// [Command]s para as ações do usuário. Nenhuma lógica fica nos widgets.
class BoardViewModel extends ChangeNotifier {
  BoardViewModel({
    required this._loadBoard,
    required this._taskRepository,
    String initialQuery = '',
    DateTime Function()? clock,
  }) : _query = initialQuery,
       _clock = clock ?? DateTime.now {
    load = Command0(_load)..execute();
    moveTask = Command1(_moveTask);
  }

  final LoadBoardUseCase _loadBoard;
  final TaskRepository _taskRepository;
  final DateTime Function() _clock;

  late final Command0<void> load;

  /// Move uma tarefa para outra coluna (arrastar e soltar).
  late final Command1<void, (Task, TaskStatus)> moveTask;

  SprintOverview? _overview;
  SprintOverview? get overview => _overview;

  List<Task> _tasks = [];
  List<Member> _members = [];

  DateTime get now => _clock();

  /// Momento da última atualização dos dados.
  DateTime? _loadedAt;
  DateTime? get loadedAt => _loadedAt;

  BoardViewMode _viewMode = BoardViewMode.kanban;
  BoardViewMode get viewMode => _viewMode;

  String _query;
  String get query => _query;

  Member? _assigneeFilter;
  Member? get assigneeFilter => _assigneeFilter;

  TaskPriority? _priorityFilter;
  TaskPriority? get priorityFilter => _priorityFilter;

  /// Pessoas que aparecem em alguma tarefa, para o filtro "Responsável".
  List<Member> get assignees {
    final seen = {for (final task in _tasks) ...task.links.people};
    return seen.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  List<Task> get filteredTasks =>
      _tasks.where(_matchesQuery).where(_matchesFilters).toList();

  bool _matchesQuery(Task task) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [
      task.title,
      task.code,
      task.category,
      task.projectName ?? '',
    ].any((text) => text.toLowerCase().contains(q));
  }

  bool _matchesFilters(Task task) {
    final assignee = _assigneeFilter;
    final priority = _priorityFilter;
    return (assignee == null || task.links.people.contains(assignee)) &&
        (priority == null || task.priority == priority);
  }

  List<Task> tasksFor(TaskStatus status) =>
      filteredTasks.where((t) => t.status == status).toList();

  void setViewMode(BoardViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setAssigneeFilter(Member? member) {
    _assigneeFilter = member;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  /// Tarefas visíveis (com os filtros aplicados) em formato CSV.
  List<int> exportCsv() => buildCsv([
    [
      'Código',
      'Título',
      'Status',
      'Prioridade',
      'Categoria',
      'Projeto',
      'Cliente',
      'Responsável',
      'Participantes',
      'Prazo',
      'Concluída em',
      'Horas estimadas',
      'Horas registradas',
      'Etiquetas',
    ],
    for (final task in filteredTasks) _csvRow(task),
  ]);

  List<Object?> _csvRow(Task task) {
    String date(DateTime? value) =>
        value == null ? '' : Formatters.fullDate(value);
    return [
      task.code,
      task.title,
      Formatters.taskStatusSingular(task.status),
      Formatters.priority(task.priority),
      task.category,
      task.projectName,
      task.clientName,
      task.owner?.name,
      task.assignees.map((m) => m.name).join(', '),
      date(task.dueDate),
      date(task.completedAt),
      task.estimatedHours,
      task.loggedHours,
      task.tags.join(', '),
    ];
  }

  Future<Result<void>> _load() async {
    final result = await _loadBoard.load();
    switch (result) {
      case Ok(:final value):
        _tasks = value.tasks;
        _members = value.members;
        _overview = value.overview;
        _loadedAt = now;
      case Error():
        break;
    }
    notifyListeners();
    return result;
  }

  /// Recalcula os indicadores após uma alteração local.
  void _refreshOverview() {
    final current = _overview;
    if (current == null) return;
    _overview = computeSprintOverview(
      tasks: _tasks,
      members: _members,
      activeSprint: current.sprintName,
      now: now,
    );
  }

  Future<Result<void>> _moveTask((Task, TaskStatus) args) async {
    final (task, status) = args;
    if (task.status == status) return const Result.ok(null);

    // Atualização otimista: a UI reflete a mudança imediatamente.
    final previous = _tasks;
    final moved = task.withStatus(status, now: now);
    _tasks = [for (final t in _tasks) t.id == task.id ? moved : t];
    _refreshOverview();
    notifyListeners();

    final result = await _taskRepository.saveTask(moved);
    if (result is Error<Task>) {
      _tasks = previous;
      _refreshOverview();
      notifyListeners();
      return Result.error(result.error);
    }
    return const Result.ok(null);
  }
}
