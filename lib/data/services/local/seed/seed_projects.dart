import '../../../../domain/models/member.dart';
import '../../../../domain/models/project.dart';
import '../../../../domain/models/task.dart';
import 'seed_calendar.dart';
import 'seed_members.dart';

/// Indicadores do portfólio exibidos no topo de "Projetos & Clientes".
const seedPortfolioSummary = PortfolioSummary(
  activeDemands: 5,
  newThisMonth: 1,
  averageDeliveryRate: 0.683,
  deliveryRateDelta: 0.042,
  activeDevs: 14,
  totalDevs: 16,
  onTimeRate: 0.94,
);

/// Projetos do portfólio.
List<Project> seedProjects(SeedCalendar calendar) => [
  ..._highPriorityProjects(calendar),
  ..._otherProjects(calendar),
];

const seedClients = [
  Client(
    id: 'c-1',
    name: 'TechVanguard Inc.',
    description: '1 projeto ativo • SLA 4h',
    tier: ClientTier.enterprise,
  ),
  Client(
    id: 'c-2',
    name: 'Logística Express',
    description: '1 projeto ativo • SLA 8h',
    tier: ClientTier.pro,
  ),
  Client(
    id: 'c-3',
    name: 'Rede FarmaMais',
    description: '1 projeto ativo • SLA Crítico',
    tier: ClientTier.custom,
  ),
  Client(
    id: 'c-4',
    name: 'Studio Design Co.',
    description: 'Garantia ativa (30d)',
    tier: ClientTier.maintenance,
  ),
];

/// Horas semanais de cada pessoa por frente de trabalho.
const seedAllocations = [
  MemberAllocation(
    member: Member(id: 'u-mariana', name: 'Mariana Souza', role: 'Lead Tech'),
    hoursByFront: {'App Mobile': 22, 'SaaS': 16},
  ),
  MemberAllocation(
    member: SeedMembers.lucasRibeiro,
    hoursByFront: {'Fiscal': 28, 'App Mobile': 14},
  ),
  MemberAllocation(member: SeedMembers.camila, hoursByFront: {'SaaS': 32}),
];

List<Project> _highPriorityProjects(SeedCalendar calendar) => [
  Project(
    id: 'p-1',
    name: 'App Mobile Flutter iOS/Android',
    clientName: 'TechVanguard Inc.',
    description:
        'Desenvolvimento cross-platform com arquitetura clean code, '
        'sincronização offline e notificações push.',
    status: ProjectStatus.inProgress,
    priority: TaskPriority.high,
    kind: ProjectKind.mobile,
    totalTasks: 24,
    completedTasks: 18,
    team: [
      SeedMembers.mariana,
      SeedMembers.dev('gs', 'Gustavo Silva'),
      SeedMembers.andre,
      SeedMembers.dev('x1', 'Xavier Yuri'),
    ],
    dueDate: calendar.days(29),
  ),
  Project(
    id: 'p-2',
    name: 'Plataforma Web SaaS & Dashboard',
    clientName: 'Logística Express',
    description:
        'Painel operacional para roteirização e rastreio de frotas com '
        'websockets em tempo real.',
    status: ProjectStatus.inProgress,
    priority: TaskPriority.high,
    kind: ProjectKind.web,
    totalTasks: 25,
    completedTasks: 10,
    team: [
      SeedMembers.lucasRibeiro,
      SeedMembers.camila,
      SeedMembers.dev('fl', 'Fernanda Lima'),
      SeedMembers.dev('x2', 'Yago Zanin'),
      SeedMembers.dev('x3', 'Zoe Bento'),
    ],
    dueDate: calendar.days(44),
  ),
  Project(
    id: 'p-3',
    name: 'Módulo de Integração Fiscal',
    clientName: 'Rede FarmaMais',
    description:
        'Emissão assíncrona de NF-e, homologação de certificado A1 e '
        'contingência offline.',
    status: ProjectStatus.inProgress,
    priority: TaskPriority.urgent,
    kind: ProjectKind.fiscal,
    totalTasks: 30,
    completedTasks: 27,
    team: [
      SeedMembers.dev('tl', 'Tiago Leal'),
      SeedMembers.dev('rb', 'Renata Borges'),
    ],
    dueDate: calendar.days(19),
  ),
];

List<Project> _otherProjects(SeedCalendar calendar) => [
  Project(
    id: 'p-4',
    name: 'Landing Page & Blog Institucional',
    clientName: 'Studio Design Co.',
    description:
        'Interface responsiva de alta conversão, CMS headless integrado, '
        'otimização de SEO e Core Web Vitals.',
    status: ProjectStatus.done,
    badge: 'Entregue',
    note: 'Em Produção',
    kind: ProjectKind.landing,
    totalTasks: 15,
    completedTasks: 15,
    team: [
      SeedMembers.dev('pa', 'Paula Andrade'),
      SeedMembers.dev('vc', 'Vitor Cardoso'),
      SeedMembers.dev('mt', 'Marcos Teixeira'),
    ],
    finishedAt: calendar.days(-5),
  ),
  Project(
    id: 'p-5',
    name: 'Refatoração da API e Microserviços',
    clientName: 'Interno',
    description:
        'Migração de monolito legado para Go e RabbitMQ para suportar '
        '50k requisições por minuto.',
    status: ProjectStatus.inProgress,
    priority: TaskPriority.medium,
    kind: ProjectKind.api,
    totalTasks: 20,
    completedTasks: 6,
    team: [
      SeedMembers.dev('dk', 'Daniel Kato'),
      SeedMembers.dev('mr', 'Marina Rocha'),
    ],
    dueDate: calendar.days(64),
  ),
  Project(
    id: 'p-6',
    name: 'Automação de Relatórios em BI',
    clientName: 'AgroData Brasil',
    description:
        'Geração de relatórios analíticos de safra e volumetria de chuva '
        'via triggers agendados.',
    status: ProjectStatus.paused,
    badge: 'Aguardando Cliente',
    note: 'Bloqueado por aprovação',
    kind: ProjectKind.report,
    totalTasks: 20,
    completedTasks: 3,
    team: [SeedMembers.dev('jn', 'João Nunes')],
    blocked: true,
  ),
];
