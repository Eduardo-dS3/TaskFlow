import 'package:flutter/material.dart';

import '../../../domain/models/member.dart';
import 'avatar.dart';

/// Seleção de várias pessoas da equipe. Retorna `null` se cancelado.
Future<List<Member>?> showMemberPicker(
  BuildContext context, {
  required String title,
  required List<Member> members,
  required List<Member> selected,
}) => showDialog<List<Member>>(
  context: context,
  builder: (context) =>
      _MemberPickerDialog(title: title, members: members, selected: selected),
);

class _MemberPickerDialog extends StatefulWidget {
  const _MemberPickerDialog({
    required this.title,
    required this.members,
    required this.selected,
  });

  final String title;
  final List<Member> members;
  final List<Member> selected;

  @override
  State<_MemberPickerDialog> createState() => _MemberPickerDialogState();
}

class _MemberPickerDialogState extends State<_MemberPickerDialog> {
  late final Set<Member> _selected = {...widget.selected};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: widget.members.isEmpty
            ? const Text('Nenhuma pessoa ativa na equipe.')
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final member in widget.members)
                    CheckboxListTile(
                      value: _selected.contains(member),
                      onChanged: (checked) => setState(() {
                        if (checked ?? false) {
                          _selected.add(member);
                        } else {
                          _selected.remove(member);
                        }
                      }),
                      secondary: InitialsAvatar(
                        initials: member.initials,
                        size: 32,
                      ),
                      title: Text(member.name),
                      subtitle: Text(member.role),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, [
            for (final m in widget.members)
              if (_selected.contains(m)) m,
          ]),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
