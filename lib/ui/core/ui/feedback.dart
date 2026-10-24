import 'package:flutter/material.dart';

import '../../../utils/command.dart';
import '../../../utils/result.dart';
import '../themes/colors.dart';

/// Texto de erro pronto para o usuário (sem o prefixo "Exception: ").
String errorMessage(Object error) =>
    error.toString().replaceFirst('Exception: ', '');

/// Mensagem do último erro do [command], se houver.
String? commandError(Command<Object?> command) {
  if (command.result case Error(:final error)) return errorMessage(error);
  return null;
}

/// Exibe uma mensagem rápida no rodapé da tela.
void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Executa [action] (que aciona [command]) e mostra no rodapé a mensagem de
/// sucesso ou o erro. Retorna `true` quando deu certo.
Future<bool> runWithFeedback(
  BuildContext context,
  Command<Object?> command,
  Future<void> Function() action, {
  required String success,
}) async {
  await action();
  if (!context.mounted) return false;
  final error = commandError(command);
  showMessage(context, error ?? success);
  return error == null;
}

/// Pede confirmação antes de uma ação destrutiva.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Excluir',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Mostra um aviso no rodapé sempre que um dos [commands] termina com erro.
class CommandErrorListener extends StatefulWidget {
  const CommandErrorListener({
    super.key,
    required this.commands,
    required this.child,
  });

  final List<Command<Object?>> commands;
  final Widget child;

  @override
  State<CommandErrorListener> createState() => _CommandErrorListenerState();
}

class _CommandErrorListenerState extends State<CommandErrorListener> {
  @override
  void initState() {
    super.initState();
    _subscribe(widget.commands);
  }

  @override
  void didUpdateWidget(covariant CommandErrorListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unsubscribe(oldWidget.commands);
    _subscribe(widget.commands);
  }

  @override
  void dispose() {
    _unsubscribe(widget.commands);
    super.dispose();
  }

  void _subscribe(List<Command<Object?>> commands) {
    for (final command in commands) {
      command.addListener(_check);
    }
  }

  void _unsubscribe(List<Command<Object?>> commands) {
    for (final command in commands) {
      command.removeListener(_check);
    }
  }

  void _check() {
    for (final command in widget.commands) {
      final message = commandError(command);
      if (message == null) continue;
      command.clearResult();
      if (mounted) showMessage(context, message);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Faixa de erro exibida dentro de formulários.
class InlineError extends StatelessWidget {
  const InlineError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
