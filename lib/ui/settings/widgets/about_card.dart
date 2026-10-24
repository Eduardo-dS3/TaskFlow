import 'package:flutter/material.dart';

import '../../../config/server_config.dart';
import '../../core/platform/file_actions.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/surface_card.dart';

/// Versão, endereço do servidor e acesso ao painel de administração.
class AboutCard extends StatelessWidget {
  const AboutCard({super.key, required this.isAdmin});

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(icon: Icons.info_outline, title: 'Sobre'),
          const SizedBox(height: 12),
          const _Line(label: 'Versão', value: appVersion),
          _Line(label: 'Servidor', value: apiBaseUrl),
          if (isAdmin) ...[
            const SizedBox(height: 12),
            const Text(
              'Backups, logs e o banco de dados ficam no painel do servidor. '
              'O acesso inicial é sa@taskflow.local com a senha 256318; '
              'troque essa senha no próprio painel depois de entrar.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => openUrl(Uri.parse('$apiBaseUrl/_/')),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Abrir painel do servidor'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
