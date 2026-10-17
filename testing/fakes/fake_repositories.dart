import 'package:taskflow/data/repositories/project/project_repository.dart';
import 'package:taskflow/data/repositories/project/project_repository_local.dart';
import 'package:taskflow/data/repositories/report/report_repository.dart';
import 'package:taskflow/data/repositories/report/report_repository_local.dart';
import 'package:taskflow/data/repositories/task/task_repository.dart';
import 'package:taskflow/data/repositories/task/task_repository_local.dart';
import 'package:taskflow/data/repositories/user/user_repository.dart';
import 'package:taskflow/data/repositories/user/user_repository_local.dart';
import 'package:taskflow/data/services/local/local_data_service.dart';
import 'package:taskflow/domain/models/task.dart';
import 'package:taskflow/utils/result.dart';

/// Data fixa usada em todos os testes.
final testNow = DateTime(2024, 10, 18, 10);

DateTime testClock() => testNow;

LocalDataService fakeDataService() => LocalDataService(clock: testClock);

/// Repositório de tarefas sem latência, com opção de falhar sob demanda.
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository([LocalDataService? service])
    : _delegate = TaskRepositoryLocal(
        localDataService: service ?? fakeDataService(),
        latency: Duration.zero,
      );

  final TaskRepositoryLocal _delegate;

  bool failNextSave = false;
  int saveCalls = 0;

  @override
  Future<Result<SprintOverview>> getSprintOverview() =>
      _delegate.getSprintOverview();

  @override
  Future<Result<List<Task>>> getTasks() => _delegate.getTasks();

  @override
  Future<Result<Task>> getTask(String id) => _delegate.getTask(id);

  @override
  Future<Result<Task>> createDraft() => _delegate.createDraft();

  @override
  Future<Result<Task>> saveTask(Task task) async {
    saveCalls++;
    if (failNextSave) {
      failNextSave = false;
      return Result.error(Exception('falha simulada'));
    }
    return _delegate.saveTask(task);
  }

  @override
  Future<Result<void>> deleteTask(String id) => _delegate.deleteTask(id);

  @override
  Future<Result<Task>> addComment(String taskId, String body) =>
      _delegate.addComment(taskId, body);
}

ProjectRepository fakeProjectRepository([LocalDataService? service]) =>
    ProjectRepositoryLocal(
      localDataService: service ?? fakeDataService(),
      latency: Duration.zero,
    );

ReportRepository fakeReportRepository([LocalDataService? service]) =>
    ReportRepositoryLocal(
      localDataService: service ?? fakeDataService(),
      latency: Duration.zero,
    );

UserRepository fakeUserRepository([LocalDataService? service]) =>
    UserRepositoryLocal(localDataService: service ?? fakeDataService());
