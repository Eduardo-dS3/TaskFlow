import 'package:flutter/material.dart';

import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/themes/dimens.dart';
import '../../core/ui/command_view.dart';
import '../../core/ui/kpi_card.dart';
import '../../core/ui/pill.dart';
import '../view_models/projects_viewmodel.dart';
import 'allocation_card.dart';
import 'clients_card.dart';
import 'project_card.dart';
import 'projects_filters.dart';

/// Tela "Projetos & Clientes".
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key, required this.viewModel});

  final ProjectsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CommandView(
      command: viewModel.load,
      onRetry: viewModel.load.execute,
      builder: (context) => ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= Dimens.breakpointWide;
            final padding = constraints.maxWidth < 600
                ? Dimens.paddingPageCompact
                : Dimens.paddingPage;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Header(),
                  const SizedBox(height: 20),
                  _Summary(viewModel: viewModel),
                  const SizedBox(height: 20),
                  ProjectsFilters(viewModel: viewModel),
                  const SizedBox(height: 20),
                  _ProjectsGrid(viewModel: viewModel),
                  const SizedBox(height: 24),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: AllocationCard(viewModel: viewModel),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ClientsCard(clients: viewModel.clients),
                        ),
                      ],
                    )
                  else ...[
                    AllocationCard(viewModel: viewModel),
                    const SizedBox(height: 20),
                    ClientsCard(clients: viewModel.clients),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

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
            Text.rich(
              TextSpan(
                text: 'PORTFÓLIO OPERACIONAL  ›  ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
                children: [
                  TextSpan(
                    text: 'WORKSPACE ENTERPRISE',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
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
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.primarySoft,
                side: BorderSide.none,
              ),
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Configurar Métricas'),
            ),
            FilledButton.icon(
              onPressed: () {},
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
          title: 'Demandas Ativas',
          value: '${summary.activeDemands}',
          icon: Icons.rocket_launch_outlined,
          badge: Pill(
            label: '+${summary.newThisMonth} este mês',
            foreground: AppColors.info,
            background: AppColors.infoSoft,
          ),
        ),
        KpiCard(
          title: 'Taxa Média de Entrega',
          value: Formatters.percent(summary.averageDeliveryRate, decimals: 1),
          icon: Icons.donut_large,
          iconColor: AppColors.info,
          iconBackground: AppColors.infoSoft,
          badge: Pill(
            label: Formatters.signedPercent(summary.deliveryRateDelta),
            foreground: AppColors.info,
            background: AppColors.infoSoft,
          ),
        ),
        KpiCard(
          title: 'Alocação de Time',
          value: '${summary.activeDevs}/${summary.totalDevs}',
          unit: 'devs ativos',
          icon: Icons.groups_outlined,
        ),
        KpiCard(
          title: 'SLA & Prazos',
          value: Formatters.percent(summary.onTimeRate),
          icon: Icons.verified_outlined,
          iconColor: AppColors.success,
          iconBackground: AppColors.successSoft,
          badge: const Pill(
            label: 'No Prazo',
            foreground: AppColors.primaryDark,
            background: AppColors.primarySoft,
          ),
        ),
      ],
    );
  }
}

class _ProjectsGrid extends StatelessWidget {
  const _ProjectsGrid({required this.viewModel});

  final ProjectsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final projects = viewModel.projects;
    if (projects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('Nenhum projeto encontrado')),
      );
    }
    if (viewModel.layout == ProjectsLayout.list) {
      return Column(
        children: [
          for (final p in projects)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProjectCard(project: p, now: viewModel.now),
            ),
        ],
      );
    }
    return ResponsiveGrid(
      minItemWidth: 280,
      spacing: 20,
      children: [
        for (final p in projects) ProjectCard(project: p, now: viewModel.now),
      ],
    );
  }
}
