import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../domain/models/task.dart';
import '../../../utils/result.dart';
import '../../core/localization/formatters.dart';
import '../../core/platform/file_actions.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/feedback.dart';
import '../../core/ui/surface_card.dart';
import '../view_models/task_details_viewmodel.dart';

/// Extensões aceitas pelo servidor (ver a migration do PocketBase).
const _allowedExtensions = [
  'png',
  'jpg',
  'jpeg',
  'gif',
  'webp',
  'pdf',
  'json',
  'txt',
  'csv',
  'zip',
  'docx',
  'xlsx',
  'pptx',
];

const _maxBytes = 25 * 1024 * 1024;

/// Painel "Arquivos Anexados".
class AttachmentsPanel extends StatelessWidget {
  const AttachmentsPanel({super.key, required this.viewModel});

  final TaskDetailsViewModel viewModel;

  Future<void> _pickAndUpload(BuildContext context) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );
    if (file == null) return;
    final size = file.lengthSync() ?? await file.length() ?? 0;
    if (size > _maxBytes) {
      if (context.mounted) {
        showMessage(context, 'O arquivo excede o limite de 25 MB.');
      }
      return;
    }
    final bytes = await file.readAsBytes();
    await viewModel.uploadAttachment.execute((name: file.name, bytes: bytes));
  }

  Future<void> _open(BuildContext context, Attachment attachment) async {
    await viewModel.openAttachment.execute(attachment);
    final result = viewModel.openAttachment.result;
    if (result case Ok(:final value)) openUrl(value);
    if (result case Error(:final error) when context.mounted) {
      showMessage(context, errorMessage(error));
    }
  }

  Future<void> _delete(BuildContext context, Attachment attachment) async {
    final confirmed = await confirmAction(
      context,
      title: 'Excluir anexo?',
      message: '"${attachment.name}" será removido da tarefa.',
    );
    if (confirmed) await viewModel.deleteAttachment.execute(attachment);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        viewModel,
        viewModel.uploadAttachment,
        viewModel.deleteAttachment,
      ]),
      builder: (context, _) {
        final task = viewModel.task!;
        return SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionTitle(
                icon: Icons.attach_file,
                title: 'Arquivos Anexados',
                trailing: Text(
                  task.attachments.length == 1
                      ? '1 arquivo'
                      : '${task.attachments.length} arquivos',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final attachment in task.attachments)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _AttachmentTile(
                    attachment: attachment,
                    onOpen: () => _open(context, attachment),
                    onDelete: () => _delete(context, attachment),
                  ),
                ),
              if (commandError(viewModel.uploadAttachment) case final error?)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InlineError(message: error),
                ),
              _UploadButton(
                enabled: task.isSaved && !viewModel.uploadAttachment.running,
                uploading: viewModel.uploadAttachment.running,
                onPressed: () => _pickAndUpload(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.attachment,
    required this.onOpen,
    required this.onDelete,
  });

  final Attachment attachment;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

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
      AttachmentType.other => (
        Icons.insert_drive_file_outlined,
        AppColors.neutral,
        AppColors.neutralSoft,
      ),
    };
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(8),
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
              Expanded(child: _AttachmentInfo(attachment: attachment)),
              IconButton(
                tooltip: 'Excluir anexo',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentInfo extends StatelessWidget {
  const _AttachmentInfo({required this.attachment});

  final Attachment attachment;

  @override
  Widget build(BuildContext context) {
    final uploader = attachment.uploadedBy?.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          attachment.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        Text(
          '${Formatters.fileSize(attachment.sizeInBytes)} · '
          '${Formatters.fullDate(attachment.uploadedAt)}'
          '${uploader == null ? '' : ' · $uploader'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({
    required this.enabled,
    required this.uploading,
    required this.onPressed,
  });

  final bool enabled;
  final bool uploading;
  final VoidCallback onPressed;

  String get _label {
    if (uploading) return 'Enviando…';
    if (enabled) return 'Anexar arquivo (até 25 MB)';
    return 'Salve a tarefa para anexar arquivos';
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: uploading
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.cloud_upload_outlined),
      label: Text(_label),
    );
  }
}
