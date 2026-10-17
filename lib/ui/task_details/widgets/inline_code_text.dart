import 'package:flutter/material.dart';

import '../../core/themes/colors.dart';

/// Renderiza texto com trechos `entre crases` em fonte monoespaçada.
class InlineCodeText extends StatelessWidget {
  const InlineCodeText(this.text, {super.key, this.style, this.strike = false});

  final String text;
  final TextStyle? style;
  final bool strike;

  @override
  Widget build(BuildContext context) {
    final base = (style ?? const TextStyle(fontSize: 13, height: 1.5)).copyWith(
      decoration: strike ? TextDecoration.lineThrough : null,
    );
    final parts = text.split('`');
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (var i = 0; i < parts.length; i++)
            if (i.isOdd)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    parts[i],
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: (base.fontSize ?? 13) - 1,
                      color: AppColors.primaryDark,
                      decoration: base.decoration,
                    ),
                  ),
                ),
              )
            else
              TextSpan(text: parts[i]),
        ],
      ),
    );
  }
}
