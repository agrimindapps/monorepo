// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../models/praga_counts.dart';
import 'category_button.dart';

class MenuCard extends StatelessWidget {
  static const Widget _verticalSpacing = SizedBox(height: 8);
  static const Widget _horizontalSpacing = SizedBox(width: 8);

  final PragaCounts counts;
  final Function(String) onInsectsTap;
  final Function(String) onDoencasTap;
  final Function(String) onPlantasTap;
  final VoidCallback onCulturasTap;

  const MenuCard({
    super.key,
    required this.counts,
    required this.onInsectsTap,
    required this.onDoencasTap,
    required this.onPlantasTap,
    required this.onCulturasTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // Removida elevação do card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Mantém o raio, mas sem borda
        side: BorderSide.none, // Remove a borda
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallDevice = screenWidth < 360;
            final useVerticalLayout = isSmallDevice || availableWidth < 320;

            if (useVerticalLayout) {
              return _buildVerticalMenuLayout(availableWidth);
            } else {
              return _buildGridMenuLayout(availableWidth, context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildVerticalMenuLayout(double availableWidth) {
    final buttonWidth = availableWidth - 16;
    final standardColor = Colors.green.shade700;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CategoryButton(
          count: counts.insetos.toString(),
          title: 'Insetos',
          width: buttonWidth,
          onTap: () => onInsectsTap('1'),
          icon: FontAwesome.bug_solid,
          color: standardColor,
        ),
        _verticalSpacing,
        CategoryButton(
          count: counts.doencas.toString(),
          title: 'Doenças',
          width: buttonWidth,
          onTap: () => onDoencasTap('2'),
          icon: FontAwesome.virus_solid,
          color: standardColor,
        ),
        _verticalSpacing,
        CategoryButton(
          count: counts.plantas.toString(),
          title: 'Plantas',
          width: buttonWidth,
          onTap: () => onPlantasTap('3'),
          icon: FontAwesome.seedling_solid,
          color: standardColor,
        ),
        _verticalSpacing,
        CategoryButton(
          count: counts.culturas.toString(),
          title: 'Culturas',
          width: buttonWidth,
          onTap: onCulturasTap,
          icon: FontAwesome.wheat_awn_solid,
          color: standardColor,
        ),
      ],
    );
  }

  Widget _buildGridMenuLayout(double availableWidth, BuildContext context) {
    final isMediumDevice = MediaQuery.of(context).size.width < 600;
    final buttonWidth =
        isMediumDevice ? (availableWidth - 32) / 3 : (availableWidth - 40) / 3;
    final standardColor = Colors.green.shade700;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CategoryButton(
              count: counts.insetos.toString(),
              title: 'Insetos',
              width: buttonWidth,
              onTap: () => onInsectsTap('1'),
              icon: FontAwesome.bug_solid,
              color: standardColor,
            ),
            _horizontalSpacing,
            CategoryButton(
              count: counts.doencas.toString(),
              title: 'Doenças',
              width: buttonWidth,
              onTap: () => onDoencasTap('2'),
              icon: FontAwesome.virus_solid,
              color: standardColor,
            ),
            _horizontalSpacing,
            CategoryButton(
              count: counts.plantas.toString(),
              title: 'Plantas',
              width: buttonWidth,
              onTap: () => onPlantasTap('3'),
              icon: FontAwesome.seedling_solid,
              color: standardColor,
            ),
          ],
        ),
        _verticalSpacing,
        CategoryButton(
          count: counts.culturas.toString(),
          title: 'Culturas',
          width: isMediumDevice ? availableWidth - 16 : availableWidth * 0.75,
          onTap: onCulturasTap,
          icon: FontAwesome.wheat_awn_solid,
          color: standardColor,
        ),
      ],
    );
  }
}
