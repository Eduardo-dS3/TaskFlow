import 'package:flutter/material.dart';

import '../../../domain/models/task.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/avatar.dart';
import '../../core/ui/meter.dart';
import '../../core/ui/pill.dart';
import '../../core/ui/surface_card.dart';
import '../view_models/task_details_viewmodel.dart';
import 'inline_code_text.dart';

/// "Checklist & Subtarefas".
class ChecklistSection extends StatefulWidget {
  const ChecklistSection({super.key, required this.viewModel});

  final TaskDetailsViewModel viewModel;

  @override
  State<ChecklistSection> createState() => _ChecklistSectionState();
}

class _ChecklistSectionState extends State<ChecklistSection> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _adding = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String value) {
    widget.viewModel.addSubtask(value);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final task = vm.task!;
        return SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionTitle(
                icon: Icons.checklist,
                title: 'Checklist & Subtarefas',
                trailing: SizedBox(
                  width: 120,
                  child: Row(
                    children: [
                      Text(
                        Formatters.percent(task.subtaskProgress),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Meter(
                          value: task.subtaskProgress,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (task.subtasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Nenhuma subtarefa ainda.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ),
              for (final subtask in task.subtasks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SubtaskTile(
                    subtask: subtask,
                    onToggle: () => vm.toggleSubtask(subtask.id),
                    onRemove: () => vm.removeSubtask(subtask.id),
                  ),
                ),
              const SizedBox(height: 8),
              if (_adding)
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  onSubmitted: _submit,
                  decoration: InputDecoration(
                    hintText: 'Descreva a subtarefa e pressione Enter',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _adding = false),
                    ),
                  ),
                )
              else
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primarySoft,
                      ),
                      onPressed: () => setState(() => _adding = true),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Adicionar Subtarefa'),
                    ),
                    const Text(
                      'Pressione Enter para criar rápido',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SubtaskTile extends StatelessWidget {
  const _SubtaskTile({
    required this.subtask,
    required this.onToggle,
    required this.onRemove,
  });

  final Subtask subtask;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  (Color, Color) get _stageColors => switch (subtask.stage) {
    SubtaskStage.resolved => (AppColors.success, AppColors.successSoft),
    SubtaskStage.readyForTest => (AppColors.primaryDark, AppColors.primarySoft),
    SubtaskStage.queued => (AppColors.neutral, AppColors.neutralSoft),
  };

  @override
  Widget build(BuildContext context) {
    final done = subtask.done;
    final highlighted = subtask.stage == SubtaskStage.readyForTest;
    final (fg, bg) = _stageColors;
    final title = subtask.code == null
        ? subtask.title
        : _withCode(subtask.title, subtask.code!);

    // Bordas com cores diferentes não podem ter cantos arredondados, então a
    // faixa de destaque fica em uma caixa interna recortada pela externa.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: done ? AppColors.surfaceMuted : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Container(
        decoration: highlighted
            ? const BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.info, width: 3),
                ),
              )
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            Checkbox(value: done, onChanged: (_) => onToggle()),
            Expanded(
              child: InlineCodeText(
                title,
                strike: done,
                style: TextStyle(
                  fontSize: 13,
                  color: done ? AppColors.textSecondary : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Pill(
                label: Formatters.subtaskStage(subtask.stage),
                foreground: fg,
                background: bg,
              ),
            ),
            if (subtask.assignee case final assignee?) ...[
              const SizedBox(width: 8),
              InitialsAvatar(initials: assignee.initials, size: 24),
            ],
            PopupMenuButton<void>(
              iconSize: 18,
              tooltip: 'Opções',
              itemBuilder: (context) => [
                PopupMenuItem(onTap: onRemove, child: const Text('Remover')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Insere o trecho técnico no título: rotas ficam ao final, entre
  /// parênteses; eventos ficam após o verbo.
  static String _withCode(String title, String code) {
    if (code.startsWith('/')) return '$title (`$code`)';
    final words = title.split(' ');
    return [
      words.first,
      words.length > 1 ? words[1] : '',
      '`$code`',
      ...words.skip(2),
    ].where((w) => w.isNotEmpty).join(' ');
  }
}
