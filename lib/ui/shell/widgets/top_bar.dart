import 'package:flutter/material.dart';

import '../../../domain/models/member.dart';
import '../../../domain/models/task.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/avatar.dart';
import '../view_models/shell_viewmodel.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.viewModel,
    required this.showMenuButton,
    required this.onNewTask,
    required this.onSearch,
    required this.onOpenTask,
  });

  final ShellViewModel viewModel;
  final bool showMenuButton;
  final VoidCallback onNewTask;
  final ValueChanged<String> onSearch;
  final ValueChanged<Task> onOpenTask;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final gutter = compact ? 8.0 : 24.0;
        return Padding(
          padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 8),
          child: Row(
            children: [
              if (showMenuButton)
                IconButton(
                  tooltip: 'Menu',
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              Expanded(child: _SearchField(onSearch: onSearch)),
              const SizedBox(width: 12),
              _NewTaskButton(compact: compact, onPressed: onNewTask),
              const SizedBox(width: 8),
              ListenableBuilder(
                listenable: viewModel,
                builder: (context, _) => Row(
                  children: [
                    _AlertsButton(
                      alerts: viewModel.alerts,
                      onOpenTask: onOpenTask,
                    ),
                    if (viewModel.user case final user?)
                      _UserMenu(
                        user: user,
                        compact: compact,
                        onLogout: viewModel.logout.execute,
                      ),
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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: TextField(
          textInputAction: TextInputAction.search,
          onSubmitted: onSearch,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search, size: 20),
            hintText: 'Buscar tarefas e pressionar Enter',
          ),
        ),
      ),
    );
  }
}

class _NewTaskButton extends StatelessWidget {
  const _NewTaskButton({required this.compact, required this.onPressed});

  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton.filled(
        tooltip: 'Nova Tarefa',
        onPressed: onPressed,
        icon: const Icon(Icons.add),
      );
    }
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Nova Tarefa'),
    );
  }
}

/// Sino com as tarefas do usuário atrasadas ou com prazo próximo.
class _AlertsButton extends StatelessWidget {
  const _AlertsButton({required this.alerts, required this.onOpenTask});

  final List<Task> alerts;
  final ValueChanged<Task> onOpenTask;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Task>(
      tooltip: 'Minhas pendências',
      onSelected: onOpenTask,
      icon: Badge(
        isLabelVisible: alerts.isNotEmpty,
        label: Text('${alerts.length}'),
        backgroundColor: AppColors.danger,
        child: const Icon(Icons.notifications_outlined),
      ),
      itemBuilder: (context) => alerts.isEmpty
          ? [
              const PopupMenuItem<Task>(
                enabled: false,
                child: Text('Nenhuma tarefa sua vence nos próximos dias.'),
              ),
            ]
          : [
              for (final task in alerts)
                PopupMenuItem<Task>(
                  value: task,
                  child: _AlertTile(task: task),
                ),
            ],
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final overdue = task.isOverdue(now);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(
        overdue ? Icons.warning_amber_rounded : Icons.schedule,
        color: overdue ? AppColors.danger : AppColors.warning,
      ),
      title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${task.code} • ${overdue ? 'Atrasada' : 'Prazo'}: '
        '${Formatters.dueLabel(task.dueDate!, now)}',
      ),
    );
  }
}

class _UserMenu extends StatelessWidget {
  const _UserMenu({
    required this.user,
    required this.compact,
    required this.onLogout,
  });

  final Member user;
  final bool compact;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<VoidCallback>(
      tooltip: 'Minha conta',
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: onLogout,
          child: const ListTile(
            leading: Icon(Icons.logout),
            title: Text('Sair'),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
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
                    user.isAdmin ? '${user.role} • Admin' : user.role,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
