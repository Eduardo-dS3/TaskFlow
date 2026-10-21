import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/domain/models/member.dart';
import 'package:taskflow/domain/models/task.dart';

void main() {
  final task = Task(
    id: 't-1',
    code: 'TK-1',
    title: 'Tarefa',
    summary: 'Resumo',
    status: TaskStatus.pending,
    priority: TaskPriority.medium,
    category: 'Geral',
  );
  final now = DateTime(2024, 10, 18, 10);

  group('Task.withStatus', () {
    test('registra a data de conclusão ao concluir', () {
      final done = task.withStatus(TaskStatus.done, now: now);
      expect(done.status, TaskStatus.done);
      expect(done.completedAt, now);
    });

    test('limpa a data de conclusão ao reabrir', () {
      final reopened = task
          .withStatus(TaskStatus.done, now: now)
          .withStatus(TaskStatus.inProgress, now: now);
      expect(reopened.status, TaskStatus.inProgress);
      expect(reopened.completedAt, isNull);
    });
  });

  test('Task.withComment adiciona no topo e incrementa o contador', () {
    final comment = TaskComment(
      id: 'c-1',
      author: const Member(id: 'u', name: 'Ana Lima', role: 'Dev'),
      body: 'Oi',
      createdAt: now,
    );
    final updated = task.withComment(comment);
    expect(updated.comments.single.body, 'Oi');
    expect(updated.commentCount, 1);
  });
}
