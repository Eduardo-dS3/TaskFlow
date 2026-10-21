import 'package:taskflow/data/repositories/auth/auth_repository_local.dart';
import 'package:taskflow/data/repositories/project/project_repository_local.dart';
import 'package:taskflow/data/repositories/settings/settings_repository_local.dart';
import 'package:taskflow/data/repositories/task/task_repository.dart';
import 'package:taskflow/data/repositories/task/task_repository_local.dart';
import 'package:taskflow/data/repositories/user/user_repository_local.dart';
import 'package:taskflow/data/services/local/local_data_service.dart';
import 'package:taskflow/domain/models/task.dart';
import 'package:taskflow/domain/use_cases/build_report_use_case.dart';
import 'package:taskflow/domain/use_cases/load_board_use_case.dart';
import 'package:taskflow/domain/use_cases/load_portfolio_use_case.dart';
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
  Future<Result<List<Task>>> getTasks() => _delegate.getTasks();

  @override
  Future<Result<Task>> getTask(String id) => _delegate.getTask(id);

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
  Future<Result<TaskComment>> addComment(String taskId, String body) =>
      _delegate.addComment(taskId, body);

  @override
  Future<Result<Attachment>> uploadAttachment(
    String taskId, {
    required String fileName,
    required List<int> bytes,
  }) => _delegate.uploadAttachment(taskId, fileName: fileName, bytes: bytes);

  @override
  Future<Result<void>> deleteAttachment(Attachment attachment) =>
      _delegate.deleteAttachment(attachment);

  @override
  Future<Result<Uri>> attachmentUrl(Attachment attachment) =>
      _delegate.attachmentUrl(attachment);
}

/// Repositórios e casos de uso falsos compartilhando os mesmos dados.
class FakeDependencies {
  FakeDependencies() : service = fakeDataService() {
    tasks = FakeTaskRepository(service);
    projects = ProjectRepositoryLocal(
      localDataService: service,
      latency: Duration.zero,
    );
    users = UserRepositoryLocal(localDataService: service);
    settings = SettingsRepositoryLocal(localDataService: service);
  }

  final LocalDataService service;
  final auth = AuthRepositoryLocal();
  late final FakeTaskRepository tasks;
  late final ProjectRepositoryLocal projects;
  late final UserRepositoryLocal users;
  late final SettingsRepositoryLocal settings;

  LoadBoardUseCase get loadBoard => LoadBoardUseCase(
    taskRepository: tasks,
    userRepository: users,
    settingsRepository: settings,
    clock: testClock,
  );

  LoadPortfolioUseCase get loadPortfolio => LoadPortfolioUseCase(
    projectRepository: projects,
    taskRepository: tasks,
    userRepository: users,
    clock: testClock,
  );

  BuildReportUseCase get buildReport => BuildReportUseCase(
    taskRepository: tasks,
    userRepository: users,
    settingsRepository: settings,
    clock: testClock,
  );
}
