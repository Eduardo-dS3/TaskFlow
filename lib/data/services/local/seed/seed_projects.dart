import '../../../../domain/models/project.dart';
import '../../../../domain/models/task.dart';
import 'seed_calendar.dart';
import 'seed_members.dart';

/// Clientes de exemplo.
const seedClients = [
  Client(
    id: 'c-1',
    name: 'TechVanguard Inc.',
    tier: ClientTier.enterprise,
    sla: 'SLA 4h',
    contract: 'Contrato Enterprise #210',
  ),
  Client(
    id: 'c-2',
    name: 'Logística Express',
    tier: ClientTier.pro,
    sla: 'SLA 8h',
  ),
  Client(
    id: 'c-3',
    name: 'Rede FarmaMais',
    tier: ClientTier.custom,
    sla: 'SLA Crítico',
  ),
  Client(
    id: 'c-4',
    name: 'Studio Design Co.',
    tier: ClientTier.maintenance,
    sla: 'Garantia ativa (30d)',
  ),
  Client(
    id: 'c-5',
    name: 'AgroData Brasil',
    tier: ClientTier.pro,
    sla: 'SLA 24h',
  ),
  Client(
    id: 'c-6',
    name: 'Banco Alfa & Parceiros',
    tier: ClientTier.enterprise,
    sla: 'SLA 2h',
    contract: 'Contrato Enterprise #490',
  ),
];

/// Projetos de exemplo, na mesma ordem do protótipo.
List<Project> seedProjects(SeedCalendar calendar) => [
  ..._highPriorityProjects(calendar),
  ..._otherProjects(calendar),
];

List<Project> _highPriorityProjects(SeedCalendar calendar) => [
  Project(
    id: 'p-1',
    name: 'App Mobile Flutter iOS/Android',
    clientId: 'c-1',
    clientName: 'TechVanguard Inc.',
    description:
        'Desenvolvimento cross-platform com arquitetura clean code, '
        'sincronização offline e notificações push.',
    status: ProjectStatus.inProgress,
    priority: TaskPriority.high,
    kind: ProjectKind.mobile,
    team: const [SeedMembers.mariana, SeedMembers.rodrigo, SeedMembers.andre],
    dueDate: calendar.days(29),
    createdAt: calendar.days(-60),
  ),
  Project(
    id: 'p-2',
    name: 'Plataforma Web SaaS & Dashboard',
    clientId: 'c-2',
    clientName: 'Logística Express',
    description:
        'Painel operacional para roteirização e rastreio de frotas com '
        'websockets em tempo real.',
    status: ProjectStatus.inProgress,
    priority: TaskPriority.high,
    kind: ProjectKind.web,
    team: const [SeedMembers.lucasRibeiro, SeedMembers.camila],
    dueDate: calendar.days(44),
    createdAt: calendar.days(-40),
  ),
  Project(
    id: 'p-3',
    name: 'Fintech Core v2',
    clientId: 'c-6',
    clientName: 'Banco Alfa & Parceiros',
    description:
        'Integração de pagamentos recorrentes, webhooks do Stripe e '
        'conciliação de faturas B2B.',
    status: ProjectStatus.inProgress,
    priority: TaskPriority.urgent,
    kind: ProjectKind.fiscal,
    team: const [SeedMembers.rafael, SeedMembers.lucasPeixoto],
    dueDate: calendar.days(19),
    createdAt: calendar.days(-3),
  ),
];

List<Project> _otherProjects(SeedCalendar calendar) => [
  Project(
    id: 'p-4',
    name: 'Landing Page & Blog Institucional',
    clientId: 'c-4',
    clientName: 'Studio Design Co.',
    description:
        'Interface responsiva de alta conversão, CMS headless integrado, '
        'otimização de SEO e Core Web Vitals.',
    status: ProjectStatus.done,
    badge: 'Entregue',
    note: 'Em Produção',
    kind: ProjectKind.landing,
    team: const [SeedMembers.beatriz, SeedMembers.andre],
    finishedAt: calendar.days(-5),
    createdAt: calendar.days(-90),
  ),
  Project(
    id: 'p-5',
    name: 'Refatoração da API e Microserviços',
    clientName: Project.internalClientName,
    description:
        'Migração de monolito legado para Go e RabbitMQ para suportar '
        '50k requisições por minuto.',
    status: ProjectStatus.inProgress,
    priority: TaskPriority.medium,
    kind: ProjectKind.api,
    team: const [SeedMembers.gabriel, SeedMembers.carla],
    dueDate: calendar.days(64),
    createdAt: calendar.days(-20),
  ),
  Project(
    id: 'p-6',
    name: 'Automação de Relatórios em BI',
    clientId: 'c-5',
    clientName: 'AgroData Brasil',
    description:
        'Geração de relatórios analíticos de safra e volumetria de chuva '
        'via triggers agendados.',
    status: ProjectStatus.paused,
    badge: 'Aguardando Cliente',
    note: 'Bloqueado por aprovação',
    kind: ProjectKind.report,
    team: const [SeedMembers.lucasRibeiro],
    createdAt: calendar.days(-30),
  ),
];
