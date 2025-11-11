import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../core/extensions/praga_drift_extension.dart';
import '../../../core/services/diagnostico_integration_service.dart';

/// Bottom sheet especializado para exibir defensivos de uma praga
/// Componente reutilizável e otimizado com performance
class DefensivosBottomSheet extends StatelessWidget {
  final PragaPorCultura pragaPorCultura;
  final VoidCallback? onDefensivoTap;

  const DefensivosBottomSheet({
    super.key,
    required this.pragaPorCultura,
    this.onDefensivoTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            Expanded(child: _buildDefensivosList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final pragaName = pragaPorCultura.praga.displayName;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FontAwesomeIcons.vial,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Defensivos disponíveis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  pragaName,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildDefensivosList(BuildContext context) {
    final theme = Theme.of(context);
    final defensivos = pragaPorCultura.defensivosRelacionados;

    if (defensivos.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      itemCount: defensivos.length,
      separatorBuilder: (context, index) =>
          Divider(color: theme.dividerColor.withValues(alpha: 0.3)),
      itemBuilder: (context, index) {
        final defensivo = defensivos[index];
        return _buildDefensivoTile(context, defensivo, index);
      },
    );
  }

  Widget _buildDefensivoTile(
    BuildContext context,
    String defensivo,
    int index,
  ) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              FontAwesomeIcons.vial,
              color: Colors.blue,
              size: 16,
            ),
          ),
          title: Text(
            defensivo,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            'Defensivo registrado para esta praga',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          onTap: () {
            Navigator.of(context).pop();
            onDefensivoTap?.call();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_outlined,
              size: 40,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum defensivo encontrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta praga não possui defensivos registrados em nossa base de dados.',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Future<void> show(
    BuildContext context,
    PragaPorCultura pragaPorCultura, {
    VoidCallback? onDefensivoTap,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DefensivosBottomSheet(
        pragaPorCultura: pragaPorCultura,
        onDefensivoTap: onDefensivoTap,
      ),
    );
  }
}
