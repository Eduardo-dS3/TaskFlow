import '../../../../domain/models/task.dart';
import 'seed_calendar.dart';
import 'seed_members.dart';
import 'seed_webhook_task.dart';

/// Tarefas iniciais do quadro.
List<Task> seedTasks(SeedCalendar calendar) => [
  ..._pendingTasks(calendar),
  ..._inProgressTasks(calendar),
  seedWebhookTask(calendar),
  ..._doneTasks(calendar),
];

/// Indicadores da sprint ativa exibidos no topo do quadro.
const seedSprintOverview = SprintOverview(
  sprintName: 'Sprint #28 (Q4)',
  totalTasks: 42,
  monthGrowth: 0.12,
  teamCapacity: 0.94,
  pending: 14,
  blockers: 3,
  inProgress: 16,
  allocatedDevs: 8,
  done: 12,
  onTimeRate: 0.88,
  onlineMembers: [
    SeedMembers.mariana,
    SeedMembers.gabriel,
    SeedMembers.carla,
    SeedMembers.rodrigo,
    SeedMembers.beatriz,
    SeedMembers.camila,
  ],
);

List<Task> _pendingTasks(SeedCalendar calendar) => [
  Task(
    id: 't-1001',
    code: 'TK-1001',
    title: 'Refatoração da autenticação JWT',
    summary:
        'Migração para tokens de curta duração e suporte a refresh '
        'tokens rotativos no app mobile.',
    status: TaskStatus.pending,
    priority: TaskPriority.urgent,
    category: 'App Mobile',
    assignees: const [SeedMembers.rodrigo],
    dueDate: calendar.days(1),
    subtasks: _placeholderSubtasks(5, 2),
  ),
  Task(
    id: 't-1002',
    code: 'TK-1002',
    title: 'Ajuste de responsividade na landing page',
    summary:
        'Corrigir quebra de layout no container de preços em '
        'resoluções intermediárias (iPad).',
    status: TaskStatus.pending,
    priority: TaskPriority.medium,
    category: 'Marketing Web',
    assignees: const [SeedMembers.mariana],
    dueDate: calendar.days(3),
    subtasks: _placeholderSubtasks(2, 0),
  ),
  Task(
    id: 't-1003',
    code: 'TK-1003',
    title: 'Mapeamento de endpoints da API de faturamento',
    summary:
        'Documentação e testes de contrato OpenAPI para emissão '
        'automática de NF-e.',
    status: TaskStatus.pending,
    priority: TaskPriority.high,
    category: 'Backend Core',
    assignees: const [SeedMembers.lucasRibeiro],
    dueDate: calendar.days(8),
  ),
];

List<Task> _inProgressTasks(SeedCalendar calendar) => [
  Task(
    id: 't-1010',
    code: 'TK-1010',
    title: 'Configuração do Pipeline CI/CD Flutter',
    summary:
        'Automação de testes unitários, build e deploy de release '
        'para Firebase Hosting e lojas.',
    status: TaskStatus.inProgress,
    priority: TaskPriority.high,
    category: 'DevOps',
    assignees: const [SeedMembers.gabriel],
    dueDate: calendar.days(0),
    progress: 0.65,
    commentCount: 3,
  ),
  Task(
    id: 't-1011',
    code: 'TK-1011',
    title: 'Design System dos componentes de formulário',
    summary:
        'Especificação visual dos estados de foco, hover e erro para '
        'campos de input e seletores.',
    status: TaskStatus.inProgress,
    priority: TaskPriority.medium,
    category: 'Design',
    assignees: const [SeedMembers.beatriz, SeedMembers.andre],
    subtasks: _placeholderSubtasks(6, 4),
  ),
];

List<Task> _doneTasks(SeedCalendar calendar) => [
  Task(
    id: 't-0990',
    code: 'TK-0990',
    title: 'Definição da arquitetura BLoC / Provider',
    summary:
        'Padronização de injeção de dependências e gerenciamento de '
        'estado reativo em todo o app.',
    status: TaskStatus.done,
    priority: TaskPriority.high,
    category: 'Flutter Web',
    assignees: const [SeedMembers.rodrigo],
    completedAt: calendar.days(0),
    reviewed: true,
  ),
  Task(
    id: 't-0991',
    code: 'TK-0991',
    title: 'Exportação dos tokens de cor para Figma',
    summary:
        'Sincronização dos Design Tokens do Tailwind com o plugin '
        'Tokens Studio no Figma.',
    status: TaskStatus.done,
    priority: TaskPriority.low,
    category: 'Design',
    assignees: const [SeedMembers.andre],
    completedAt: calendar.days(-1),
  ),
];

/// Checklist genérico com [total] itens, dos quais [done] resolvidos.
List<Subtask> _placeholderSubtasks(int total, int done) => [
  for (var i = 0; i < total; i++)
    Subtask(
      id: 'st-$total-$done-$i',
      title: 'Item ${i + 1}',
      stage: i < done ? SubtaskStage.resolved : SubtaskStage.queued,
    ),
];
