import 'package:flutter/material.dart';

import '../../../domain/models/project.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/surface_card.dart';
import '../view_models/projects_viewmodel.dart';

/// Abas por status + filtros de busca, cliente, responsável e período.
class ProjectsFilters extends StatelessWidget {
  const ProjectsFilters({super.key, required this.viewModel});

  final ProjectsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _StatusTabs(viewModel: viewModel)),
              _LayoutToggle(
                icon: Icons.grid_view,
                selected: viewModel.layout == ProjectsLayout.grid,
                onTap: () => viewModel.setLayout(ProjectsLayout.grid),
              ),
              _LayoutToggle(
                icon: Icons.view_list,
                selected: viewModel.layout == ProjectsLayout.list,
                onTap: () => viewModel.setLayout(ProjectsLayout.list),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FilterFields(viewModel: viewModel),
        ],
      ),
    );
  }
}

/// Abas "Todos / Em Andamento / Concluídos / Pausados" com contadores.
class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.viewModel});

  final ProjectsViewModel viewModel;

  static const _tabs = <(ProjectStatus?, String)>[
    (null, 'Todos os Projetos'),
    (ProjectStatus.inProgress, 'Em Andamento'),
    (ProjectStatus.done, 'Concluídos'),
    (ProjectStatus.paused, 'Pausados'),
  ];

  int _count(ProjectStatus? status) =>
      status == null ? viewModel.totalCount : viewModel.countFor(status);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (status, label) in _tabs)
          _Tab(
            label: label,
            count: _count(status),
            selected: viewModel.statusFilter == status,
            onTap: () => viewModel.setStatusFilter(status),
          ),
      ],
    );
  }
}

/// Campos de busca e seleção, distribuídos em até 4 colunas.
class _FilterFields extends StatelessWidget {
  const _FilterFields({required this.viewModel});

  final ProjectsViewModel viewModel;

  static int _columnsFor(double width) {
    if (width > 800) return 4;
    if (width > 500) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.maxWidth);
        final width = (constraints.maxWidth - 12 * (columns - 1)) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: width,
              child: TextField(
                onChanged: viewModel.setQuery,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, size: 18),
                  hintText: 'Filtrar por nome de projeto...',
                  fillColor: AppColors.surfaceMuted,
                ),
              ),
            ),
            SizedBox(
              width: width,
              child: _ClientSelect(viewModel: viewModel),
            ),
            SizedBox(
              width: width,
              child: const _StaticSelect(
                icon: Icons.badge_outlined,
                label: 'Responsável Geral',
              ),
            ),
            SizedBox(
              width: width,
              child: const _StaticSelect(
                icon: Icons.calendar_month_outlined,
                label: 'Período: Q4',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ClientSelect extends StatelessWidget {
  const _ClientSelect({required this.viewModel});

  final ProjectsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: viewModel.clientFilter,
      isExpanded: true,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.business_outlined, size: 18),
        fillColor: AppColors.surfaceMuted,
      ),
      items: [
        const DropdownMenuItem(child: Text('Todos os Clientes')),
        for (final client in viewModel.clientNames)
          DropdownMenuItem(value: client, child: Text(client)),
      ],
      onChanged: viewModel.setClientFilter,
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textPrimary;
    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: fg,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LayoutToggle extends StatelessWidget {
  const _LayoutToggle({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      isSelected: selected,
      style: IconButton.styleFrom(
        backgroundColor: selected ? AppColors.primarySoft : null,
      ),
      icon: Icon(
        icon,
        size: 20,
        color: selected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}

class _StaticSelect extends StatelessWidget {
  const _StaticSelect({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18),
        suffixIcon: const Icon(Icons.keyboard_arrow_down),
        fillColor: AppColors.surfaceMuted,
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
}
