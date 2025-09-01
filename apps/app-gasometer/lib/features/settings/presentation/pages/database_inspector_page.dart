import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Database Inspector Page for GasOMeter - Using Unified Implementation
/// Configured with blue theme and GasOMeter-specific custom boxes
class DatabaseInspectorPage extends StatelessWidget {
  const DatabaseInspectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedDataInspectorPage(
      appName: 'GasoMeter',
      primaryColor: Colors.blue,
      customBoxes: <CustomBoxType>[
        CustomBoxType(
          key: 'vehicles',
          displayName: 'Veículos',
          description: 'Dados dos veículos cadastrados no app',
          module: 'Veículos',
        ),
        CustomBoxType(
          key: 'fuel_records',
          displayName: 'Abastecimentos',
          description: 'Registros de abastecimento de combustível',
          module: 'Combustível',
        ),
        CustomBoxType(
          key: 'maintenance',
          displayName: 'Manutenções',
          description: 'Registros de manutenção dos veículos',
          module: 'Manutenção',
        ),
        CustomBoxType(
          key: 'odometer',
          displayName: 'Odômetro',
          description: 'Leituras do odômetro dos veículos',
          module: 'Odômetro',
        ),
        CustomBoxType(
          key: 'expenses',
          displayName: 'Despesas',
          description: 'Despesas relacionadas aos veículos',
          module: 'Despesas',
        ),
        CustomBoxType(
          key: 'sync_queue',
          displayName: 'Fila de Sincronização',
          description: 'Fila de itens pendentes para sincronização',
          module: 'Sincronização',
        ),
        CustomBoxType(
          key: 'categories',
          displayName: 'Categorias',
          description: 'Categorias para classificação de despesas',
          module: 'Categorias',
        ),
      ],
    );
  }
}