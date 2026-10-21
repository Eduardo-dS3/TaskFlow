import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:taskflow/domain/models/task.dart';
import 'package:taskflow/ui/board/view_models/board_viewmodel.dart';

import '../../../testing/fakes/fake_repositories.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  group('BoardViewModel', () {
    late FakeDependencies deps;
    late BoardViewModel viewModel;

    BoardViewModel build({String initialQuery = ''}) => BoardViewModel(
      loadBoard: deps.loadBoard,
      taskRepository: deps.tasks,
      initialQuery: initialQuery,
      clock: testClock,
    );

    setUp(() async {
      deps = FakeDependencies();
      viewModel = build();
      await pumpEventQueue();
    });

    test('carrega tarefas e calcula os indicadores a partir delas', () {
      expect(viewModel.load.completed, isTrue);
      final overview = viewModel.overview!;
      expect(viewModel.tasksFor(TaskStatus.pending), hasLength(3));
      expect(overview.pending, 3);
      expect(overview.inProgress, 3);
      expect(overview.done, 2);
      expect(overview.totalTasks, 8);
    });

    test('filtra por texto e prioridade', () {
      viewModel.setQuery('jwt');
      expect(viewModel.filteredTasks.single.title, contains('JWT'));

      viewModel
        ..setQuery('')
        ..setPriorityFilter(TaskPriority.low);
      expect(
        viewModel.filteredTasks.every((t) => t.priority == TaskPriority.low),
        isTrue,
      );
    });

    test('aplica a busca vinda da barra superior', () async {
      final searched = build(initialQuery: 'TK-1048');
      await pumpEventQueue();
      expect(searched.filteredTasks.single.code, 'TK-1048');
    });

    test('move tarefa entre colunas e atualiza os indicadores', () async {
      final task = viewModel.tasksFor(TaskStatus.pending).first;
      await viewModel.moveTask.execute((task, TaskStatus.done));

      expect(
        viewModel.tasksFor(TaskStatus.done).map((t) => t.id),
        contains(task.id),
      );
      expect(viewModel.overview!.done, 3);
      expect(deps.tasks.saveCalls, 1);
    });

    test('desfaz a movimentação quando o salvamento falha', () async {
      deps.tasks.failNextSave = true;
      final task = viewModel.tasksFor(TaskStatus.pending).first;
      await viewModel.moveTask.execute((task, TaskStatus.done));

      expect(viewModel.moveTask.error, isTrue);
      expect(
        viewModel.tasksFor(TaskStatus.pending).map((t) => t.id),
        contains(task.id),
      );
      expect(viewModel.overview!.done, 2);
    });

    test('exporta as tarefas visíveis em CSV', () {
      final csv = utf8.decode(viewModel.exportCsv().skip(3).toList());
      expect(csv, startsWith('Código;Título;Status'));
      expect(csv.split('\r\n'), hasLength(9));
    });
  });
}
