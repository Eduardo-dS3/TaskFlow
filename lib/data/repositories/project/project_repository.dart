import '../../../domain/models/project.dart';
import '../../../utils/result.dart';

/// Fonte da verdade para projetos, clientes e alocação do time.
abstract class ProjectRepository {
  Future<Result<PortfolioSummary>> getPortfolioSummary();

  Future<Result<List<Project>>> getProjects();

  Future<Result<List<Client>>> getClients();

  Future<Result<List<MemberAllocation>>> getAllocations();
}
