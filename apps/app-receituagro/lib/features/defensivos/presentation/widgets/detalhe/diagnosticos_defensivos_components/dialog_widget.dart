import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../../../core/data/models/pragas_legacy.dart';
// DEPRECATED: import '../../../../../../core/data/repositories/pragas_legacy_repository.dart';
import '../../../../../../core/di/injection_container.dart';
import '../../../../../../core/services/receituagro_navigation_service.dart';
import '../../../../../../core/widgets/praga_image_widget.dart';

/// Widget responsável pelo modal de detalhes do diagnóstico
///
/// Responsabilidade única: exibir detalhes completos de um diagnóstico em modal
/// - Layout responsivo com constraints adequados
/// - Informações detalhadas do diagnóstico
/// - Ações para navegar para defensivo ou diagnóstico detalhado
/// - Premium badges para features pagas
class DiagnosticoDefensivoDialogWidget extends StatefulWidget {
  final dynamic diagnostico;
  final String defensivoName;
  final ReceitaAgroNavigationService navigationService;

  const DiagnosticoDefensivoDialogWidget({
    super.key,
    required this.diagnostico,
    required this.defensivoName,
    required this.navigationService,
  });

  @override
  State<DiagnosticoDefensivoDialogWidget> createState() =>
      _DiagnosticoDefensivoDialogWidgetState();

  /// Mostra o modal de detalhes
  static Future<void> show(
    BuildContext context,
    dynamic diagnostico,
    String defensivoName,
  ) {
    final navigationService = GetIt.instance<ReceitaAgroNavigationService>();
    return showDialog<void>(
      context: context,
      builder:
          (context) => DiagnosticoDefensivoDialogWidget(
            diagnostico: diagnostico,
            defensivoName: defensivoName,
            navigationService: navigationService,
          ),
    );
  }
}

