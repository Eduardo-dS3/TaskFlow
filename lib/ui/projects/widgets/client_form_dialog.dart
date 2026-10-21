import 'package:flutter/material.dart';

import '../../../domain/models/project.dart';
import '../../core/localization/formatters.dart';
import '../../core/ui/validators.dart';

/// Cadastro ou edição de cliente. Retorna `null` se cancelado.
Future<Client?> showClientForm(BuildContext context, {Client? client}) =>
    showDialog<Client>(
      context: context,
      builder: (context) => _ClientFormDialog(client: client),
    );

class _ClientFormDialog extends StatefulWidget {
  const _ClientFormDialog({this.client});

  final Client? client;

  @override
  State<_ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends State<_ClientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.client?.name);
  late final _sla = TextEditingController(text: widget.client?.sla);
  late final _contract = TextEditingController(text: widget.client?.contract);
  late ClientTier _tier = widget.client?.tier ?? ClientTier.pro;

  @override
  void dispose() {
    _name.dispose();
    _sla.dispose();
    _contract.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Client(
        id: widget.client?.id ?? '',
        name: _name.text.trim(),
        tier: _tier,
        sla: _sla.text.trim(),
        contract: _contract.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.client == null ? 'Novo cliente' : 'Editar cliente'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => Validators.required(v, 'o nome'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ClientTier>(
                initialValue: _tier,
                decoration: const InputDecoration(
                  labelText: 'Plano contratual',
                ),
                items: [
                  for (final tier in ClientTier.values)
                    DropdownMenuItem(
                      value: tier,
                      child: Text(Formatters.clientTier(tier)),
                    ),
                ],
                onChanged: (tier) => setState(() => _tier = tier ?? _tier),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sla,
                decoration: const InputDecoration(
                  labelText: 'SLA',
                  hintText: 'Ex.: SLA 4h',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contract,
                decoration: const InputDecoration(
                  labelText: 'Contrato',
                  hintText: 'Ex.: Contrato Enterprise #490',
                ),
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
        FilledButton(onPressed: _submit, child: const Text('Salvar')),
      ],
    );
  }
}
