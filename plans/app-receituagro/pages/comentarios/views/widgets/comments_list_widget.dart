// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../models/comentarios_models.dart';
import '../../controller/comentarios_controller.dart';
import 'comentarios_card.dart';

class CommentsListWidget extends StatelessWidget {
  final ComentariosController controller;
  final List<Comentarios> comentarios;
  final String? ferramenta;
  final String? pkIdentificador;

  const CommentsListWidget({
    super.key,
    required this.controller,
    required this.comentarios,
    this.ferramenta,
    this.pkIdentificador,
  });

  @override
  Widget build(BuildContext context) {
    if (comentarios.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('Nenhum comentário encontrado.'),
        ),
      );
    }

    return ListView.builder(
      itemCount: comentarios.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final comentario = comentarios[index];
        return ComentariosCard(
          comentario: comentario,
          ferramenta: ferramenta ?? '',
          pkIdentificador: pkIdentificador ?? '',
          controller: controller,
          onEdit: controller.onCardEdit,
          onDelete: () => controller.onCardDelete(comentario),
          onCancel: controller.onCardCancel,
        );
      },
    );
  }
}