class _DiagnosticoDefensivoDialogWidgetState
    extends State<DiagnosticoDefensivoDialogWidget> {
  PragasHive? _pragaData;

  @override
  void initState() {
    super.initState();
    _loadPragaData();
  }

  /// Carrega dados da praga relacionada ao diagnóstico
  Future<void> _loadPragaData() async {
    try {
      final nomePraga = _getProperty('nomePraga', 'grupo');
      if (nomePraga != null && nomePraga.isNotEmpty) {
        final pragaRepository = sl<PragasLegacyRepository>();
        final praga = await pragaRepository.findByNomeComum(nomePraga);
        if (mounted) {
          setState(() {
            _pragaData = praga;
          });
        }
      } else {
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Helper para extrair propriedades do diagnóstico
  String? _getProperty(String primaryKey, [String? secondaryKey]) {
    try {
      if (widget.diagnostico is Map<String, dynamic>) {
        final map = widget.diagnostico as Map<String, dynamic>;
        return map[primaryKey]?.toString() ??
            (secondaryKey != null ? map[secondaryKey]?.toString() : null);
      } else {
        switch (primaryKey) {
          case 'nomeDefensivo':
            return widget.diagnostico.nomeDefensivo?.toString();
          case 'nome':
            return widget.diagnostico.nome?.toString();
          case 'ingredienteAtivo':
            return widget.diagnostico.ingredienteAtivo?.toString();
          case 'nomePraga':
            return widget.diagnostico.nomePraga?.toString();
          case 'grupo':
            return widget.diagnostico.grupo?.toString();
          case 'dosagem':
            return widget.diagnostico.dosagem?.toString();
          case 'cultura':
            return widget.diagnostico.cultura?.toString();
          case 'carencia':
            return widget.diagnostico.carencia?.toString();
          case 'periodoAplicacao':
            return widget.diagnostico.periodoAplicacao?.toString();
          case 'id':
            // Tenta múltiplas variações de ID
            return widget.diagnostico.id?.toString() ??
                   widget.diagnostico.idReg?.toString() ??
                   widget.diagnostico.objectId?.toString();
          case 'idReg':
            return widget.diagnostico.idReg?.toString();
          case 'objectId':
            return widget.diagnostico.objectId?.toString();
          case 'aplicacaoTerrestre':
            return widget.diagnostico.aplicacaoTerrestre?.toString();
          case 'aplicacaoAerea':
            return widget.diagnostico.aplicacaoAerea?.toString();
          case 'intervaloDias':
            return widget.diagnostico.intervaloDias?.toString();
          default:
            return null;
        }
      }
    } catch (e) {
      return null;
    }
  }

  /// Navega para a página de detalhes da praga
  void _navigateToPraga(BuildContext context) {
    final nomePraga = _getProperty('nomePraga', 'grupo');
    final nomeComumPraga = _getProperty('nomeComumPraga', 'nomeComum');
    final idPraga = _getProperty('fkIdPraga') ?? _getProperty('idPraga');

    if (nomePraga != null) {
      widget.navigationService.navigateToDetalhePraga(
        pragaName: nomePraga,
        pragaId: idPraga,
        pragaScientificName: nomeComumPraga,
      );
    }
  }

  /// Navega para a página de detalhes do diagnóstico
  void _navigateToDetailedDiagnostic(BuildContext context) {
    // Tenta múltiplas variações de ID
    final diagnosticoId = _getProperty('id') ??
                          _getProperty('idReg') ??
                          _getProperty('objectId');

    final nomeDefensivo = _getProperty('nomeDefensivo', 'nome') ?? widget.defensivoName;
    final nomePraga = _getProperty('nomePraga', 'grupo') ?? 'Não especificado';
    final cultura = _getProperty('cultura') ?? 'Não especificada';

    if (diagnosticoId != null && diagnosticoId.isNotEmpty) {
      Navigator.of(context).pushNamed(
        '/detalhe-diagnostico',
        arguments: {
          'diagnosticoId': diagnosticoId,
          'nomeDefensivo': nomeDefensivo,
          'nomePraga': nomePraga,
          'cultura': cultura,
        },
      );
    } else {
      // Debug log para ajudar a identificar o problema
      debugPrint('❌ [DiagnosticoDefensivoDialog] ID do diagnóstico não encontrado');
      debugPrint('   diagnostico type: ${widget.diagnostico.runtimeType}');
      if (widget.diagnostico is Map) {
        debugPrint('   keys: ${(widget.diagnostico as Map).keys.toList()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width - 32,
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
    );
  }

  /// Cabeçalho moderno baseado no mockup
  Widget _buildModernHeader(BuildContext context) {
    final theme = Theme.of(context);
    final nomeDefensivo =
        _getProperty('nomeDefensivo', 'nome') ?? 'Defensivo não identificado';
    final ingredienteAtivo =
        _getProperty('ingredienteAtivo') ??
        'Ingrediente ativo não especificado';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nomeDefensivo,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
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
          const SizedBox(height: 8),
          Text(
            'Ingrediente Ativo: $ingredienteAtivo',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (_pragaData?.nomeCientifico != null) ...[
            const SizedBox(height: 16),
            _buildPragaImageSection(context),
          ],
        ],
      ),
    );
  }

  /// Seção da imagem da praga
  Widget _buildPragaImageSection(BuildContext context) {
    final theme = Theme.of(context);
    final nomePraga =
        _getProperty('nomePraga', 'grupo') ?? 'Praga não identificada';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bug_report_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Praga Relacionada',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: PragaImageWidget(
                nomeCientifico: _pragaData!.nomeCientifico,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: ColoredBox(
                  color: theme.colorScheme.surface,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bug_report_outlined,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Carregando imagem...',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                errorWidget: ColoredBox(
                  color: theme.colorScheme.surface,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bug_report_outlined,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Imagem não disponível',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nomePraga,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _pragaData!.nomeCientifico,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Conteúdo moderno com seções organizadas
  Widget _buildModernContent(BuildContext context) {
    final dosagem = _getProperty('dosagem')?.toString();
    final aplicacaoTerrestre = _getProperty('aplicacaoTerrestre');
    final aplicacaoAerea = _getProperty('aplicacaoAerea');
    final intervalo = _getProperty('intervaloDias')?.toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildModernInfoItem(
            context,
            icon: Icons.medical_services,
            title: 'Dosagem',
            value: dosagem != null && dosagem.isNotEmpty
                ? '$dosagem mg/L'
                : 'Não disponível',
            isPremium: false,
          ),
          _buildModernInfoItem(
            context,
            icon: Icons.agriculture,
            title: 'Aplicação Terrestre',
            value: aplicacaoTerrestre != null && aplicacaoTerrestre.isNotEmpty
                ? '$aplicacaoTerrestre L/ha'
                : 'Não disponível',
            isPremium: false,
          ),
          _buildModernInfoItem(
            context,
            icon: Icons.flight,
            title: 'Aplicação Aérea',
            value: aplicacaoAerea != null && aplicacaoAerea.isNotEmpty
                ? '$aplicacaoAerea L/ha'
                : 'Não disponível',
            isPremium: false,
          ),
          _buildModernInfoItem(
            context,
            icon: Icons.schedule,
            title: 'Intervalo de Aplicação',
            value: intervalo != null && intervalo.isNotEmpty
                ? '$intervalo dias'
                : 'Não disponível',
            isPremium: false,
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
    bool isPremium = false,
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
          if (isPremium) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.diamond, size: 12, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Premium',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToPraga(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: theme.colorScheme.outline),
              ),
              child: Text(
                'Pragas',
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
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToDetailedDiagnostic(context);
              },
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
}
