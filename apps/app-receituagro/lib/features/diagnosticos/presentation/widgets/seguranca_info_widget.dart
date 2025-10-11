import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Widget especializado para exibir informações de segurança
/// Mostra dados de toxicidade, classe ambiental e outros alertas
class SegurancaInfoWidget extends StatelessWidget {
  final Map<String, String> informacoesSeguranca;
  final bool isCritico;

  const SegurancaInfoWidget({
    super.key,
    required this.informacoesSeguranca,
    this.isCritico = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (informacoesSeguranca.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme),
        const SizedBox(height: 16),
        _buildSegurancaCards(theme),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCritico 
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isCritico ? Icons.dangerous : Icons.security,
            color: isCritico ? Colors.red : Colors.orange,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informações de Segurança',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (isCritico)
                Text(
                  'Atenção especial requerida',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegurancaCards(ThemeData theme) {
    return Column(
      children: informacoesSeguranca.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildSegurancaCard(theme, entry.key, entry.value),
        );
      }).toList(),
    );
  }

  Widget _buildSegurancaCard(ThemeData theme, String tipo, String valor) {
    final segurancaConfig = _getSegurancaConfig(tipo, valor);
    
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: segurancaConfig.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: segurancaConfig.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: segurancaConfig.iconBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              segurancaConfig.icon,
              color: segurancaConfig.iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: segurancaConfig.textColor,
                  ),
                ),
                if (segurancaConfig.descricao != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    segurancaConfig.descricao!,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (segurancaConfig.severity == SeverityLevel.alto)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'ALTO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  SegurancaConfig _getSegurancaConfig(String tipo, String valor) {
    switch (tipo.toLowerCase()) {
      case 'toxicidade':
        return _getToxicidadeConfig(valor);
      case 'classe ambiental':
        return _getClasseAmbientalConfig(valor);
      case 'corrosivo':
        return SegurancaConfig(
          icon: FontAwesomeIcons.droplet,
          iconColor: Colors.orange,
          iconBackgroundColor: Colors.orange.withValues(alpha: 0.1),
          backgroundColor: Colors.orange.withValues(alpha: 0.05),
          borderColor: Colors.orange.withValues(alpha: 0.3),
          textColor: Colors.orange.shade700,
          severity: SeverityLevel.medio,
          descricao: 'Produto com propriedades corrosivas',
        );
      case 'inflamável':
        return SegurancaConfig(
          icon: FontAwesomeIcons.fire,
          iconColor: Colors.red,
          iconBackgroundColor: Colors.red.withValues(alpha: 0.1),
          backgroundColor: Colors.red.withValues(alpha: 0.05),
          borderColor: Colors.red.withValues(alpha: 0.3),
          textColor: Colors.red.shade700,
          severity: SeverityLevel.alto,
          descricao: 'Material inflamável - mantenha longe do fogo',
        );
      default:
        return SegurancaConfig(
          icon: Icons.info,
          iconColor: Colors.blue,
          iconBackgroundColor: Colors.blue.withValues(alpha: 0.1),
          backgroundColor: Colors.blue.withValues(alpha: 0.05),
          borderColor: Colors.blue.withValues(alpha: 0.3),
          textColor: Colors.blue.shade700,
          severity: SeverityLevel.baixo,
        );
    }
  }

  SegurancaConfig _getToxicidadeConfig(String valor) {
    final valorLower = valor.toLowerCase();
    
    if (valorLower.contains('i') || valorLower.contains('1')) {
      return SegurancaConfig(
        icon: FontAwesomeIcons.skull,
        iconColor: Colors.red,
        iconBackgroundColor: Colors.red.withValues(alpha: 0.1),
        backgroundColor: Colors.red.withValues(alpha: 0.05),
        borderColor: Colors.red.withValues(alpha: 0.3),
        textColor: Colors.red.shade700,
        severity: SeverityLevel.alto,
        descricao: 'Extremamente tóxico - use todos os EPIs',
      );
    } else if (valorLower.contains('ii') || valorLower.contains('2')) {
      return SegurancaConfig(
        icon: FontAwesomeIcons.triangleExclamation,
        iconColor: Colors.orange,
        iconBackgroundColor: Colors.orange.withValues(alpha: 0.1),
        backgroundColor: Colors.orange.withValues(alpha: 0.05),
        borderColor: Colors.orange.withValues(alpha: 0.3),
        textColor: Colors.orange.shade700,
        severity: SeverityLevel.medio,
        descricao: 'Altamente tóxico - use EPIs adequados',
      );
    } else if (valorLower.contains('iii') || valorLower.contains('3')) {
      return SegurancaConfig(
        icon: FontAwesomeIcons.exclamation,
        iconColor: Colors.amber,
        iconBackgroundColor: Colors.amber.withValues(alpha: 0.1),
        backgroundColor: Colors.amber.withValues(alpha: 0.05),
        borderColor: Colors.amber.withValues(alpha: 0.3),
        textColor: Colors.amber.shade700,
        severity: SeverityLevel.medio,
        descricao: 'Medianamente tóxico - cuidados necessários',
      );
    } else if (valorLower.contains('iv') || valorLower.contains('4')) {
      return SegurancaConfig(
        icon: FontAwesomeIcons.shield,
        iconColor: Colors.green,
        iconBackgroundColor: Colors.green.withValues(alpha: 0.1),
        backgroundColor: Colors.green.withValues(alpha: 0.05),
        borderColor: Colors.green.withValues(alpha: 0.3),
        textColor: Colors.green.shade700,
        severity: SeverityLevel.baixo,
        descricao: 'Pouco tóxico - cuidados básicos',
      );
    } else {
      return SegurancaConfig(
        icon: Icons.help,
        iconColor: Colors.grey,
        iconBackgroundColor: Colors.grey.withValues(alpha: 0.1),
        backgroundColor: Colors.grey.withValues(alpha: 0.05),
        borderColor: Colors.grey.withValues(alpha: 0.3),
        textColor: Colors.grey.shade700,
        severity: SeverityLevel.baixo,
        descricao: 'Classificação não identificada',
      );
    }
  }

  SegurancaConfig _getClasseAmbientalConfig(String valor) {
    final valorLower = valor.toLowerCase();
    
    if (valorLower.contains('i') || valorLower.contains('1')) {
      return SegurancaConfig(
        icon: FontAwesomeIcons.leaf,
        iconColor: Colors.red,
        iconBackgroundColor: Colors.red.withValues(alpha: 0.1),
        backgroundColor: Colors.red.withValues(alpha: 0.05),
        borderColor: Colors.red.withValues(alpha: 0.3),
        textColor: Colors.red.shade700,
        severity: SeverityLevel.alto,
        descricao: 'Altamente perigoso ao meio ambiente',
      );
    } else if (valorLower.contains('ii') || valorLower.contains('2')) {
      return SegurancaConfig(
        icon: FontAwesomeIcons.tree,
        iconColor: Colors.orange,
        iconBackgroundColor: Colors.orange.withValues(alpha: 0.1),
        backgroundColor: Colors.orange.withValues(alpha: 0.05),
        borderColor: Colors.orange.withValues(alpha: 0.3),
        textColor: Colors.orange.shade700,
        severity: SeverityLevel.medio,
        descricao: 'Perigoso ao meio ambiente',
      );
    } else if (valorLower.contains('iii') || valorLower.contains('3')) {
      return SegurancaConfig(
        icon: FontAwesomeIcons.seedling,
        iconColor: Colors.amber,
        iconBackgroundColor: Colors.amber.withValues(alpha: 0.1),
        backgroundColor: Colors.amber.withValues(alpha: 0.05),
        borderColor: Colors.amber.withValues(alpha: 0.3),
        textColor: Colors.amber.shade700,
        severity: SeverityLevel.medio,
        descricao: 'Perigoso ao meio ambiente',
      );
    } else if (valorLower.contains('iv') || valorLower.contains('4')) {
      return SegurancaConfig(
        icon: FontAwesomeIcons.earthAmericas,
        iconColor: Colors.green,
        iconBackgroundColor: Colors.green.withValues(alpha: 0.1),
        backgroundColor: Colors.green.withValues(alpha: 0.05),
        borderColor: Colors.green.withValues(alpha: 0.3),
        textColor: Colors.green.shade700,
        severity: SeverityLevel.baixo,
        descricao: 'Pouco perigoso ao meio ambiente',
      );
    } else {
      return SegurancaConfig(
        icon: Icons.eco,
        iconColor: Colors.grey,
        iconBackgroundColor: Colors.grey.withValues(alpha: 0.1),
        backgroundColor: Colors.grey.withValues(alpha: 0.05),
        borderColor: Colors.grey.withValues(alpha: 0.3),
        textColor: Colors.grey.shade700,
        severity: SeverityLevel.baixo,
        descricao: 'Classificação ambiental não identificada',
      );
    }
  }
}

enum SeverityLevel { baixo, medio, alto }

class SegurancaConfig {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final SeverityLevel severity;
  final String? descricao;

  SegurancaConfig({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.severity,
    this.descricao,
  });
}
