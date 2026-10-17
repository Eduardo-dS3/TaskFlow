import '../../../domain/models/member.dart';
import '../../../domain/models/productivity_report.dart';
import '../../../domain/models/project.dart';
import '../../../domain/models/task.dart';

/// Fonte de dados local em memória que simula o backend do TaskFlow.
///
/// Os repositórios são os únicos que conhecem este serviço. Para trocar por
/// uma API real, basta criar um `ApiClient` e uma nova implementação dos
/// repositórios, sem alterar a camada de UI.
class LocalDataService {
  LocalDataService({DateTime Function()? clock})
    : _now = (clock ?? DateTime.now)() {
    _tasks = _seedTasks();
  }

  final DateTime _now;
  late List<Task> _tasks;

  DateTime _days(int days, {int hour = 0, int minute = 0}) {
    final today = DateTime(_now.year, _now.month, _now.day);
    return today.add(Duration(days: days, hours: hour, minutes: minute));
  }

  // ---------------------------------------------------------------------------
  // Pessoas
  // ---------------------------------------------------------------------------

  static const mariana = Member(
    id: 'u-mariana',
    name: 'Mariana Souza',
    role: 'Product Manager',
  );
  static const lucasPeixoto = Member(
    id: 'u-lucas-p',
    name: 'Lucas Peixoto',
    role: 'Backend Engineer',
  );
  static const rodrigo = Member(
    id: 'u-rodrigo',
    name: 'Rodrigo Nogueira',
    role: 'Tech Lead',
  );
  static const beatriz = Member(
    id: 'u-beatriz',
    name: 'Beatriz Ramos',
    role: 'Lead Product Designer',
  );
  static const lucasRibeiro = Member(
    id: 'u-lucas-r',
    name: 'Lucas Ribeiro',
    role: 'Backend Senior',
  );
  static const camila = Member(
    id: 'u-camila',
    name: 'Camila Duarte',
    role: 'Frontend Dev',
  );
  static const rafael = Member(
    id: 'u-rafael',
    name: 'Rafael Costa',
    role: 'Backend Engineer',
  );
  static const andre = Member(
    id: 'u-andre',
    name: 'André Lima',
    role: 'Designer',
  );
  static const gabriel = Member(
    id: 'u-gabriel',
    name: 'Gabriel Lopes',
    role: 'Mobile Dev',
  );
  static const carla = Member(
    id: 'u-carla',
    name: 'Carla Alves',
    role: 'QA Engineer',
  );

  static Member _m(String id, String name) =>
      Member(id: id, name: name, role: 'Dev');

  Member get currentUser => mariana;

  List<Member> get members => const [
    mariana,
    lucasPeixoto,
    rodrigo,
    beatriz,
    lucasRibeiro,
    camila,
    rafael,
    andre,
    gabriel,
    carla,
  ];

  // ---------------------------------------------------------------------------
  // Tarefas
  // ---------------------------------------------------------------------------

  List<Task> get tasks => List.unmodifiable(_tasks);

