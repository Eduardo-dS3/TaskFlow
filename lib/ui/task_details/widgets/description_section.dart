import 'package:flutter/material.dart';

import '../../core/themes/colors.dart';
import '../../core/ui/pill.dart';
import '../../core/ui/surface_card.dart';
import '../view_models/task_details_viewmodel.dart';
import 'inline_code_text.dart';

/// "Descrição & Especificação Técnica".
class DescriptionSection extends StatefulWidget {
  const DescriptionSection({super.key, required this.viewModel});

  final TaskDetailsViewModel viewModel;

  @override
  State<DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<DescriptionSection> {
  late final _controller = TextEditingController(
    text: widget.viewModel.task?.description,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Envolve a seleção atual com marcadores Markdown.
  void _wrapSelection(String left, [String? right]) {
    final selection = _controller.selection;
    if (!selection.isValid) return;
    final text = _controller.text;
    final selected = selection.textInside(text);
    final replaced = '$left$selected${right ?? left}';
    _controller.value = TextEditingValue(
      text: text.replaceRange(selection.start, selection.end, replaced),
      selection: TextSelection.collapsed(
        offset: selection.start + replaced.length,
      ),
    );
    widget.viewModel.updateDescription(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.viewModel.task!;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(
            icon: Icons.notes,
            title: 'Descrição & Especificação Técnica',
            trailing: Pill(label: 'Markdown Habilitado'),
          ),
          const SizedBox(height: 16),
          _Toolbar(onWrap: _wrapSelection),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            onChanged: widget.viewModel.updateDescription,
            maxLines: null,
            minLines: 3,
            style: const TextStyle(fontSize: 13, height: 1.6),
            decoration: const InputDecoration(
              hintText: 'Descreva o objetivo, contexto e critérios de aceite…',
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (task.requirements.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.shield_outlined, size: 18, color: AppColors.info),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Requisitos de Homologação & Segurança',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final requirement in task.requirements)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 6),
                child: InlineCodeText(requirement),
              ),
          ],
          if (task.payloadExample case final payload?) ...[
            const SizedBox(height: 12),
            _CodeBlock(
              title: 'PAYLOAD ESPERADO (EXEMPLO SANDBOX)',
              language: 'application/json',
              code: payload,
            ),
          ],
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.onWrap});

  final void Function(String left, [String? right]) onWrap;

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, String tooltip, VoidCallback onPressed) =>
        IconButton(
          tooltip: tooltip,
          visualDensity: VisualDensity.compact,
          iconSize: 18,
          onPressed: onPressed,
          icon: Icon(icon),
        );

    const divider = SizedBox(height: 20, child: VerticalDivider(width: 12));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          button(Icons.format_bold, 'Negrito', () => onWrap('**')),
          button(Icons.format_italic, 'Itálico', () => onWrap('_')),
          button(Icons.code, 'Código', () => onWrap('`')),
          divider,
          button(
            Icons.format_list_numbered,
            'Lista numerada',
            () => onWrap('\n1. ', ''),
          ),
          button(Icons.format_list_bulleted, 'Lista', () => onWrap('\n- ', '')),
          button(Icons.link, 'Link', () => onWrap('[', '](url)')),
          button(Icons.format_quote, 'Citação', () => onWrap('\n> ', '')),
          divider,
          button(
            Icons.data_object,
            'Bloco de código',
            () => onWrap('\n```\n', '\n```\n'),
          ),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({
    required this.title,
    required this.language,
    required this.code,
  });

  final String title;
  final String language;
  final String code;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.codeHeader,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.codeText,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                Text(
                  language,
                  style: const TextStyle(
                    color: AppColors.codeText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: AppColors.codeBackground,
            padding: const EdgeInsets.all(14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                code,
                style: const TextStyle(
                  color: AppColors.codeText,
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
