import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/task_attachment_entity.dart';
import '../../providers/task_attachment_notifier.dart';
import 'attachment_list_tile.dart';
import 'attachment_picker_bottom_sheet.dart';

class AttachmentsSection extends ConsumerWidget {
  final String taskId;
  final String userId;

  const AttachmentsSection({
    super.key,
    required this.taskId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachmentsAsync = ref.watch(taskAttachmentNotifierProvider(taskId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Anexos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () => _showAttachmentPicker(context, ref),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Adicionar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        attachmentsAsync.when(
          data: (attachments) {
            if (attachments.isEmpty) {
              return _buildEmptyState(context);
            }

            return Column(
              children: attachments
                  .map(
                    (attachment) => AttachmentListTile(
                      attachment: attachment,
                      onDelete: () => _deleteAttachment(ref, attachment.id),
                    ),
                  )
                  .toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Erro ao carregar anexos: $error',
              style: TextStyle(color: Colors.red[300]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.attach_file, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Nenhum anexo',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Toque em "Adicionar" para anexar arquivos',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentPicker(BuildContext context, WidgetRef ref) {
    AttachmentPickerBottomSheet.show(
      context,
      onCamera: () => _addFromCamera(ref),
      onGallery: () => _addFromGallery(ref),
      onFiles: () => _addFromFiles(ref),
    );
  }

  Future<void> _addFromCamera(WidgetRef ref) async {
    await ref.read(taskAttachmentNotifierProvider(taskId).notifier).addFromCamera(userId);
  }

  Future<void> _addFromGallery(WidgetRef ref) async {
    await ref.read(taskAttachmentNotifierProvider(taskId).notifier).addFromGallery(userId);
  }

  Future<void> _addFromFiles(WidgetRef ref) async {
    await ref.read(taskAttachmentNotifierProvider(taskId).notifier).addFromFiles(userId);
  }

  Future<void> _deleteAttachment(WidgetRef ref, String attachmentId) async {
    await ref
        .read(taskAttachmentNotifierProvider(taskId).notifier)
        .removeAttachment(attachmentId);
  }
}
