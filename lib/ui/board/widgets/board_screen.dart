import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../core/themes/dimens.dart';
import '../../core/ui/command_view.dart';
import '../view_models/board_viewmodel.dart';
import 'board_footer.dart';
import 'board_kanban.dart';
import 'board_list.dart';
import 'board_summary.dart';
import 'board_toolbar.dart';

/// Tela "Dashboard & Quadro de Tarefas".
class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key, required this.viewModel});

  final BoardViewModel viewModel;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.moveTask.addListener(_onMoveResult);
  }

  @override
  void didUpdateWidget(covariant BoardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      oldWidget.viewModel.moveTask.removeListener(_onMoveResult);
      widget.viewModel.moveTask.addListener(_onMoveResult);
    }
  }

  @override
  void dispose() {
    widget.viewModel.moveTask.removeListener(_onMoveResult);
    super.dispose();
  }

  void _onMoveResult() {
    final command = widget.viewModel.moveTask;
    if (command.error) {
      command.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível mover a tarefa')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    return CommandView(
      command: viewModel.load,
      onRetry: viewModel.load.execute,
      builder: (context) => ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final padding = constraints.maxWidth < 600
                  ? Dimens.paddingPageCompact
                  : Dimens.paddingPage;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(padding, 8, padding, padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BoardToolbar(
                      viewModel: viewModel,
                      onCreateTask: () => context.go(Routes.newTask),
                    ),
                    const SizedBox(height: 20),
                    if (viewModel.overview case final overview?)
                      BoardSummary(overview: overview),
                    const SizedBox(height: 24),
                    switch (viewModel.viewMode) {
                      BoardViewMode.kanban => BoardKanban(
                        viewModel: viewModel,
                        onOpenTask: (task) =>
                            context.go(Routes.taskWithId(task.id)),
                      ),
                      BoardViewMode.list => BoardList(
                        viewModel: viewModel,
                        onOpenTask: (task) =>
                            context.go(Routes.taskWithId(task.id)),
                      ),
                    },
                    const SizedBox(height: 24),
                    if (viewModel.overview case final overview?)
                      BoardFooter(onlineMembers: overview.onlineMembers),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
