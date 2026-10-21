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

enum AttachmentType { image, pdf, json, other }

class Attachment {
  const Attachment({
    required this.id,
    required this.name,
    required this.sizeInBytes,
    required this.uploadedAt,
    required this.type,
    this.fileName,
    this.uploadedBy,
  });

  final String id;

  /// Nome original do arquivo enviado.
  final String name;
  final int sizeInBytes;
  final DateTime uploadedAt;
  final AttachmentType type;

  /// Nome do arquivo armazenado no servidor.
  final String? fileName;
  final Member? uploadedBy;

  static AttachmentType typeFor(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return switch (extension) {
      'png' || 'jpg' || 'jpeg' || 'gif' || 'webp' => AttachmentType.image,
      'pdf' => AttachmentType.pdf,
      'json' => AttachmentType.json,
      _ => AttachmentType.other,
    };
  }
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

/// Datas e esforço (planejado e registrado) de uma tarefa.
class TaskSchedule {
  const TaskSchedule({
    this.startDate,
    this.dueDate,
    this.completedAt,
    this.estimatedHours = 0,
    this.loggedHours = 0,
  });

  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final double estimatedHours;
  final double loggedHours;

  double get hoursProgress =>
      estimatedHours == 0 ? 0 : (loggedHours / estimatedHours).clamp(0, 1);

  /// Cópia com novas datas de planejamento (`null` remove a data).
  TaskSchedule withDates({
    required DateTime? startDate,
    required DateTime? dueDate,
  }) => TaskSchedule(
    startDate: startDate,
    dueDate: dueDate,
    completedAt: completedAt,
    estimatedHours: estimatedHours,
    loggedHours: loggedHours,
  );

  TaskSchedule withHours({
    required double estimatedHours,
    required double loggedHours,
  }) => TaskSchedule(
    startDate: startDate,
    dueDate: dueDate,
    completedAt: completedAt,
    estimatedHours: estimatedHours,
    loggedHours: loggedHours,
  );

  TaskSchedule withCompletion(DateTime? completedAt) => TaskSchedule(
    startDate: startDate,
    dueDate: dueDate,
    completedAt: completedAt,
    estimatedHours: estimatedHours,
    loggedHours: loggedHours,
  );
}

/// Projeto, cliente e pessoas ligadas a uma tarefa.
class TaskLinks {
  const TaskLinks({
    this.projectId,
    this.projectName,
    this.clientName,
    this.clientContract,
    this.owner,
    this.assignees = const [],
  });

  final String? projectId;
  final String? projectName;
  final String? clientName;
  final String? clientContract;

  /// Responsável principal.
  final Member? owner;

  /// Demais participantes.
  final List<Member> assignees;

  /// Responsável e participantes, sem repetição.
  List<Member> get people => {?owner, ...assignees}.toList();

  /// Cópia ligada a outro projeto (`id` nulo desvincula a tarefa).
  TaskLinks withProject({
    required String? id,
    required String? name,
    required String? clientName,
  }) => TaskLinks(
    projectId: id,
    projectName: name,
    clientName: clientName,
    clientContract: id == projectId ? clientContract : null,
    owner: owner,
    assignees: assignees,
  );

  TaskLinks withOwner(Member? owner) => TaskLinks(
    projectId: projectId,
    projectName: projectName,
    clientName: clientName,
    clientContract: clientContract,
    owner: owner,
    assignees: assignees,
  );

  TaskLinks withAssignees(List<Member> assignees) => TaskLinks(
    projectId: projectId,
    projectName: projectName,
    clientName: clientName,
    clientContract: clientContract,
    owner: owner,
    assignees: assignees,
  );
}

/// Tarefa do quadro Kanban.
class Task {
  Task({
    required String id,
    required String code,
    required String title,
    required String summary,
    required TaskStatus status,
    required TaskPriority priority,
    required String category,
    String description = '',
    List<String> requirements = const [],
    String? payloadExample,
    String? sprint,
    String? projectId,
    String? projectName,
    String? clientName,
    String? clientContract,
    bool isPrivate = false,
    Member? owner,
    List<Member> assignees = const [],
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completedAt,
    double loggedHours = 0,
    double estimatedHours = 0,
    double? progress,
    bool reviewed = false,
    List<String> tags = const [],
    List<Subtask> subtasks = const [],
    List<Attachment> attachments = const [],
    List<TaskComment> comments = const [],
    int commentCount = 0,
    DateTime? createdAt,
  }) : this._(
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
         isPrivate: isPrivate,
         progress: progress,
         reviewed: reviewed,
         tags: tags,
         subtasks: subtasks,
         attachments: attachments,
         comments: comments,
         commentCount: commentCount,
         createdAt: createdAt,
         schedule: TaskSchedule(
           startDate: startDate,
           dueDate: dueDate,
           completedAt: completedAt,
           estimatedHours: estimatedHours,
           loggedHours: loggedHours,
         ),
         links: TaskLinks(
           projectId: projectId,
           projectName: projectName,
           clientName: clientName,
           clientContract: clientContract,
           owner: owner,
           assignees: assignees,
         ),
       );

  /// Tarefa em branco para o formulário de cadastro: começa hoje, prazo em
  /// uma semana e o usuário logado como responsável.
  factory Task.draft({
    required DateTime now,
    Member? owner,
    TaskStatus status = TaskStatus.pending,
    String sprint = '',
  }) {
    final today = DateTime(now.year, now.month, now.day);
    return Task(
      id: '',
      code: 'NOVA',
      title: '',
      summary: '',
      status: status,
      priority: TaskPriority.medium,
      category: 'Geral',
      sprint: sprint.isEmpty ? null : sprint,
      owner: owner,
      startDate: today,
      dueDate: today.add(const Duration(days: 7)),
      completedAt: status == TaskStatus.done ? now : null,
      estimatedHours: 8,
    );
  }

