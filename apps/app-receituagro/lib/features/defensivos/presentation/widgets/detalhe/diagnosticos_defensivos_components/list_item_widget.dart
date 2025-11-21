import 'package:flutter/material.dart';

import '../../../../../../core/di/injection_container.dart';
import '../../../../../../core/extensions/diagnostico_drift_extension.dart';
import '../../../../../../core/theme/spacing_tokens.dart';
import '../../../../../../database/receituagro_database.dart';
import '../../../../../../database/repositories/pragas_repository.dart';

/// Widget responsável por renderizar um item de diagnóstico na lista
///
/// Responsabilidade única: exibir dados de um diagnóstico específico
/// - Layout consistente com card design
/// - Informações principais visíveis (nome comum, nome científico, dosagem)
/// - Avatar com imagem da praga baseada no nome científico
/// - Ação de tap configurável
/// - Performance otimizada com RepaintBoundary
class DiagnosticoDefensivoListItemWidget extends StatefulWidget {
  final dynamic diagnostico;
  final VoidCallback onTap;
  final bool isDense;
  final bool hasElevation;

  const DiagnosticoDefensivoListItemWidget({
    super.key,
    required this.diagnostico,
    required this.onTap,
    this.isDense = false,
    this.hasElevation = true,
  });

  @override
  State<DiagnosticoDefensivoListItemWidget> createState() =>
      _DiagnosticoDefensivoListItemWidgetState();
}

