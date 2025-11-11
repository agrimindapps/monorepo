import 'package:flutter/material.dart';

import '../../../../../../database/repositories/culturas_repository.dart';
import '../../../../../../core/di/injection_container.dart';
import '../../../../../../core/theme/spacing_tokens.dart';

/// Widget para seção de cultura com contador de diagnósticos e dados detalhados
class DiagnosticoDefensivoCultureSectionWidget extends StatefulWidget {
  final String cultura;
  final int diagnosticCount;
  final List<dynamic>? diagnosticos;

  const DiagnosticoDefensivoCultureSectionWidget({
    super.key,
    required this.cultura,
    required this.diagnosticCount,
    this.diagnosticos,
  });

  @override
  State<DiagnosticoDefensivoCultureSectionWidget> createState() =>
      _DiagnosticoDefensivoCultureSectionWidgetState();
}

class _DiagnosticoDefensivoCultureSectionWidgetState
    extends State<DiagnosticoDefensivoCultureSectionWidget> {
  bool _isLoadingCultura = false;

  @override
  void initState() {
    super.initState();
    _loadCulturaData();
  }

  Future<void> _loadCulturaData() async {
    if (widget.cultura == 'Não especificado' || widget.diagnosticos == null) {
      return;
    }

    setState(() {
      _isLoadingCultura = true;
    });

    try {
      final culturaRepository = sl<CulturasRepository>();
      for (final diagnostic in widget.diagnosticos!) {
        final idCulturaStr = _getProperty(diagnostic, 'idCultura');
        if (idCulturaStr != null) {
          final idCultura = int.tryParse(idCulturaStr);
          if (idCultura == null) continue;
          
          final culturaData = await culturaRepository.findById(idCultura);
          if (culturaData != null &&
              culturaData.nome.toLowerCase() ==
                  widget.cultura.toLowerCase()) {
            if (mounted) {
              setState(() {
                _isLoadingCultura = false;
              });
            }
            return;
          }
        }
      }
      if (mounted) {
        setState(() {
          _isLoadingCultura = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCultura = false;
        });
      }
    }
  }

  String? _getProperty(dynamic obj, String property) {
    try {
      if (obj is Map<String, dynamic>) {
        return obj[property]?.toString();
      } else {
        switch (property) {
          case 'idCultura':
            return obj.idCultura?.toString();
          default:
            return null;
        }
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = widget.cultura;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (_isLoadingCultura) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
                const SizedBox(width: SpacingTokens.sm),
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
                    '${widget.diagnosticCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
