import '../../data/repositories/project/project_repository.dart';
import '../../data/repositories/task/task_repository.dart';
import '../../data/repositories/user/user_repository.dart';
import '../../utils/result.dart';
import '../metrics/portfolio_metrics.dart';
import '../models/member.dart';
import '../models/project.dart';

/// Tudo o que a tela "Projetos & Clientes" precisa para ser exibida.
class PortfolioData {
  const PortfolioData({
    required this.summary,
    required this.projects,
    required this.clients,
    required this.allocations,
    required this.members,
  });

  final PortfolioSummary summary;

  /// Projetos com os totais de tarefas calculados.
  final List<Project> projects;

  /// Clientes com a quantidade de projetos ativos.
  final List<Client> clients;
  final List<MemberAllocation> allocations;
  final List<Member> members;
}

/// Carrega projetos, clientes e tarefas e calcula os indicadores.
class LoadPortfolioUseCase {
  LoadPortfolioUseCase({
    required this._projectRepository,
    required this._taskRepository,
    required this._userRepository,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;
  final UserRepository _userRepository;
  final DateTime Function() _clock;

  Future<Result<PortfolioData>> load() async {
    final results = await (
      _projectRepository.getProjects(),
      _projectRepository.getClients(),
      _taskRepository.getTasks(),
      _userRepository.getMembers(),
    ).wait;

    switch (results) {
      case (
        Ok(value: final projects),
        Ok(value: final clients),
        Ok(value: final tasks),
        Ok(value: final members),
      ):
        final counted = withTaskCounts(projects, tasks);
        return Result.ok(
          PortfolioData(
            summary: computePortfolioSummary(
              projects: counted,
              tasks: tasks,
              members: members,
              now: _clock(),
            ),
            projects: counted,
            clients: withActiveProjects(clients, counted),
            allocations: computeAllocations(tasks: tasks, members: members),
            members: members,
          ),
        );
      case (Error(:final error), _, _, _) ||
          (_, Error(:final error), _, _) ||
          (_, _, Error(:final error), _) ||
          (_, _, _, Error(:final error)):
        return Result.error(error);
    }
  }
}
