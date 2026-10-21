import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/data/repositories/task/task_repository_local.dart';
import 'package:taskflow/domain/models/task.dart';
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
      expect(result, isA<Error<Task>>());
    });

    test('não salva tarefa sem título', () async {
      final result = await repository.saveTask(Task.draft(now: testNow));
      expect(result, isA<Error<Task>>());
    });

    test('cria tarefa nova com id e código e a inclui na listagem', () async {
      final draft = Task.draft(now: testNow).copyWith(title: 'Nova');
      final saved = (await repository.saveTask(draft) as Ok<Task>).value;

      expect(saved.isSaved, isTrue);
      expect(saved.code, startsWith('TK-'));
      final tasks = (await repository.getTasks() as Ok<List<Task>>).value;
      expect(tasks.any((Task t) => t.id == saved.id), isTrue);
    });

    test('addComment devolve o comentário e incrementa o contador', () async {
      final result = await repository.addComment('t-1048', 'Olá');
      expect((result as Ok<TaskComment>).value.body, 'Olá');

      final task = (await repository.getTask('t-1048') as Ok<Task>).value;
      expect(task.comments.first.body, 'Olá');
      expect(task.commentCount, 3);
    });

    test('anexa e remove arquivo', () async {
      final upload = await repository.uploadAttachment(
        't-1048',
        fileName: 'nota.pdf',
        bytes: [1, 2, 3],
      );
      final attachment = (upload as Ok<Attachment>).value;
      expect(attachment.type, AttachmentType.pdf);
      expect(await repository.attachmentUrl(attachment), isA<Ok<Uri>>());

      await repository.deleteAttachment(attachment);
      final task = (await repository.getTask('t-1048') as Ok<Task>).value;
      expect(task.attachments.any((a) => a.id == attachment.id), isFalse);
    });
  });
}
