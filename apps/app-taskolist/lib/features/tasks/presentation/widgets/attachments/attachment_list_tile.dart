import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../../domain/task_attachment_entity.dart';

class AttachmentListTile extends StatelessWidget {
  final TaskAttachmentEntity attachment;
  final VoidCallback onDelete;

  const AttachmentListTile({
    super.key,
    required this.attachment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: _buildLeadingWidget(),
        title: Text(
          attachment.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          attachment.humanReadableSize,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!attachment.isUploaded)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  size: 16,
                  color: Colors.orange[300],
                ),
              ),
            if (attachment.isUploaded)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.cloud_done,
                  size: 16,
                  color: Colors.green[300],
                ),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
              color: Colors.red[300],
            ),
          ],
        ),
        onTap: () => _openFile(context),
      ),
    );
  }

  Widget _buildLeadingWidget() {
    if (attachment.type == AttachmentType.image &&
        attachment.filePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          File(attachment.filePath!),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildIconWidget(),
        ),
      );
    }

    return _buildIconWidget();
  }

  Widget _buildIconWidget() {
    IconData icon;
    Color color;

    switch (attachment.type) {
      case AttachmentType.image:
        icon = Icons.image;
        color = Colors.blue;
        break;
      case AttachmentType.pdf:
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case AttachmentType.document:
        icon = Icons.description;
        color = Colors.orange;
        break;
      case AttachmentType.other:
        icon = Icons.attach_file;
        color = Colors.grey;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Future<void> _openFile(BuildContext context) async {
    if (attachment.filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arquivo não disponível offline')),
      );
      return;
    }

    try {
      await OpenFilex.open(attachment.filePath!);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao abrir arquivo: $e')));
      }
    }
  }
}
