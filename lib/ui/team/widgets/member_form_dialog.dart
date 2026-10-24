import 'package:flutter/material.dart';

import '../../../data/repositories/user/user_repository.dart';
import '../../../domain/models/member.dart';
import '../../core/ui/validators.dart';

/// Cadastro de uma nova pessoa. Retorna `null` se cancelado.
Future<NewMember?> showNewMemberForm(BuildContext context) =>
    showDialog<NewMember>(
      context: context,
      builder: (context) => const _MemberFormDialog(),
    );

/// Edição de uma pessoa. [isSelf] bloqueia a troca do próprio perfil de
/// administrador. Retorna `null` se cancelado.
Future<Member?> showEditMemberForm(
  BuildContext context, {
  required Member member,
  required bool isSelf,
}) => showDialog<Member>(
  context: context,
  builder: (context) => _MemberFormDialog(member: member, isSelf: isSelf),
);

class _MemberFormDialog extends StatefulWidget {
  const _MemberFormDialog({this.member, this.isSelf = false});

  /// Pessoa em edição; `null` no cadastro.
  final Member? member;
  final bool isSelf;

  @override
  State<_MemberFormDialog> createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends State<_MemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.member?.name);
  late final _email = TextEditingController(text: widget.member?.email);
  late final _username = TextEditingController(text: widget.member?.username);
  late final _role = TextEditingController(text: widget.member?.role);
  late final _capacity = TextEditingController(
    text: (widget.member?.weeklyCapacity ?? 40).round().toString(),
  );
  final _password = TextEditingController();
  late bool _isAdmin = widget.member?.isAdmin ?? false;

  bool get _creating => widget.member == null;

  @override
  void dispose() {
    for (final c in [_name, _email, _username, _role, _capacity, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validateCapacity(String? value) {
    final hours = Validators.parseNumber(value ?? '');
    if (hours == null || hours < 0 || hours > 168) {
      return 'Informe de 0 a 168 horas.';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final capacity = Validators.parseNumber(_capacity.text) ?? 40;
    final member = widget.member;
    if (member == null) {
      Navigator.pop(
        context,
        NewMember(
          name: _name.text.trim(),
          email: _email.text.trim(),
          username: _username.text.trim(),
          role: _role.text.trim(),
          password: _password.text,
          isAdmin: _isAdmin,
          weeklyCapacity: capacity,
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      member.copyWith(
        name: _name.text.trim(),
        email: _email.text.trim(),
        username: _username.text.trim(),
        role: _role.text.trim(),
        isAdmin: _isAdmin,
        weeklyCapacity: capacity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_creating ? 'Nova pessoa' : 'Editar pessoa'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 440,
          child: SingleChildScrollView(child: _fields()),
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

  Widget _fields() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextFormField(
        controller: _name,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nome'),
        validator: (v) => Validators.required(v, 'o nome'),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'E-mail (login)'),
        validator: Validators.email,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _username,
        decoration: const InputDecoration(
          labelText: 'Usuário (opcional)',
          helperText: 'Login curto aceito no lugar do e-mail. Ex.: joana',
        ),
        validator: Validators.username,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _role,
        decoration: const InputDecoration(labelText: 'Cargo ou função'),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _capacity,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Capacidade semanal (horas)',
        ),
        validator: _validateCapacity,
      ),
      if (_creating) ...[
        const SizedBox(height: 12),
        TextFormField(
          controller: _password,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Senha inicial',
            helperText: 'A pessoa pode trocar depois em Configurações',
          ),
          validator: Validators.password,
        ),
      ],
      const SizedBox(height: 8),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: _isAdmin,
        onChanged: widget.isSelf
            ? null
            : (value) => setState(() => _isAdmin = value ?? false),
        title: const Text('Administrador'),
        subtitle: Text(
          widget.isSelf
              ? 'Você não pode alterar o próprio perfil de administrador.'
              : 'Gerencia a equipe e as configurações gerais.',
        ),
      ),
    ],
  );
}
