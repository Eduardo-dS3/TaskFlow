import 'package:flutter/material.dart';

import '../../../config/server_config.dart';
import '../../../routing/routes.dart';
import '../../core/themes/colors.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.location,
    required this.onNavigate,
    required this.onHelp,
  });

  final String location;
  final ValueChanged<String> onNavigate;
  final VoidCallback onHelp;

  static const _items = [
    (Icons.view_kanban_outlined, 'Quadro & Tarefas', Routes.board),
    (Icons.add_circle_outline, 'Nova Tarefa', Routes.newTask),
    (Icons.folder_open_outlined, 'Projetos & Clientes', Routes.projects),
    (Icons.insights_outlined, 'Produtividade & Relatórios', Routes.reports),
  ];

  bool _isActive(String route) {
    if (route == Routes.board) {
      // Detalhes de tarefa existentes pertencem ao quadro.
      return location == Routes.board ||
          (location.startsWith(Routes.tasks) && location != Routes.newTask);
    }
    return location == route;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Logo(),
            const SizedBox(height: 28),
            for (final (icon, label, route) in _items)
              _NavItem(
                icon: icon,
                label: label,
                active: _isActive(route),
                onTap: () => onNavigate(route),
              ),
            const Spacer(),
            _NavItem(icon: Icons.help_outline, label: 'Ajuda', onTap: onHelp),
            const SizedBox(height: 8),
            const _VersionBadge(),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(Icons.task_alt_rounded, color: AppColors.primary, size: 28),
          SizedBox(width: 10),
          Text(
            'TaskFlow',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? AppColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
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

class _VersionBadge extends StatelessWidget {
  const _VersionBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.circle, size: 8, color: AppColors.successBright),
          SizedBox(width: 6),
          Text(
            'Conectado',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
          Spacer(),
          Text(
            'v$appVersion',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
