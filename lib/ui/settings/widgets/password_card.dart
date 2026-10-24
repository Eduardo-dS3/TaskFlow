import 'package:flutter/material.dart';

import '../../core/ui/feedback.dart';
import '../../core/ui/surface_card.dart';
import '../../core/ui/validators.dart';
import '../view_models/settings_viewmodel.dart';

/// Troca da senha do usuário logado.
class PasswordCard extends StatefulWidget {
  const PasswordCard({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  State<PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<PasswordCard> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_current, _next, _confirmation]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final command = widget.viewModel.changePassword;
    final ok = await runWithFeedback(
      context,
      command,
      () => command.execute((current: _current.text, next: _next.text)),
      success: 'Senha alterada',
    );
    if (ok) {
      for (final controller in [_current, _next, _confirmation]) {
        controller.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final command = widget.viewModel.changePassword;
    return SurfaceCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionTitle(
              icon: Icons.lock_outline,
              title: 'Alterar senha',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _current,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha atual'),
              validator: (v) => Validators.required(v, 'a senha atual'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _next,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nova senha'),
              validator: Validators.password,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmation,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirme a nova senha',
              ),
              validator: (v) => Validators.confirmation(v, _next.text),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ListenableBuilder(
                listenable: command,
                builder: (context, _) => FilledButton(
                  onPressed: command.running ? null : _submit,
                  child: const Text('Alterar senha'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
