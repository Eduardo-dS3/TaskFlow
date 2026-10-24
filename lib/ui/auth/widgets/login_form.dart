import 'package:flutter/material.dart';

import '../../core/themes/colors.dart';
import '../../core/ui/feedback.dart';
import '../../core/ui/validators.dart';
import '../view_models/login_viewmodel.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _identity = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _identity.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.viewModel.login.execute((
      identity: _identity.text,
      password: _password.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final command = widget.viewModel.login;
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Entrar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Use o usuário (ou e-mail) e a senha cadastrados pelo administrador.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _identity,
              autofillHints: const [AutofillHints.username],
              decoration: const InputDecoration(labelText: 'Usuário ou e-mail'),
              validator: (v) => Validators.required(v, 'o usuário ou e-mail'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Senha',
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) => Validators.required(v, 'a senha'),
            ),
            const SizedBox(height: 20),
            ListenableBuilder(
              listenable: command,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (commandError(command) case final error?) ...[
                    InlineError(message: error),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(
                    onPressed: command.running ? null : _submit,
                    child: command.running
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
