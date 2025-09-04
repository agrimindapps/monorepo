import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Data Inspector Page for ReceitaAgro - Using Unified Implementation
/// Configured with green theme and ReceitaAgro-specific custom boxes
class DataInspectorPage extends StatelessWidget {
  const DataInspectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedDataInspectorPage(
      appName: 'ReceitaAgro',
      primaryColor: Colors.green,
      customBoxes: <CustomBoxType>[
        CustomBoxType(
          key: 'receituagro_culturas',
          displayName: 'Culturas',
          description: 'Dados de culturas agrícolas',
          module: 'ReceitaAgro',
        ),
        CustomBoxType(
          key: 'receituagro_diagnosticos',
          displayName: 'Diagnósticos',
          description: 'Diagnósticos de pragas e doenças',
          module: 'ReceitaAgro',
        ),
        CustomBoxType(
          key: 'receituagro_fitossanitarios',
          displayName: 'Fitossanitários',
          description: 'Produtos fitossanitários e defensivos',
          module: 'ReceitaAgro',
        ),
        CustomBoxType(
          key: 'receituagro_fitossanitarios_info',
          displayName: 'Fitossanitários Info',
          description: 'Informações detalhadas dos fitossanitários',
          module: 'ReceitaAgro',
        ),
        CustomBoxType(
          key: 'receituagro_plantas_inf',
          displayName: 'Plantas Info',
          description: 'Informações sobre plantas daninhas',
          module: 'ReceitaAgro',
        ),
        CustomBoxType(
          key: 'receituagro_pragas',
          displayName: 'Pragas',
          description: 'Dados de pragas e insetos',
          module: 'ReceitaAgro',
        ),
        CustomBoxType(
          key: 'receituagro_pragas_inf',
          displayName: 'Pragas Info',
          description: 'Informações detalhadas das pragas',
          module: 'ReceitaAgro',
        ),
      ],
    );
  }
}