import 'package:flutter/material.dart';

import '../../constants/settings_design_tokens.dart';
// ⚠️ REMOVED: import '../../presentation/pages/data_inspector_page.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';
import '../shared/settings_list_tile.dart';

/// Development tools section (debug mode only)
/// Provides testing and debugging functionality
class DevelopmentSection extends StatelessWidget {
  const DevelopmentSection({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Desenvolvimento',
          icon: SettingsDesignTokens.devIcon,
          showIcon: false,
        ),
        SettingsCard(
          child: SettingsListTile(
            leadingIcon: Icons.storage,
            iconColor: Colors.green.shade600,
            backgroundColor: Colors.green.withValues(alpha: 0.1),
            title: 'Inspetor de Dados',
            subtitle: 'Visualizar e gerenciar dados locais',
            onTap: () => _openDataInspector(context),
          ),
        ),
      ],
    );
  }

  Future<void> _openDataInspector(BuildContext context) async {
    // ⚠️ REMOVED: DataInspectorPage no longer exists
    // await Navigator.of(context).push(
    //   MaterialPageRoute<void>(
    //     builder: (context) => const DataInspectorPage(),
    //   ),
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data Inspector foi removido')),
    );
  }
}
