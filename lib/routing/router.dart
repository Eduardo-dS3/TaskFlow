import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ui/board/view_models/board_viewmodel.dart';
import '../ui/board/widgets/board_screen.dart';
import '../ui/projects/view_models/projects_viewmodel.dart';
import '../ui/projects/widgets/projects_screen.dart';
import '../ui/reports/view_models/reports_viewmodel.dart';
import '../ui/reports/widgets/reports_screen.dart';
import '../ui/shell/view_models/shell_viewmodel.dart';
import '../ui/shell/widgets/app_shell.dart';
import '../ui/task_details/view_models/task_details_viewmodel.dart';
import '../ui/task_details/widgets/task_details_screen.dart';
import 'routes.dart';

/// Configuração de navegação.
///
/// Cada rota cria seu ViewModel injetando os repositórios obtidos do
/// [Provider] (injeção de dependência), conforme o guia de arquitetura.
GoRouter router() {
  // O shell persiste entre as rotas, então seu ViewModel é criado uma vez.
  ShellViewModel? shellViewModel;

  return GoRouter(
    initialLocation: Routes.board,
    routes: [
      GoRoute(path: '/', redirect: (_, _) => Routes.board),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          viewModel: shellViewModel ??= ShellViewModel(
            userRepository: context.read(),
          ),
          location: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: Routes.board,
            pageBuilder: (context, state) => _page(
              state,
              BoardScreen(
                viewModel: BoardViewModel(taskRepository: context.read()),
              ),
            ),
          ),
          GoRoute(
            path: Routes.newTask,
            pageBuilder: (context, state) => _page(
              state,
              TaskDetailsScreen(
                viewModel: TaskDetailsViewModel(
                  taskRepository: context.read(),
                  userRepository: context.read(),
                  projectRepository: context.read(),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '${Routes.tasks}/:id',
            pageBuilder: (context, state) => _page(
              state,
              TaskDetailsScreen(
                viewModel: TaskDetailsViewModel(
                  taskRepository: context.read(),
                  userRepository: context.read(),
                  projectRepository: context.read(),
                  taskId: state.pathParameters['id'],
                ),
              ),
            ),
          ),
          GoRoute(
            path: Routes.projects,
            pageBuilder: (context, state) => _page(
              state,
              ProjectsScreen(
                viewModel: ProjectsViewModel(projectRepository: context.read()),
              ),
            ),
          ),
          GoRoute(
            path: Routes.reports,
            pageBuilder: (context, state) => _page(
              state,
              ReportsScreen(
                viewModel: ReportsViewModel(reportRepository: context.read()),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Transição sem animação, adequada para navegação lateral em web/desktop.
Page<void> _page(GoRouterState state, Widget child) =>
    NoTransitionPage(key: state.pageKey, child: child);
