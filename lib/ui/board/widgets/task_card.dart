import 'package:flutter/material.dart';

import '../../../domain/models/task.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/avatar.dart';
import '../../core/ui/meter.dart';
import '../../core/ui/pill.dart';
import '../../core/ui/surface_card.dart';

/// Card de uma tarefa no quadro Kanban.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.now,
    this.onTap,
  });

  final Task task;
  final DateTime now;
  final VoidCallback? onTap;

  bool get _done => task.status == TaskStatus.done;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PriorityPill(priority: task.priority),
              const Spacer(),
              if (task.reviewed)
                const Pill(
                  label: 'Revisado',
                  icon: Icons.check_circle_outline,
                  foreground: AppColors.success,
                  background: AppColors.successSoft,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            task.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: _done ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            task.excerpt,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Pill(
            label: task.category,
            foreground: AppColors.textPrimary,
            background: AppColors.primarySoft,
          ),
          if (task.progress case final progress?) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Progresso', style: TextStyle(fontSize: 11)),
                const Spacer(),
                Text(
                  Formatters.percent(progress),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Meter(value: progress, color: AppColors.info),
          ],
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: _meta(),
                ),
              ),
              const SizedBox(width: 8),
              AvatarStack(
                initials: [for (final m in task.links.people) m.initials],
                size: 26,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _meta() {
    const muted = AppColors.textSecondary;
    const style = TextStyle(fontSize: 12, color: muted);
    final items = <Widget>[];

    if (_done) {
      final completedAt = task.completedAt;
      if (completedAt != null) {
        final today =
            Formatters.completedLabel(completedAt, now) == 'Concluído hoje';
        final color = today ? AppColors.success : muted;
        items.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                today ? Icons.check_circle_outline : Icons.done_all,
                size: 15,
                color: color,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  Formatters.completedLabel(completedAt, now),
                  overflow: TextOverflow.ellipsis,
                  style: style.copyWith(color: color),
                ),
              ),
            ],
          ),
        );
      }
      return items;
    }

    if (task.dueDate case final due?) {
      final urgent = due.difference(now).inDays < 1;
      final color = urgent ? AppColors.danger : muted;
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              urgent ? Icons.schedule : Icons.calendar_today_outlined,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              Formatters.dueLabel(due, now),
              style: style.copyWith(color: color),
            ),
          ],
        ),
      );
    }
    if (task.subtasks.isNotEmpty) {
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.checklist, size: 15, color: muted),
            const SizedBox(width: 4),
            Text(
              '${task.completedSubtasks}/${task.subtasks.length}',
              style: style,
            ),
          ],
        ),
      );
    }
    if (task.commentCount > 0) {
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 14, color: muted),
            const SizedBox(width: 4),
            Text('${task.commentCount}', style: style),
          ],
        ),
      );
    }

    return [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(width: 12),
        items[i],
      ],
    ];
  }
}
