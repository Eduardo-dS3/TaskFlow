import 'package:flutter/material.dart';

import '../../../config/server_config.dart';
import '../../core/themes/colors.dart';

/// Guia rápido de uso do TaskFlow.
Future<void> showHelpDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Ajuda'),
    content: const SizedBox(
      width: 520,
      child: SingleChildScrollView(child: _HelpContent()),
    ),
    actions: [
      FilledButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Fechar'),
      ),
    ],
  ),
);

class _HelpContent extends StatelessWidget {
  const _HelpContent();

  static const _topics = [
    (
      Icons.view_kanban_outlined,
      'Quadro',
      'Arraste um card (clique e segure) para mudar o status. Use o "+" de '
          'cada coluna para criar uma tarefa já naquele status.',
    ),
    (
      Icons.edit_note,
      'Tarefas',
      'Na tela da tarefa, edite os campos e clique em "Salvar Alterações". '
          'Comentários e anexos são salvos na hora.',
    ),
    (
      Icons.folder_open_outlined,
      'Projetos & Clientes',
      'Cadastre clientes e projetos; o progresso de cada projeto é calculado '
          'pelas tarefas vinculadas a ele.',
    ),
    (
      Icons.insights_outlined,
      'Relatórios',
      'Indicadores calculados a partir das tarefas, com exportação em CSV '
          'e PDF.',
    ),
    (
      Icons.admin_panel_settings_outlined,
      'Administração',
      'O administrador cadastra a equipe no painel do servidor, em /_/ no '
          'mesmo endereço do app (coleção "users", marcando "active"). '
          'Backups, logs e o banco de dados também ficam nesse painel.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (icon, title, text) in _topics)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(text, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'TaskFlow versão $appVersion • Servidor: $apiBaseUrl',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
