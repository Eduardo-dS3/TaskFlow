import 'package:flutter/material.dart';

import '../../core/themes/colors.dart';
import '../../core/themes/dimens.dart';
import '../view_models/reports_viewmodel.dart';

/// Chamada para gerar o PDF executivo.
class ExecutiveBanner extends StatefulWidget {
  const ExecutiveBanner({super.key, required this.viewModel});

  final ReportsViewModel viewModel;

  @override
  State<ExecutiveBanner> createState() => _ExecutiveBannerState();
}

class _ExecutiveBannerState extends State<ExecutiveBanner> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.exportPdf.addListener(_onExport);
  }

  @override
  void didUpdateWidget(covariant ExecutiveBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      oldWidget.viewModel.exportPdf.removeListener(_onExport);
      widget.viewModel.exportPdf.addListener(_onExport);
    }
  }

  @override
  void dispose() {
    widget.viewModel.exportPdf.removeListener(_onExport);
    super.dispose();
  }

  void _onExport() {
    final command = widget.viewModel.exportPdf;
    if (command.completed) {
      command.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF executivo gerado com sucesso')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final command = widget.viewModel.exportPdf;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(Dimens.radius),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: Colors.white),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Precisa deste relatório para a reunião de diretoria?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Gere um documento executivo formatado com marcas de '
                        'confidencialidade, KPIs do sprint e análise de risco '
                        'automatizada.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: () {},
                child: const Text('Visualizar Prévia'),
              ),
              ListenableBuilder(
                listenable: command,
                builder: (context, _) => FilledButton(
                  onPressed: command.running ? null : command.execute,
                  child: command.running
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Gerar PDF Executivo'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
