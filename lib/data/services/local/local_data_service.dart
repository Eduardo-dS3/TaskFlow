import '../../../domain/models/member.dart';
import '../../../domain/models/productivity_report.dart';
import '../../../domain/models/project.dart';
import '../../../domain/models/task.dart';
import 'seed/seed_calendar.dart';
import 'seed/seed_members.dart';
import 'seed/seed_projects.dart';
import 'seed/seed_report.dart';
import 'seed/seed_tasks.dart';

/// Fonte de dados local em memória que simula o backend do TaskFlow.
///
/// Os repositórios são os únicos que conhecem este serviço. Para trocar por
/// uma API real, basta criar um `ApiClient` e uma nova implementação dos
/// repositórios, sem alterar a camada de UI. Os dados iniciais ficam em
/// `seed/`.
class LocalDataService {
  LocalDataService({DateTime Function()? clock})
    : _calendar = SeedCalendar((clock ?? DateTime.now)()) {
    _tasks = seedTasks(_calendar);
  }

  final SeedCalendar _calendar;
  late List<Task> _tasks;
  int _sequence = 1100;

  // ---------------------------------------------------------------------------
  // Pessoas
  // ---------------------------------------------------------------------------

  Member get currentUser => SeedMembers.mariana;

  List<Member> get members => SeedMembers.all;

  // ---------------------------------------------------------------------------
  // Tarefas
  // ---------------------------------------------------------------------------

  SprintOverview get sprintOverview => seedSprintOverview;

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

  String nextTaskCode() => 'TK-${++_sequence}';

  // ---------------------------------------------------------------------------
  // Projetos & Clientes
  // ---------------------------------------------------------------------------

  PortfolioSummary get portfolioSummary => seedPortfolioSummary;

  List<Project> get projects => seedProjects(_calendar);

  List<Client> get clients => seedClients;

  List<MemberAllocation> get allocations => seedAllocations;

  // ---------------------------------------------------------------------------
  // Relatórios
  // ---------------------------------------------------------------------------

  ProductivityReport report(ReportPeriod period) => seedReport(period);
}
