import 'package:flutter/material.dart';

import '../../../domain/models/project.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/themes/dimens.dart';
import '../../core/ui/command_view.dart';
import '../../core/ui/feedback.dart';
import '../../core/ui/kpi_card.dart';
import '../../core/ui/pill.dart';
import '../view_models/projects_viewmodel.dart';
import 'allocation_card.dart';
import 'clients_card.dart';
import 'clients_dialog.dart';
import 'project_card.dart';
import 'project_form_dialog.dart';
import 'projects_filters.dart';

/// Tela "Projetos & Clientes".
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key, required this.viewModel});

  final ProjectsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final actions = _ProjectActions(viewModel);
    return CommandErrorListener(
      commands: [
        viewModel.saveProject,
        viewModel.deleteProject,
        viewModel.saveClient,
        viewModel.deleteClient,
      ],
      child: CommandView(
        command: viewModel.load,
        onRetry: viewModel.load.execute,
        builder: (context) => ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) => LayoutBuilder(
            builder: (context, constraints) => _ProjectsContent(
              viewModel: viewModel,
              actions: actions,
              maxWidth: constraints.maxWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectsContent extends StatelessWidget {
  const _ProjectsContent({
    required this.viewModel,
    required this.actions,
    required this.maxWidth,
  });

  final ProjectsViewModel viewModel;
  final _ProjectActions actions;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final wide = maxWidth >= Dimens.breakpointWide;
    final padding = maxWidth < 600
        ? Dimens.paddingPageCompact
        : Dimens.paddingPage;
    final clientsCard = ClientsCard(
      clients: viewModel.clients,
      onManage: () => actions.manageClients(context),
    );
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            onNewProject: () => actions.newProject(context),
            onManageClients: () => actions.manageClients(context),
          ),
          const SizedBox(height: 20),
          _Summary(viewModel: viewModel),
          const SizedBox(height: 20),
          ProjectsFilters(viewModel: viewModel),
          const SizedBox(height: 20),
          _ProjectsGrid(viewModel: viewModel, actions: actions),
          const SizedBox(height: 24),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: AllocationCard(viewModel: viewModel)),
                const SizedBox(width: 20),
                Expanded(child: clientsCard),
              ],
            )
          else ...[
            AllocationCard(viewModel: viewModel),
            const SizedBox(height: 20),
            clientsCard,
          ],
        ],
      ),
    );
  }
}

/// Ações da tela que abrem formulários e acionam o ViewModel.
class _ProjectActions {
  _ProjectActions(this.viewModel);

  final ProjectsViewModel viewModel;

  Future<void> newProject(BuildContext context) => edit(context, null);

  Future<void> edit(BuildContext context, Project? project) async {
    final saved = await showProjectForm(
      context,
      project: project,
      clients: viewModel.clients,
      members: viewModel.members,
    );
    if (saved != null) await viewModel.saveProject.execute(saved);
  }

  Future<void> delete(BuildContext context, Project project) async {
    final confirmed = await confirmAction(
      context,
      title: 'Excluir projeto?',
      message:
          '"${project.name}" será excluído. As tarefas vinculadas continuam '
          'no quadro, sem projeto.',
    );
    if (confirmed) await viewModel.deleteProject.execute(project.id);
  }

  Future<void> manageClients(BuildContext context) =>
      showClientsDialog(context, viewModel);
}

class _Header extends StatelessWidget {
  const _Header({required this.onNewProject, required this.onManageClients});

  final VoidCallback onNewProject;
  final VoidCallback onManageClients;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      runSpacing: 12,
      spacing: 12,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PORTFÓLIO OPERACIONAL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Projetos & Clientes',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            Text(
              'Visão unificada de frentes de trabalho, capacidade alocada e '
              'ritmo de entregas.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: onManageClients,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.primarySoft,
                side: BorderSide.none,
              ),
              icon: const Icon(Icons.business_outlined, size: 18),
              label: const Text('Clientes'),
            ),
            FilledButton.icon(
              onPressed: onNewProject,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Novo Projeto'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.viewModel});

  final ProjectsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final summary = viewModel.summary;
    if (summary == null) return const SizedBox.shrink();
    return ResponsiveGrid(
      children: [
        KpiCard(
          title: 'Projetos Ativos',
          value: '${summary.activeDemands}',
          icon: Icons.rocket_launch_outlined,
          badge: Pill(
            label: '+${summary.newThisMonth} este mês',
            foreground: AppColors.info,
            background: AppColors.infoSoft,
          ),
        ),
        KpiCard(
          title: 'Progresso Médio',
          value: Formatters.percent(summary.averageDeliveryRate, decimals: 1),
          icon: Icons.donut_large,
          iconColor: AppColors.info,
          iconBackground: AppColors.infoSoft,
          unit: 'dos ativos',
        ),
        KpiCard(
          title: 'Alocação da Equipe',
          value: '${summary.activeDevs}/${summary.totalDevs}',
          unit: 'pessoas em projetos ativos',
          icon: Icons.groups_outlined,
        ),
        KpiCard(
          title: 'Entregas no Prazo',
          value: Formatters.optionalPercent(summary.onTimeRate),
          icon: Icons.verified_outlined,
          iconColor: AppColors.success,
          iconBackground: AppColors.successSoft,
          badge: Pill(
            label: summary.onTimeRate == null ? 'Sem prazos' : 'No Prazo',
            foreground: AppColors.primaryDark,
            background: AppColors.primarySoft,
          ),
        ),
      ],
    );
  }
}

class _ProjectsGrid extends StatelessWidget {
  const _ProjectsGrid({required this.viewModel, required this.actions});

  final ProjectsViewModel viewModel;
  final _ProjectActions actions;

  Widget _card(BuildContext context, Project project) => ProjectCard(
    project: project,
    now: viewModel.now,
    onEdit: () => actions.edit(context, project),
    onDelete: viewModel.isAdmin ? () => actions.delete(context, project) : null,
  );

  @override
  Widget build(BuildContext context) {
    final projects = viewModel.projects;
    if (projects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Nenhum projeto encontrado. Use "Novo Projeto" para cadastrar.',
          ),
        ),
      );
    }
    if (viewModel.layout == ProjectsLayout.list) {
      return Column(
        children: [
          for (final p in projects)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _card(context, p),
            ),
        ],
      );
    }
    return ResponsiveGrid(
      minItemWidth: 280,
      spacing: 20,
      children: [for (final p in projects) _card(context, p)],
    );
  }
}
