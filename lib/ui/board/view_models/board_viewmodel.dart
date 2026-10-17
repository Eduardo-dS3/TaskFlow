import 'package:flutter/foundation.dart';

import '../../../data/repositories/task/task_repository.dart';
import '../../../domain/models/member.dart';
import '../../../domain/models/task.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

enum BoardViewMode { kanban, list }

/// ViewModel do quadro Kanban.
///
/// Mantém o estado da tela (tarefas, filtros, modo de exibição) e expõe
/// [Command]s para as ações do usuário. Nenhuma lógica fica nos widgets.
class BoardViewModel extends ChangeNotifier {
  BoardViewModel({required this._taskRepository, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    load = Command0(_load)..execute();
    moveTask = Command1(_moveTask);
  }

  final TaskRepository _taskRepository;
  final DateTime Function() _clock;

  late final Command0<void> load;

  /// Move uma tarefa para outra coluna (arrastar e soltar).
  late final Command1<void, (Task, TaskStatus)> moveTask;

  SprintOverview? _overview;
  SprintOverview? get overview => _overview;

  List<Task> _tasks = [];

  DateTime get now => _clock();

  BoardViewMode _viewMode = BoardViewMode.kanban;
  BoardViewMode get viewMode => _viewMode;

  String _query = '';
  String get query => _query;

  Member? _assigneeFilter;
  Member? get assigneeFilter => _assigneeFilter;

  TaskPriority? _priorityFilter;
  TaskPriority? get priorityFilter => _priorityFilter;

  bool get hasActiveFilters =>
      _query.isNotEmpty || _assigneeFilter != null || _priorityFilter != null;

  /// Pessoas que aparecem em alguma tarefa, para o filtro "Responsável".
  List<Member> get assignees {
    final seen = <Member>{};
    for (final task in _tasks) {
      seen.addAll(task.assignees);
    }
    return seen.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  List<Task> get filteredTasks {
    final q = _query.trim().toLowerCase();
    return _tasks.where((task) {
      if (q.isNotEmpty &&
          !task.title.toLowerCase().contains(q) &&
          !task.category.toLowerCase().contains(q)) {
        return false;
      }
      if (_assigneeFilter != null &&
          !task.assignees.contains(_assigneeFilter)) {
        return false;
      }
      if (_priorityFilter != null && task.priority != _priorityFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Task> tasksFor(TaskStatus status) =>
      filteredTasks.where((t) => t.status == status).toList();

  /// Total exibido no cabeçalho da coluna (indicador da sprint).
  int columnCount(TaskStatus status) {
    final overview = _overview;
    if (overview == null || hasActiveFilters) return tasksFor(status).length;
    return switch (status) {
      TaskStatus.pending => overview.pending,
      TaskStatus.inProgress => overview.inProgress,
      TaskStatus.done => overview.done,
    };
  }

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

  Future<Result<void>> _load() async {
    final overviewResult = await _taskRepository.getSprintOverview();
    if (overviewResult is Error<SprintOverview>) {
      notifyListeners();
      return overviewResult;
    }
    _overview = (overviewResult as Ok<SprintOverview>).value;

    final tasksResult = await _taskRepository.getTasks();
    switch (tasksResult) {
      case Ok():
        _tasks = tasksResult.value;
      case Error():
        notifyListeners();
        return tasksResult;
    }
    notifyListeners();
    return const Result.ok(null);
  }

  Future<Result<void>> _moveTask((Task, TaskStatus) args) async {
    final (task, status) = args;
    if (task.status == status) return const Result.ok(null);

    // Atualização otimista: a UI reflete a mudança imediatamente.
    final previous = _tasks;
    final moved = task.withStatus(status, now: now);
    _tasks = [for (final t in _tasks) t.id == task.id ? moved : t];
    notifyListeners();

    final result = await _taskRepository.saveTask(moved);
    if (result is Error<Task>) {
      _tasks = previous;
      notifyListeners();
      return Result.error(result.error);
    }
    return const Result.ok(null);
  }
}
