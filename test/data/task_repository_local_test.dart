import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/data/repositories/task/task_repository_local.dart';
import 'package:taskflow/utils/result.dart';

import '../../testing/fakes/fake_repositories.dart';

void main() {
  group('TaskRepositoryLocal', () {
    late TaskRepositoryLocal repository;

    setUp(() {
      repository = TaskRepositoryLocal(
        localDataService: fakeDataService(),
        latency: Duration.zero,
      );
    });

    test('retorna erro para tarefa inexistente', () async {
      final result = await repository.getTask('nao-existe');
      expect(result, isA<Error>());
    });

    test('não salva tarefa sem título', () async {
      final draft = (await repository.createDraft() as Ok).value;
      final result = await repository.saveTask(draft);
      expect(result, isA<Error>());
    });

    test('salva nova tarefa e a inclui na listagem', () async {
      final draft = (await repository.createDraft() as Ok).value;
      await repository.saveTask(
        draft.copyWith(title: 'Nova', description: 'x'),
      );

      final tasks = (await repository.getTasks() as Ok).value;
      expect(tasks.any((t) => t.title == 'Nova'), isTrue);
    });

    test('addComment adiciona no início e incrementa o contador', () async {
      final result = await repository.addComment('t-1048', 'Olá');
      final task = (result as Ok).value;
      expect(task.comments.first.body, 'Olá');
      expect(task.commentCount, 4);
    });
  });
}
