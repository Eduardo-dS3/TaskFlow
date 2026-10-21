import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/auth/auth_repository_local.dart';
import '../data/repositories/project/project_repository.dart';
import '../data/repositories/project/project_repository_local.dart';
import '../data/repositories/project/project_repository_remote.dart';
import '../data/repositories/settings/settings_repository.dart';
import '../data/repositories/settings/settings_repository_local.dart';
import '../data/repositories/settings/settings_repository_remote.dart';
import '../data/repositories/task/task_repository.dart';
import '../data/repositories/task/task_repository_local.dart';
import '../data/repositories/task/task_repository_remote.dart';
import '../data/repositories/user/user_repository.dart';
import '../data/repositories/user/user_repository_local.dart';
import '../data/repositories/user/user_repository_remote.dart';
import '../data/services/api/api_client.dart';
import '../data/services/local/local_data_service.dart';
import '../domain/use_cases/build_report_use_case.dart';
import '../domain/use_cases/load_board_use_case.dart';
import '../domain/use_cases/load_portfolio_use_case.dart';

/// Dependências de produção: dados no servidor do TaskFlow.
///
/// Os repositórios são expostos pelo tipo abstrato, de modo que a UI nunca
/// dependa de uma implementação concreta.
List<SingleChildWidget> providersRemote({
  required ApiClient apiClient,
  required AuthRepository authRepository,
}) => [
  Provider.value(value: apiClient),
  ChangeNotifierProvider<AuthRepository>.value(value: authRepository),
  Provider<TaskRepository>(
    create: (_) => TaskRepositoryRemote(apiClient: apiClient),
  ),
  Provider<ProjectRepository>(
    create: (_) => ProjectRepositoryRemote(apiClient: apiClient),
  ),
  Provider<UserRepository>(
    create: (_) => UserRepositoryRemote(apiClient: apiClient),
  ),
  Provider<SettingsRepository>(
    create: (_) => SettingsRepositoryRemote(apiClient: apiClient),
  ),
  ..._useCases,
];

/// Dependências do modo de demonstração: dados de exemplo em memória.
List<SingleChildWidget> providersLocal() => [
  Provider(create: (_) => LocalDataService()),
  ChangeNotifierProvider<AuthRepository>(create: (_) => AuthRepositoryLocal()),
  Provider<TaskRepository>(
    create: (context) => TaskRepositoryLocal(localDataService: context.read()),
  ),
  Provider<ProjectRepository>(
    create: (context) =>
        ProjectRepositoryLocal(localDataService: context.read()),
  ),
  Provider<UserRepository>(
    create: (context) => UserRepositoryLocal(localDataService: context.read()),
  ),
  Provider<SettingsRepository>(
    create: (context) =>
        SettingsRepositoryLocal(localDataService: context.read()),
  ),
  ..._useCases,
];

/// Casos de uso do domínio, que combinam vários repositórios.
List<SingleChildWidget> get _useCases => [
  Provider(
    create: (context) => LoadBoardUseCase(
      taskRepository: context.read(),
      userRepository: context.read(),
      settingsRepository: context.read(),
    ),
  ),
  Provider(
    create: (context) => LoadPortfolioUseCase(
      projectRepository: context.read(),
      taskRepository: context.read(),
      userRepository: context.read(),
    ),
  ),
  Provider(
    create: (context) => BuildReportUseCase(
      taskRepository: context.read(),
      userRepository: context.read(),
      settingsRepository: context.read(),
    ),
  ),
];
