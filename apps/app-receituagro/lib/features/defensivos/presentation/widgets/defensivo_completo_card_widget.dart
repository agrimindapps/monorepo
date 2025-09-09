import 'package:flutter/material.dart';

import '../../domain/entities/defensivo_entity.dart';

/// Widget de card para exibir informações completas de um defensivo
/// Migrado e adaptado de defensivos_agrupados para nova arquitetura SOLID
class DefensivoCompletoCardWidget extends StatelessWidget {
  final DefensivoEntity defensivo;
  final bool modoComparacao;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onSelecaoChanged;

  const DefensivoCompletoCardWidget({
    super.key,
    required this.defensivo,
    required this.modoComparacao,
    required this.isSelected,
    required this.onTap,
    this.onSelecaoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected 
            ? BorderSide(color: theme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: modoComparacao ? onSelecaoChanged : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 12),
              _buildInfoPrincipal(),
              const SizedBox(height: 8),
              _buildInfoSecundaria(),
              if (modoComparacao) ...[
                const SizedBox(height: 12),
                _buildSelectionIndicator(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                defensivo.displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                defensivo.displayFabricante,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        if (defensivo.quantidadeDiagnosticos != null && defensivo.quantidadeDiagnosticos! > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${defensivo.quantidadeDiagnosticos} usos',
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoPrincipal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Ingrediente Ativo', defensivo.displayIngredient),
        const SizedBox(height: 4),
        _buildInfoRow('Classe Agronômica', defensivo.displayClass),
      ],
    );
  }

  Widget _buildInfoSecundaria() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        if (defensivo.displayModoAcao != 'Não especificado')
          _buildChip('Modo: ${defensivo.displayModoAcao}', Icons.track_changes),
        if (defensivo.displayToxico != 'Não informado')
          _buildChip('Toxicidade: ${defensivo.displayToxico}', Icons.warning),
        if (defensivo.isComercializado)
          _buildChip('Comercializado', Icons.store, Colors.green),
        if (defensivo.isElegivel)
          _buildChip('Elegível', Icons.verified, Colors.blue),
      ],
    );
  }

  Widget _buildSelectionIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isSelected ? theme.primaryColor : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            isSelected ? 'Selecionado para comparação' : 'Toque para selecionar',
            style: TextStyle(
              color: isSelected ? theme.primaryColor : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, [Color? color]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color ?? Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color ?? Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}