  const Task._({
    required this.id,
    required this.code,
    required this.title,
    required this.summary,
    required this.status,
    required this.priority,
    required this.category,
    required this.description,
    required this.requirements,
    required this.payloadExample,
    required this.sprint,
    required this.isPrivate,
    required this.progress,
    required this.reviewed,
    required this.tags,
    required this.subtasks,
    required this.attachments,
    required this.comments,
    required this.commentCount,
    required this.createdAt,
    required this.schedule,
    required this.links,
  });

  /// Identificador no banco. Vazio enquanto a tarefa ainda não foi salva.
  final String id;

  /// Código legível (ex.: TK-1048).
  final String code;
  final String title;

  /// Resumo curto exibido no card quando não há descrição.
  final String summary;
  final TaskStatus status;
  final TaskPriority priority;

  /// Frente de trabalho exibida como etiqueta no card (ex.: "DevOps").
  final String category;
  final String description;
  final List<String> requirements;
  final String? payloadExample;
  final String? sprint;
  final bool isPrivate;

  /// Progresso explícito (0..1) exibido no card, quando houver.
  final double? progress;
  final bool reviewed;
  final List<String> tags;
  final List<Subtask> subtasks;
  final List<Attachment> attachments;
  final List<TaskComment> comments;

  /// Total de comentários (pode ser maior que [comments] carregados).
  final int commentCount;
  final DateTime? createdAt;
  final TaskSchedule schedule;
  final TaskLinks links;

  bool get isSaved => id.isNotEmpty;

  DateTime? get startDate => schedule.startDate;
  DateTime? get dueDate => schedule.dueDate;
  DateTime? get completedAt => schedule.completedAt;
  double get estimatedHours => schedule.estimatedHours;
  double get loggedHours => schedule.loggedHours;
  double get hoursProgress => schedule.hoursProgress;

  String? get projectId => links.projectId;
  String? get projectName => links.projectName;
  String? get clientName => links.clientName;
  String? get clientContract => links.clientContract;
  Member? get owner => links.owner;
  List<Member> get assignees => links.assignees;

  int get completedSubtasks => subtasks.where((s) => s.done).length;

  double get subtaskProgress =>
      subtasks.isEmpty ? 0 : completedSubtasks / subtasks.length;

  /// Texto curto para o card: primeira linha da descrição ou o resumo.
  String get excerpt {
    final firstLine = description
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');
    return firstLine.isNotEmpty ? firstLine : summary;
  }

  /// A tarefa está aberta e o prazo terminou antes de hoje.
  bool isOverdue(DateTime now) {
    final due = dueDate;
    if (status == TaskStatus.done || due == null) return false;
    return due.isBefore(DateTime(now.year, now.month, now.day));
  }

  /// Cópia com os campos informados alterados.
  ///
  /// Para mudar o status use [withStatus], que mantém a data de conclusão
  /// coerente.
  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? category,
    String? sprint,
    TaskSchedule? schedule,
    TaskLinks? links,
    List<String>? tags,
    List<Subtask>? subtasks,
    List<Attachment>? attachments,
    List<TaskComment>? comments,
    int? commentCount,
  }) {
    return Task._(
      id: id,
      code: code,
      title: title ?? this.title,
      summary: summary,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      description: description ?? this.description,
      requirements: requirements,
      payloadExample: payloadExample,
      sprint: sprint ?? this.sprint,
      isPrivate: isPrivate,
      progress: progress,
      reviewed: reviewed,
      tags: tags ?? this.tags,
      subtasks: subtasks ?? this.subtasks,
      attachments: attachments ?? this.attachments,
      comments: comments ?? this.comments,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt,
      schedule: schedule ?? this.schedule,
      links: links ?? this.links,
    );
  }

  /// Cópia com novo [status]. A data de conclusão passa a ser [now] quando a
  /// tarefa é concluída e é limpa quando ela sai de "Concluídas".
  Task withStatus(TaskStatus status, {required DateTime now}) {
    final completedAt = switch (status) {
      TaskStatus.done when this.status == TaskStatus.done => this.completedAt,
      TaskStatus.done => now,
      _ => null,
    };
    return copyWith(
      status: status,
      schedule: schedule.withCompletion(completedAt),
    );
  }

  /// Cópia com [comment] no topo da discussão.
  Task withComment(TaskComment comment) => copyWith(
    comments: [comment, ...comments],
    commentCount: commentCount + 1,
  );
}

/// Indicadores consolidados do quadro (cards do topo).
class SprintOverview {
  const SprintOverview({
    required this.sprintName,
    required this.totalTasks,
    required this.monthGrowth,
    required this.teamCapacity,
    required this.pending,
    required this.overdue,
    required this.inProgress,
    required this.allocatedDevs,
    required this.done,
    required this.onTimeRate,
    required this.onlineMembers,
  });

  final String sprintName;
  final int totalTasks;

  /// Variação de tarefas criadas neste mês em relação ao anterior.
  final double monthGrowth;

  /// Horas estimadas em andamento sobre a capacidade semanal da equipe.
  final double teamCapacity;
  final int pending;

  /// Tarefas abertas com prazo vencido.
  final int overdue;
  final int inProgress;
  final int allocatedDevs;
  final int done;

  /// Concluídas dentro do prazo; `null` quando nenhuma tinha prazo.
  final double? onTimeRate;
  final List<Member> onlineMembers;
}
