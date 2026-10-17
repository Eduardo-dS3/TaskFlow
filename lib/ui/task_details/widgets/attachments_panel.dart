import 'package:flutter/material.dart';

import '../../../domain/models/task.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/surface_card.dart';
import '../view_models/task_details_viewmodel.dart';

/// Painel "Arquivos Anexados".
class AttachmentsPanel extends StatelessWidget {
  const AttachmentsPanel({super.key, required this.viewModel});

  final TaskDetailsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final attachments = viewModel.task!.attachments;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(
            icon: Icons.attach_file,
            title: 'Arquivos Anexados',
            trailing: Text(
              '${attachments.length} arquivos',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final attachment in attachments)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AttachmentTile(attachment: attachment),
            ),
          const SizedBox(height: 4),
          const _DropZone(),
        ],
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.attachment});

  final Attachment attachment;

  @override
  Widget build(BuildContext context) {
    final (icon, color, bg) = switch (attachment.type) {
      AttachmentType.image => (
        Icons.image_outlined,
        AppColors.info,
        AppColors.infoSoft,
      ),
      AttachmentType.pdf => (
        Icons.picture_as_pdf_outlined,
        AppColors.danger,
        AppColors.dangerSoft,
      ),
      AttachmentType.json => (
        Icons.data_object,
        AppColors.primary,
        AppColors.primarySoft,
      ),
    };
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${Formatters.fileSize(attachment.sizeInBytes)} · '
                  '${Formatters.shortDate(attachment.uploadedAt)} '
                  '${attachment.uploadedAt.year}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Baixar',
            onPressed: () {},
            icon: const Icon(Icons.download_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}

class _DropZone extends StatelessWidget {
  const _DropZone();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined, color: AppColors.textSecondary),
            SizedBox(height: 6),
            Text(
              'Arraste novos documentos',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              'PDF, PNG ou JSON até 25MB',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
      );
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 9) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
