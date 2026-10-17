import 'package:flutter/material.dart';

import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/avatar.dart';
import '../../core/ui/meter.dart';
import '../../core/ui/pill.dart';
import '../../core/ui/surface_card.dart';
import '../view_models/task_details_viewmodel.dart';

/// Painel "Propriedades": projeto, cliente, responsável, datas, horas e tags.
class PropertiesPanel extends StatefulWidget {
  const PropertiesPanel({super.key, required this.viewModel});

  final TaskDetailsViewModel viewModel;

  @override
  State<PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<PropertiesPanel> {
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    widget.viewModel.addTag(_tagController.text);
    _tagController.clear();
  }

  Future<void> _pickDate(
    DateTime? initial,
    ValueChanged<DateTime> onPicked,
  ) async {
    final now = widget.viewModel.now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final task = vm.task!;
        final remaining = task.estimatedHours - task.loggedHours;
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
              const _Label(
                icon: Icons.folder_outlined,
                text: 'Projeto Associado',
              ),
              DropdownButtonFormField<String>(
                initialValue: task.projectName,
                isExpanded: true,
                hint: const Text('Selecione um projeto'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                items: [
                  for (final name in vm.projectNames)
                    DropdownMenuItem(value: name, child: Text(name)),
                ],
                onChanged: (value) {
                  if (value != null) vm.setProject(value);
                },
              ),
              if (task.clientName case final client?) ...[
                const SizedBox(height: 16),
                const _Label(icon: Icons.business_outlined, text: 'Cliente'),
                _InfoTile(
                  leading: _initialsBox(client),
                  title: client,
                  subtitle: task.clientContract,
                ),
              ],
              const SizedBox(height: 16),
              const _Label(
                icon: Icons.person_outline,
                text: 'Responsável Principal',
              ),
              _InfoTile(
                leading: InitialsAvatar(
                  initials: task.owner?.initials ?? '?',
                  size: 34,
                ),
                title: task.owner?.name ?? 'Sem responsável',
                subtitle: task.owner?.role,
                trailing: PopupMenuButton<void>(
                  tooltip: 'Trocar responsável',
                  icon: const Icon(Icons.swap_horiz, color: AppColors.primary),
                  itemBuilder: (context) => [
                    for (final member in vm.members)
                      PopupMenuItem<void>(
                        onTap: () => vm.setOwner(member),
                        child: Text(member.name),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Início',
                      icon: Icons.calendar_today_outlined,
                      date: task.startDate,
                      onTap: () => _pickDate(task.startDate, vm.setStartDate),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DateField(
                      label: 'Prazo Final',
                      icon: Icons.flag_outlined,
                      date: task.dueDate,
                      danger: true,
                      onTap: () => _pickDate(task.dueDate, vm.setDueDate),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
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
                          '${Formatters.hours(remaining < 0 ? 0 : remaining)} restantes',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: _Label(icon: Icons.label_outline, text: 'Etiquetas'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '+ Gerenciar',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in task.tags)
                    Pill(
                      label: '#$tag',
                      fontSize: 12,
                      foreground: tag.contains('Prioridade')
                          ? AppColors.warning
                          : AppColors.textPrimary,
                      background: tag.contains('Prioridade')
                          ? AppColors.warningSoft
                          : AppColors.primarySoft,
                      onDeleted: () => vm.removeTag(tag),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tagController,
                onSubmitted: (_) => _addTag(),
                decoration: InputDecoration(
                  hintText: 'Adicionar nova tag...',
                  fillColor: AppColors.surfaceMuted,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    onPressed: _addTag,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _initialsBox(String name) {
    final parts = name.split(' ');
    final initials = parts.length > 1
        ? parts[0][0] + parts[1][0]
        : name.substring(0, 2);
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          fontSize: 12,
        ),
      ),
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
                if (subtitle != null)
                  Text(
                    subtitle!,
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
    this.danger = false,
  });

  final String label;
  final IconData icon;
  final DateTime? date;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.textSecondary;
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
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                date == null ? '—' : Formatters.fullDate(date!),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: danger ? AppColors.danger : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
