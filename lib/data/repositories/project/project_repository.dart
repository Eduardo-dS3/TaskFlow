import '../../../domain/models/project.dart';
import '../../../utils/result.dart';

/// Fonte da verdade para projetos e clientes.
abstract class ProjectRepository {
  /// Projetos cadastrados (sem os totais de tarefas, calculados no domínio).
  Future<Result<List<Project>>> getProjects();

  /// Cria o projeto quando ainda não foi salvo, ou atualiza o existente.
  Future<Result<Project>> saveProject(Project project);

  Future<Result<void>> deleteProject(String id);

  Future<Result<List<Client>>> getClients();

  /// Cria o cliente quando ainda não foi salvo, ou atualiza o existente.
  Future<Result<Client>> saveClient(Client client);

  Future<Result<void>> deleteClient(String id);
}
