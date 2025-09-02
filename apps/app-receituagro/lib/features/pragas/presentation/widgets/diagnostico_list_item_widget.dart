import 'package:flutter/material.dart';

import '../providers/diagnosticos_praga_provider.dart';

/// Widget responsável por renderizar um item de diagnóstico na lista
/// 
/// Responsabilidade única: exibir dados de um diagnóstico específico
/// - Layout consistente com card design
/// - Informações principais visíveis (nome, ingrediente ativo, dosagem)
/// - Ação de tap configurável
/// - Performance otimizada com RepaintBoundary
class DiagnosticoListItemWidget extends StatelessWidget {
  final DiagnosticoModel diagnostico;
  final VoidCallback onTap;

  const DiagnosticoListItemWidget({
    super.key,
    required this.diagnostico,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8.0),
          decoration: _buildCardDecoration(context),
          child: Row(
            children: [
              _buildIcon(context),
              const SizedBox(width: 16),
              Expanded(
                child: _buildContent(context),
              ),
              _buildTrailingActions(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Decoração do card do item
  BoxDecoration _buildCardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: theme.shadowColor.withValues(alpha: 0.1),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Ícone representativo do diagnóstico
  Widget _buildIcon(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.agriculture,
        color: theme.colorScheme.onPrimary,
        size: 24,
      ),
    );
  }

  /// Conteúdo principal com informações do diagnóstico
  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          diagnostico.nome,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          diagnostico.ingredienteAtivo,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Dosagem: ${diagnostico.dosagem}',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  /// Ações à direita (ícones de aviso e navegação)
  Widget _buildTrailingActions(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          Icons.warning,
          color: Colors.orange[600],
          size: 18,
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ],
    );
  }
}

/// Widget para seção de cultura que agrupa diagnósticos
/// 
/// Responsabilidade única: exibir cabeçalho de agrupamento por cultura
class DiagnosticoCultureSectionWidget extends StatelessWidget {
  final String cultura;
  final int diagnosticCount;

  const DiagnosticoCultureSectionWidget({
    super.key,
    required this.cultura,
    required this.diagnosticCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diagnosticText = '$diagnosticCount diagnóstico${diagnosticCount > 1 ? 's' : ''}';
    
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.eco,
              color: theme.colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              '$cultura ($diagnosticText)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}