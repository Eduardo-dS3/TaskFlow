import '../../../domain/models/project.dart';
import '../../../utils/result.dart';
import '../../services/local/local_data_service.dart';
import 'project_repository.dart';

/// Implementação de [ProjectRepository] em memória (demonstração e testes).
class ProjectRepositoryLocal implements ProjectRepository {
  ProjectRepositoryLocal({
    required LocalDataService localDataService,
    this._latency = const Duration(milliseconds: 300),
  }) : _service = localDataService;

  final LocalDataService _service;
  final Duration _latency;

  Future<void> _simulateNetwork() => Future<void>.delayed(_latency);

  @override
  Future<Result<List<Project>>> getProjects() async {
    await _simulateNetwork();
    return Result.ok(_service.projects);
  }

  @override
  Future<Result<Project>> saveProject(Project project) async {
    await _simulateNetwork();
    if (project.name.trim().isEmpty) {
      return Result.error(Exception('O nome do projeto é obrigatório'));
    }
    final clientId = project.clientId;
    final client = clientId == null ? null : _service.findClient(clientId);
    final saved = Project(
      id: project.id.isEmpty ? _service.newId('p') : project.id,
      name: project.name.trim(),
      clientId: client?.id,
      clientName: client?.name ?? Project.internalClientName,
      description: project.description,
      status: project.status,
      kind: project.kind,
      team: project.team,
      priority: project.priority,
      badge: project.badge,
      note: project.note,
      dueDate: project.dueDate,
      finishedAt: project.status == ProjectStatus.done
          ? project.finishedAt ?? _service.now
          : null,
      createdAt: project.createdAt ?? _service.now,
    );
    return Result.ok(_service.upsertProject(saved));
  }

  @override
  Future<Result<void>> deleteProject(String id) async {
    await _simulateNetwork();
    if (!_service.deleteProject(id)) {
      return Result.error(Exception('Projeto não encontrado'));
    }
    return const Result.ok(null);
  }

  @override
  Future<Result<List<Client>>> getClients() async {
    await _simulateNetwork();
    return Result.ok(_service.clients);
  }

  @override
  Future<Result<Client>> saveClient(Client client) async {
    await _simulateNetwork();
    if (client.name.trim().isEmpty) {
      return Result.error(Exception('O nome do cliente é obrigatório'));
    }
    final saved = Client(
      id: client.id.isEmpty ? _service.newId('c') : client.id,
      name: client.name.trim(),
      tier: client.tier,
      sla: client.sla,
      contract: client.contract,
    );
    return Result.ok(_service.upsertClient(saved));
  }

  @override
  Future<Result<void>> deleteClient(String id) async {
    await _simulateNetwork();
    if (!_service.deleteClient(id)) {
      return Result.error(Exception('Cliente não encontrado'));
    }
    return const Result.ok(null);
  }
}
