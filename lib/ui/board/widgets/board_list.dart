import 'package:flutter/material.dart';

import '../../../domain/models/task.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/avatar.dart';
import '../../core/ui/pill.dart';
import '../../core/ui/surface_card.dart';
import '../view_models/board_viewmodel.dart';
import 'board_kanban.dart';

/// Modo "Lista / Tabela" do quadro.
class BoardList extends StatelessWidget {
  const BoardList({
    super.key,
    required this.viewModel,
    required this.onOpenTask,
  });

  final BoardViewModel viewModel;
  final ValueChanged<Task> onOpenTask;

  @override
  Widget build(BuildContext context) {
    final tasks = viewModel.filteredTasks;
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('Nenhuma tarefa encontrada'),
            ),
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0) const Divider(),
            ListTile(
              onTap: () => onOpenTask(tasks[i]),
              leading: Icon(
                Icons.circle,
                size: 12,
                color: statusColor(tasks[i].status),
              ),
              title: Text(
                tasks[i].title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                '${tasks[i].code} • ${tasks[i].category} • '
                '${Formatters.taskStatusSingular(tasks[i].status)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PriorityPill(priority: tasks[i].priority),
                  const SizedBox(width: 12),
                  AvatarStack(
                    initials: [for (final m in tasks[i].assignees) m.initials],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
