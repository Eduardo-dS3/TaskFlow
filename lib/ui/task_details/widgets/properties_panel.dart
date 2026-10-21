import 'package:flutter/material.dart';

import '../../../domain/models/member.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/avatar.dart';
import '../../core/ui/member_picker_dialog.dart';
import '../../core/ui/meter.dart';
import '../../core/ui/pill.dart';
import '../../core/ui/surface_card.dart';
import '../view_models/task_details_viewmodel.dart';
import 'hours_dialog.dart';

/// Painel "Propriedades": projeto, pessoas, planejamento, horas e tags.
class PropertiesPanel extends StatelessWidget {
  const PropertiesPanel({super.key, required this.viewModel});

  final TaskDetailsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final task = vm.task!;
        return SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle(
                title: 'Propriedades',
                trailing: Icon(
                  Icons.tune,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
              const Divider(height: 24),
              _ProjectField(viewModel: vm),
              if (task.clientName case final client?) ...[
                const SizedBox(height: 16),
                _ClientField(client: client, contract: task.clientContract),
              ],
              const SizedBox(height: 16),
              _OwnerField(viewModel: vm),
              const SizedBox(height: 16),
              _AssigneesField(viewModel: vm),
              const SizedBox(height: 16),
              _PlanningFields(viewModel: vm),
              const SizedBox(height: 16),
              _DatesRow(viewModel: vm),
              const SizedBox(height: 16),
              _HoursCard(viewModel: vm),
              const SizedBox(height: 16),
              _TagsSection(viewModel: vm),
            ],
          ),
        );
      },
    );
  }
}

class _ProjectField extends StatelessWidget {
  const _ProjectField({required this.viewModel});

  final TaskDetailsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final projectId = viewModel.task!.projectId;
    final known = viewModel.projects.any((p) => p.id == projectId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Label(icon: Icons.folder_outlined, text: 'Projeto Associado'),
        DropdownButtonFormField<String?>(
          initialValue: known ? projectId : null,
          isExpanded: true,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          items: [
            const DropdownMenuItem<String?>(child: Text('Sem projeto')),
            for (final project in viewModel.projects)
              DropdownMenuItem(value: project.id, child: Text(project.name)),
          ],
          onChanged: viewModel.setProject,
        ),
      ],
    );
  }
}

class _ClientField extends StatelessWidget {
  const _ClientField({required this.client, this.contract});

  final String client;
  final String? contract;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Label(icon: Icons.business_outlined, text: 'Cliente'),
        _InfoTile(
          leading: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              initialsOf(client),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
          title: client,
          subtitle: contract,
        ),
      ],
    );
  }
}

class _OwnerField extends StatelessWidget {
  const _OwnerField({required this.viewModel});

