import 'package:flutter/material.dart';

import '../../core/themes/colors.dart';
import '../../core/ui/avatar.dart';
import '../view_models/shell_viewmodel.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.viewModel,
    required this.showMenuButton,
    required this.onNewTask,
  });

  final ShellViewModel viewModel;
  final bool showMenuButton;
  final VoidCallback onNewTask;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 8 : 24,
            12,
            compact ? 8 : 24,
            8,
          ),
          child: Row(
            children: [
              if (showMenuButton)
                IconButton(
                  tooltip: 'Menu',
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: const TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, size: 20),
                        hintText: 'Buscar tarefas, projetos... [Ctrl+K]',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              compact
                  ? IconButton.filled(
                      tooltip: 'Nova Tarefa',
                      onPressed: onNewTask,
                      icon: const Icon(Icons.add),
                    )
                  : FilledButton.icon(
                      onPressed: onNewTask,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Nova Tarefa'),
                    ),
              const SizedBox(width: 8),
              ListenableBuilder(
                listenable: viewModel,
                builder: (context, _) => Row(
                  children: [
                    IconButton(
                      tooltip: 'Notificações',
                      onPressed: viewModel.markNotificationsAsRead,
                      icon: Badge(
                        isLabelVisible: viewModel.hasNotifications,
                        smallSize: 8,
                        backgroundColor: AppColors.danger,
                        child: const Icon(Icons.notifications_outlined),
                      ),
                    ),
                    if (viewModel.user case final user?) ...[
                      const SizedBox(width: 8),
                      InitialsAvatar(initials: user.initials, size: 36),
                      if (!compact) ...[
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              user.role,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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
