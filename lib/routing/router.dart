import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../domain/models/task.dart';
import '../ui/auth/view_models/login_viewmodel.dart';
import '../ui/auth/widgets/login_screen.dart';
import '../ui/board/view_models/board_viewmodel.dart';
import '../ui/board/widgets/board_screen.dart';
import '../ui/projects/view_models/projects_viewmodel.dart';
import '../ui/projects/widgets/projects_screen.dart';
import '../ui/reports/view_models/reports_viewmodel.dart';
import '../ui/reports/widgets/reports_screen.dart';
import '../ui/settings/view_models/settings_viewmodel.dart';
import '../ui/settings/widgets/settings_screen.dart';
import '../ui/shell/view_models/shell_viewmodel.dart';
import '../ui/shell/widgets/app_shell.dart';
import '../ui/task_details/view_models/task_details_viewmodel.dart';
import '../ui/task_details/widgets/task_details_screen.dart';
import '../ui/team/view_models/team_viewmodel.dart';
import '../ui/team/widgets/team_screen.dart';
import 'routes.dart';

/// Configuração de navegação.
///
/// Cada rota cria seu ViewModel injetando repositórios e casos de uso
/// obtidos do [Provider] (injeção de dependência), conforme o guia de
/// arquitetura. Sem sessão ativa, toda rota leva ao login.
GoRouter router(AuthRepository authRepository) {
  // O shell persiste entre as rotas, então seu ViewModel é criado uma vez.
  ShellViewModel? shellViewModel;

  return GoRouter(
    initialLocation: Routes.board,
    refreshListenable: authRepository,
    redirect: (context, state) => _redirect(authRepository, state),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => Routes.board),
      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) => _page(
          state,
          LoginScreen(
            viewModel: LoginViewModel(authRepository: context.read()),
          ),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          viewModel: shellViewModel ??= ShellViewModel(
            authRepository: context.read(),
            userRepository: context.read(),
            taskRepository: context.read(),
          ),
          location: state.uri.path,
          child: child,
        ),
        routes: _appRoutes,
      ),
    ],
  );
}

String? _redirect(AuthRepository auth, GoRouterState state) {
  final atLogin = state.matchedLocation == Routes.login;
  if (!auth.isAuthenticated) return atLogin ? null : Routes.login;
  if (atLogin) return Routes.board;
  return null;
}

final _appRoutes = <RouteBase>[
  GoRoute(
    path: Routes.board,
    pageBuilder: (context, state) => _page(
      state,
      BoardScreen(
        viewModel: BoardViewModel(
          loadBoard: context.read(),
          taskRepository: context.read(),
          initialQuery: state.uri.queryParameters['q'] ?? '',
        ),
      ),
    ),
  ),
  GoRoute(
    path: Routes.newTask,
    pageBuilder: (context, state) => _page(
      state,
      TaskDetailsScreen(
        viewModel: _taskDetails(
          context,
          initialStatus: TaskStatus.values
              .asNameMap()[state.uri.queryParameters['status']],
        ),
      ),
    ),
  ),
  GoRoute(
    path: '${Routes.tasks}/:id',
    pageBuilder: (context, state) => _page(
      state,
      TaskDetailsScreen(
        viewModel: _taskDetails(context, taskId: state.pathParameters['id']),
      ),
    ),
  ),
  GoRoute(
    path: Routes.projects,
    pageBuilder: (context, state) => _page(
      state,
      ProjectsScreen(
        viewModel: ProjectsViewModel(
          loadPortfolio: context.read(),
          projectRepository: context.read(),
          userRepository: context.read(),
        ),
      ),
    ),
  ),
  GoRoute(
    path: Routes.reports,
    pageBuilder: (context, state) => _page(
      state,
      ReportsScreen(
        viewModel: ReportsViewModel(
          buildReport: context.read(),
          projectRepository: context.read(),
          settingsRepository: context.read(),
        ),
      ),
    ),
  ),
  GoRoute(
    path: Routes.settings,
    pageBuilder: (context, state) => _page(
      state,
      SettingsScreen(
        viewModel: SettingsViewModel(
          userRepository: context.read(),
          settingsRepository: context.read(),
        ),
      ),
    ),
  ),
  GoRoute(
    path: Routes.team,
    pageBuilder: (context, state) => _page(
      state,
      TeamScreen(viewModel: TeamViewModel(userRepository: context.read())),
    ),
  ),
];

TaskDetailsViewModel _taskDetails(
  BuildContext context, {
  String? taskId,
  TaskStatus? initialStatus,
}) => TaskDetailsViewModel(
  taskRepository: context.read(),
  userRepository: context.read(),
  projectRepository: context.read(),
  settingsRepository: context.read(),
  taskId: taskId,
  initialStatus: initialStatus ?? TaskStatus.pending,
);

/// Transição sem animação, adequada para navegação lateral em web/desktop.
Page<void> _page(GoRouterState state, Widget child) =>
    NoTransitionPage(key: state.pageKey, child: child);
