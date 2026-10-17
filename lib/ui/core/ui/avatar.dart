import 'package:flutter/material.dart';

import '../themes/colors.dart';

const _palette = [
  Color(0xFF6D5FE8),
  Color(0xFF0B6A9B),
  Color(0xFF2E7D5B),
  Color(0xFFB4532A),
  Color(0xFF8E44AD),
  Color(0xFF455A64),
  Color(0xFFC0392B),
];

/// Avatar circular com as iniciais da pessoa.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 28,
    this.soft = false,
  });

  final String initials;
  final double size;

  /// Usa fundo claro com texto colorido em vez de fundo sólido.
  final bool soft;

  @override
  Widget build(BuildContext context) {
    final color =
        _palette[initials.codeUnits.fold(0, (a, b) => a + b) % _palette.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: soft ? AppColors.primarySoft : color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: soft ? AppColors.primary : Colors.white,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Avatares sobrepostos com contador de excedentes ("+2").
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.initials,
    this.max = 3,
    this.size = 26,
  });

  final List<String> initials;
  final int max;
  final double size;

  @override
  Widget build(BuildContext context) {
    final visible = initials.take(max).toList();
    final extra = initials.length - visible.length;
    final count = visible.length + (extra > 0 ? 1 : 0);
    final overlap = size * 0.68;

    return SizedBox(
      height: size,
      width: count == 0 ? 0 : size + (count - 1) * overlap,
      child: Stack(
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * overlap,
              child: InitialsAvatar(
                initials: visible[i],
                size: size,
                soft: true,
              ),
            ),
          if (extra > 0)
            Positioned(
              left: visible.length * overlap,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '+$extra',
                  style: TextStyle(
                    fontSize: size * 0.36,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
