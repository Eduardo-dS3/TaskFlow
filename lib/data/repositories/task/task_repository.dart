import '../../../domain/models/task.dart';
import '../../../utils/result.dart';

/// Fonte da verdade para as tarefas do quadro.
abstract class TaskRepository {
  /// Todas as tarefas (sem comentários e anexos, para o quadro).
  Future<Result<List<Task>>> getTasks();

  /// Tarefa completa (descrição, checklist, anexos, comentários).
  Future<Result<Task>> getTask(String id);

  /// Cria a tarefa quando ainda não foi salva, ou atualiza a existente.
  Future<Result<Task>> saveTask(Task task);

  Future<Result<void>> deleteTask(String id);

  /// Publica um comentário do usuário logado.
  Future<Result<TaskComment>> addComment(String taskId, String body);

  /// Envia um arquivo e o anexa à tarefa.
  Future<Result<Attachment>> uploadAttachment(
    String taskId, {
    required String fileName,
    required List<int> bytes,
  });

  Future<Result<void>> deleteAttachment(Attachment attachment);

  /// Endereço temporário para abrir ou baixar o anexo.
  Future<Result<Uri>> attachmentUrl(Attachment attachment);
}
