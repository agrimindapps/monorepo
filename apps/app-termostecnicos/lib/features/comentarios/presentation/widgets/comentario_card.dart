import 'package:flutter/material.dart';

import '../../domain/entities/comentario.dart';

/// Widget card for displaying a single comentario
class ComentarioCard extends StatelessWidget {
  final Comentario comentario;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ComentarioCard({
    super.key,
    required this.comentario,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                child: Text(
                  comentario.conteudo,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _extractFerramentaName(comentario.ferramenta),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        _buildDateInfo(comentario),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (onEdit != null)
                    IconButton(
                      color: Theme.of(context).primaryColorDark,
                      padding: const EdgeInsets.all(0.0),
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                    ),
                  if (onDelete != null)
                    IconButton(
                      color: Theme.of(context).primaryColorDark,
                      padding: const EdgeInsets.all(0.0),
                      icon: const Icon(Icons.delete),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractFerramentaName(String ferramenta) {
    final parts = ferramenta.split(' - ');
    return parts.isNotEmpty ? parts[0] : ferramenta;
  }

  String _buildDateInfo(Comentario comentario) {
    final dateStr = _formatDate(comentario.createdAt);
    final parts = comentario.ferramenta.split(' - ');

    if (parts.length > 1) {
      return '${parts[1]} - $dateStr';
    }

    return dateStr;
  }

  String _formatDate(DateTime date) {
    return date.toString().substring(0, 10).split('-').reversed.join('/');
  }
}
