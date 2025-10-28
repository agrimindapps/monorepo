import 'package:flutter/material.dart';

/// Widget displayed when there are no comentarios
class EmptyComentariosWidget extends StatelessWidget {
  const EmptyComentariosWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: SizedBox(
          width: 280,
          child: Text(
            'Nenhum comentário disponível. Adicione novos comentários via Termos.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
