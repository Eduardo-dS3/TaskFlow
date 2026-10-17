import 'package:flutter/material.dart';

import '../../../domain/models/member.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/avatar.dart';
import '../../core/ui/surface_card.dart';

/// Rodapé do quadro: membros online, auto-save e ações.
class BoardFooter extends StatelessWidget {
  const BoardFooter({super.key, required this.onlineMembers});

  final List<Member> onlineMembers;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          Wrap(
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
                  AvatarStack(
                    initials: [for (final m in onlineMembers) m.initials],
                  ),
                ],
              ),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_done_outlined,
                    size: 18,
                    color: AppColors.success,
                  ),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Auto-save ativo (Flutter Web)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Wrap(
            children: [
              TextButton.icon(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                ),
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Exportar Quadro'),
              ),
              TextButton.icon(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                ),
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: const Text('Regras de Fluxo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
