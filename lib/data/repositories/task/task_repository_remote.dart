import 'package:http/http.dart' as http;

import '../../../domain/models/member.dart';
import '../../../domain/models/task.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import '../../services/api/mappers/member_mappers.dart';
import '../../services/api/mappers/task_mappers.dart';
import 'task_repository.dart';

/// Implementação de [TaskRepository] no servidor (PocketBase).
class TaskRepositoryRemote implements TaskRepository {
  TaskRepositoryRemote({required ApiClient apiClient}) : _api = apiClient;

  static const _tasks = 'tasks';
  static const _comments = 'comments';
  static const _attachments = 'attachments';

  final ApiClient _api;

  @override
  Future<Result<List<Task>>> getTasks() async {
    final result = await _api.list(
      _tasks,
      sort: '-created',
      expand: taskExpand,
    );
    return switch (result) {
      Ok(:final value) => Result.ok([for (final r in value) taskFromRecord(r)]),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<Task>> getTask(String id) async {
    final byTask = _api.filter('task = {:id}', {'id': id});
    final results = await (
      _api.getOne(_tasks, id, expand: taskExpand),
      _api.list(_comments, filter: byTask, sort: '-created', expand: 'author'),
      _api.list(
        _attachments,
        filter: byTask,
        sort: 'created',
        expand: 'uploadedBy',
      ),
      _api.list(ApiClient.usersCollection),
    ).wait;

    switch (results) {
      case (
        Ok(value: final task),
        Ok(value: final comments),
        Ok(value: final attachments),
        Ok(value: final users),
      ):
        final members = <String, Member>{
          for (final u in users) u.id: memberFromRecord(u),
        };
        return Result.ok(
          taskFromRecord(task, members: members).copyWith(
            comments: [for (final c in comments) commentFromRecord(c)],
            attachments: [for (final a in attachments) attachmentFromRecord(a)],
          ),
        );
      case (Error(:final error), _, _, _) ||
          (_, Error(:final error), _, _) ||
          (_, _, Error(:final error), _) ||
          (_, _, _, Error(:final error)):
        return Result.error(error);
    }
  }

  @override
  Future<Result<Task>> saveTask(Task task) async {
    if (task.title.trim().isEmpty) {
      return Result.error(Exception('O título da tarefa é obrigatório'));
    }
    final body = taskToBody(task);
    final result = task.isSaved
        ? await _api.update(_tasks, task.id, body, expand: taskExpand)
        : await _api.create(_tasks, body, expand: taskExpand);
    return switch (result) {
      // Comentários e anexos ficam em coleções próprias: mantém os já
      // carregados e as subtarefas com os responsáveis resolvidos.
      Ok(:final value) => Result.ok(
        taskFromRecord(value).copyWith(
          subtasks: task.subtasks,
          comments: task.comments,
          attachments: task.attachments,
        ),
      ),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<void>> deleteTask(String id) => _api.delete(_tasks, id);

  @override
  Future<Result<TaskComment>> addComment(String taskId, String body) async {
    final result = await _api.create(_comments, {
      'task': taskId,
      'author': _api.authId,
      'body': body,
    }, expand: 'author');
    return switch (result) {
      Ok(:final value) => Result.ok(commentFromRecord(value)),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<Attachment>> uploadAttachment(
    String taskId, {
    required String fileName,
    required List<int> bytes,
  }) async {
    final result = await _api.create(
      _attachments,
      {
        'task': taskId,
        'uploadedBy': _api.authId,
        'name': fileName,
        'size': bytes.length,
      },
      files: [http.MultipartFile.fromBytes('file', bytes, filename: fileName)],
      expand: 'uploadedBy',
    );
    return switch (result) {
      Ok(:final value) => Result.ok(attachmentFromRecord(value)),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<void>> deleteAttachment(Attachment attachment) =>
      _api.delete(_attachments, attachment.id);

  @override
  Future<Result<Uri>> attachmentUrl(Attachment attachment) => _api
      .protectedFileUrl(_attachments, attachment.id, attachment.fileName ?? '');
}
