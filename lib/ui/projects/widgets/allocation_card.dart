import 'package:flutter/material.dart';

import '../../../domain/models/project.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/avatar.dart';
import '../../core/ui/meter.dart';
import '../../core/ui/pill.dart';
import '../../core/ui/surface_card.dart';
import '../view_models/projects_viewmodel.dart';

const _frontColors = [AppColors.primary, AppColors.info, AppColors.danger];

/// "Capacidade & Alocação do Time".
class AllocationCard extends StatelessWidget {
  const AllocationCard({super.key, required this.viewModel});

  final ProjectsViewModel viewModel;

  Color _colorFor(String front) {
    final index = viewModel.fronts.indexOf(front);
    return _frontColors[index % _frontColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(
            title: 'Capacidade & Alocação do Time',
            subtitle:
                'Distribuição de horas semanais alocadas por frente de '
                'desenvolvimento',
            trailing: Pill(
              label:
                  '${Formatters.percent(viewModel.totalOccupancy)} '
                  'Ocupação Total',
              foreground: AppColors.primaryDark,
              background: AppColors.primarySoft,
            ),
          ),
          const SizedBox(height: 20),
          for (final allocation in viewModel.allocations)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _AllocationRow(
                allocation: allocation,
                colorFor: _colorFor,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FrontsLegend(
                  fronts: viewModel.fronts,
                  colorFor: _colorFor,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Ver matriz completa →'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Horas de uma pessoa, com barra segmentada por frente de trabalho.
class _AllocationRow extends StatelessWidget {
  const _AllocationRow({required this.allocation, required this.colorFor});

  final MemberAllocation allocation;
  final Color Function(String front) colorFor;

  @override
  Widget build(BuildContext context) {
    final member = allocation.member;
    final overloaded = allocation.overloaded;
    return Row(
      children: [
        InitialsAvatar(initials: member.initials, size: 34, soft: true),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${member.name} (${member.role})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${Formatters.hours(allocation.allocatedHours)} / '
                    '${Formatters.hours(allocation.capacityHours)}'
                    '${overloaded ? ' (Sobrecarga)' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: overloaded
                          ? AppColors.danger
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SegmentedMeter(
                total: allocation.capacityHours,
                segments: [
                  for (final e in allocation.hoursByFront.entries)
                    (e.value, colorFor(e.key)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FrontsLegend extends StatelessWidget {
  const _FrontsLegend({required this.fronts, required this.colorFor});

  final List<String> fronts;
  final Color Function(String front) colorFor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        for (final front in fronts)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 10, color: colorFor(front)),
              const SizedBox(width: 6),
              Text(front, style: const TextStyle(fontSize: 12)),
            ],
          ),
      ],
    );
  }
}
