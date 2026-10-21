import 'package:flutter/material.dart';

import '../../../domain/models/project.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/feedback.dart';
import '../view_models/projects_viewmodel.dart';
import 'client_form_dialog.dart';

/// Cadastro de clientes: lista, inclusão, edição e exclusão.
Future<void> showClientsDialog(
  BuildContext context,
  ProjectsViewModel viewModel,
) => showDialog<void>(
  context: context,
  builder: (context) => _ClientsDialog(viewModel: viewModel),
);

class _ClientsDialog extends StatelessWidget {
  const _ClientsDialog({required this.viewModel});

  final ProjectsViewModel viewModel;

  Future<void> _edit(BuildContext context, Client? client) async {
    final saved = await showClientForm(context, client: client);
    if (saved != null) await viewModel.saveClient.execute(saved);
  }

  Future<void> _delete(BuildContext context, Client client) async {
    final confirmed = await confirmAction(
      context,
      title: 'Excluir cliente?',
      message:
          '"${client.name}" será excluído. Os projetos dele passam a '
          'aparecer como internos.',
    );
    if (confirmed) await viewModel.deleteClient.execute(client.id);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Clientes'),
      content: SizedBox(
        width: 520,
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final clients = viewModel.clients;
            if (clients.isEmpty) {
              return const Text('Nenhum cliente cadastrado.');
            }
            return ListView.separated(
              shrinkWrap: true,
              itemCount: clients.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) => _ClientRow(
                client: clients[index],
                onEdit: () => _edit(context, clients[index]),
                onDelete: viewModel.isAdmin
                    ? () => _delete(context, clients[index])
                    : null,
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
        FilledButton.icon(
          onPressed: () => _edit(context, null),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Novo cliente'),
        ),
      ],
    );
  }
}

class _ClientRow extends StatelessWidget {
  const _ClientRow({
    required this.client,
    required this.onEdit,
    required this.onDelete,
  });

  final Client client;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(client.name),
      subtitle: Text(
        [
          Formatters.clientTier(client.tier),
          client.description,
          if (client.contract.isNotEmpty) client.contract,
        ].join(' • '),
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Editar',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Excluir',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
            ),
        ],
      ),
    );
  }
}
