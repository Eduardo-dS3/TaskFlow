import '../../../domain/models/task.dart';
import '../../../utils/result.dart';
import '../../services/local/local_data_service.dart';
import 'task_repository.dart';

/// Implementação de [TaskRepository] baseada no [LocalDataService].
class TaskRepositoryLocal implements TaskRepository {
  TaskRepositoryLocal({
    required LocalDataService localDataService,
    this._latency = const Duration(milliseconds: 300),
  }) : _service = localDataService;

  final LocalDataService _service;
  final Duration _latency;

  Future<void> _simulateNetwork() => Future<void>.delayed(_latency);

  @override
  Future<Result<SprintOverview>> getSprintOverview() async {
    await _simulateNetwork();
    return Result.ok(_service.sprintOverview);
  }

  @override
  Future<Result<List<Task>>> getTasks() async {
    await _simulateNetwork();
    return Result.ok(_service.tasks);
  }

  @override
  Future<Result<Task>> getTask(String id) async {
    await _simulateNetwork();
    final task = _service.findTask(id);
    if (task == null) {
      return Result.error(Exception('Tarefa $id não encontrada'));
    }
    return Result.ok(task);
  }

  @override
  Future<Result<Task>> createDraft() async {
    await _simulateNetwork();
    final code = _service.nextTaskCode();
    final now = DateTime.now();
    return Result.ok(
      Task(
        id: 't-${code.toLowerCase()}',
        code: code,
        title: '',
        summary: '',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        category: 'Geral',
        owner: _service.currentUser,
        startDate: DateTime(now.year, now.month, now.day),
        dueDate: DateTime(now.year, now.month, now.day + 7),
        estimatedHours: 8,
      ),
    );
  }

  @override
  Future<Result<Task>> saveTask(Task task) async {
    await _simulateNetwork();
    if (task.title.trim().isEmpty) {
      return Result.error(Exception('O título da tarefa é obrigatório'));
    }
    final summary = task.summary.isNotEmpty
        ? task.summary
        : task.description.split('\n').first;
    return Result.ok(_service.upsertTask(task.copyWith(summary: summary)));
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    await _simulateNetwork();
    if (!_service.deleteTask(id)) {
      return Result.error(Exception('Tarefa $id não encontrada'));
    }
    return const Result.ok(null);
  }

  @override
  Future<Result<Task>> addComment(String taskId, String body) async {
    await _simulateNetwork();
    final task = _service.findTask(taskId);
    if (task == null) {
      return Result.error(Exception('Salve a tarefa antes de comentar'));
    }
    final comment = TaskComment(
      id: 'c-${DateTime.now().microsecondsSinceEpoch}',
      author: _service.currentUser,
      body: body,
      createdAt: DateTime.now(),
    );
    return Result.ok(_service.upsertTask(task.withComment(comment)));
  }
}
