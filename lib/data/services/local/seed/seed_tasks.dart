import '../../../../domain/models/task.dart';
import 'seed_calendar.dart';
import 'seed_members.dart';
import 'seed_webhook_task.dart';

/// Sprint ativa dos dados de exemplo.
const seedActiveSprint = 'Sprint #28 (Q4)';

/// Tarefas iniciais do quadro.
List<Task> seedTasks(SeedCalendar calendar) => [
  ..._pendingTasks(calendar),
  ..._inProgressTasks(calendar),
  seedWebhookTask(calendar),
  ..._doneTasks(calendar),
];

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
    sprint: seedActiveSprint,
    projectId: 'p-1',
    projectName: 'App Mobile Flutter iOS/Android',
    clientName: 'TechVanguard Inc.',
    assignees: const [SeedMembers.rodrigo],
    dueDate: calendar.days(1),
    estimatedHours: 16,
    subtasks: _placeholderSubtasks(5, 2),
    createdAt: calendar.days(-6),
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
    projectId: 'p-4',
    projectName: 'Landing Page & Blog Institucional',
    clientName: 'Studio Design Co.',
    assignees: const [SeedMembers.mariana],
    dueDate: calendar.days(3),
    estimatedHours: 6,
    subtasks: _placeholderSubtasks(2, 0),
    createdAt: calendar.days(-2),
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
    sprint: seedActiveSprint,
    projectId: 'p-5',
    projectName: 'Refatoração da API e Microserviços',
    assignees: const [SeedMembers.lucasRibeiro],
    dueDate: calendar.days(8),
    estimatedHours: 12,
    createdAt: calendar.days(-1),
  ),
];

List<Task> _inProgressTasks(SeedCalendar calendar) => [
  Task(
    id: 't-1010',
    code: 'TK-1010',
    title: 'Configuração do Pipeline CI/CD Flutter',
    summary:
        'Automação de testes unitários, build e deploy de release '
        'para o servidor de produção.',
    status: TaskStatus.inProgress,
    priority: TaskPriority.high,
    category: 'DevOps',
    sprint: seedActiveSprint,
    projectId: 'p-5',
    projectName: 'Refatoração da API e Microserviços',
    assignees: const [SeedMembers.gabriel],
    dueDate: calendar.days(0),
    estimatedHours: 20,
    loggedHours: 13,
    progress: 0.65,
    commentCount: 3,
    createdAt: calendar.days(-12),
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
    sprint: seedActiveSprint,
    projectId: 'p-1',
    projectName: 'App Mobile Flutter iOS/Android',
    clientName: 'TechVanguard Inc.',
    assignees: const [SeedMembers.beatriz, SeedMembers.andre],
    estimatedHours: 24,
    loggedHours: 10,
    subtasks: _placeholderSubtasks(6, 4),
    createdAt: calendar.days(-9),
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
    sprint: seedActiveSprint,
    projectId: 'p-1',
    projectName: 'App Mobile Flutter iOS/Android',
    clientName: 'TechVanguard Inc.',
    assignees: const [SeedMembers.rodrigo],
    dueDate: calendar.days(1),
    completedAt: calendar.days(0),
    estimatedHours: 8,
    loggedHours: 8,
    reviewed: true,
    createdAt: calendar.days(-15),
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
    projectId: 'p-4',
    projectName: 'Landing Page & Blog Institucional',
    clientName: 'Studio Design Co.',
    assignees: const [SeedMembers.andre],
    dueDate: calendar.days(-3),
    completedAt: calendar.days(-1),
    estimatedHours: 4,
    loggedHours: 5,
    createdAt: calendar.days(-20),
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