class _DiagnosticoDefensivoListItemWidgetState
    extends State<DiagnosticoDefensivoListItemWidget> {
  Praga? _pragaData;
  bool _isLoadingPraga = true;

  @override
  void initState() {
    super.initState();
    _loadPragaData();
  }

  Future<void> _loadPragaData() async {
    try {
      final pragasRepository = sl<PragasRepository>();
      final idPraga = _getProperty('fkIdPraga') ?? _getProperty('idPraga');

      if (idPraga != null) {
        final praga = await pragasRepository.getById(idPraga);

        if (mounted) {
          setState(() {
            _pragaData = praga;
            _isLoadingPraga = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingPraga = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPraga = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Prepara dados do conteúdo
    String nomeComumPraga = 'Praga não identificada';
    String nomeCientificoPraga = '';
    String dosagemFormatada = '';

    if (widget.diagnostico is Diagnostico) {
      // Diagnostico from Drift doesn't have denormalized nomePraga field
      // Use _getProperty to access map data or load from repository using pragaId
      final nomePragaModel = _getProperty('nomePraga') ?? _getProperty('grupo');
      nomeComumPraga = nomePragaModel ?? 'Praga não identificada';
    } else {
      final nomePragaModel = _getProperty('nomePraga') ?? _getProperty('grupo');
      if (nomePragaModel != null &&
          nomePragaModel.isNotEmpty &&
          nomePragaModel != 'Não especificado') {
        nomeComumPraga = nomePragaModel;
      }
    }
    
    // Sobrescreve com dados da praga carregada se disponível
    if (_pragaData != null) {
      final nomeComumCompleto = _pragaData!.nome;
      if (nomeComumCompleto.contains(',')) {
        nomeComumPraga = nomeComumCompleto.split(',').first.trim();
      } else if (nomeComumCompleto.contains(';')) {
        nomeComumPraga = nomeComumCompleto.split(';').first.trim();
      } else {
        nomeComumPraga = nomeComumCompleto;
      }
      
      nomeCientificoPraga = _pragaData!.nomeLatino ?? '';
    }

    final dosagemEntity = _getProperty('dosagem');
    if (dosagemEntity != null) {
      dosagemFormatada = dosagemEntity.toString();
    }

    return RepaintBoundary(
      child: Container(
        margin:
            widget.isDense
                ? const EdgeInsets.symmetric(horizontal: 8)
                : const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
        decoration:
            widget.hasElevation
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
          onTap: widget.onTap,
          dense: widget.isDense,
          contentPadding:
              widget.isDense
                  ? const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.md,
                    vertical: SpacingTokens.xs,
                  )
                  : const EdgeInsets.all(SpacingTokens.md),
          leading: _buildAvatar(context),
          title: Text(
            nomeComumPraga,
            style: TextStyle(
              fontSize: widget.isDense ? 15 : 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (nomeCientificoPraga.isNotEmpty) ...[
                SizedBox(height: widget.isDense ? 2 : SpacingTokens.xs),
                Text(
                  nomeCientificoPraga,
                  style: TextStyle(
                    fontSize: widget.isDense ? 13 : 14,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (dosagemFormatada.isNotEmpty) ...[
                SizedBox(height: widget.isDense ? 2 : SpacingTokens.xs),
                Text(
                  dosagemFormatada,
                  style: TextStyle(
                    fontSize: widget.isDense ? 11 : 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: widget.isDense ? 14 : 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          shape:
              widget.hasElevation
                  ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                  : null,
        ),
      ),
    );
  }

  /// Avatar com imagem da praga baseada no nome científico
  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoadingPraga) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_pragaData?.nomeLatino != null) {
      final imagePath =
          'assets/imagens/bigsize/${_pragaData!.nomeLatino}.jpg';

      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return ColoredBox(
                color: theme.colorScheme.primary,
                child: Icon(
                  Icons.bug_report,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
              );
            },
          ),
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.bug_report,
        color: theme.colorScheme.onPrimary,
        size: 24,
      ),
    );
  }

  /// Helper para extrair propriedades com fallbacks
  String? _getProperty(String primaryKey, [String? fallbackKey]) {
    try {
      if (widget.diagnostico is Diagnostico) {
        final diag = widget.diagnostico as Diagnostico;
        switch (primaryKey) {
          case 'dosagem':
            return diag.displayDosagem;
          case 'fkIdPraga':
          case 'idPraga':
            return diag.pragaId.toString();
          case 'fkIdCultura':
          case 'idCultura':
            return diag.culturaId.toString();
          case 'idDefensivo':
            return diag.defensivoId.toString();
          case 'nomePraga':
          case 'grupo':
            // Retorna null para forçar o carregamento via pragaId no initState/build
            return null; 
          default:
            // Tenta acessar propriedades diretas se existirem
            return _getObjectProperty(diag, primaryKey)?.toString();
        }
      } else if (widget.diagnostico is Map<String, dynamic>) {
        final map = widget.diagnostico as Map<String, dynamic>;
        return map[primaryKey]?.toString() ??
            (fallbackKey != null ? map[fallbackKey]?.toString() : null);
      } else {
        final primary = _getObjectProperty(widget.diagnostico, primaryKey);
        if (primary != null) return primary.toString();

        if (fallbackKey != null) {
          final fallback = _getObjectProperty(widget.diagnostico, fallbackKey);
          if (fallback != null) return fallback.toString();
        }
      }
    } catch (e) {
      // Ignore extraction errors
    }
    return null;
  }

  /// Helper para acessar propriedades de objeto dinamicamente
  dynamic _getObjectProperty(dynamic obj, String property) {
    try {
      switch (property) {
        case 'fkIdPraga':
          return obj.fkIdPraga;
        case 'idPraga':
          return obj.idPraga;
        case 'fkIdCultura':
          return obj.fkIdCultura;
        case 'idCultura':
          return obj.idCultura;
        case 'nomeDefensivo':
          return obj.nomeDefensivo;
        case 'nomeCultura':
          return obj.nomeCultura;
        case 'nomePraga':
          return obj.nomePraga;
        case 'dosagem':
          return obj.dosagem;
        case 'cultura':
          return obj.cultura;
        case 'grupo':
          return obj.grupo;
        case 'idDefensivo':
          return obj.idDefensivo;
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }
}
