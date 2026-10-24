import 'package:flutter/material.dart';

import '../../../domain/models/member.dart';
import '../../core/ui/validators.dart';

/// Define uma nova senha para [member]. Retorna `null` se cancelado.
Future<String?> showResetPasswordDialog(
  BuildContext context, {
  required Member member,
}) => showDialog<String>(
  context: context,
  builder: (context) => _ResetPasswordDialog(member: member),
);

class _ResetPasswordDialog extends StatefulWidget {
  const _ResetPasswordDialog({required this.member});

  final Member member;

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nova senha para ${widget.member.name}'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _password,
                autofocus: true,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nova senha'),
                validator: Validators.password,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmation,
                obscureText: true,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Confirme a senha',
                ),
                validator: (v) => Validators.confirmation(v, _password.text),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Definir senha')),
      ],
    );
  }
}
