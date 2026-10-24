import 'package:flutter/material.dart';

import '../../../domain/models/member.dart';
import '../../core/themes/colors.dart';
import '../../core/themes/dimens.dart';
import '../../core/ui/command_view.dart';
import '../../core/ui/feedback.dart';
import '../view_models/team_viewmodel.dart';
import 'member_form_dialog.dart';
import 'member_row.dart';
import 'reset_password_dialog.dart';

/// Tela "Equipe": cadastro e acesso das pessoas (somente administradores).
class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key, required this.viewModel});

  final TeamViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final actions = _TeamActions(viewModel);
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
              constraints: const BoxConstraints(maxWidth: 960),
              child: viewModel.isAdmin
                  ? _TeamContent(viewModel: viewModel, actions: actions)
                  : const _AdminsOnly(),
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamContent extends StatelessWidget {
  const _TeamContent({required this.viewModel, required this.actions});

  final TeamViewModel viewModel;
  final _TeamActions actions;

  @override
  Widget build(BuildContext context) {
    final members = viewModel.members;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 12,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Equipe',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${viewModel.activeCount} pessoas ativas de '
                  '${members.length} cadastradas',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: () => actions.create(context),
              icon: const Icon(Icons.person_add_alt, size: 18),
              label: const Text('Nova pessoa'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        for (final member in members)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MemberRow(
              member: member,
              isSelf: viewModel.isSelf(member),
              now: viewModel.now,
              onEdit: () => actions.edit(context, member),
              onResetPassword: () => actions.resetPassword(context, member),
              onToggleActive: () => actions.toggleActive(context, member),
            ),
          ),
      ],
    );
  }
}

/// Ações que abrem formulários e acionam o ViewModel.
class _TeamActions {
  _TeamActions(this.viewModel);

  final TeamViewModel viewModel;

  Future<void> create(BuildContext context) async {
    final data = await showNewMemberForm(context);
    if (data == null || !context.mounted) return;
    await runWithFeedback(
      context,
      viewModel.createMember,
      () => viewModel.createMember.execute(data),
      success: '${data.name} cadastrado(a)',
    );
  }

  Future<void> edit(BuildContext context, Member member) async {
    final updated = await showEditMemberForm(
      context,
      member: member,
      isSelf: viewModel.isSelf(member),
    );
    if (updated == null || !context.mounted) return;
    await runWithFeedback(
      context,
      viewModel.updateMember,
      () => viewModel.updateMember.execute(updated),
      success: 'Dados de ${updated.name} atualizados',
    );
  }

  Future<void> resetPassword(BuildContext context, Member member) async {
    final password = await showResetPasswordDialog(context, member: member);
    if (password == null || !context.mounted) return;
    await runWithFeedback(
      context,
      viewModel.resetPassword,
      () =>
          viewModel.resetPassword.execute((member: member, password: password)),
      success: 'Senha de ${member.name} redefinida',
    );
  }

  Future<void> toggleActive(BuildContext context, Member member) async {
    if (member.active) {
      final confirmed = await confirmAction(
        context,
        title: 'Desativar ${member.name}?',
        message:
            'A pessoa não conseguirá mais entrar no TaskFlow. O histórico de '
            'tarefas e comentários é mantido e a conta pode ser reativada.',
        confirmLabel: 'Desativar',
      );
      if (!confirmed || !context.mounted) return;
    }
    await runWithFeedback(
      context,
      viewModel.toggleActive,
      () => viewModel.toggleActive.execute(member),
      success: member.active
          ? '${member.name} foi desativado(a)'
          : '${member.name} foi reativado(a)',
    );
  }
}

class _AdminsOnly extends StatelessWidget {
  const _AdminsOnly();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(Icons.lock_outline, size: 40, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text(
            'Apenas administradores podem gerenciar a equipe.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
