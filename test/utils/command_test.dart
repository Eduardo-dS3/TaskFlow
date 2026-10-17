import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/utils/command.dart';
import 'package:taskflow/utils/result.dart';

void main() {
  group('Command', () {
    test('expõe running enquanto executa e completed ao terminar', () async {
      final completer = Completer<Result<int>>();
      final command = Command0<int>(() => completer.future);

      final future = command.execute();
      expect(command.running, isTrue);

      completer.complete(const Result.ok(1));
      await future;

      expect(command.running, isFalse);
      expect(command.completed, isTrue);
      expect(command.error, isFalse);
    });

    test('marca error quando a ação falha', () async {
      final command = Command0<void>(() async => Result.error(Exception('x')));
      await command.execute();
      expect(command.error, isTrue);
    });

    test('ignora execuções concorrentes', () async {
      var calls = 0;
      final completer = Completer<Result<void>>();
      final command = Command1<void, int>((_) {
        calls++;
        return completer.future;
      });

      final first = command.execute(1);
      unawaited(command.execute(2));
      completer.complete(const Result.ok(null));
      await first;

      expect(calls, 1);
    });

    test('clearResult limpa o estado', () async {
      final command = Command0<void>(() async => const Result.ok(null));
      await command.execute();
      command.clearResult();
      expect(command.completed, isFalse);
      expect(command.result, isNull);
    });
  });
}
