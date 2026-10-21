import '../../../domain/models/task.dart';
import '../../../utils/result.dart';
import '../../services/local/local_data_service.dart';
import 'task_repository.dart';

/// Implementação de [TaskRepository] em memória (demonstração e testes).
class TaskRepositoryLocal implements TaskRepository {
  TaskRepositoryLocal({
    required LocalDataService localDataService,
    this._latency = const Duration(milliseconds: 300),
  }) : _service = localDataService;

  final LocalDataService _service;
  final Duration _latency;

  Future<void> _simulateNetwork() => Future<void>.delayed(_latency);

  Result<Task> _taskOrError(String id) {
    final task = _service.findTask(id);
    if (task == null) return Result.error(Exception('Tarefa não encontrada'));
    return Result.ok(task);
  }

  @override
  Future<Result<List<Task>>> getTasks() async {
    await _simulateNetwork();
    return Result.ok(_service.tasks);
  }

  @override
  Future<Result<Task>> getTask(String id) async {
    await _simulateNetwork();
    return _taskOrError(id);
  }

  @override
  Future<Result<Task>> saveTask(Task task) async {
    await _simulateNetwork();
    if (task.title.trim().isEmpty) {
      return Result.error(Exception('O título da tarefa é obrigatório'));
    }
    if (task.isSaved) return Result.ok(_service.upsertTask(task));

    final created =
        Task(
          id: _service.newId('t'),
          code: _service.nextTaskCode(),
          title: task.title,
          summary: task.summary,
          status: task.status,
          priority: task.priority,
          category: task.category,
          description: task.description,
          createdAt: _service.now,
        ).copyWith(
          sprint: task.sprint,
          schedule: task.schedule,
          links: task.links,
          tags: task.tags,
          subtasks: task.subtasks,
        );
    return Result.ok(_service.upsertTask(created));
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    await _simulateNetwork();
    if (!_service.deleteTask(id)) {
      return Result.error(Exception('Tarefa não encontrada'));
    }
    return const Result.ok(null);
  }

  @override
  Future<Result<TaskComment>> addComment(String taskId, String body) async {
    await _simulateNetwork();
    final task = _service.findTask(taskId);
    if (task == null) {
      return Result.error(Exception('Salve a tarefa antes de comentar'));
    }
    final comment = TaskComment(
      id: _service.newId('c'),
      author: _service.currentUser,
      body: body,
      createdAt: _service.now,
    );
    _service.upsertTask(task.withComment(comment));
    return Result.ok(comment);
  }

  @override
  Future<Result<Attachment>> uploadAttachment(
    String taskId, {
    required String fileName,
    required List<int> bytes,
  }) async {
    await _simulateNetwork();
    final task = _service.findTask(taskId);
    if (task == null) {
      return Result.error(Exception('Salve a tarefa antes de anexar arquivos'));
    }
    final attachment = Attachment(
      id: _service.newId('a'),
      name: fileName,
      sizeInBytes: bytes.length,
      uploadedAt: _service.now,
      type: Attachment.typeFor(fileName),
      uploadedBy: _service.currentUser,
    );
    _service.attachmentBytes[attachment.id] = bytes;
    _service.upsertTask(
      task.copyWith(attachments: [...task.attachments, attachment]),
    );
    return Result.ok(attachment);
  }

  @override
  Future<Result<void>> deleteAttachment(Attachment attachment) async {
    await _simulateNetwork();
    for (final task in _service.tasks) {
      if (task.attachments.any((a) => a.id == attachment.id)) {
        _service.upsertTask(
          task.copyWith(
            attachments: task.attachments
                .where((a) => a.id != attachment.id)
                .toList(),
          ),
        );
      }
    }
    _service.attachmentBytes.remove(attachment.id);
    return const Result.ok(null);
  }

  @override
  Future<Result<Uri>> attachmentUrl(Attachment attachment) async {
    final bytes = _service.attachmentBytes[attachment.id];
    if (bytes == null) {
      return Result.error(
        Exception('Arquivo de exemplo: não há conteúdo para abrir'),
      );
    }
    return Result.ok(Uri.dataFromBytes(bytes));
  }
}