  final TaskDetailsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final owner = viewModel.task!.owner;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Label(icon: Icons.person_outline, text: 'Responsável Principal'),
        _InfoTile(
          leading: InitialsAvatar(initials: owner?.initials ?? '?', size: 34),
          title: owner?.name ?? 'Sem responsável',
          subtitle: owner?.role,
          trailing: PopupMenuButton<Member?>(
            tooltip: 'Trocar responsável',
            icon: const Icon(Icons.swap_horiz, color: AppColors.primary),
            onSelected: viewModel.setOwner,
            itemBuilder: (context) => [
              const PopupMenuItem<Member?>(child: Text('Sem responsável')),
              for (final member in viewModel.members)
                PopupMenuItem<Member?>(value: member, child: Text(member.name)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssigneesField extends StatelessWidget {
  const _AssigneesField({required this.viewModel});

  final TaskDetailsViewModel viewModel;

  Future<void> _edit(BuildContext context) async {
    final selected = await showMemberPicker(
      context,
      title: 'Participantes da tarefa',
      members: viewModel.members,
      selected: viewModel.task!.assignees,
    );
    if (selected != null) viewModel.setAssignees(selected);
  }

  @override
  Widget build(BuildContext context) {
    final assignees = viewModel.task!.assignees;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: _Label(icon: Icons.group_outlined, text: 'Participantes'),
            ),
            TextButton(
              onPressed: () => _edit(context),
              child: const Text('Editar', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        if (assignees.isEmpty)
          const Text(
            'Nenhum participante além do responsável.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final member in assignees)
                Chip(
                  avatar: InitialsAvatar(initials: member.initials, size: 22),
                  label: Text(
                    member.name,
                    style: const TextStyle(fontSize: 12),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
      ],
    );
  }
}

/// Categoria (frente de trabalho) e sprint.
class _PlanningFields extends StatefulWidget {
  const _PlanningFields({required this.viewModel});

  final TaskDetailsViewModel viewModel;

  @override
  State<_PlanningFields> createState() => _PlanningFieldsState();
}

class _PlanningFieldsState extends State<_PlanningFields> {
  late final _category = TextEditingController(
    text: widget.viewModel.task!.category,
  );
  late final _sprint = TextEditingController(
    text: widget.viewModel.task!.sprint ?? '',
  );

  @override
  void dispose() {
    _category.dispose();
    _sprint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _category,
            onChanged: widget.viewModel.setCategory,
            decoration: const InputDecoration(
              labelText: 'Categoria',
              hintText: 'Ex.: Backend',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _sprint,
            onChanged: widget.viewModel.setSprint,
            decoration: const InputDecoration(labelText: 'Sprint'),
          ),
        ),
      ],
    );
  }
}

class _DatesRow extends StatelessWidget {
  const _DatesRow({required this.viewModel});

  final TaskDetailsViewModel viewModel;

  Future<void> _pick(
    BuildContext context,
    DateTime? initial,
    ValueChanged<DateTime> onPicked,
  ) async {
    final now = viewModel.now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final task = viewModel.task!;
    final setDates = viewModel.setDates;
    return Row(
      children: [
        Expanded(
          child: _DateField(
            label: 'Início',
            icon: Icons.calendar_today_outlined,
            date: task.startDate,
            onTap: () => _pick(
              context,
              task.startDate,
              (d) => setDates(start: d, due: task.dueDate),
            ),
            onClear: () => setDates(start: null, due: task.dueDate),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DateField(
            label: 'Prazo Final',
            icon: Icons.flag_outlined,
            date: task.dueDate,
            danger: true,
            onTap: () => _pick(
              context,
              task.dueDate,
              (d) => setDates(start: task.startDate, due: d),
            ),
            onClear: () => setDates(start: task.startDate, due: null),
          ),
        ),
      ],
    );
  }
}

/// Horas registradas vs. estimadas, com edição.
class _HoursCard extends StatelessWidget {
  const _HoursCard({required this.viewModel});

  final TaskDetailsViewModel viewModel;

  Future<void> _edit(BuildContext context) async {
    final task = viewModel.task!;
    final hours = await showHoursDialog(
      context,
      estimated: task.estimatedHours,
      logged: task.loggedHours,
    );
    if (hours != null) {
      viewModel.setHours(estimated: hours.estimated, logged: hours.logged);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = viewModel.task!;
    final remaining = task.estimatedHours - task.loggedHours;
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _edit(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Horas Registradas',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Text(
                    '${Formatters.hours(task.loggedHours)} / '
                    '${Formatters.hours(task.estimatedHours)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit_outlined, size: 14),
                ],
              ),
              const SizedBox(height: 8),
              Meter(
                value: task.hoursProgress,
                height: 8,
                background: AppColors.border,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${Formatters.percent(task.hoursProgress)} consumido',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    remaining >= 0
                        ? '${Formatters.hours(remaining)} restantes'
                        : '${Formatters.hours(-remaining)} acima da estimativa',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: remaining >= 0
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Etiquetas da tarefa com campo para adicionar novas.
class _TagsSection extends StatefulWidget {
  const _TagsSection({required this.viewModel});

  final TaskDetailsViewModel viewModel;

  @override
  State<_TagsSection> createState() => _TagsSectionState();
}

class _TagsSectionState extends State<_TagsSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag() {
    widget.viewModel.addTag(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Label(icon: Icons.label_outline, text: 'Etiquetas'),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final tag in vm.task!.tags)
              _TagPill(tag: tag, onDeleted: () => vm.removeTag(tag)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onSubmitted: (_) => _addTag(),
          decoration: InputDecoration(
            hintText: 'Adicionar nova tag...',
            fillColor: AppColors.surfaceMuted,
            suffixIcon: IconButton(
              tooltip: 'Adicionar',
              icon: const Icon(Icons.add, color: AppColors.primary),
              onPressed: _addTag,
            ),
          ),
        ),
      ],
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.tag, required this.onDeleted});

  final String tag;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final highlight = tag.contains('Prioridade');
    return Pill(
      label: '#$tag',
      fontSize: 12,
      foreground: highlight ? AppColors.warning : AppColors.textPrimary,
      background: highlight ? AppColors.warningSoft : AppColors.primarySoft,
      onDeleted: onDeleted,
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle case final text? when text.isNotEmpty)
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.icon,
    required this.date,
    required this.onTap,
    required this.onClear,
    this.danger = false,
  });

  final String label;
  final IconData icon;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.textSecondary;
    final value = date;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        Material(
          color: danger ? AppColors.dangerSoft : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value == null ? 'Definir' : Formatters.fullDate(value),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: danger
                            ? AppColors.danger
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remover data',
                    visualDensity: VisualDensity.compact,
                    iconSize: 16,
                    onPressed: value == null ? null : onClear,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
