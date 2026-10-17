import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../../utils/result.dart';
import '../../core/themes/dimens.dart';
import '../../core/ui/command_view.dart';
import '../view_models/task_details_viewmodel.dart';
import 'activity_section.dart';
import 'attachments_panel.dart';
import 'checklist_section.dart';
import 'description_section.dart';
import 'properties_panel.dart';
import 'task_header.dart';

/// Tela "Cadastro & Edição de Tarefas".
class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key, required this.viewModel});

  final TaskDetailsViewModel viewModel;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _subscribe(widget.viewModel);
  }

  @override
  void didUpdateWidget(covariant TaskDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      _unsubscribe(oldWidget.viewModel);
      _subscribe(widget.viewModel);
    }
  }

  @override
  void dispose() {
    _unsubscribe(widget.viewModel);
    super.dispose();
  }

  void _subscribe(TaskDetailsViewModel vm) {
    vm.save.addListener(_onSaveResult);
    vm.delete.addListener(_onDeleteResult);
    vm.addComment.addListener(_onCommentResult);
  }

  void _unsubscribe(TaskDetailsViewModel vm) {
    vm.save.removeListener(_onSaveResult);
    vm.delete.removeListener(_onDeleteResult);
    vm.addComment.removeListener(_onCommentResult);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _onSaveResult() {
    final vm = widget.viewModel;
    final result = vm.save.result;
    if (result == null) return;
    vm.save.clearResult();

    switch (result) {
      case Ok(:final value):
        _showMessage('Alterações salvas');
        // Após criar, a URL passa a apontar para a tarefa salva.
        if (vm.isNew) context.go(Routes.taskWithId(value.id));
      case Error(:final error):
        _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _onDeleteResult() {
    final command = widget.viewModel.delete;
    if (command.completed) {
      command.clearResult();
      _showMessage('Tarefa excluída');
      context.go(Routes.board);
    } else if (command.error) {
      command.clearResult();
      _showMessage('Não foi possível excluir a tarefa');
    }
  }

  void _onCommentResult() {
    final command = widget.viewModel.addComment;
    if (command.error) {
      command.clearResult();
      _showMessage('Salve a tarefa antes de comentar');
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) widget.viewModel.delete.execute();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return CommandView(
      command: vm.load,
      onRetry: vm.load.execute,
      errorTitle: 'Tarefa não encontrada',
      builder: (context) => LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= Dimens.breakpointWide;
          final padding = constraints.maxWidth < 600
              ? Dimens.paddingPageCompact
              : Dimens.paddingPage;

          final main = [
            DescriptionSection(viewModel: vm),
            ChecklistSection(viewModel: vm),
            if (!vm.isNew) ActivitySection(viewModel: vm),
          ];
          final side = [
            PropertiesPanel(viewModel: vm),
            AttachmentsPanel(viewModel: vm),
          ];

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TaskHeader(
                  viewModel: vm,
                  onDelete: _confirmDelete,
                  onBack: () => context.go(Routes.board),
                ),
                const SizedBox(height: 20),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: _column(main)),
                      const SizedBox(width: 20),
                      Expanded(flex: 3, child: _column(side)),
                    ],
                  )
                else
                  _column([...main.take(1), ...side, ...main.skip(1)]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _column(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) const SizedBox(height: 20),
        children[i],
      ],
    ],
  );
}
