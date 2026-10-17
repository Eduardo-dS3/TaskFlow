import 'package:flutter/material.dart';

import '../../../domain/models/project.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/pill.dart';
import '../../core/ui/surface_card.dart';

/// "Clientes Ativos" com o tier contratual de cada um.
class ClientsCard extends StatelessWidget {
  const ClientsCard({super.key, required this.clients});

  final List<Client> clients;

  (Color, Color) _tierColors(ClientTier tier) => switch (tier) {
    ClientTier.enterprise => (Colors.white, AppColors.primary),
    ClientTier.pro => (Colors.white, AppColors.info),
    ClientTier.custom => (Colors.white, AppColors.danger),
    ClientTier.maintenance => (AppColors.textPrimary, AppColors.neutralSoft),
  };

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(
            title: 'Clientes Ativos',
            trailing: Text(
              'Tier Contratual',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          for (final client in clients)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        client.initials,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: client.tier == ClientTier.custom
                              ? AppColors.danger
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            client.description,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Pill(
                      label: Formatters.clientTier(client.tier),
                      foreground: _tierColors(client.tier).$1,
                      background: _tierColors(client.tier).$2,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primarySoft,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.person_add_alt, size: 18),
            label: const Text('Gerenciar Contratos & Clientes'),
          ),
        ],
      ),
    );
  }
}
