import 'package:flutter/foundation.dart';

import '../../../data/repositories/project/project_repository.dart';
import '../../../data/repositories/settings/settings_repository.dart';
import '../../../data/repositories/task/task_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../domain/models/member.dart';
import '../../../domain/models/project.dart';
import '../../../domain/models/task.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// Arquivo escolhido pelo usuário para anexar.
typedef PickedFile = ({String name, List<int> bytes});

/// ViewModel da tela de cadastro e edição de tarefas.
///
/// Quando `taskId` é nulo, uma nova tarefa em branco é criada.
/// As edições são aplicadas a uma cópia de trabalho imutável ([task]) e só
/// são persistidas pelo comando [save]. Comentários e anexos são salvos na
/// hora, pois ficam em coleções próprias.
class TaskDetailsViewModel extends ChangeNotifier {
  TaskDetailsViewModel({
    required this._taskRepository,
    required this._userRepository,
    required this._projectRepository,
    required this._settingsRepository,
    this._taskId,
    this._initialStatus = TaskStatus.pending,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    load = Command0(_load)..execute();
    save = Command0(_save);
    delete = Command0(_delete);
    addComment = Command1(_addComment);
    uploadAttachment = Command1(_uploadAttachment);
    deleteAttachment = Command1(_deleteAttachment);
    openAttachment = Command1(_taskRepository.attachmentUrl);
  }

  final TaskRepository _taskRepository;
  final UserRepository _userRepository;
  final ProjectRepository _projectRepository;
  final SettingsRepository _settingsRepository;
  final String? _taskId;
  final TaskStatus _initialStatus;
  final DateTime Function() _clock;

  late final Command0<void> load;
  late final Command0<Task> save;
  late final Command0<void> delete;
  late final Command1<void, String> addComment;
  late final Command1<void, PickedFile> uploadAttachment;
  late final Command1<void, Attachment> deleteAttachment;

  /// Gera o endereço temporário para abrir um anexo.
  late final Command1<Uri, Attachment> openAttachment;

  Task? _task;
  Task? get task => _task;

  bool get isNew => _taskId == null;

  bool _dirty = false;

  /// Há alterações locais ainda não salvas.
  bool get dirty => _dirty;

  DateTime? _lastSavedAt;
  DateTime? get lastSavedAt => _lastSavedAt;

  Member? _currentUser;
  Member? get currentUser => _currentUser;

  List<Member> _members = [];

  /// Pessoas ativas que podem ser atribuídas.
  List<Member> get members => _members.where((m) => m.active).toList();

  List<Project> _projects = [];
  List<Project> get projects => _projects;

  DateTime get now => _clock();

  /// A pessoa pode excluir: administradores ou o responsável pela tarefa.
  bool get canDelete {
    final user = _currentUser;
    if (user == null || isNew) return false;
    return user.isAdmin || _task?.owner == user;
  }

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

  void setStatus(TaskStatus status) =>
      _update((t) => t.withStatus(status, now: now));

  void setPriority(TaskPriority priority) =>
      _update((t) => t.copyWith(priority: priority));

  void setCategory(String value) =>
      _update((t) => t.copyWith(category: value.trim()));

  void setSprint(String value) =>
      _update((t) => t.copyWith(sprint: value.trim()));

  /// Vincula a tarefa a um projeto (`null` desvincula).
  void setProject(String? projectId) {
    final project = _projects.where((p) => p.id == projectId).firstOrNull;
    _update(
      (t) => t.copyWith(
        links: t.links.withProject(
          id: project?.id,
          name: project?.name,
          clientName: project?.clientName,
        ),
      ),
    );
  }

  void setOwner(Member? member) =>
      _update((t) => t.copyWith(links: t.links.withOwner(member)));

  void setAssignees(List<Member> members) =>
      _update((t) => t.copyWith(links: t.links.withAssignees(members)));

  void setDates({required DateTime? start, required DateTime? due}) => _update(
    (t) => t.copyWith(
      schedule: t.schedule.withDates(startDate: start, dueDate: due),
    ),
  );

  void setHours({required double estimated, required double logged}) => _update(
    (t) => t.copyWith(
      schedule: t.schedule.withHours(
        estimatedHours: estimated,
        loggedHours: logged,
      ),
    ),
  );

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
    // Dados auxiliares: uma falha aqui não impede a edição da tarefa.
    final auxiliary = await (
      _userRepository.getCurrentUser(),
      _userRepository.getMembers(),
      _projectRepository.getProjects(),
    ).wait;
    if (auxiliary.$1 case Ok(:final value)) _currentUser = value;
    if (auxiliary.$2 case Ok(:final value)) _members = value;
    if (auxiliary.$3 case Ok(:final value)) _projects = value;

    final taskResult = await _loadTask();
    if (taskResult case Ok(:final value)) _task = value;
    _lastSavedAt = null;
    notifyListeners();
    return taskResult;
  }

  Future<Result<Task>> _loadTask() async {
    final id = _taskId;
    if (id != null) return _taskRepository.getTask(id);
    final settings = await _settingsRepository.getSettings();
    final sprint = switch (settings) {
      Ok(:final value) => value.activeSprint,
      Error() => '',
    };
    return Result.ok(
      Task.draft(
        now: now,
        owner: _currentUser,
        status: _initialStatus,
        sprint: sprint,
      ),
    );
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
      return Result.error(Exception('Escreva o comentário antes de enviar'));
    }
    final result = await _taskRepository.addComment(current.id, body.trim());
    switch (result) {
      case Ok(:final value):
        // Preserva as edições locais e incorpora só o novo comentário.
        _task = _task!.withComment(value);
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _uploadAttachment(PickedFile file) async {
    final current = _task;
    if (current == null || !current.isSaved) {
      return Result.error(Exception('Salve a tarefa antes de anexar arquivos'));
    }
    final result = await _taskRepository.uploadAttachment(
      current.id,
      fileName: file.name,
      bytes: file.bytes,
    );
    switch (result) {
      case Ok(:final value):
        _task = _task!.copyWith(attachments: [..._task!.attachments, value]);
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _deleteAttachment(Attachment attachment) async {
    final result = await _taskRepository.deleteAttachment(attachment);
    if (result case Ok()) {
      _task = _task!.copyWith(
        attachments: _task!.attachments
            .where((a) => a.id != attachment.id)
            .toList(),
      );
      notifyListeners();
    }
    return result;
  }
}
