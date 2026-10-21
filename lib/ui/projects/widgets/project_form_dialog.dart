import 'package:flutter/material.dart';

import '../../../domain/models/member.dart';
import '../../../domain/models/project.dart';
import '../../../domain/models/task.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/avatar.dart';
import '../../core/ui/member_picker_dialog.dart';
import '../../core/ui/validators.dart';

/// Cadastro ou edição de projeto. Retorna `null` se cancelado.
Future<Project?> showProjectForm(
  BuildContext context, {
  Project? project,
  required List<Client> clients,
  required List<Member> members,
}) => showDialog<Project>(
  context: context,
  builder: (context) =>
      _ProjectFormDialog(project: project, clients: clients, members: members),
);

class _ProjectFormDialog extends StatefulWidget {
  const _ProjectFormDialog({
    required this.project,
    required this.clients,
    required this.members,
  });

  final Project? project;
  final List<Client> clients;
  final List<Member> members;

  @override
  State<_ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<_ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Project? _initial = widget.project;
  late final _name = TextEditingController(text: _initial?.name);
  late final _description = TextEditingController(text: _initial?.description);
  late final _badge = TextEditingController(text: _initial?.badge);
  late final _note = TextEditingController(text: _initial?.note);
  late String? _clientId = _initial?.clientId;
  late ProjectStatus _status = _initial?.status ?? ProjectStatus.inProgress;
  late TaskPriority? _priority = _initial?.priority ?? TaskPriority.medium;
  late ProjectKind _kind = _initial?.kind ?? ProjectKind.web;
  late DateTime? _dueDate = _initial?.dueDate;
  late List<Member> _team = [...?_initial?.team];

  @override
  void dispose() {
    for (final c in [_name, _description, _badge, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _text(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final client = widget.clients.where((c) => c.id == _clientId).firstOrNull;
    Navigator.pop(
      context,
      Project(
        id: _initial?.id ?? '',
        name: _name.text.trim(),
        clientId: client?.id,
        clientName: client?.name ?? Project.internalClientName,
        description: _description.text.trim(),
        status: _status,
        kind: _kind,
        team: _team,
        priority: _priority,
        badge: _text(_badge),
        note: _text(_note),
        dueDate: _dueDate,
        finishedAt: _initial?.finishedAt,
        createdAt: _initial?.createdAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_initial == null ? 'Novo projeto' : 'Editar projeto'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nome do projeto',
                  ),
                  validator: (v) => Validators.required(v, 'o nome'),
                ),
                const SizedBox(height: 12),
                _clientField(),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                ),
                const SizedBox(height: 12),
                _classificationFields(),
                const SizedBox(height: 12),
                _labelFields(),
                const SizedBox(height: 12),
                _DueDateField(
                  date: _dueDate,
                  onChanged: (date) => setState(() => _dueDate = date),
                ),
                const SizedBox(height: 12),
                _TeamField(
                  team: _team,
                  members: widget.members,
                  onChanged: (team) => setState(() => _team = team),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Salvar')),
      ],
    );
  }

  Widget _clientField() {
    final known = widget.clients.any((c) => c.id == _clientId);
    return DropdownButtonFormField<String?>(
      initialValue: known ? _clientId : null,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Cliente'),
      items: [
        const DropdownMenuItem<String?>(
          child: Text('${Project.internalClientName} (sem cliente)'),
        ),
        for (final client in widget.clients)
          DropdownMenuItem(value: client.id, child: Text(client.name)),
      ],
      onChanged: (id) => setState(() => _clientId = id),
    );
  }

  Widget _classificationFields() => Row(
    children: [
      Expanded(
        child: DropdownButtonFormField<ProjectStatus>(
          initialValue: _status,
          decoration: const InputDecoration(labelText: 'Status'),
          items: [
            for (final s in ProjectStatus.values)
              DropdownMenuItem(
                value: s,
                child: Text(Formatters.projectStatus(s)),
              ),
          ],
          onChanged: (s) => setState(() => _status = s ?? _status),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: DropdownButtonFormField<TaskPriority?>(
          initialValue: _priority,
          decoration: const InputDecoration(labelText: 'Prioridade'),
          items: [
            const DropdownMenuItem<TaskPriority?>(child: Text('Nenhuma')),
            for (final p in TaskPriority.values)
              DropdownMenuItem(value: p, child: Text(Formatters.priority(p))),
          ],
          onChanged: (p) => setState(() => _priority = p),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: DropdownButtonFormField<ProjectKind>(
          initialValue: _kind,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Tipo'),
          items: [
            for (final k in ProjectKind.values)
              DropdownMenuItem(
                value: k,
                child: Text(Formatters.projectKind(k)),
              ),
          ],
          onChanged: (k) => setState(() => _kind = k ?? _kind),
        ),
      ),
    ],
  );

  Widget _labelFields() => Row(
    children: [
      Expanded(
        child: TextFormField(
          controller: _badge,
          decoration: const InputDecoration(
            labelText: 'Etiqueta (opcional)',
            hintText: 'Ex.: Aguardando Cliente',
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: TextFormField(
          controller: _note,
          decoration: const InputDecoration(
            labelText: 'Observação (opcional)',
            hintText: 'Ex.: Em Produção',
          ),
        ),
      ),
    ],
  );
}

class _DueDateField extends StatelessWidget {
  const _DueDateField({required this.date, required this.onChanged});

  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final value = date;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Prazo',
        suffixIcon: value == null
            ? null
            : IconButton(
                tooltip: 'Remover prazo',
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => onChanged(null),
              ),
      ),
      child: InkWell(
        onTap: () => _pick(context),
        child: Text(
          value == null ? 'Sem data definida' : Formatters.fullDate(value),
        ),
      ),
    );
  }
}

class _TeamField extends StatelessWidget {
  const _TeamField({
    required this.team,
    required this.members,
    required this.onChanged,
  });

  final List<Member> team;
  final List<Member> members;
  final ValueChanged<List<Member>> onChanged;

  Future<void> _edit(BuildContext context) async {
    final selected = await showMemberPicker(
      context,
      title: 'Equipe do projeto',
      members: members,
      selected: team,
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Equipe'),
      child: Row(
        children: [
          Expanded(
            child: team.isEmpty
                ? const Text(
                    'Ninguém alocado',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                : Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final m in team)
                        Tooltip(
                          message: m.name,
                          child: InitialsAvatar(initials: m.initials, size: 28),
                        ),
                    ],
                  ),
          ),
          TextButton(
            onPressed: () => _edit(context),
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }
}
