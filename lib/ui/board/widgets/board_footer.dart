import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/member.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/avatar.dart';
import '../../core/ui/surface_card.dart';

/// Rodapé do quadro: quem está usando o sistema agora e última atualização.
class BoardFooter extends StatelessWidget {
  const BoardFooter({
    super.key,
    required this.onlineMembers,
    required this.loadedAt,
  });

  final List<Member> onlineMembers;
  final DateTime? loadedAt;

  @override
  Widget build(BuildContext context) {
    final updated = loadedAt;
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Membros online:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              if (onlineMembers.isEmpty)
                const Flexible(
                  child: Text(
                    'ninguém no momento',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                Tooltip(
                  message: onlineMembers.map((m) => m.name).join(', '),
                  child: AvatarStack(
                    initials: [for (final m in onlineMembers) m.initials],
                    max: 6,
                  ),
                ),
            ],
          ),
          if (updated != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_done_outlined,
                  size: 18,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  'Atualizado às ${DateFormat.Hm('pt_BR').format(updated)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
