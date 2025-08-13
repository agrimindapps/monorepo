// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../constants/layout_constants.dart';
import '../models/defensivos_home_data.dart';
import 'category_button.dart';

class CategoriesSection extends StatelessWidget {
  final DefensivosHomeData homeData;
  final Function(String) onCategoryTap;

  const CategoriesSection({
    super.key,
    required this.homeData,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallDevice = size.width < LayoutConstants.smallDeviceMaxWidth;
    final isMediumDevice = size.width >= LayoutConstants.smallDeviceMaxWidth && size.width < LayoutConstants.mediumDeviceMaxWidth;
    
    return Card(
      elevation: ElevationConstants.cardElevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LayoutConstants.defaultBorderRadius)),
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.defaultPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final useVerticalLayout = isSmallDevice || availableWidth < LayoutConstants.responsiveLayoutBreakpoint;
            double buttonWidth;
            
            if (useVerticalLayout) {
              buttonWidth = availableWidth - LayoutConstants.categoryButtonMargin;
            } else if (isMediumDevice) {
              buttonWidth = (availableWidth - LayoutConstants.categoryButtonSpacing) / 2;
            } else {
              buttonWidth = (availableWidth - LayoutConstants.categoryButtonLargeSpacing) / 2;
            }
            
            final standardColor = Colors.green[ColorConstants.greenShade700]!;
            
            if (useVerticalLayout) {
              return _buildVerticalLayout(buttonWidth, standardColor);
            } else {
              return _buildHorizontalLayout(buttonWidth, standardColor);
            }
          },
        ),
      ),
    );
  }

  Widget _buildVerticalLayout(double buttonWidth, Color standardColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CategoryButton(
          count: homeData.defensivos.toString(),
          title: 'Defensivos',
          width: buttonWidth,
          onTap: () => onCategoryTap('defensivos'),
          icon: FontAwesome.spray_can_solid,
          color: standardColor,
        ),
        const SizedBox(height: LayoutConstants.defaultSpacing),
        CategoryButton(
          count: homeData.fabricantes.toString(),
          title: 'Fabricantes',
          width: buttonWidth,
          onTap: () => onCategoryTap('fabricantes'),
          icon: FontAwesome.industry_solid,
          color: standardColor,
        ),
        const SizedBox(height: LayoutConstants.defaultSpacing),
        CategoryButton(
          count: homeData.actionMode.toString(),
          title: 'Modo de Ação',
          width: buttonWidth,
          onTap: () => onCategoryTap('modoAcao'),
          icon: FontAwesome.bullseye_solid,
          color: standardColor,
        ),
        const SizedBox(height: LayoutConstants.defaultSpacing),
        CategoryButton(
          count: homeData.activeIngredient.toString(),
          title: 'Ingrediente Ativo',
          width: buttonWidth,
          onTap: () => onCategoryTap('ingredienteAtivo'),
          icon: FontAwesome.flask_solid,
          color: standardColor,
        ),
        const SizedBox(height: LayoutConstants.defaultSpacing),
        CategoryButton(
          count: homeData.agronomicClass.toString(),
          title: 'Classe Agronômica',
          width: buttonWidth,
          onTap: () => onCategoryTap('classeAgronomica'),
          icon: FontAwesome.seedling_solid,
          color: standardColor,
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(double buttonWidth, Color standardColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CategoryButton(
              count: homeData.defensivos.toString(),
              title: 'Defensivos',
              width: buttonWidth,
              onTap: () => onCategoryTap('defensivos'),
              icon: FontAwesome.spray_can_solid,
              color: standardColor,
            ),
            CategoryButton(
              count: homeData.fabricantes.toString(),
              title: 'Fabricantes',
              width: buttonWidth,
              onTap: () => onCategoryTap('fabricantes'),
              icon: FontAwesome.industry_solid,
              color: standardColor,
            ),
          ],
        ),
        const SizedBox(height: LayoutConstants.defaultSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CategoryButton(
              count: homeData.actionMode.toString(),
              title: 'Modo de Ação',
              width: buttonWidth,
              onTap: () => onCategoryTap('modoAcao'),
              icon: FontAwesome.bullseye_solid,
              color: standardColor,
            ),
            CategoryButton(
              count: homeData.activeIngredient.toString(),
              title: 'Ingrediente Ativo',
              width: buttonWidth,
              onTap: () => onCategoryTap('ingredienteAtivo'),
              icon: FontAwesome.flask_solid,
              color: standardColor,
            ),
          ],
        ),
        const SizedBox(height: LayoutConstants.defaultSpacing),
        CategoryButton(
          count: homeData.agronomicClass.toString(),
          title: 'Classe Agronômica',
          width: buttonWidth,
          onTap: () => onCategoryTap('classeAgronomica'),
          icon: FontAwesome.seedling_solid,
          color: standardColor,
        ),
      ],
    );
  }
}
