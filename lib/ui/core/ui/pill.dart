import 'package:flutter/material.dart';

import '../../../domain/models/task.dart';
import '../localization/formatters.dart';
import '../themes/colors.dart';

/// Etiqueta arredondada usada para status, prioridades e tags.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.foreground = AppColors.textSecondary,
    this.background = AppColors.surfaceMuted,
    this.icon,
    this.dot = false,
    this.fontSize = 11,
    this.onDeleted,
    this.monospace = false,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;
  final bool dot;
  final double fontSize;
  final VoidCallback? onDeleted;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: foreground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                fontFamily: monospace ? 'monospace' : null,
              ),
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onDeleted,
              child: Icon(Icons.close, size: fontSize + 1, color: foreground),
            ),
          ],
        ],
      ),
    );
  }
}

/// Cores de cada prioridade.
(Color foreground, Color background) priorityColors(TaskPriority priority) =>
    switch (priority) {
      TaskPriority.urgent => (AppColors.danger, AppColors.dangerSoft),
      TaskPriority.high => (AppColors.primary, AppColors.primarySoft),
      TaskPriority.medium => (AppColors.info, AppColors.infoSoft),
      TaskPriority.low => (AppColors.neutral, AppColors.neutralSoft),
    };

class PriorityPill extends StatelessWidget {
  const PriorityPill({super.key, required this.priority, this.label});

  final TaskPriority priority;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = priorityColors(priority);
    return Pill(
      label: label ?? Formatters.priority(priority),
      foreground: fg,
      background: bg,
      dot: true,
    );
  }
}
