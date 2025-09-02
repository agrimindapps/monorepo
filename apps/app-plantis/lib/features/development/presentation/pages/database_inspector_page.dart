import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Consolidated Data Inspector Page for Plantis - Using Unified Implementation
/// Configured with developer dark theme and Plantis-specific custom boxes
/// Maintains security protection for production builds
class DatabaseInspectorPage extends StatelessWidget {
  const DatabaseInspectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return UnifiedDataInspectorPage(
      appName: 'Plantis',
      theme: DataInspectorTheme.developer(
        primaryColor: Colors.teal,
        accentColor: Colors.tealAccent,
      ),
      showDevelopmentWarning: true,
      customBoxes: const <CustomBoxType>[
        CustomBoxType(
          key: 'plants',
          displayName: 'Plantas',
          description: 'Dados das plantas cadastradas',
          module: 'Plantis',
        ),
        CustomBoxType(
          key: 'tasks',
          displayName: 'Tarefas',
          description: 'Tarefas de cuidado das plantas',
          module: 'Plantis',
        ),
        CustomBoxType(
          key: 'spaces',
          displayName: 'Espaços',
          description: 'Espaços onde as plantas estão localizadas',
          module: 'Plantis',
        ),
        CustomBoxType(
          key: 'settings',
          displayName: 'Configurações',
          description: 'Configurações do app',
          module: 'Plantis',
        ),
      ],
    );
  }
}

/// Alias for backward compatibility
class DataInspectorPage extends DatabaseInspectorPage {
  const DataInspectorPage({super.key});
}