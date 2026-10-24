import 'package:flutter/material.dart';

import '../../../domain/models/member.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/avatar.dart';
import '../../core/ui/pill.dart';
import '../../core/ui/surface_card.dart';

/// Linha da lista da equipe com as ações disponíveis.
class MemberRow extends StatelessWidget {
  const MemberRow({
    super.key,
    required this.member,
    required this.isSelf,
    required this.now,
    required this.onEdit,
    required this.onResetPassword,
    required this.onToggleActive,
  });

  final Member member;
  final bool isSelf;
  final DateTime now;
  final VoidCallback onEdit;
  final VoidCallback onResetPassword;
  final VoidCallback onToggleActive;

  String get _lastSeen {
    final seen = member.lastSeen;
    if (seen == null) return 'Nunca acessou';
    if (member.isOnline(now)) return 'Online agora';
    return 'Último acesso ${Formatters.relativeTime(seen, now)}';
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: member.active ? 1 : 0.6,
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            InitialsAvatar(initials: member.initials, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: _Details(member: member, isSelf: isSelf),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                '${Formatters.hours(member.weeklyCapacity)}/semana\n$_lastSeen',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            _menu(),
          ],
        ),
      ),
    );
  }

  Widget _menu() => PopupMenuButton<VoidCallback>(
    tooltip: 'Ações',
    onSelected: (action) => action(),
    itemBuilder: (context) => [
      PopupMenuItem(value: onEdit, child: const Text('Editar')),
      PopupMenuItem(
        value: onResetPassword,
        child: const Text('Redefinir senha'),
      ),
      if (!isSelf)
        PopupMenuItem(
          value: onToggleActive,
          child: Text(member.active ? 'Desativar acesso' : 'Reativar acesso'),
        ),
    ],
  );
}

class _Details extends StatelessWidget {
  const _Details({required this.member, required this.isSelf});

  final Member member;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              isSelf ? '${member.name} (você)' : member.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (member.isAdmin)
              const Pill(
                label: 'Admin',
                foreground: AppColors.primaryDark,
                background: AppColors.primarySoft,
              ),
            if (!member.active)
              const Pill(
                label: 'Desativado',
                foreground: AppColors.danger,
                background: AppColors.dangerSoft,
              ),
          ],
        ),
        Text(
          [
            if (member.username.isNotEmpty) '@${member.username}',
            member.email,
            member.role,
          ].where((s) => s.isNotEmpty).join(' • '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
