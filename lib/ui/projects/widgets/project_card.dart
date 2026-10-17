import 'package:flutter/material.dart';

import '../../../domain/models/project.dart';
import '../../../domain/models/task.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/themes/dimens.dart';
import '../../core/ui/avatar.dart';
import '../../core/ui/meter.dart';
import '../../core/ui/pill.dart';

/// Card de projeto com faixa colorida no topo.
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.now});

  final Project project;
  final DateTime now;

  Color get _accent => switch (project.status) {
    ProjectStatus.done => AppColors.success,
    ProjectStatus.paused => AppColors.neutral,
    ProjectStatus.inProgress => switch (project.priority) {
      TaskPriority.urgent => AppColors.danger,
      TaskPriority.medium => const Color(0xFF5B4FE0),
      _ when project.kind == ProjectKind.web => AppColors.info,
      _ => AppColors.primary,
    },
  };

  IconData get _icon => switch (project.kind) {
    ProjectKind.mobile => Icons.smartphone,
    ProjectKind.web => Icons.dashboard_outlined,
    ProjectKind.fiscal => Icons.account_balance_outlined,
    ProjectKind.landing => Icons.web,
    ProjectKind.api => Icons.hub_outlined,
    ProjectKind.report => Icons.description_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Dimens.radius),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 4, color: accent),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: _statusPill()),
                    const Spacer(),
                    if (_priorityPill() case final pill?) Flexible(child: pill),
                    const Icon(Icons.more_vert, size: 18),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_icon, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.business, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                project.clientName,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      project.status == ProjectStatus.done
                          ? 'Status Final'
                          : 'Progresso de Sprints',
                      style: const TextStyle(fontSize: 11),
                    ),
                    const Spacer(),
                    Text(
                      Formatters.percent(project.progress),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Meter(value: project.progress, color: accent),
                const SizedBox(height: 8),
                _progressInfo(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    AvatarStack(
                      initials: [for (final m in project.team) m.initials],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _deadline(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill() => switch (project.status) {
    ProjectStatus.inProgress => const Pill(
      label: 'Em Andamento',
      dot: true,
      foreground: AppColors.primary,
      background: AppColors.primarySoft,
    ),
    ProjectStatus.done => const Pill(
      label: 'Concluído',
      icon: Icons.done_all,
      foreground: AppColors.success,
      background: AppColors.successSoft,
    ),
    ProjectStatus.paused => const Pill(
      label: 'Pausado',
      dot: true,
      foreground: AppColors.neutral,
      background: AppColors.neutralSoft,
    ),
  };

  Widget? _priorityPill() {
    if (project.badge case final badge?) {
      return Pill(label: badge, foreground: AppColors.textPrimary);
    }
    return switch (project.priority) {
      TaskPriority.urgent => const Pill(
        label: 'Urgente',
        icon: Icons.warning_amber_rounded,
        foreground: AppColors.danger,
        background: AppColors.dangerSoft,
      ),
      final TaskPriority p => Pill(
        label: 'Prioridade ${Formatters.priority(p)}',
        foreground: AppColors.textPrimary,
      ),
      null => null,
    };
  }

  Widget _progressInfo() {
    final critical = project.priority == TaskPriority.urgent;
    String right;
    Color rightColor = AppColors.textSecondary;
    if (project.note case final note?) {
      right = note;
      if (project.status == ProjectStatus.done) rightColor = AppColors.success;
    } else {
      right =
          '${project.remainingTasks} restantes${critical ? ' (Crítico)' : ''}';
      if (critical) rightColor = AppColors.danger;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          project.blocked
              ? Icons.pause_circle_outline
              : Icons.check_circle_outline,
          size: 14,
          color: project.blocked ? AppColors.neutral : AppColors.success,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${project.completedTasks} de ${project.totalTasks} tarefas concluídas',
            style: const TextStyle(fontSize: 11),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            right,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              color: rightColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _deadline() {
    if (project.finishedAt case final finished?) {
      return Pill(
        label: 'Finalizado em: ${Formatters.shortDate(finished)}',
        icon: Icons.check,
        foreground: AppColors.success,
        background: AppColors.successSoft,
      );
    }
    if (project.dueDate case final due?) {
      final urgent = project.priority == TaskPriority.urgent;
      return Pill(
        label: 'Prazo: ${Formatters.shortDate(due)}',
        icon: urgent ? Icons.alarm : Icons.event_outlined,
        foreground: urgent ? AppColors.danger : AppColors.textPrimary,
        background: urgent ? AppColors.dangerSoft : AppColors.surfaceMuted,
      );
    }
    return const Pill(
      label: 'Sem data definida',
      icon: Icons.pause,
      foreground: AppColors.textPrimary,
    );
  }
}
