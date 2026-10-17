import '../../../domain/models/task.dart';
import '../../../utils/result.dart';

/// Fonte da verdade para as tarefas do quadro.
abstract class TaskRepository {
  /// Indicadores consolidados da sprint ativa.
  Future<Result<SprintOverview>> getSprintOverview();

  /// Todas as tarefas visíveis no quadro.
  Future<Result<List<Task>>> getTasks();

  /// Tarefa completa (descrição, checklist, anexos, comentários).
  Future<Result<Task>> getTask(String id);

  /// Cria uma tarefa em branco pronta para edição.
  Future<Result<Task>> createDraft();

  /// Persiste a tarefa (criação ou edição).
  Future<Result<Task>> saveTask(Task task);

  Future<Result<void>> deleteTask(String id);

  /// Publica um comentário e devolve a tarefa atualizada.
  Future<Result<Task>> addComment(String taskId, String body);
}
