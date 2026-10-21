import 'package:pocketbase/pocketbase.dart';

import '../../../../domain/models/member.dart';
import '../../../../domain/models/project.dart';
import '../../../../domain/models/task.dart';
import 'member_mappers.dart';
import 'record_utils.dart';

/// Relações expandidas ao buscar tarefas.
const taskExpand = 'owner,assignees,project.client';

/// Converte um registro de tarefa. [members] resolve os responsáveis das
/// subtarefas, que ficam guardadas em JSON.
Task taskFromRecord(
  RecordModel record, {
  Map<String, Member> members = const {},
}) {
  final project = expandedOne(record, 'project');
  final client = project == null ? null : expandedOne(project, 'client');
  final owner = expandedOne(record, 'owner');
  return Task(
    id: record.id,
    code: record.getStringValue('code'),
    title: record.getStringValue('title'),
    summary: '',
    status: enumByName(
      TaskStatus.values,
      record.getStringValue('status'),
      TaskStatus.pending,
    ),
    priority: enumByName(
      TaskPriority.values,
      record.getStringValue('priority'),
      TaskPriority.medium,
    ),
    category: record.getStringValue('category'),
    description: record.getStringValue('description'),
    sprint: nonEmpty(record.getStringValue('sprint')),
    projectId: project?.id,
    projectName: project?.getStringValue('name'),
    clientName: project == null
        ? null
        : client?.getStringValue('name') ?? Project.internalClientName,
    clientContract: nonEmpty(client?.getStringValue('contract') ?? ''),
    owner: owner == null ? null : memberFromRecord(owner),
    assignees: [
      for (final r in expanded(record, 'assignees')) memberFromRecord(r),
    ],
    startDate: parseDate(record.getStringValue('startDate')),
    dueDate: parseDate(record.getStringValue('dueDate')),
    completedAt: parseDate(record.getStringValue('completedAt')),
    estimatedHours: record.getDoubleValue('estimatedHours'),
    loggedHours: record.getDoubleValue('loggedHours'),
    tags: stringList(record.data['tags']),
    subtasks: _subtasks(record.data['subtasks'], members),
    commentCount: record.getIntValue('commentCount'),
    createdAt: parseDate(record.getStringValue('created')),
  );
}

List<Subtask> _subtasks(Object? json, Map<String, Member> members) {
  if (json is! List) return const [];
  return [
    for (final item in json)
      if (item is Map) _subtask(item, members),
  ];
}

Subtask _subtask(Map<dynamic, dynamic> json, Map<String, Member> members) {
  final code = json['code']?.toString() ?? '';
  final assigneeId = json['assignee']?.toString() ?? '';
  return Subtask(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    code: code.isEmpty ? null : code,
    stage: enumByName(
      SubtaskStage.values,
      json['stage']?.toString() ?? '',
      SubtaskStage.queued,
    ),
    assignee: members[assigneeId],
  );
}

Map<String, dynamic> _subtaskToJson(Subtask subtask) => {
  'id': subtask.id,
  'title': subtask.title,
  'code': subtask.code ?? '',
  'stage': subtask.stage.name,
  'assignee': subtask.assignee?.id ?? '',
};

/// Campos enviados ao criar ou atualizar uma tarefa.
Map<String, dynamic> taskToBody(Task task) => {
  'title': task.title.trim(),
  'description': task.description,
  'status': task.status.name,
  'priority': task.priority.name,
  'category': task.category.trim(),
  'sprint': task.sprint?.trim() ?? '',
  'project': task.projectId ?? '',
  'owner': task.owner?.id ?? '',
  'assignees': [for (final m in task.assignees) m.id],
  'startDate': formatDate(task.startDate),
  'dueDate': formatDate(task.dueDate),
  'completedAt': formatDate(task.completedAt),
  'estimatedHours': task.estimatedHours,
  'loggedHours': task.loggedHours,
  'tags': task.tags,
  'subtasks': [for (final s in task.subtasks) _subtaskToJson(s)],
};

TaskComment commentFromRecord(RecordModel record) {
  final author = expandedOne(record, 'author');
  return TaskComment(
    id: record.id,
    author: author == null
        ? unknownMember(record.getStringValue('author'))
        : memberFromRecord(author),
    body: record.getStringValue('body'),
    createdAt: parseDate(record.getStringValue('created')) ?? DateTime.now(),
  );
}

Attachment attachmentFromRecord(RecordModel record) {
  final name = record.getStringValue('name');
  final uploader = expandedOne(record, 'uploadedBy');
  return Attachment(
    id: record.id,
    name: name,
    sizeInBytes: record.getIntValue('size'),
    uploadedAt: parseDate(record.getStringValue('created')) ?? DateTime.now(),
    type: Attachment.typeFor(name),
    fileName: record.getStringValue('file'),
    uploadedBy: uploader == null ? null : memberFromRecord(uploader),
  );
}
