import '../../../domain/models/project.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import '../../services/api/mappers/project_mappers.dart';
import 'project_repository.dart';

/// Implementação de [ProjectRepository] no servidor (PocketBase).
class ProjectRepositoryRemote implements ProjectRepository {
  ProjectRepositoryRemote({required ApiClient apiClient}) : _api = apiClient;

  static const _projects = 'projects';
  static const _clients = 'clients';

  final ApiClient _api;

  @override
  Future<Result<List<Project>>> getProjects() async {
    final result = await _api.list(
      _projects,
      sort: 'status,-created',
      expand: projectExpand,
    );
    return switch (result) {
      Ok(:final value) => Result.ok([
        for (final r in value) projectFromRecord(r),
      ]),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<Project>> saveProject(Project project) async {
    if (project.name.trim().isEmpty) {
      return Result.error(Exception('O nome do projeto é obrigatório'));
    }
    final body = projectToBody(project);
    final result = project.id.isEmpty
        ? await _api.create(_projects, body, expand: projectExpand)
        : await _api.update(_projects, project.id, body, expand: projectExpand);
    return switch (result) {
      Ok(:final value) => Result.ok(projectFromRecord(value)),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<void>> deleteProject(String id) => _api.delete(_projects, id);

  @override
  Future<Result<List<Client>>> getClients() async {
    final result = await _api.list(_clients, sort: 'name');
    return switch (result) {
      Ok(:final value) => Result.ok([
        for (final r in value) clientFromRecord(r),
      ]),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<Client>> saveClient(Client client) async {
    if (client.name.trim().isEmpty) {
      return Result.error(Exception('O nome do cliente é obrigatório'));
    }
    final body = clientToBody(client);
    final result = client.id.isEmpty
        ? await _api.create(_clients, body)
        : await _api.update(_clients, client.id, body);
    return switch (result) {
      Ok(:final value) => Result.ok(clientFromRecord(value)),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<void>> deleteClient(String id) => _api.delete(_clients, id);
}
