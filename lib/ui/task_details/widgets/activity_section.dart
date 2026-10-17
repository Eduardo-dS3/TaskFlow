import 'package:flutter/material.dart';

import '../../../domain/models/task.dart';
import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/avatar.dart';
import '../../core/ui/pill.dart';
import '../../core/ui/surface_card.dart';
import '../view_models/task_details_viewmodel.dart';

/// "Atividades & Discussão Técnica".
class ActivitySection extends StatefulWidget {
  const ActivitySection({super.key, required this.viewModel});

  final TaskDetailsViewModel viewModel;

  @override
  State<ActivitySection> createState() => _ActivitySectionState();
}

class _ActivitySectionState extends State<ActivitySection> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.addComment.addListener(_onCommentResult);
  }

  @override
  void dispose() {
    widget.viewModel.addComment.removeListener(_onCommentResult);
    _controller.dispose();
    super.dispose();
  }

  void _onCommentResult() {
    if (widget.viewModel.addComment.completed) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final task = vm.task!;
        return SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionTitle(
                icon: Icons.forum_outlined,
                title: 'Atividades & Discussão Técnica',
                trailing: Text(
                  '${task.commentCount} comentários',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.owner case final owner?)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: InitialsAvatar(initials: owner.initials, size: 36),
                    ),
                  Expanded(child: _composer(vm)),
                ],
              ),
              const SizedBox(height: 20),
              for (final comment in task.comments)
                _CommentTile(comment: comment, now: vm.now),
            ],
          ),
        );
      },
    );
  }

  Widget _composer(TaskDetailsViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _controller,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Escreva um comentário ou mencione colegas com @...',
            fillColor: AppColors.surfaceMuted,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.attach_file,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.alternate_email,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const Spacer(),
            ListenableBuilder(
              listenable: vm.addComment,
              builder: (context, _) => FilledButton(
                onPressed: vm.addComment.running
                    ? null
                    : () => vm.addComment.execute(_controller.text),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                child: const Text('Comentar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, required this.now});

  final TaskComment comment;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InitialsAvatar(initials: comment.author.initials, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      comment.author.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      comment.author.role,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '· ${Formatters.relativeTime(comment.createdAt, now)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.body,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
                if (comment.commit != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Pill(
                        label: 'commit: ${comment.commit}',
                        monospace: true,
                        foreground: AppColors.textPrimary,
                      ),
                      if (comment.ciApproved)
                        const Pill(
                          label: 'CI/CD Aprovado',
                          icon: Icons.check,
                          foreground: AppColors.success,
                          background: Colors.transparent,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
