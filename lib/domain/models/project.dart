import 'member.dart';
import 'task.dart';

enum ProjectStatus { inProgress, done, paused }

/// Tipo do projeto, usado para escolher o ícone na UI.
enum ProjectKind { mobile, web, fiscal, landing, api, report }

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.clientName,
    required this.description,
    required this.status,
    required this.kind,
    required this.totalTasks,
    required this.completedTasks,
    required this.team,
    this.priority,
    this.badge,
    this.note,
    this.dueDate,
    this.finishedAt,
    this.blocked = false,
  });

  final String id;
  final String name;
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
  final bool blocked;

  int get remainingTasks => totalTasks - completedTasks;

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;
}

enum ClientTier { enterprise, pro, custom, maintenance }

class Client {
  const Client({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
  });

  final String id;
  final String name;
  final String description;
  final ClientTier tier;

  String get initials {
    final parts = name.split(' ');
    return (parts[0][0] + parts[1][0]).toUpperCase();
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
    required this.deliveryRateDelta,
    required this.activeDevs,
    required this.totalDevs,
    required this.onTimeRate,
  });

  final int activeDemands;
  final int newThisMonth;
  final double averageDeliveryRate;
  final double deliveryRateDelta;
  final int activeDevs;
  final int totalDevs;
  final double onTimeRate;
}
