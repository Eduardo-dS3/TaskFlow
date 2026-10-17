import 'dart:async';

import 'package:flutter/foundation.dart';

import 'result.dart';

typedef CommandAction0<T> = Future<Result<T>> Function();
typedef CommandAction1<T, A> = Future<Result<T>> Function(A);

/// Facilita a interação entre a View e o ViewModel.
///
/// Encapsula uma ação, expõe seus estados ([running], [error], [completed])
/// e impede que a mesma ação seja executada várias vezes em paralelo.
///
/// Segue o padrão "Command" recomendado em
/// https://docs.flutter.dev/app-architecture/design-patterns/command
abstract class Command<T> extends ChangeNotifier {
  Command();

  bool _running = false;

  /// `true` enquanto a ação está em execução.
  bool get running => _running;

  Result<T>? _result;

  /// `true` se a ação terminou com erro.
  bool get error => _result is Error;

  /// `true` se a ação terminou com sucesso.
  bool get completed => _result is Ok;

  /// Resultado da última execução.
  Result<T>? get result => _result;

  /// Limpa o último resultado.
  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> _execute(CommandAction0<T> action) async {
    // Evita execuções concorrentes (ex.: duplo clique).
    if (_running) return;

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

/// [Command] sem argumentos.
class Command0<T> extends Command<T> {
  Command0(this._action);

  final CommandAction0<T> _action;

  Future<void> execute() async {
    await _execute(_action);
  }
}

/// [Command] com um argumento.
class Command1<T, A> extends Command<T> {
  Command1(this._action);

  final CommandAction1<T, A> _action;

  Future<void> execute(A argument) async {
    await _execute(() => _action(argument));
  }
}
