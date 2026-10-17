import 'package:flutter/material.dart';

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
              child: Row(
                children: [
                  InitialsAvatar(
                    initials: allocation.member.initials,
                    size: 34,
                    soft: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${allocation.member.name} '
                                '(${allocation.member.role})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${Formatters.hours(allocation.allocatedHours)} / '
                              '${Formatters.hours(allocation.capacityHours)}'
                              '${allocation.overloaded ? ' (Sobrecarga)' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: allocation.overloaded
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
                              (e.value, _colorFor(e.key)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    for (final front in viewModel.fronts)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 10, color: _colorFor(front)),
                          const SizedBox(width: 6),
                          Text(front, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                  ],
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
