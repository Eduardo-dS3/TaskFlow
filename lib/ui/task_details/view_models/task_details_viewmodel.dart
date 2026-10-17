import 'package:flutter/foundation.dart';

import '../../../data/repositories/project/project_repository.dart';
import '../../../data/repositories/task/task_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../domain/models/member.dart';
import '../../../domain/models/project.dart';
import '../../../domain/models/task.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// ViewModel da tela de cadastro e edição de tarefas.
///
/// Quando `taskId` é nulo, uma nova tarefa em branco é criada.
/// As edições são aplicadas a uma cópia de trabalho imutável ([task]) e só
/// são persistidas pelo comando [save].
class TaskDetailsViewModel extends ChangeNotifier {
  TaskDetailsViewModel({
    required this._taskRepository,
    required this._userRepository,
    required this._projectRepository,
    this._taskId,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    load = Command0(_load)..execute();
    save = Command0(_save);
    delete = Command0(_delete);
    addComment = Command1(_addComment);
  }

  final TaskRepository _taskRepository;
  final UserRepository _userRepository;
  final ProjectRepository _projectRepository;
  final String? _taskId;
  final DateTime Function() _clock;

  late final Command0<void> load;
  late final Command0<Task> save;
  late final Command0<void> delete;
  late final Command1<void, String> addComment;

  Task? _task;
  Task? get task => _task;

  bool get isNew => _taskId == null;

  bool _dirty = false;

  /// Há alterações locais ainda não salvas.
  bool get dirty => _dirty;

  DateTime? _lastSavedAt;
  DateTime? get lastSavedAt => _lastSavedAt;

  List<Member> _members = [];
  List<Member> get members => _members;

  List<Project> _projects = [];
  List<String> get projectNames => [
    if (_task?.projectName case final current?
        when !_projects.any((p) => p.name == current))
      current,
    for (final p in _projects) p.name,
  ];

  DateTime get now => _clock();

  // ---------------------------------------------------------------------------
  // Edição
  // ---------------------------------------------------------------------------

  void _update(Task Function(Task task) change) {
    final current = _task;
    if (current == null) return;
    _task = change(current);
    _dirty = true;
    notifyListeners();
  }

  void updateTitle(String value) => _update((t) => t.copyWith(title: value));

  void updateDescription(String value) =>
      _update((t) => t.copyWith(description: value));

  void setStatus(TaskStatus status) => _update(
    (t) => t.copyWith(
      status: status,
      completedAt: status == TaskStatus.done ? now : null,
    ),
  );

  void setPriority(TaskPriority priority) =>
      _update((t) => t.copyWith(priority: priority));

  void setProject(String projectName) {
    final project = _projects.where((p) => p.name == projectName).firstOrNull;
    _update(
      (t) =>
          t.copyWith(projectName: projectName, clientName: project?.clientName),
    );
  }

  void setOwner(Member member) => _update((t) => t.copyWith(owner: member));

  void setStartDate(DateTime date) =>
      _update((t) => t.copyWith(startDate: date));

  void setDueDate(DateTime date) => _update((t) => t.copyWith(dueDate: date));

  void addTag(String value) {
    final tag = value.trim().replaceFirst(RegExp('^#'), '');
    if (tag.isEmpty || (_task?.tags.contains(tag) ?? true)) return;
    _update((t) => t.copyWith(tags: [...t.tags, tag]));
  }

  void removeTag(String tag) =>
      _update((t) => t.copyWith(tags: t.tags.where((x) => x != tag).toList()));

  void toggleSubtask(String subtaskId) => _update(
    (t) => t.copyWith(
      subtasks: [
        for (final s in t.subtasks)
          if (s.id == subtaskId)
            s.copyWith(
              stage: s.done ? SubtaskStage.queued : SubtaskStage.resolved,
            )
          else
            s,
      ],
    ),
  );

  void addSubtask(String title) {
    if (title.trim().isEmpty) return;
    _update(
      (t) => t.copyWith(
        subtasks: [
          ...t.subtasks,
          Subtask(id: 'st-${now.microsecondsSinceEpoch}', title: title.trim()),
        ],
      ),
    );
  }

  void removeSubtask(String subtaskId) => _update(
    (t) => t.copyWith(
      subtasks: t.subtasks.where((s) => s.id != subtaskId).toList(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Comandos
  // ---------------------------------------------------------------------------

  Future<Result<void>> _load() async {
    final taskResult = _taskId == null
        ? await _taskRepository.createDraft()
        : await _taskRepository.getTask(_taskId);

    switch (taskResult) {
      case Ok():
        _task = taskResult.value;
      case Error():
        notifyListeners();
        return taskResult;
    }

    // Dados auxiliares: uma falha aqui não impede a edição da tarefa.
    if (await _userRepository.getMembers() case Ok(:final value)) {
      _members = value;
    }
    if (await _projectRepository.getProjects() case Ok(:final value)) {
      _projects = value;
    }

    _lastSavedAt = isNew ? null : now.subtract(const Duration(minutes: 2));
    notifyListeners();
    return const Result.ok(null);
  }

  Future<Result<Task>> _save() async {
    final current = _task;
    if (current == null) return Result.error(Exception('Nada para salvar'));

    final result = await _taskRepository.saveTask(current);
    if (result case Ok(:final value)) {
      _task = value;
      _dirty = false;
      _lastSavedAt = now;
    }
    notifyListeners();
    return result;
  }

  Future<Result<void>> _delete() async {
    final current = _task;
    if (current == null || isNew) return const Result.ok(null);
    return _taskRepository.deleteTask(current.id);
  }

  Future<Result<void>> _addComment(String body) async {
    final current = _task;
    if (current == null || body.trim().isEmpty) {
      return Result.error(Exception('Comentário vazio'));
    }
    final result = await _taskRepository.addComment(current.id, body.trim());
    switch (result) {
      case Ok():
        // Preserva edições locais e incorpora apenas os comentários.
        _task = current.copyWith(
          comments: result.value.comments,
          commentCount: result.value.commentCount,
        );
        notifyListeners();
        return const Result.ok(null);
      case Error():
        return Result.error(result.error);
    }
  }
}
