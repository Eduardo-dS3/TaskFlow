import 'package:flutter/material.dart';

import '../../../domain/models/task.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/themes/dimens.dart';
import '../view_models/board_viewmodel.dart';
import 'task_card.dart';

/// Colunas do quadro Kanban com suporte a arrastar e soltar.
class BoardKanban extends StatelessWidget {
  const BoardKanban({
    super.key,
    required this.viewModel,
    required this.onOpenTask,
  });

  final BoardViewModel viewModel;
  final ValueChanged<Task> onOpenTask;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = [
          for (final status in TaskStatus.values)
            _KanbanColumn(
              status: status,
              count: viewModel.columnCount(status),
              tasks: viewModel.tasksFor(status),
              now: viewModel.now,
              onOpenTask: onOpenTask,
              onDrop: (task) => viewModel.moveTask.execute((task, status)),
            ),
        ];

        if (constraints.maxWidth >= Dimens.breakpointWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < columns.length; i++) ...[
                if (i > 0) const SizedBox(width: 24),
                Expanded(child: columns[i]),
              ],
            ],
          );
        }

        // Em telas estreitas as colunas rolam horizontalmente.
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final column in columns)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(width: 290, child: column),
                ),
            ],
          ),
        );
      },
    );
  }
}

Color statusColor(TaskStatus status) => switch (status) {
  TaskStatus.pending => AppColors.danger,
  TaskStatus.inProgress => AppColors.info,
  TaskStatus.done => AppColors.success,
};

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.status,
    required this.count,
    required this.tasks,
    required this.now,
    required this.onOpenTask,
    required this.onDrop,
  });

  final TaskStatus status;
  final int count;
  final List<Task> tasks;
  final DateTime now;
  final ValueChanged<Task> onOpenTask;
  final ValueChanged<Task> onDrop;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, candidates, _) {
        final highlighted = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: highlighted ? AppColors.primarySoft : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(Dimens.radius),
            border: Border.all(
              color: highlighted ? AppColors.primary : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ColumnHeader(status: status, count: count),
              const SizedBox(height: 12),
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Nenhuma tarefa',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
              for (final task in tasks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DraggableTaskCard(
                    task: task,
                    now: now,
                    onTap: () => onOpenTask(task),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Título da coluna com bolinha de status e contador.
class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({required this.status, required this.count});

  final TaskStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: statusColor(status)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            Formatters.taskStatus(status),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.neutralSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        const Spacer(),
        const Icon(Icons.add, size: 20, color: AppColors.textSecondary),
      ],
    );
  }
}

/// Card que pode ser arrastado (toque longo) para outra coluna.
class _DraggableTaskCard extends StatelessWidget {
  const _DraggableTaskCard({
    required this.task,
    required this.now,
    required this.onTap,
  });

  final Task task;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Task>(
      data: task,
      delay: const Duration(milliseconds: 150),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 280,
          child: Opacity(
            opacity: 0.9,
            child: TaskCard(task: task, now: now),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: TaskCard(task: task, now: now),
      ),
      child: TaskCard(task: task, now: now, onTap: onTap),
    );
  }
}
