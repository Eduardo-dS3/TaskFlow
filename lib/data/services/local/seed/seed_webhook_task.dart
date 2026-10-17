import '../../../../domain/models/member.dart';
import '../../../../domain/models/task.dart';
import 'seed_calendar.dart';
import 'seed_members.dart';

/// Tarefa TK-1048, exibida em detalhes no protótipo de cadastro e edição.
Task seedWebhookTask(SeedCalendar calendar) => Task(
  id: 't-1048',
  code: 'TK-1048',
  title: 'Integração de Webhooks e Pagamentos Recorrentes',
  summary:
      'Tratamento de eventos assíncronos para pagamentos aprovados, '
      'estornos e renovações.',
  status: TaskStatus.inProgress,
  priority: TaskPriority.high,
  category: 'Financeiro',
  isPrivate: true,
  sprint: 'Sprint 42 (Q4 FinTech)',
  projectName: 'Fintech Core v2',
  clientName: 'Banco Alfa & Parceiros',
  clientContract: 'Contrato Enterprise #490',
  owner: _owner,
  assignees: const [SeedMembers.rafael],
  description: _description,
  requirements: _requirements,
  payloadExample: _payloadExample,
  startDate: calendar.days(-10),
  dueDate: calendar.days(11),
  loggedHours: 14,
  estimatedHours: 20,
  tags: const ['Backend', 'Fintech', 'Stripe', 'Alta Prioridade'],
  subtasks: _subtasks,
  attachments: _attachments(calendar),
  comments: _comments(calendar),
  commentCount: 3,
);

const _owner = Member(
  id: 'u-mariana',
  name: 'Mariana Souza',
  role: 'Tech Lead / PM',
);

const _description =
    'Implementar o endpoint receptor seguro para os eventos transacionais '
    'providos pelo gateway Stripe API v2023-10-16. O foco é a sincronização '
    'instantânea do status de subscrições ativas e baixa de faturas B2B do '
    'cliente Banco Alfa.';

const _requirements = [
  'Garantir validação rigorosa de assinatura HMAC-SHA256 no cabeçalho '
      '`Stripe-Signature`.',
  'Implementar tolerância de drift de relógio de até 300 segundos para '
      'mitigação de ataques de repetição (Replay Attacks).',
  'Idempotência garantida via Redis com TTL de 24 horas usando o '
      '`event.id`.',
];

const _payloadExample = '''
{
  "id": "evt_1OcX9E2eZvKYlo2CLvK9Q8Zp",
  "object": "event",
  "api_version": "2023-10-16",
  "type": "customer.subscription.updated",
  "data": {
    "object": {
      "id": "sub_1OcX9D2eZvKYlo2CPuX9j11K",
      "customer": "cus_PF8mP2eXo",
      "status": "active",
      "current_period_end": 1730160000
    }
  }
}''';

const _subtasks = [
  Subtask(
    id: 'st-1',
    title: 'Criar rota de webhook no servidor',
    code: '/api/v1/stripe',
    stage: SubtaskStage.resolved,
    assignee: SeedMembers.lucasPeixoto,
  ),
  Subtask(
    id: 'st-2',
    title: 'Validar assinatura criptográfica do cabeçalho',
    stage: SubtaskStage.resolved,
    assignee: SeedMembers.lucasPeixoto,
  ),
  Subtask(
    id: 'st-3',
    title: 'Testar eventos no sandbox',
    code: 'customer.subscription.updated',
    stage: SubtaskStage.readyForTest,
  ),
  Subtask(
    id: 'st-4',
    title: 'Notificar usuário via push e e-mail após confirmação',
  ),
];

List<Attachment> _attachments(SeedCalendar calendar) => [
  Attachment(
    id: 'a-1',
    name: 'fluxo-arquitetura-webhook.png',
    sizeInBytes: 1468006,
    uploadedAt: calendar.days(-4),
    type: AttachmentType.image,
  ),
  Attachment(
    id: 'a-2',
    name: 'Stripe_Alfa_Contrato_v2.pdf',
    sizeInBytes: 430080,
    uploadedAt: calendar.days(-8),
    type: AttachmentType.pdf,
  ),
];

List<TaskComment> _comments(SeedCalendar calendar) => [
  TaskComment(
    id: 'c-1',
    author: SeedMembers.lucasPeixoto,
    body:
        'Subi os testes de carga do endpoint de webhook com mock de 500 '
        'requisições simultâneas. O Redis respondeu com tempo médio de '
        '12ms por transação.',
    createdAt: calendar.now.subtract(const Duration(hours: 3)),
    commit: '74f1b20a',
    ciApproved: true,
  ),
  TaskComment(
    id: 'c-2',
    author: const Member(id: 'u-mariana', name: 'Mariana Souza', role: 'PM'),
    body:
        'Alinhei com a equipe técnica do Banco Alfa: eles vão liberar '
        'as chaves de API restritas da Sandbox até o final desta tarde.',
    createdAt: calendar.days(-1, hour: 16, minute: 45),
  ),
];
