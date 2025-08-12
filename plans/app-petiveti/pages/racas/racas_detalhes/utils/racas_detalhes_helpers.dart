// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'racas_detalhes_constants.dart';

class RacasDetalhesHelpers {
  static Color getSectionColor(String section) {
    return RacasDetalhesConstants.sectionColors[section] ?? Colors.grey;
  }

  static IconData getSectionIcon(String section) {
    return RacasDetalhesConstants.sectionIcons[section] ?? Icons.info;
  }

  static Color getSectionBackgroundColor(String section) {
    return RacasDetalhesConstants.getSectionBackgroundColor(section);
  }

  static Color getSectionIconColor(String section) {
    return RacasDetalhesConstants.getSectionIconColor(section);
  }

  static BoxDecoration getCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(RacasDetalhesConstants.borderRadius),
      boxShadow: [RacasDetalhesConstants.cardShadow],
    );
  }

  static BoxDecoration getSectionHeaderDecoration(String section) {
    return BoxDecoration(
      color: getSectionBackgroundColor(section),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(RacasDetalhesConstants.borderRadius),
        topRight: Radius.circular(RacasDetalhesConstants.borderRadius),
      ),
    );
  }

  static BoxDecoration getIconContainerDecoration(String section) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(RacasDetalhesConstants.smallBorderRadius),
    );
  }

  static Widget buildCharacteristicBar(BuildContext context, int value) {
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = (screenWidth - 64) / RacasDetalhesConstants.maxCharacteristicValue;

    return Row(
      children: List.generate(RacasDetalhesConstants.maxCharacteristicValue, (index) {
        return Container(
          width: barWidth,
          height: RacasDetalhesConstants.characteristicBarHeight,
          margin: const EdgeInsets.only(
            right: RacasDetalhesConstants.characteristicBarSpacing,
          ),
          decoration: BoxDecoration(
            color: index < value
                ? getSectionIconColor('caracteristicas')
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  static String formatCharacteristicValue(int value) {
    const labels = ['Muito Baixo', 'Baixo', 'Médio', 'Alto', 'Muito Alto'];
    if (value < 1 || value > 5) return 'Não avaliado';
    return labels[value - 1];
  }

  static Color getCharacteristicColor(int value) {
    if (value <= 2) return Colors.red;
    if (value <= 3) return Colors.orange;
    if (value <= 4) return Colors.blue;
    return Colors.green;
  }

  static EdgeInsets getCardMargin() {
    return const EdgeInsets.fromLTRB(
      RacasDetalhesConstants.cardMargin,
      RacasDetalhesConstants.sectionSpacing,
      RacasDetalhesConstants.cardMargin,
      RacasDetalhesConstants.sectionSpacing,
    );
  }

  static EdgeInsets getCardPadding() {
    return const EdgeInsets.all(RacasDetalhesConstants.cardPadding);
  }

  static EdgeInsets getSectionPadding() {
    return const EdgeInsets.all(RacasDetalhesConstants.cardPadding);
  }

  static BorderRadius getDefaultBorderRadius() {
    return BorderRadius.circular(RacasDetalhesConstants.borderRadius);
  }

  static BorderRadius getSmallBorderRadius() {
    return BorderRadius.circular(RacasDetalhesConstants.smallBorderRadius);
  }

  static Widget buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: RacasDetalhesConstants.infoLabelStyle,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: RacasDetalhesConstants.infoValueStyle,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildSectionHeader(String title, String section) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: getIconContainerDecoration(section),
          child: Icon(
            getSectionIcon(section),
            color: getSectionIconColor(section),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: RacasDetalhesConstants.sectionTitleStyle.copyWith(
            color: getSectionIconColor(section),
          ),
        ),
      ],
    );
  }

  static Widget buildGalleryItem(String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: RacasDetalhesConstants.galleryItemWidth,
        margin: const EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: getSmallBorderRadius(),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error, color: Colors.grey),
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget buildRelatedBreedItem(
    String nome,
    String imagePath,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: RacasDetalhesConstants.relatedBreedWidth,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: getSmallBorderRadius(),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: RacasDetalhesConstants.relatedBreedWidth,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.pets, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              nome,
              style: RacasDetalhesConstants.relatedBreedNameStyle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  static Duration getAnimationDuration({bool fast = false}) {
    return fast 
        ? RacasDetalhesConstants.fastAnimationDuration
        : RacasDetalhesConstants.defaultAnimationDuration;
  }
}
