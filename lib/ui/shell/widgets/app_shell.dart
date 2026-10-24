import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../core/themes/colors.dart';
import '../../core/themes/dimens.dart';
import '../view_models/shell_viewmodel.dart';
import 'help_dialog.dart';
import 'sidebar.dart';
import 'top_bar.dart';

/// Moldura comum a todas as telas: barra lateral + barra superior.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.viewModel,
    required this.location,
    required this.child,
  });

  final ShellViewModel viewModel;
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= Dimens.breakpointSidebar;
        void navigate(String route) {
          if (!wide) Navigator.of(context).maybePop();
          context.go(route);
        }

        final sidebar = ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) => Sidebar(
            location: location,
            isAdmin: viewModel.isAdmin,
            onNavigate: navigate,
            onHelp: () => showHelpDialog(context),
          ),
        );

        return Scaffold(
          drawer: wide ? null : Drawer(width: 260, child: sidebar),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (wide)
                SizedBox(
                  width: Dimens.sidebarWidth,
                  child: Material(color: AppColors.surface, child: sidebar),
                ),
              Expanded(
                child: Column(
                  children: [
                    TopBar(
                      viewModel: viewModel,
                      showMenuButton: !wide,
                      onNewTask: () => context.go(Routes.newTask),
                      onSearch: (query) =>
                          context.go(Routes.boardSearch(query)),
                      onOpenTask: (task) =>
                          context.go(Routes.taskWithId(task.id)),
                      onOpenSettings: () => context.go(Routes.settings),
                    ),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
