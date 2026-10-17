import 'member.dart';

enum TaskStatus { pending, inProgress, done }

enum TaskPriority { urgent, high, medium, low }

/// Estágio de uma subtarefa do checklist.
enum SubtaskStage { queued, readyForTest, resolved }

class Subtask {
  const Subtask({
    required this.id,
    required this.title,
    this.code,
    this.stage = SubtaskStage.queued,
    this.assignee,
  });

  final String id;
  final String title;

  /// Trecho técnico exibido em fonte monoespaçada dentro do título.
  final String? code;
  final SubtaskStage stage;
  final Member? assignee;

  bool get done => stage == SubtaskStage.resolved;

  Subtask copyWith({SubtaskStage? stage}) => Subtask(
    id: id,
    title: title,
    code: code,
    stage: stage ?? this.stage,
    assignee: assignee,
  );
}

enum AttachmentType { image, pdf, json }

class Attachment {
  const Attachment({
    required this.id,
    required this.name,
    required this.sizeInBytes,
    required this.uploadedAt,
    required this.type,
  });

  final String id;
  final String name;
  final int sizeInBytes;
  final DateTime uploadedAt;
  final AttachmentType type;
}

class TaskComment {
  const TaskComment({
    required this.id,
    required this.author,
    required this.body,
    required this.createdAt,
    this.commit,
    this.ciApproved = false,
  });

  final String id;
  final Member author;
  final String body;
  final DateTime createdAt;
  final String? commit;
  final bool ciApproved;
}

/// Tarefa do quadro Kanban.
class Task {
  const Task({
    required this.id,
    required this.code,
    required this.title,
    required this.summary,
    required this.status,
    required this.priority,
    required this.category,
    this.description = '',
    this.requirements = const [],
    this.payloadExample,
    this.sprint,
    this.projectName,
    this.clientName,
    this.clientContract,
    this.isPrivate = false,
    this.owner,
    this.assignees = const [],
    this.startDate,
    this.dueDate,
    this.completedAt,
    this.loggedHours = 0,
    this.estimatedHours = 0,
    this.progress,
    this.reviewed = false,
    this.tags = const [],
    this.subtasks = const [],
    this.attachments = const [],
    this.comments = const [],
    this.commentCount = 0,
  });

  final String id;

  /// Código legível (ex.: TK-1048).
  final String code;
  final String title;

  /// Resumo curto exibido no card do quadro.
  final String summary;
  final TaskStatus status;
  final TaskPriority priority;

  /// Frente de trabalho exibida como etiqueta no card (ex.: "DevOps").
  final String category;
  final String description;
  final List<String> requirements;
  final String? payloadExample;
  final String? sprint;
  final String? projectName;
  final String? clientName;
  final String? clientContract;
  final bool isPrivate;
  final Member? owner;
  final List<Member> assignees;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final double loggedHours;
  final double estimatedHours;

  /// Progresso explícito (0..1) exibido no card, quando houver.
  final double? progress;
  final bool reviewed;
  final List<String> tags;
  final List<Subtask> subtasks;
  final List<Attachment> attachments;
  final List<TaskComment> comments;

  /// Total de comentários (pode ser maior que [comments] carregados).
  final int commentCount;

  int get completedSubtasks => subtasks.where((s) => s.done).length;

  double get subtaskProgress =>
      subtasks.isEmpty ? 0 : completedSubtasks / subtasks.length;

  double get hoursProgress =>
      estimatedHours == 0 ? 0 : (loggedHours / estimatedHours).clamp(0, 1);

  /// Cópia com os campos editáveis alterados.
  ///
  /// Status e data de conclusão mudam juntos, por isso ficam em [withStatus].
  Task copyWith({
    String? title,
    String? summary,
    TaskPriority? priority,
    String? description,
    String? projectName,
    String? clientName,
    Member? owner,
    DateTime? startDate,
    DateTime? dueDate,
    List<String>? tags,
    List<Subtask>? subtasks,
    List<TaskComment>? comments,
    int? commentCount,
  }) {
    return Task(
      id: id,
      code: code,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      status: status,
      priority: priority ?? this.priority,
      category: category,
      description: description ?? this.description,
      requirements: requirements,
      payloadExample: payloadExample,
      sprint: sprint,
      projectName: projectName ?? this.projectName,
      clientName: clientName ?? this.clientName,
      clientContract: clientContract,
      isPrivate: isPrivate,
      owner: owner ?? this.owner,
      assignees: assignees,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt,
      loggedHours: loggedHours,
      estimatedHours: estimatedHours,
      progress: progress,
      reviewed: reviewed,
      tags: tags ?? this.tags,
      subtasks: subtasks ?? this.subtasks,
      attachments: attachments,
      comments: comments ?? this.comments,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  /// Cópia com novo [status]. A data de conclusão passa a ser [now] quando a
  /// tarefa é concluída e é limpa quando ela sai de "Concluídas".
  Task withStatus(TaskStatus status, {required DateTime now}) {
    return Task(
      id: id,
      code: code,
      title: title,
      summary: summary,
      status: status,
      priority: priority,
      category: category,
      description: description,
      requirements: requirements,
      payloadExample: payloadExample,
      sprint: sprint,
      projectName: projectName,
      clientName: clientName,
      clientContract: clientContract,
      isPrivate: isPrivate,
      owner: owner,
      assignees: assignees,
      startDate: startDate,
      dueDate: dueDate,
      completedAt: status == TaskStatus.done ? now : null,
      loggedHours: loggedHours,
      estimatedHours: estimatedHours,
      progress: progress,
      reviewed: reviewed,
      tags: tags,
      subtasks: subtasks,
      attachments: attachments,
      comments: comments,
      commentCount: commentCount,
    );
  }

  /// Cópia com [comment] no topo da discussão.
  Task withComment(TaskComment comment) => copyWith(
    comments: [comment, ...comments],
    commentCount: commentCount + 1,
  );
}

/// Indicadores consolidados da sprint ativa (cards do topo do quadro).
class SprintOverview {
  const SprintOverview({
    required this.sprintName,
    required this.totalTasks,
    required this.monthGrowth,
    required this.teamCapacity,
    required this.pending,
    required this.blockers,
    required this.inProgress,
    required this.allocatedDevs,
    required this.done,
    required this.onTimeRate,
    required this.onlineMembers,
  });

  final String sprintName;
  final int totalTasks;
  final double monthGrowth;
  final double teamCapacity;
  final int pending;
  final int blockers;
  final int inProgress;
  final int allocatedDevs;
  final int done;
  final double onTimeRate;
  final List<Member> onlineMembers;
}
