import 'package:flutter/material.dart';
import '../../domain/entities/card_entity.dart';
import 'memory_card_widget.dart';

class MemoryGridWidget extends StatelessWidget {
  final List<CardEntity> cards;
  final int gridSize;
  final Function(String cardId) onCardTap;

  const MemoryGridWidget({
    super.key,
    required this.cards,
    required this.gridSize,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;
    final availableWidth = isPortrait ? size.width * 0.95 : size.width * 0.6;
    final cardSize = (availableWidth / gridSize) - 8;

    return Center(
      child: SizedBox(
        width: availableWidth,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            childAspectRatio: 1,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return MemoryCardWidget(
              card: card,
              onTap: () => onCardTap(card.id),
              size: cardSize,
            );
          },
        ),
      ),
    );
  }
}
