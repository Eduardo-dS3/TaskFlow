import 'package:pocketbase/pocketbase.dart';

import '../../../../domain/models/project.dart';
import '../../../../domain/models/task.dart';
import 'member_mappers.dart';
import 'record_utils.dart';

/// Relações expandidas ao buscar projetos.
const projectExpand = 'client,team';

Project projectFromRecord(RecordModel record) {
  final client = expandedOne(record, 'client');
  return Project(
    id: record.id,
    name: record.getStringValue('name'),
    clientId: client?.id,
    clientName: client?.getStringValue('name') ?? Project.internalClientName,
    description: record.getStringValue('description'),
    status: enumByName(
      ProjectStatus.values,
      record.getStringValue('status'),
      ProjectStatus.inProgress,
    ),
    kind: enumByName(
      ProjectKind.values,
      record.getStringValue('kind'),
      ProjectKind.other,
    ),
    team: [for (final r in expanded(record, 'team')) memberFromRecord(r)],
    priority: enumOrNull(
      TaskPriority.values,
      record.getStringValue('priority'),
    ),
    badge: nonEmpty(record.getStringValue('badge')),
    note: nonEmpty(record.getStringValue('note')),
    dueDate: parseDate(record.getStringValue('dueDate')),
    finishedAt: parseDate(record.getStringValue('finishedAt')),
    createdAt: parseDate(record.getStringValue('created')),
  );
}

Map<String, dynamic> projectToBody(Project project) => {
  'name': project.name.trim(),
  'client': project.clientId ?? '',
  'description': project.description.trim(),
  'status': project.status.name,
  'priority': project.priority?.name ?? '',
  'kind': project.kind.name,
  'badge': project.badge?.trim() ?? '',
  'note': project.note?.trim() ?? '',
  'dueDate': formatDate(project.dueDate),
  'team': [for (final m in project.team) m.id],
};

Client clientFromRecord(RecordModel record) => Client(
  id: record.id,
  name: record.getStringValue('name'),
  tier: enumByName(
    ClientTier.values,
    record.getStringValue('tier'),
    ClientTier.pro,
  ),
  sla: record.getStringValue('sla'),
  contract: record.getStringValue('contract'),
);

Map<String, dynamic> clientToBody(Client client) => {
  'name': client.name.trim(),
  'tier': client.tier.name,
  'sla': client.sla.trim(),
  'contract': client.contract.trim(),
};
