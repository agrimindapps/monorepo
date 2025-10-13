import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

/// Widget para seção de sincronização (placeholder Phase 2)
class ProfileSyncSection extends StatelessWidget {
  const ProfileSyncSection({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusDialog,
        ),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(Icons.sync, color: Theme.of(context).colorScheme.primary),
        title: const Text('Sincronização'),
        subtitle: const Text('Aguardando Phase 2 - UnifiedSync'),
        trailing: const Icon(Icons.info_outline),
      ),
    );
  }
}
