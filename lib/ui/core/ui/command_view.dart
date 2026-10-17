import 'package:flutter/material.dart';

import '../../../utils/command.dart';
import '../themes/colors.dart';

/// Exibe carregamento, erro ou o conteúdo conforme o estado de um [Command]
/// de carregamento inicial.
class CommandView extends StatelessWidget {
  const CommandView({
    super.key,
    required this.command,
    required this.onRetry,
    required this.builder,
    this.errorTitle = 'Não foi possível carregar os dados',
  });

  final Command command;
  final VoidCallback onRetry;
  final WidgetBuilder builder;
  final String errorTitle;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: command,
      builder: (context, child) {
        if (command.running) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (command.error) {
          return ErrorIndicator(title: errorTitle, onRetry: onRetry);
        }
        return child!;
      },
      child: Builder(builder: builder),
    );
  }
}

class ErrorIndicator extends StatelessWidget {
  const ErrorIndicator({super.key, required this.title, required this.onRetry});

  final String title;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 40),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
