import 'package:flutter/material.dart';

import '../../../domain/models/member.dart';
import '../../../domain/models/task.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/pill.dart';
import '../view_models/board_viewmodel.dart';

class BoardToolbar extends StatelessWidget {
  const BoardToolbar({
    super.key,
    required this.viewModel,
    required this.onCreateTask,
  });

  final BoardViewModel viewModel;
  final VoidCallback onCreateTask;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<BoardViewMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: BoardViewMode.kanban,
              icon: Icon(Icons.view_kanban_outlined, size: 18),
              label: Text('Kanban'),
            ),
            ButtonSegment(
              value: BoardViewMode.list,
              icon: Icon(Icons.table_rows_outlined, size: 18),
              label: Text('Lista / Tabela'),
            ),
          ],
          selected: {viewModel.viewMode},
          onSelectionChanged: (s) => viewModel.setViewMode(s.first),
        ),
        if (viewModel.overview case final overview?)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SPRINT ATIVA:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Pill(
                label: overview.sprintName,
                foreground: AppColors.primaryDark,
                background: AppColors.primarySoft,
                fontSize: 12,
              ),
            ],
          ),
        SizedBox(
          width: 200,
          child: TextField(
            onChanged: viewModel.setQuery,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.filter_alt_outlined, size: 18),
              hintText: 'Filtrar por nome...',
            ),
          ),
        ),
        _FilterMenu<Member?>(
          icon: Icons.people_outline,
          label: viewModel.assigneeFilter?.name ?? 'Responsável',
          options: [
            (null, 'Todos'),
            for (final m in viewModel.assignees) (m, m.name),
          ],
          onSelected: viewModel.setAssigneeFilter,
        ),
        _FilterMenu<TaskPriority?>(
          icon: Icons.flag_outlined,
          label: viewModel.priorityFilter == null
              ? 'Prioridade'
              : Formatters.priority(viewModel.priorityFilter!),
          options: [
            (null, 'Todas'),
            for (final p in TaskPriority.values) (p, Formatters.priority(p)),
          ],
          onSelected: viewModel.setPriorityFilter,
        ),
        FilledButton.icon(
          onPressed: onCreateTask,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Criar Tarefa'),
        ),
      ],
    );
  }
}

class _FilterMenu<T> extends StatelessWidget {
  const _FilterMenu({
    required this.icon,
    required this.label,
    required this.options,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final List<(T, String)> options;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        for (final (value, text) in options)
          MenuItemButton(onPressed: () => onSelected(value), child: Text(text)),
      ],
      builder: (context, controller, _) => OutlinedButton.icon(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: Icon(icon, size: 18),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}
