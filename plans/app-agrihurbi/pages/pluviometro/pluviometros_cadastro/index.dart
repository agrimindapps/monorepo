// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/widgets/dialog_cadastro_widget.dart';
import '../../../models/pluviometros_models.dart';
import 'widgets/pluviometro_form_widget.dart';

Future<bool?> pluviometroCadastro(
  BuildContext context,
  Pluviometro? pluviometro,
) {
  final formWidgetKey = GlobalKey<PluviometroFormWidgetState>();

  return DialogCadastro.show(
    context: context,
    title: 'Pluviômetro',
    formKey: formWidgetKey,
    maxHeight: _getResponsiveDialogHeight(context),
    onSubmit: () => formWidgetKey.currentState!.submit(),
    formWidget: (key) => PluviometroFormWidget(
      key: key,
      pluviometro: pluviometro,
    ),
  );
}

/// Calcula altura responsiva para o dialog baseada no tamanho da tela
double _getResponsiveDialogHeight(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final screenHeight = screenSize.height;
  final screenWidth = screenSize.width;

  // Detecta orientação
  final isLandscape = screenWidth > screenHeight;

  // Calcula altura baseada no tamanho da tela
  double baseHeight;

  if (screenHeight <= 600) {
    // Telas pequenas (phones pequenos)
    baseHeight = isLandscape ? screenHeight * 0.85 : screenHeight * 0.6;
  } else if (screenHeight <= 800) {
    // Telas médias (phones grandes)
    baseHeight = isLandscape ? screenHeight * 0.8 : screenHeight * 0.5;
  } else if (screenHeight <= 1024) {
    // Telas grandes (tablets)
    baseHeight = isLandscape ? screenHeight * 0.75 : screenHeight * 0.45;
  } else {
    // Telas muito grandes (desktop)
    baseHeight = isLandscape ? screenHeight * 0.7 : screenHeight * 0.4;
  }

  // Garante altura mínima e máxima
  const minHeight = 300.0;
  const maxHeight = 800.0;

  return baseHeight.clamp(minHeight, maxHeight);
}
