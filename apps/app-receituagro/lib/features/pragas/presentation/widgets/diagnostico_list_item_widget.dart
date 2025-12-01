import 'package:flutter/material.dart';

import '../../../../core/theme/spacing_tokens.dart';
import '../providers/diagnosticos_praga_notifier.dart';

/// Widget responsável por renderizar um item de diagnóstico na lista
///
/// Responsabilidade única: exibir dados de um diagnóstico específico
/// - Layout consistente com card design (similar ao de defensivos)
/// - Informações principais visíveis (nome do defensivo, ingrediente ativo, dosagem)
/// - Avatar com iniciais do defensivo
/// - Ação de tap configurável
/// - Performance otimizada com RepaintBoundary
class DiagnosticoListItemWidget extends StatelessWidget {
  final DiagnosticoModel diagnostico;
  final VoidCallback onTap;
  final bool isDense;
  final bool hasElevation;

  const DiagnosticoListItemWidget({
    super.key,
    required this.diagnostico,
    required this.onTap,
    this.isDense = false,
    this.hasElevation = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Container(
        margin: isDense
            ? const EdgeInsets.symmetric(horizontal: 8)
            : const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
        decoration: hasElevation
            ? BoxDecoration(
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
              )
            : null,
        child: ListTile(
          onTap: onTap,
          dense: isDense,
          contentPadding: isDense
              ? const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.xs,
                )
              : const EdgeInsets.all(SpacingTokens.md),
          leading: _buildAvatar(context),
          title: Text(
            diagnostico.nome,
            style: TextStyle(
              fontSize: isDense ? 15 : 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (diagnostico.ingredienteAtivo.isNotEmpty &&
                  diagnostico.ingredienteAtivo != 'Não especificado') ...[
                SizedBox(height: isDense ? 2 : SpacingTokens.xs),
                Text(
                  diagnostico.ingredienteAtivo,
                  style: TextStyle(
                    fontSize: isDense ? 13 : 14,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (diagnostico.dosagem.isNotEmpty &&
                  diagnostico.dosagem != 'Não informado') ...[
                SizedBox(height: isDense ? 2 : SpacingTokens.xs),
                Text(
                  diagnostico.dosagem,
                  style: TextStyle(
                    fontSize: isDense ? 11 : 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: isDense ? 14 : 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          shape: hasElevation
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
        ),
      ),
    );
  }

  /// Avatar com ícone do defensivo (consistente com o visual de defensivos)
  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.science_outlined, // Ícone de defensivo/química
        color: theme.colorScheme.onPrimary,
        size: 24,
      ),
    );
  }
}

/// Widget para seção de cultura que agrupa diagnósticos
///
/// Responsabilidade única: exibir cabeçalho de agrupamento por cultura
/// Visual similar ao DiagnosticoDefensivoCultureSectionWidget
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

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.md,
        ),
        margin: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.eco,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                cultura,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.sm,
                vertical: SpacingTokens.xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$diagnosticCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
