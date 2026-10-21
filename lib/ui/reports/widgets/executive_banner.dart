import 'package:flutter/material.dart';

import '../../core/themes/colors.dart';
import '../../core/themes/dimens.dart';
import '../view_models/reports_viewmodel.dart';
import 'reports_screen.dart';

/// Chamada para gerar o PDF executivo (prévia em nova aba ou download).
class ExecutiveBanner extends StatelessWidget {
  const ExecutiveBanner({
    super.key,
    required this.viewModel,
    required this.exports,
  });

  final ReportsViewModel viewModel;
  final ReportExports exports;

  @override
  Widget build(BuildContext context) {
    final command = viewModel.exportPdf;
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
            child: const _BannerText(),
          ),
          ListenableBuilder(
            listenable: command,
            builder: (context, _) => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton(
                  onPressed: command.running
                      ? null
                      : () => exports.pdf(preview: true),
                  child: const Text('Visualizar Prévia'),
                ),
                FilledButton(
                  onPressed: command.running
                      ? null
                      : () => exports.pdf(preview: false),
                  child: command.running
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Baixar PDF Executivo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerText extends StatelessWidget {
  const _BannerText();

  @override
  Widget build(BuildContext context) {
    return Row(
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
                'Precisa deste relatório para uma reunião?',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 2),
              Text(
                'Gere um documento executivo com marca de confidencialidade, '
                'indicadores do período e análise de risco automática.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
