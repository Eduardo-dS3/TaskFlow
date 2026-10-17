import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/project/project_repository.dart';
import '../data/repositories/project/project_repository_local.dart';
import '../data/repositories/report/report_repository.dart';
import '../data/repositories/report/report_repository_local.dart';
import '../data/repositories/task/task_repository.dart';
import '../data/repositories/task/task_repository_local.dart';
import '../data/repositories/user/user_repository.dart';
import '../data/repositories/user/user_repository_local.dart';
import '../data/services/local/local_data_service.dart';

/// Dependências da configuração local (dados em memória).
///
/// Os repositórios são expostos pelo tipo abstrato, de modo que a UI nunca
/// dependa de uma implementação concreta. Para usar um backend real, crie
/// `providersRemote` registrando implementações `*Remote`.
List<SingleChildWidget> get providersLocal => [
  Provider(create: (_) => LocalDataService()),
  Provider<TaskRepository>(
    create: (context) => TaskRepositoryLocal(localDataService: context.read()),
  ),
  Provider<ProjectRepository>(
    create: (context) =>
        ProjectRepositoryLocal(localDataService: context.read()),
  ),
  Provider<ReportRepository>(
    create: (context) =>
        ReportRepositoryLocal(localDataService: context.read()),
  ),
  Provider<UserRepository>(
    create: (context) => UserRepositoryLocal(localDataService: context.read()),
  ),
];
