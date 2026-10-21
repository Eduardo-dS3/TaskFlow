import 'package:flutter/material.dart';

import '../../core/themes/colors.dart';
import '../../core/ui/command_view.dart';
import '../../core/ui/surface_card.dart';
import '../view_models/login_viewmodel.dart';
import 'login_form.dart';
import 'setup_form.dart';

/// Tela de entrada: login ou, num servidor novo, criação do administrador.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Brand(),
                const SizedBox(height: 24),
                SurfaceCard(
                  padding: const EdgeInsets.all(24),
                  child: CommandView(
                    command: viewModel.checkSetup,
                    onRetry: viewModel.checkSetup.execute,
                    errorTitle: 'Não foi possível conectar ao servidor',
                    builder: (context) => ListenableBuilder(
                      listenable: viewModel,
                      builder: (context, _) => viewModel.needsSetup
                          ? SetupForm(viewModel: viewModel)
                          : LoginForm(viewModel: viewModel),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.task_alt_rounded, color: AppColors.primary, size: 36),
        SizedBox(width: 10),
        Text(
          'TaskFlow',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
