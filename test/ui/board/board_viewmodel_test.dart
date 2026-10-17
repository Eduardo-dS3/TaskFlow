import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/domain/models/task.dart';
import 'package:taskflow/ui/board/view_models/board_viewmodel.dart';

import '../../../testing/fakes/fake_repositories.dart';

void main() {
  group('BoardViewModel', () {
    late FakeTaskRepository repository;
    late BoardViewModel viewModel;

    setUp(() async {
      repository = FakeTaskRepository();
      viewModel = BoardViewModel(taskRepository: repository, clock: testClock);
      await pumpEventQueue();
    });

    test('carrega indicadores e tarefas', () {
      expect(viewModel.load.completed, isTrue);
      expect(viewModel.overview, isNotNull);
      expect(viewModel.tasksFor(TaskStatus.pending), hasLength(3));
      expect(viewModel.columnCount(TaskStatus.pending), 14);
    });

    test('filtra por texto e prioridade', () {
      viewModel.setQuery('jwt');
      expect(viewModel.filteredTasks.single.title, contains('JWT'));
      // Com filtros ativos, o contador reflete as tarefas visíveis.
      expect(viewModel.columnCount(TaskStatus.pending), 1);

      viewModel
        ..setQuery('')
        ..setPriorityFilter(TaskPriority.low);
      expect(
        viewModel.filteredTasks.every((t) => t.priority == TaskPriority.low),
        isTrue,
      );
    });

    test('move tarefa entre colunas', () async {
      final task = viewModel.tasksFor(TaskStatus.pending).first;
      await viewModel.moveTask.execute((task, TaskStatus.done));

      expect(
        viewModel.tasksFor(TaskStatus.done).map((t) => t.id),
        contains(task.id),
      );
      expect(repository.saveCalls, 1);
    });

    test('desfaz a movimentação quando o salvamento falha', () async {
      repository.failNextSave = true;
      final task = viewModel.tasksFor(TaskStatus.pending).first;
      await viewModel.moveTask.execute((task, TaskStatus.done));

      expect(viewModel.moveTask.error, isTrue);
      expect(
        viewModel.tasksFor(TaskStatus.pending).map((t) => t.id),
        contains(task.id),
      );
    });
  });
}