  Task? findTask(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  Task upsertTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      _tasks = [..._tasks, task];
    } else {
      _tasks = [..._tasks]..[index] = task;
    }
    return task;
  }

  bool deleteTask(String id) {
    final before = _tasks.length;
    _tasks = _tasks.where((t) => t.id != id).toList();
    return _tasks.length != before;
  }

  int _sequence = 1100;

  String nextTaskCode() => 'TK-${++_sequence}';

  SprintOverview get sprintOverview => const SprintOverview(
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
    onlineMembers: [mariana, gabriel, carla, rodrigo, beatriz, camila],
  );

  List<Task> _seedTasks() {
    return [
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
        assignees: const [rodrigo],
        dueDate: _days(1),
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
        assignees: const [mariana],
        dueDate: _days(3),
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
        assignees: const [lucasRibeiro],
        dueDate: _days(8),
      ),
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
        assignees: const [gabriel],
        dueDate: _days(0),
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
        assignees: const [beatriz, andre],
        subtasks: _placeholderSubtasks(6, 4),
      ),
      _webhookTask(),
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
        assignees: const [rodrigo],
        completedAt: _days(0),
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
        assignees: const [andre],
        completedAt: _days(-1),
      ),
    ];
  }

  List<Subtask> _placeholderSubtasks(int total, int done) => [
    for (var i = 0; i < total; i++)
      Subtask(
        id: 'st-$total-$done-$i',
        title: 'Item ${i + 1}',
        stage: i < done ? SubtaskStage.resolved : SubtaskStage.queued,
      ),
  ];

  Task _webhookTask() {
    return Task(
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
      owner: const Member(
        id: 'u-mariana',
        name: 'Mariana Souza',
        role: 'Tech Lead / PM',
      ),
      assignees: const [rafael],
      description:
          'Implementar o endpoint receptor seguro para os eventos '
          'transacionais providos pelo gateway Stripe API v2023-10-16. O foco '
          'é a sincronização instantânea do status de subscrições ativas e '
          'baixa de faturas B2B do cliente Banco Alfa.',
      requirements: const [
        'Garantir validação rigorosa de assinatura HMAC-SHA256 no cabeçalho '
            '`Stripe-Signature`.',
        'Implementar tolerância de drift de relógio de até 300 segundos para '
            'mitigação de ataques de repetição (Replay Attacks).',
        'Idempotência garantida via Redis com TTL de 24 horas usando o '
            '`event.id`.',
      ],
      payloadExample: '''
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
}''',
      startDate: _days(-10),
      dueDate: _days(11),
      loggedHours: 14,
      estimatedHours: 20,
      tags: const ['Backend', 'Fintech', 'Stripe', 'Alta Prioridade'],
      subtasks: const [
        Subtask(
          id: 'st-1',
          title: 'Criar rota de webhook no servidor',
          code: '/api/v1/stripe',
          stage: SubtaskStage.resolved,
          assignee: lucasPeixoto,
        ),
        Subtask(
          id: 'st-2',
          title: 'Validar assinatura criptográfica do cabeçalho',
          stage: SubtaskStage.resolved,
          assignee: lucasPeixoto,
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
      ],
      attachments: [
        Attachment(
          id: 'a-1',
          name: 'fluxo-arquitetura-webhook.png',
          sizeInBytes: 1468006,
          uploadedAt: _days(-4),
          type: AttachmentType.image,
        ),
        Attachment(
          id: 'a-2',
          name: 'Stripe_Alfa_Contrato_v2.pdf',
          sizeInBytes: 430080,
          uploadedAt: _days(-8),
          type: AttachmentType.pdf,
        ),
      ],
      comments: [
        TaskComment(
          id: 'c-1',
          author: lucasPeixoto,
          body:
              'Subi os testes de carga do endpoint de webhook com mock de 500 '
              'requisições simultâneas. O Redis respondeu com tempo médio de '
              '12ms por transação.',
          createdAt: _now.subtract(const Duration(hours: 3)),
          commit: '74f1b20a',
          ciApproved: true,
        ),
        TaskComment(
          id: 'c-2',
          author: const Member(
            id: 'u-mariana',
            name: 'Mariana Souza',
            role: 'PM',
          ),
          body:
              'Alinhei com a equipe técnica do Banco Alfa: eles vão liberar '
              'as chaves de API restritas da Sandbox até o final desta tarde.',
          createdAt: _days(-1, hour: 16, minute: 45),
        ),
      ],
      commentCount: 3,
    );
  }

  // ---------------------------------------------------------------------------
  // Projetos & Clientes
  // ---------------------------------------------------------------------------

  PortfolioSummary get portfolioSummary => const PortfolioSummary(
    activeDemands: 5,
    newThisMonth: 1,
    averageDeliveryRate: 0.683,
    deliveryRateDelta: 0.042,
    activeDevs: 14,
    totalDevs: 16,
    onTimeRate: 0.94,
  );

  List<Project> get projects => [
    Project(
      id: 'p-1',
      name: 'App Mobile Flutter iOS/Android',
      clientName: 'TechVanguard Inc.',
      description:
          'Desenvolvimento cross-platform com arquitetura clean '
          'code, sincronização offline e notificações push.',
      status: ProjectStatus.inProgress,
      priority: TaskPriority.high,
      kind: ProjectKind.mobile,
      totalTasks: 24,
      completedTasks: 18,
      team: [
        mariana,
        _m('gs', 'Gustavo Silva'),
        andre,
        _m('x1', 'Xavier Yuri'),
      ],
      dueDate: _days(29),
    ),
    Project(
      id: 'p-2',
      name: 'Plataforma Web SaaS & Dashboard',
      clientName: 'Logística Express',
      description:
          'Painel operacional para roteirização e rastreio de '
          'frotas com websockets em tempo real.',
      status: ProjectStatus.inProgress,
      priority: TaskPriority.high,
      kind: ProjectKind.web,
      totalTasks: 25,
      completedTasks: 10,
      team: [
        lucasRibeiro,
        camila,
        _m('fl', 'Fernanda Lima'),
        _m('x2', 'Yago Zanin'),
        _m('x3', 'Zoe Bento'),
      ],
      dueDate: _days(44),
    ),
    Project(
      id: 'p-3',
      name: 'Módulo de Integração Fiscal',
      clientName: 'Rede FarmaMais',
      description:
          'Emissão assíncrona de NF-e, homologação de '
          'certificado A1 e contingência offline.',
      status: ProjectStatus.inProgress,
      priority: TaskPriority.urgent,
      kind: ProjectKind.fiscal,
      totalTasks: 30,
      completedTasks: 27,
      team: [_m('tl', 'Tiago Leal'), _m('rb', 'Renata Borges')],
      dueDate: _days(19),
    ),
    Project(
      id: 'p-4',
      name: 'Landing Page & Blog Institucional',
      clientName: 'Studio Design Co.',
      description:
          'Interface responsiva de alta conversão, CMS headless '
          'integrado, otimização de SEO e Core Web Vitals.',
      status: ProjectStatus.done,
      badge: 'Entregue',
      note: 'Em Produção',
      kind: ProjectKind.landing,
      totalTasks: 15,
      completedTasks: 15,
      team: [
        _m('pa', 'Paula Andrade'),
        _m('vc', 'Vitor Cardoso'),
        _m('mt', 'Marcos Teixeira'),
      ],
      finishedAt: _days(-5),
    ),
    Project(
      id: 'p-5',
      name: 'Refatoração da API e Microserviços',
      clientName: 'Interno',
      description:
          'Migração de monolito legado para Go e RabbitMQ para '
          'suportar 50k requisições por minuto.',
      status: ProjectStatus.inProgress,
      priority: TaskPriority.medium,
      kind: ProjectKind.api,
      totalTasks: 20,
      completedTasks: 6,
      team: [_m('dk', 'Daniel Kato'), _m('mr', 'Marina Rocha')],
      dueDate: _days(64),
    ),
    const Project(
      id: 'p-6',
      name: 'Automação de Relatórios em BI',
      clientName: 'AgroData Brasil',
      description:
          'Geração de relatórios analíticos de safra e volumetria '
          'de chuva via triggers agendados.',
      status: ProjectStatus.paused,
      badge: 'Aguardando Cliente',
      note: 'Bloqueado por aprovação',
      kind: ProjectKind.report,
      totalTasks: 20,
      completedTasks: 3,
      team: [Member(id: 'jn', name: 'João Nunes', role: 'Dev')],
      blocked: true,
    ),
  ];

  List<Client> get clients => const [
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

  List<MemberAllocation> get allocations => const [
    MemberAllocation(
      member: Member(id: 'u-mariana', name: 'Mariana Souza', role: 'Lead Tech'),
      hoursByFront: {'App Mobile': 22, 'SaaS': 16},
    ),
    MemberAllocation(
      member: lucasRibeiro,
      hoursByFront: {'Fiscal': 28, 'App Mobile': 14},
    ),
    MemberAllocation(member: camila, hoursByFront: {'SaaS': 32}),
  ];

  // ---------------------------------------------------------------------------
  // Relatórios
  // ---------------------------------------------------------------------------

  ProductivityReport report(ReportPeriod period) {
    // Fator simples para diferenciar os períodos na simulação.
    final factor = switch (period) {
      ReportPeriod.last30Days => 1.0,
      ReportPeriod.quarter => 2.6,
      ReportPeriod.year => 9.4,
      ReportPeriod.custom => 1.0,
    };
    int scale(int value) => (value * factor).round();

    return ProductivityReport(
      period: period,
      onTimeRate: 0.942,
      slaTarget: 0.90,
      previousOnTimeRate: 0.907,
      averageResolutionDays: 2.8,
      resolutionDeltaDays: -0.4,
      finishedTasks: scale(148),
      activeTasks: scale(192),
      sprintProgress: 0.77,
      criticalBlockers: 3,
      netThroughputAboveGoal: scale(18),
      weeklyThroughput: const [
        WeeklyThroughput(label: 'Semana 01', completed: 22, created: 14),
        WeeklyThroughput(label: 'Semana 02', completed: 29, created: 18),
        WeeklyThroughput(label: 'Semana 03', completed: 33, created: 24),
        WeeklyThroughput(label: 'Semana 04', completed: 34, created: 30),
        WeeklyThroughput(
          label: 'Semana 05 (Atual)',
          completed: 39,
          created: 35,
        ),
      ],
      statusDistribution: {
        TaskStatus.done: scale(71),
        TaskStatus.inProgress: scale(73),
        TaskStatus.pending: scale(48),
      },
      priorityDistribution: {
        TaskPriority.urgent: scale(14),
        TaskPriority.high: scale(58),
        TaskPriority.medium: scale(86),
        TaskPriority.low: scale(34),
      },
      totalMembers: 18,
      members: const [
        MemberPerformance(
          name: 'Rodrigo Nogueira',
          subtitle: 'Tech Lead • Core Flutter',
          assigned: 42,
          completed: 39,
          inProgress: 3,
          efficiency: 0.975,
          workload: 0.75,
          workloadLevel: WorkloadLevel.optimized,
        ),
        MemberPerformance(
          name: 'Beatriz Ramos',
          subtitle: 'Lead Product Designer',
          assigned: 36,
          completed: 32,
          inProgress: 4,
          efficiency: 0.941,
          workload: 0.68,
          workloadLevel: WorkloadLevel.balanced,
        ),
        MemberPerformance(
          name: 'Lucas Farias',
          subtitle: 'Senior Backend • API Integrations',
          assigned: 51,
          completed: 38,
          inProgress: 13,
          efficiency: 0.863,
          workload: 0.94,
          workloadLevel: WorkloadLevel.overloaded,
        ),
        MemberPerformance(
          name: 'Camila Duarte',
          subtitle: 'QA Automation Engineer',
          assigned: 28,
          completed: 25,
          inProgress: 3,
          efficiency: 0.96,
          workload: 0.52,
          workloadLevel: WorkloadLevel.stable,
        ),
        MemberPerformance(
          name: 'OmniBank Financials',
          subtitle: 'Cliente Estratégico • Squad Alfa',
          assigned: 35,
          completed: 14,
          inProgress: 21,
          efficiency: 0.792,
          workload: 0,
          workloadLevel: WorkloadLevel.validating,
          workloadNote: 'Atraso 2d',
          isClient: true,
        ),
      ],
    );
  }
}
