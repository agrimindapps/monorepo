// MÓDULO: Detalhes de Diagnóstico
// ARQUIVO: Widget Botão de Favorito
// DESCRIÇÃO: Componente para marcar/desmarcar itens como favoritos
// RESPONSABILIDADES: UI do botão favorito, animações de estado
// DEPENDÊNCIAS: Flutter Material
// CRIADO: 2025-06-22 | ATUALIZADO: 2025-06-22
// AUTOR: Sistema de Desenvolvimento ReceituAgro

// Flutter imports:
import 'package:flutter/material.dart';

class FavoriteButtonWidget extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggle;

  const FavoriteButtonWidget({
    super.key,
    required this.isFavorite,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isFavorite ? Colors.pink.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFavorite ? Colors.pink.shade200 : Colors.grey.shade300,
        ),
      ),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey<bool>(isFavorite),
            color: isFavorite ? Colors.pink : Colors.grey.shade600,
          ),
        ),
        onPressed: onToggle,
        tooltip:
            isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
        iconSize: 20,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        splashRadius: 24,
      ),
    );
  }
}
