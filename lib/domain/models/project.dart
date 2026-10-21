import 'member.dart';
import 'task.dart';

enum ProjectStatus { inProgress, done, paused }

/// Tipo do projeto, usado para escolher o ícone na UI.
enum ProjectKind { mobile, web, fiscal, landing, api, report, other }

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.clientName,
    required this.description,
    required this.status,
    required this.kind,
    this.clientId,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.team = const [],
    this.priority,
    this.badge,
    this.note,
    this.dueDate,
    this.finishedAt,
    this.createdAt,
  });

  /// Nome exibido quando o projeto não tem cliente vinculado.
  static const internalClientName = 'Interno';

  /// Identificador no banco. Vazio enquanto o projeto não foi salvo.
  final String id;
  final String name;
  final String? clientId;
  final String clientName;
  final String description;
  final ProjectStatus status;
  final ProjectKind kind;
  final int totalTasks;
  final int completedTasks;
  final List<Member> team;
  final TaskPriority? priority;

  /// Etiqueta de status complementar (ex.: "Entregue", "Aguardando Cliente").
  final String? badge;

  /// Observação exibida junto ao progresso (ex.: "Em Produção").
  final String? note;
  final DateTime? dueDate;
  final DateTime? finishedAt;
  final DateTime? createdAt;

  /// Projetos pausados ficam bloqueados até serem retomados.
  bool get blocked => status == ProjectStatus.paused;

  int get remainingTasks => totalTasks - completedTasks;

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;

  /// Cópia com os totais de tarefas calculados a partir do quadro.
  Project withTaskCounts({required int total, required int completed}) =>
      Project(
        id: id,
        name: name,
        clientId: clientId,
        clientName: clientName,
        description: description,
        status: status,
        kind: kind,
        totalTasks: total,
        completedTasks: completed,
        team: team,
        priority: priority,
        badge: badge,
        note: note,
        dueDate: dueDate,
        finishedAt: finishedAt,
        createdAt: createdAt,
      );
}

enum ClientTier { enterprise, pro, custom, maintenance }

class Client {
  const Client({
    required this.id,
    required this.name,
    required this.tier,
    this.sla = '',
    this.contract = '',
    this.activeProjects = 0,
  });

  /// Identificador no banco. Vazio enquanto o cliente não foi salvo.
  final String id;
  final String name;
  final ClientTier tier;

  /// Acordo de nível de serviço (ex.: "SLA 4h").
  final String sla;

  /// Referência do contrato (ex.: "Contrato Enterprise #490").
  final String contract;

  /// Projetos em andamento deste cliente.
  final int activeProjects;

  String get initials => initialsOf(name);

  Client withActiveProjects(int count) => Client(
    id: id,
    name: name,
    tier: tier,
    sla: sla,
    contract: contract,
    activeProjects: count,
  );

  /// Resumo exibido na lista de clientes.
  String get description {
    final parts = [
      if (activeProjects == 1) '1 projeto ativo',
      if (activeProjects > 1) '$activeProjects projetos ativos',
      if (sla.isNotEmpty) sla,
    ];
    return parts.isEmpty ? 'Sem projetos ativos' : parts.join(' • ');
  }
}

/// Horas semanais de um membro distribuídas por frente de trabalho.
class MemberAllocation {
  const MemberAllocation({
    required this.member,
    required this.hoursByFront,
    this.capacityHours = 40,
  });

  final Member member;
  final Map<String, double> hoursByFront;
  final double capacityHours;

  double get allocatedHours => hoursByFront.values.fold(0, (a, b) => a + b);

  bool get overloaded => allocatedHours > capacityHours;
}

/// Indicadores do portfólio (cards do topo de "Projetos & Clientes").
class PortfolioSummary {
  const PortfolioSummary({
    required this.activeDemands,
    required this.newThisMonth,
    required this.averageDeliveryRate,
    required this.activeDevs,
    required this.totalDevs,
    required this.onTimeRate,
  });

  /// Projetos em andamento.
  final int activeDemands;

  /// Projetos criados no mês corrente.
  final int newThisMonth;

  /// Média de progresso dos projetos em andamento.
  final double averageDeliveryRate;

  /// Pessoas alocadas em projetos em andamento.
  final int activeDevs;

  /// Pessoas ativas na equipe.
  final int totalDevs;

  /// Tarefas concluídas no prazo; `null` quando nenhuma tinha prazo.
  final double? onTimeRate;
}
