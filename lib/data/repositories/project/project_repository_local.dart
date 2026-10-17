import '../../../domain/models/project.dart';
import '../../../utils/result.dart';
import '../../services/local/local_data_service.dart';
import 'project_repository.dart';

class ProjectRepositoryLocal implements ProjectRepository {
  ProjectRepositoryLocal({
    required LocalDataService localDataService,
    this._latency = const Duration(milliseconds: 300),
  }) : _service = localDataService;

  final LocalDataService _service;
  final Duration _latency;

  @override
  Future<Result<PortfolioSummary>> getPortfolioSummary() async {
    await Future.delayed(_latency);
    return Result.ok(_service.portfolioSummary);
  }

  @override
  Future<Result<List<Project>>> getProjects() async {
    await Future.delayed(_latency);
    return Result.ok(_service.projects);
  }

  @override
  Future<Result<List<Client>>> getClients() async {
    await Future.delayed(_latency);
    return Result.ok(_service.clients);
  }

  @override
  Future<Result<List<MemberAllocation>>> getAllocations() async {
    await Future.delayed(_latency);
    return Result.ok(_service.allocations);
  }
}
