import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/domain/models/task.dart';
import 'package:taskflow/ui/task_details/view_models/task_details_viewmodel.dart';

import '../../../testing/fakes/fake_repositories.dart';

void main() {
  late FakeTaskRepository repository;

  TaskDetailsViewModel build({String? taskId}) {
    final service = fakeDataService();
    repository = FakeTaskRepository(service);
    return TaskDetailsViewModel(
      taskRepository: repository,
      userRepository: fakeUserRepository(service),
      projectRepository: fakeProjectRepository(service),
      taskId: taskId,
      clock: testClock,
    );
  }

  Future<void> settle() => pumpEventQueue();

  group('TaskDetailsViewModel (edição)', () {
    late TaskDetailsViewModel viewModel;

    setUp(() async {
      viewModel = build(taskId: 't-1048');
      await settle();
    });

    test('carrega a tarefa, membros e projetos', () {
      expect(viewModel.task?.code, 'TK-1048');
      expect(viewModel.task?.completedSubtasks, 2);
      expect(viewModel.members, isNotEmpty);
      expect(viewModel.projectNames, contains('Fintech Core v2'));
      expect(viewModel.dirty, isFalse);
    });

    test('alternar subtarefa marca a tarefa como alterada', () {
      viewModel.toggleSubtask('st-3');
      expect(viewModel.task!.completedSubtasks, 3);
      expect(viewModel.dirty, isTrue);
    });

    test('tags não aceitam duplicatas e removem o #', () {
      viewModel
        ..addTag('#Redis')
        ..addTag('Redis');
      expect(viewModel.task!.tags.where((t) => t == 'Redis'), hasLength(1));
    });

    test('salvar persiste e limpa o estado de alteração', () async {
      viewModel.setPriority(TaskPriority.urgent);
      await viewModel.save.execute();

      expect(viewModel.save.completed, isTrue);
      expect(viewModel.dirty, isFalse);
      expect(viewModel.lastSavedAt, testNow);
    });

    test('comentar preserva edições locais', () async {
      viewModel.updateTitle('Título editado');
      await viewModel.addComment.execute('Novo comentário');

      expect(viewModel.task!.title, 'Título editado');
      expect(viewModel.task!.comments.first.body, 'Novo comentário');
    });
  });

  group('TaskDetailsViewModel (cadastro)', () {
    test('cria rascunho e exige título para salvar', () async {
      final viewModel = build();
      await settle();

      expect(viewModel.isNew, isTrue);
      await viewModel.save.execute();
      expect(viewModel.save.error, isTrue);

      viewModel.updateTitle('Minha tarefa');
      await viewModel.save.execute();
      expect(viewModel.save.completed, isTrue);
    });

    test('falha ao carregar tarefa inexistente', () async {
      final viewModel = build(taskId: 'x');
      await settle();
      expect(viewModel.load.error, isTrue);
    });
  });
}
