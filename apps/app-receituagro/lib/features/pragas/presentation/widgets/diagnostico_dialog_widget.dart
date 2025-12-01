import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../database/receituagro_database.dart';
import '../../../defensivos/presentation/pages/detalhe_defensivo_page.dart';
import '../../../diagnosticos/presentation/pages/detalhe_diagnostico_page.dart';
import '../providers/diagnosticos_praga_notifier.dart';

/// Widget responsável pelo modal de detalhes do diagnóstico (a partir de uma praga)
///
/// Responsabilidade única: exibir detalhes completos de um diagnóstico em modal
/// - Layout responsivo e moderno (similar ao dialog de defensivos)
/// - Informações detalhadas do diagnóstico
/// - Ações para navegar para defensivo ou diagnóstico detalhado
/// - Carrega dados do defensivo relacionado para exibir imagem/detalhes
class DiagnosticoDialogWidget extends ConsumerStatefulWidget {
  final DiagnosticoModel diagnostico;
  final String pragaName;

  const DiagnosticoDialogWidget({
    super.key,
    required this.diagnostico,
    required this.pragaName,
  });

  /// Mostra o modal de detalhes
  static Future<void> show(
    BuildContext context,
    DiagnosticoModel diagnostico,
    String pragaName,
  ) {
    return showDialog<void>(
      context: context,
      builder:
          (context) => DiagnosticoDialogWidget(
            diagnostico: diagnostico,
            pragaName: pragaName,
          ),
    );
  }

  @override
  ConsumerState<DiagnosticoDialogWidget> createState() =>
      _DiagnosticoDialogWidgetState();
}

class _DiagnosticoDialogWidgetState
    extends ConsumerState<DiagnosticoDialogWidget> {
  Fitossanitario? _defensivoData;
  bool _isLoadingDefensivo = true;

  @override
  void initState() {
    super.initState();
    _loadDefensivoData();
  }

  /// Carrega dados do defensivo relacionado ao diagnóstico
  Future<void> _loadDefensivoData() async {
    try {
      final defensivoRepository = ref.read(fitossanitariosRepositoryProvider);
      
      // Tenta buscar por ID do defensivo
      if (widget.diagnostico.defensivoId.isNotEmpty) {
        // Primeiro tenta como int (ID do banco)
        final intId = int.tryParse(widget.diagnostico.defensivoId);
        Fitossanitario? defensivo;
        
        if (intId != null) {
          defensivo = await defensivoRepository.findById(intId);
        }
        
        // Se não encontrou, tenta como string (idDefensivo original)
        if (defensivo == null) {
          defensivo = await defensivoRepository.getById(widget.diagnostico.defensivoId);
        }
        
        if (mounted) {
          setState(() {
            _defensivoData = defensivo;
            _isLoadingDefensivo = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingDefensivo = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDefensivo = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 500, // Limite máximo de largura
          ),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModernHeader(context),
              Flexible(child: _buildModernContent(context)),
              _buildModernActions(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Cabeçalho moderno com informações do defensivo
  Widget _buildModernHeader(BuildContext context) {
    final theme = Theme.of(context);
    final nomeDefensivo = widget.diagnostico.nome;
    final ingredienteAtivo = widget.diagnostico.ingredienteAtivo.isNotEmpty
        ? widget.diagnostico.ingredienteAtivo
        : 'Ingrediente ativo não especificado';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar do defensivo
              _buildDefensivoAvatar(context),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeDefensivo,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ingredienteAtivo,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 24,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () => Navigator.of(context).pop(),
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Card com cultura
          _buildCulturaCard(context),
        ],
      ),
    );
  }

  /// Avatar do defensivo
  Widget _buildDefensivoAvatar(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoadingDefensivo) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.science_outlined,
        color: theme.colorScheme.onPrimary,
        size: 28,
      ),
    );
  }

  /// Card com informação da cultura
  Widget _buildCulturaCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.eco,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Cultura: ${widget.diagnostico.cultura}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Conteúdo moderno com informações do diagnóstico
  Widget _buildModernContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildModernInfoItem(
            context,
            icon: Icons.medical_services,
            title: 'Dosagem',
            value: widget.diagnostico.dosagem.isNotEmpty &&
                    widget.diagnostico.dosagem != 'Não informado'
                ? widget.diagnostico.dosagem
                : 'Não disponível',
          ),
          _buildModernInfoItem(
            context,
            icon: Icons.agriculture,
            title: 'Aplicação Terrestre',
            value: widget.diagnostico.aplicacaoTerrestre.isNotEmpty
                ? widget.diagnostico.aplicacaoTerrestre
                : 'Não disponível',
          ),
          _buildModernInfoItem(
            context,
            icon: Icons.flight,
            title: 'Aplicação Aérea',
            value: widget.diagnostico.aplicacaoAerea.isNotEmpty
                ? widget.diagnostico.aplicacaoAerea
                : 'Não disponível',
          ),
          _buildModernInfoItem(
            context,
            icon: Icons.schedule,
            title: 'Intervalo de Segurança',
            value: widget.diagnostico.intervaloSeguranca.isNotEmpty
                ? widget.diagnostico.intervaloSeguranca
                : 'Não disponível',
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Widget para item de informação moderno
  Widget _buildModernInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Ações modernas do modal (botões inferiores)
  Widget _buildModernActions(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _navigateToDefensivo(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: theme.colorScheme.outline),
              ),
              child: Text(
                'Defensivo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _navigateToDiagnostico(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Diagnóstico',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Navega para página de detalhes do defensivo
  void _navigateToDefensivo(BuildContext context) {
    final fabricante = _defensivoData?.fabricante ?? 'Fabricante Desconhecido';

    if (context.mounted) Navigator.of(context).pop();
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder:
              (context) => DetalheDefensivoPage(
                defensivoName: widget.diagnostico.nome,
                fabricante: fabricante,
              ),
        ),
      );
    }
  }

  /// Navega para página de detalhes do diagnóstico
  void _navigateToDiagnostico(BuildContext context) {
    if (context.mounted) Navigator.of(context).pop();
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder:
              (context) => DetalheDiagnosticoPage(
                diagnosticoId: widget.diagnostico.id,
                nomeDefensivo: widget.diagnostico.nome,
                nomePraga: widget.pragaName,
                cultura: widget.diagnostico.cultura,
              ),
        ),
      );
    }
  }
}
