import 'package:flutter/material.dart';

import '../../../domain/models/task.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/pill.dart';
import '../../core/ui/surface_card.dart';
import '../view_models/task_details_viewmodel.dart';

/// Breadcrumb + cabeçalho com título, status, prioridade e ações.
class TaskHeader extends StatefulWidget {
  const TaskHeader({
    super.key,
    required this.viewModel,
    required this.onDelete,
    required this.onBack,
  });

  final TaskDetailsViewModel viewModel;
  final VoidCallback onDelete;
  final VoidCallback onBack;

  @override
  State<TaskHeader> createState() => _TaskHeaderState();
}

class _TaskHeaderState extends State<TaskHeader> {
  late final _titleController = TextEditingController(
    text: widget.viewModel.task?.title,
  );

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final task = vm.task!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Breadcrumb(
              task: task,
              isNew: vm.isNew,
              saveLabel: _saveLabel(vm),
              onBack: widget.onBack,
            ),
            const SizedBox(height: 12),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: _titleBlock(task),
                      ),
                      _actions(vm),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _EnumDropdown<TaskStatus>(
                        prefix: 'STATUS:',
                        value: task.status,
                        values: TaskStatus.values,
                        label: Formatters.taskStatusSingular,
                        foreground: AppColors.info,
                        background: AppColors.infoSoft,
                        onChanged: vm.setStatus,
                      ),
                      _EnumDropdown<TaskPriority>(
                        prefix: 'PRIORIDADE:',
                        value: task.priority,
                        values: TaskPriority.values,
                        label: Formatters.priority,
                        foreground: priorityColors(task.priority).$1,
                        background: priorityColors(task.priority).$2,
                        onChanged: vm.setPriority,
                      ),
                      if (task.sprint case final sprint?)
                        Pill(
                          label: sprint,
                          icon: Icons.directions_run,
                          foreground: AppColors.primaryDark,
                          background: AppColors.primarySoft,
                          fontSize: 12,
                        ),
                      if (task.subtasks.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${task.completedSubtasks} de '
                                '${task.subtasks.length} subtarefas finalizadas '
                                '(${Formatters.percent(task.subtaskProgress)})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _saveLabel(TaskDetailsViewModel vm) {
    if (vm.save.running) return 'Salvando…';
    if (vm.dirty) return 'Alterações não salvas';
    final saved = vm.lastSavedAt;
    if (saved == null) return 'Rascunho';
    final minutes = vm.now.difference(saved).inMinutes;
    return minutes < 1 ? 'Salvo agora' : 'Salvo automaticamente há ${minutes}m';
  }

  Widget _titleBlock(Task task) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.terminal, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Pill(
                    label: task.code,
                    foreground: AppColors.primaryDark,
                    background: AppColors.primarySoft,
                  ),
                  if (task.isPrivate)
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline, size: 14),
                        SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            'Privado para o Projeto',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              TextField(
                controller: _titleController,
                onChanged: widget.viewModel.updateTitle,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                decoration: const InputDecoration(
                  hintText: 'Título da tarefa',
                  hintStyle: TextStyle(fontSize: 22),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actions(TaskDetailsViewModel vm) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.share_outlined, size: 18),
          label: const Text('Compartilhar'),
        ),
        if (!vm.isNew)
          ListenableBuilder(
            listenable: vm.delete,
            builder: (context, _) => OutlinedButton.icon(
              onPressed: vm.delete.running ? null : widget.onDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                backgroundColor: AppColors.dangerSoft,
                side: BorderSide.none,
              ),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Excluir'),
            ),
          ),
        ListenableBuilder(
          listenable: vm.save,
          builder: (context, _) => FilledButton.icon(
            onPressed: vm.save.running ? null : vm.save.execute,
            icon: vm.save.running
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.done_all, size: 18),
            label: Text(vm.isNew ? 'Criar Tarefa' : 'Salvar Alterações'),
          ),
        ),
      ],
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({
    required this.task,
    required this.isNew,
    required this.saveLabel,
    required this.onBack,
  });

  final Task task;
  final bool isNew;
  final String saveLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    const muted = TextStyle(fontSize: 12, color: AppColors.textSecondary);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 8,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            InkWell(
              onTap: onBack,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.view_kanban_outlined, size: 14),
                  SizedBox(width: 4),
                  Text('Tarefas', style: muted),
                ],
              ),
            ),
            const Text('/', style: muted),
            Text(isNew ? 'Nova Tarefa' : 'Detalhes da Tarefa', style: muted),
            const Text('/', style: muted),
            Pill(
              label: task.title.isEmpty
                  ? task.code
                  : '${task.code}: ${task.title}',
              foreground: AppColors.textPrimary,
              background: AppColors.primarySoft,
            ),
          ],
        ),
        Pill(
          label: saveLabel,
          dot: true,
          foreground: saveLabel.startsWith('Alterações')
              ? AppColors.warning
              : AppColors.success,
          background: AppColors.surface,
        ),
      ],
    );
  }
}

/// Seletor compacto em formato de etiqueta (status/prioridade).
class _EnumDropdown<T> extends StatelessWidget {
  const _EnumDropdown({
    required this.prefix,
    required this.value,
    required this.values,
    required this.label,
    required this.foreground,
    required this.background,
    required this.onChanged,
  });

  final String prefix;
  final T value;
  final List<T> values;
  final String Function(T) label;
  final Color foreground;
  final Color background;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        for (final v in values)
          MenuItemButton(onPressed: () => onChanged(v), child: Text(label(v))),
      ],
      builder: (context, controller, _) => InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: foreground),
              const SizedBox(width: 6),
              Text(
                prefix,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label(value),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
