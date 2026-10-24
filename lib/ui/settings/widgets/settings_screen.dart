import 'package:flutter/material.dart';

import '../../core/themes/colors.dart';
import '../../core/themes/dimens.dart';
import '../../core/ui/command_view.dart';
import '../view_models/settings_viewmodel.dart';
import 'about_card.dart';
import 'organization_card.dart';
import 'password_card.dart';
import 'profile_card.dart';

/// Tela "Configurações": perfil, senha, organização e informações do sistema.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CommandView(
      command: viewModel.load,
      onRetry: viewModel.load.execute,
      builder: (context) => ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Dimens.paddingPageCompact,
            8,
            Dimens.paddingPageCompact,
            Dimens.paddingPage,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Configurações',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const Text(
                    'Seus dados de acesso e as configurações gerais do TaskFlow.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ProfileCard(viewModel: viewModel),
                  const SizedBox(height: 20),
                  PasswordCard(viewModel: viewModel),
                  if (viewModel.isAdmin) ...[
                    const SizedBox(height: 20),
                    OrganizationCard(viewModel: viewModel),
                  ],
                  const SizedBox(height: 20),
                  AboutCard(isAdmin: viewModel.isAdmin),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
