import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/responsive_layout.dart';

/// Data Inspector Page for Plantis - Using Unified Implementation
/// Configured with developer dark theme and Plantis-specific custom boxes
/// Maintains security protection for production builds
class DataInspectorPage extends StatelessWidget {
  const DataInspectorPage({super.key});

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
          module: 'plants',
          description: 'Dados das plantas cadastradas',
        ),
        CustomBoxType(
          key: 'tasks',
          displayName: 'Tarefas de Cuidados',
          module: 'tasks',
          description: 'Lembretes e tarefas de cuidados',
        ),
        CustomBoxType(
          key: 'spaces',
          displayName: 'Espaços',
          module: 'spaces',
          description: 'Espaços onde as plantas estão localizadas',
        ),
      ],
    );
  }
}