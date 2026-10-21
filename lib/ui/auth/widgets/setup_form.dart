import 'package:flutter/material.dart';

import '../../core/themes/colors.dart';
import '../../core/ui/feedback.dart';
import '../../core/ui/validators.dart';
import '../view_models/login_viewmodel.dart';

/// Criação do primeiro administrador, exibida enquanto o servidor não tem
/// nenhuma conta.
class SetupForm extends StatefulWidget {
  const SetupForm({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  State<SetupForm> createState() => _SetupFormState();
}

class _SetupFormState extends State<SetupForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_name, _email, _password, _confirmation]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.viewModel.setup.execute((
      name: _name.text,
      email: _email.text,
      password: _password.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Configuração inicial',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Crie a conta do administrador. Ela também dá acesso ao painel '
            'do servidor (/_/), onde ficam os backups.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Seu nome'),
            validator: (v) => Validators.required(v, 'o nome'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-mail'),
            validator: Validators.email,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Senha'),
            validator: Validators.password,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmation,
            obscureText: true,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(labelText: 'Confirme a senha'),
            validator: (v) => Validators.confirmation(v, _password.text),
          ),
          const SizedBox(height: 20),
          _SubmitArea(viewModel: widget.viewModel, onSubmit: _submit),
        ],
      ),
    );
  }
}

class _SubmitArea extends StatelessWidget {
  const _SubmitArea({required this.viewModel, required this.onSubmit});

  final LoginViewModel viewModel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final command = viewModel.setup;
    return ListenableBuilder(
      listenable: command,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (commandError(command) case final error?) ...[
            InlineError(message: error),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: command.running ? null : onSubmit,
            child: command.running
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Criar administrador e entrar'),
          ),
        ],
      ),
    );
  }
}
