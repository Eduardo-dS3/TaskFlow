import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/data/services/local/seed/seed_tasks.dart';
import 'package:taskflow/domain/models/task.dart';
import 'package:taskflow/ui/task_details/view_models/task_details_viewmodel.dart';

import '../../../testing/fakes/fake_repositories.dart';

void main() {
  late FakeDependencies deps;

  TaskDetailsViewModel build({String? taskId, TaskStatus? status}) {
    deps = FakeDependencies();
    return TaskDetailsViewModel(
      taskRepository: deps.tasks,
      userRepository: deps.users,
      projectRepository: deps.projects,
      settingsRepository: deps.settings,
      taskId: taskId,
      initialStatus: status ?? TaskStatus.pending,
      clock: testClock,
    );
  }

  group('TaskDetailsViewModel (edição)', () {
    late TaskDetailsViewModel viewModel;

    setUp(() async {
      viewModel = build(taskId: 't-1048');
      await pumpEventQueue();
    });

    test('carrega a tarefa, a equipe e os projetos', () {
      expect(viewModel.task?.code, 'TK-1048');
      expect(viewModel.task?.completedSubtasks, 2);
      expect(viewModel.members, isNotEmpty);
      expect(
        viewModel.projects.map((p) => p.name),
        contains('Fintech Core v2'),
      );
      expect(viewModel.dirty, isFalse);
      expect(viewModel.canDelete, isTrue, reason: 'Mariana é administradora');
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

    test('troca de projeto, horas e datas', () {
      viewModel
        ..setProject('p-1')
        ..setHours(estimated: 30, logged: 16)
        ..setDates(start: null, due: null);
      final task = viewModel.task!;
      expect(task.projectName, 'App Mobile Flutter iOS/Android');
      expect(task.estimatedHours, 30);
      expect(task.loggedHours, 16);
      expect(task.dueDate, isNull);

      viewModel.setProject(null);
      expect(viewModel.task!.projectId, isNull);
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

    test('anexa arquivo na tarefa salva', () async {
      final before = viewModel.task!.attachments.length;
      await viewModel.uploadAttachment.execute((name: 'a.png', bytes: [1]));
      expect(viewModel.task!.attachments, hasLength(before + 1));
    });
  });

  _creationTests(build);
}

void _creationTests(
  TaskDetailsViewModel Function({String? taskId, TaskStatus? status}) build,
) {
  group('TaskDetailsViewModel (cadastro)', () {
    test('cria rascunho na coluna e na sprint ativa', () async {
      final viewModel = build(status: TaskStatus.inProgress);
      await pumpEventQueue();

      final draft = viewModel.task!;
      expect(viewModel.isNew, isTrue);
      expect(draft.status, TaskStatus.inProgress);
      expect(draft.sprint, seedActiveSprint);
      expect(draft.owner?.name, 'Mariana Souza');
    });

    test('exige título para salvar e não aceita anexos antes', () async {
      final viewModel = build();
      await pumpEventQueue();

      await viewModel.uploadAttachment.execute((name: 'a.png', bytes: [1]));
      expect(viewModel.uploadAttachment.error, isTrue);

      await viewModel.save.execute();
      expect(viewModel.save.error, isTrue);

      viewModel.updateTitle('Minha tarefa');
      await viewModel.save.execute();
      expect(viewModel.save.completed, isTrue);
      expect(viewModel.task!.isSaved, isTrue);
    });

    test('falha ao carregar tarefa inexistente', () async {
      final viewModel = build(taskId: 'x');
      await pumpEventQueue();
      expect(viewModel.load.error, isTrue);
    });
  });
}
