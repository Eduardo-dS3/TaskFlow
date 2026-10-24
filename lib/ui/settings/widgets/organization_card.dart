import 'package:flutter/material.dart';

import '../../core/themes/colors.dart';
import '../../core/ui/feedback.dart';
import '../../core/ui/surface_card.dart';
import '../view_models/settings_viewmodel.dart';

/// Nome da organização e sprint ativa (somente administradores).
class OrganizationCard extends StatefulWidget {
  const OrganizationCard({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  State<OrganizationCard> createState() => _OrganizationCardState();
}

class _OrganizationCardState extends State<OrganizationCard> {
  late final _organization = TextEditingController(
    text: widget.viewModel.settings.organization,
  );
  late final _sprint = TextEditingController(
    text: widget.viewModel.settings.activeSprint,
  );

  @override
  void dispose() {
    _organization.dispose();
    _sprint.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final command = widget.viewModel.saveOrganization;
    await runWithFeedback(
      context,
      command,
      () => command.execute((
        organization: _organization.text,
        activeSprint: _sprint.text,
      )),
      success: 'Configurações gerais salvas',
    );
  }

  @override
  Widget build(BuildContext context) {
    final command = widget.viewModel.saveOrganization;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(
            icon: Icons.apartment_outlined,
            title: 'Organização',
            subtitle: 'Visível para toda a equipe',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _organization,
            decoration: const InputDecoration(
              labelText: 'Nome da empresa ou equipe',
              helperText: 'Aparece no cabeçalho do PDF executivo',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sprint,
            decoration: const InputDecoration(
              labelText: 'Sprint ativa',
              hintText: 'Ex.: Sprint 12',
              helperText:
                  'Exibida no quadro e usada como sprint padrão das novas '
                  'tarefas',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'O progresso da sprint nos relatórios considera as tarefas com '
            'exatamente este nome de sprint.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ListenableBuilder(
              listenable: command,
              builder: (context, _) => FilledButton(
                onPressed: command.running ? null : _submit,
                child: const Text('Salvar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
