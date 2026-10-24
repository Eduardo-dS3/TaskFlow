import 'package:flutter/material.dart';

import '../../core/ui/feedback.dart';
import '../../core/ui/surface_card.dart';
import '../../core/ui/validators.dart';
import '../view_models/settings_viewmodel.dart';

/// Nome e cargo do usuário logado.
class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.viewModel.user?.name);
  late final _role = TextEditingController(text: widget.viewModel.user?.role);

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final command = widget.viewModel.saveProfile;
    await runWithFeedback(
      context,
      command,
      () => command.execute((name: _name.text, role: _role.text)),
      success: 'Perfil atualizado',
    );
  }

  @override
  Widget build(BuildContext context) {
    final command = widget.viewModel.saveProfile;
    return SurfaceCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionTitle(icon: Icons.person_outline, title: 'Meu perfil'),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.viewModel.user?.email,
              enabled: false,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) => Validators.required(v, 'o nome'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _role,
              decoration: const InputDecoration(
                labelText: 'Cargo ou função',
                hintText: 'Ex.: Desenvolvedora Backend',
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ListenableBuilder(
                listenable: command,
                builder: (context, _) => FilledButton(
                  onPressed: command.running ? null : _submit,
                  child: const Text('Salvar perfil'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
