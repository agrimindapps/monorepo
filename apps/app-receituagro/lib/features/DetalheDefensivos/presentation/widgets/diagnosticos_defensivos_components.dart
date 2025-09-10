import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/spacing_tokens.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/models/cultura_hive.dart';
import '../../../../core/models/pragas_hive.dart';
import '../../../../core/repositories/cultura_hive_repository.dart';
import '../../../../core/repositories/pragas_hive_repository.dart';
import '../../../detalhes_diagnostico/detalhe_diagnostico_page.dart';
import '../../detalhe_defensivo_page.dart' as defensivo_page;
import '../providers/diagnosticos_provider_legacy.dart';

/// Componentes modulares para exibição de diagnósticos em páginas de defensivos
/// 
/// Este arquivo contém todos os widgets auxiliares necessários para replicar
/// a funcionalidade e visual dos diagnósticos da página de pragas, adaptados
/// para funcionar com defensivos.

// ============================================================================
// FILTRO DE DIAGNÓSTICOS
// ============================================================================

/// Widget responsável pelos filtros de diagnósticos
/// 
/// Responsabilidade única: renderizar e gerenciar filtros de pesquisa e cultura
/// - Campo de busca por texto
/// - Dropdown de seleção de cultura
/// - Layout responsivo e design consistente
class DiagnosticoDefensivoFilterWidget extends StatelessWidget {
  const DiagnosticoDefensivoFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Consumer<DiagnosticosProvider>(
        builder: (context, provider, child) {
          
          return Container(
            padding: const EdgeInsets.all(SpacingTokens.sm),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _SearchField(
                    onChanged: (query) => provider.setSearchQuery(query),
                  ),
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  flex: 1,
                  child: _CultureDropdown(
                    value: provider.selectedCultura ?? 'Todas',
                    cultures: provider.availableCulturas,
                    onChanged: (cultura) => provider.setSelectedCultura(cultura),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}

/// Campo de busca personalizado
class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Pesquisar diagnósticos...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}

/// Dropdown de seleção de cultura
class _CultureDropdown extends StatelessWidget {
  final String value;
  final List<String> cultures;
  final ValueChanged<String> onChanged;

  const _CultureDropdown({
    required this.value,
    required this.cultures,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        items: cultures.map<DropdownMenuItem<String>>((String culture) {
          return DropdownMenuItem<String>(
            value: culture,
            child: Text(
              culture,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ============================================================================
// GERENCIAMENTO DE ESTADOS
// ============================================================================

/// Widget para gerenciamento de estados da lista de diagnósticos
class DiagnosticoDefensivoStateManager extends StatelessWidget {
  final String defensivoName;
  final Widget Function(List<dynamic>) builder;
  final VoidCallback? onRetry;

  const DiagnosticoDefensivoStateManager({
    super.key,
    required this.defensivoName,
    required this.builder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DiagnosticosProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const DiagnosticoDefensivoLoadingWidget();
        }

        if (provider.hasError) {
          return DiagnosticoDefensivoErrorWidget(
            errorMessage: provider.errorMessage ?? 'Erro desconhecido',
            onRetry: onRetry,
          );
        }

        if (provider.diagnosticos.isEmpty) {
          return DiagnosticoDefensivoEmptyWidget(defensivoName: defensivoName);
        }

        return builder(provider.diagnosticos);
      },
    );
  }
}

/// Widget para estado de carregamento
class DiagnosticoDefensivoLoadingWidget extends StatelessWidget {
  const DiagnosticoDefensivoLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(SpacingTokens.xxl),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Widget para estado de erro
class DiagnosticoDefensivoErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const DiagnosticoDefensivoErrorWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: SpacingTokens.lg),
              Text(
                'Erro ao carregar diagnósticos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: SpacingTokens.lg),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para estado vazio
class DiagnosticoDefensivoEmptyWidget extends StatelessWidget {
  final String defensivoName;

  const DiagnosticoDefensivoEmptyWidget({
    super.key,
    required this.defensivoName,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: SpacingTokens.lg),
              Text(
                'Nenhum diagnóstico encontrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Não há diagnósticos disponíveis para $defensivoName',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SEÇÃO DE CULTURA
// ============================================================================

/// Widget para seção de cultura com contador de diagnósticos e dados detalhados
class DiagnosticoDefensivoCultureSectionWidget extends StatefulWidget {
  final String cultura;
  final int diagnosticCount;
  /// Lista de diagnósticos para buscar dados de cultura reais
  final List<dynamic>? diagnosticos;

  const DiagnosticoDefensivoCultureSectionWidget({
    super.key,
    required this.cultura,
    required this.diagnosticCount,
    this.diagnosticos,
  });

  @override
  State<DiagnosticoDefensivoCultureSectionWidget> createState() => _DiagnosticoDefensivoCultureSectionWidgetState();
}

class _DiagnosticoDefensivoCultureSectionWidgetState extends State<DiagnosticoDefensivoCultureSectionWidget> {
  CulturaHive? _culturaData;
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
      final culturaRepository = sl<CulturaHiveRepository>();
      
      // Tenta buscar pelos diagnósticos primeiro (usando idCultura)
      for (final diagnostic in widget.diagnosticos!) {
        final idCultura = _getProperty(diagnostic, 'idCultura');
        if (idCultura != null) {
          final culturaData = culturaRepository.getById(idCultura);
          if (culturaData != null && culturaData.cultura.toLowerCase() == widget.cultura.toLowerCase()) {
            if (mounted) {
              setState(() {
                _culturaData = culturaData;
                _isLoadingCultura = false;
              });
            }
            return;
          }
        }
      }
      
      // Se não encontrou, tenta buscar por nome
      final culturaData = culturaRepository.findByName(widget.cultura);
      if (mounted) {
        setState(() {
          _culturaData = culturaData;
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

  /// Helper para extrair propriedades
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

// ============================================================================
// ITEM DE DIAGNÓSTICO
// ============================================================================

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

  const DiagnosticoDefensivoListItemWidget({
    super.key,
    required this.diagnostico,
    required this.onTap,
  });

  @override
  State<DiagnosticoDefensivoListItemWidget> createState() => _DiagnosticoDefensivoListItemWidgetState();
}

class _DiagnosticoDefensivoListItemWidgetState extends State<DiagnosticoDefensivoListItemWidget> {
  PragasHive? _pragaData;
  bool _isLoadingPraga = true;

  @override
  void initState() {
    super.initState();
    _loadPragaData();
  }

  Future<void> _loadPragaData() async {
    try {
      final pragasRepository = sl<PragasHiveRepository>();
      
      // Debug completo do diagnóstico
      print('🔬 === DEBUG DIAGNÓSTICO COMPLETO ===');
      print('📋 Tipo do objeto: ${widget.diagnostico.runtimeType}');
      
      if (widget.diagnostico is Map<String, dynamic>) {
        final map = widget.diagnostico as Map<String, dynamic>;
        print('🗝️ Chaves disponíveis: ${map.keys.toList()}');
        print('📊 Valores: ${map}');
      } else {
        print('🔧 Propriedades do objeto:');
        try {
          final props = [
            'idPraga', 'fkIdPraga', 'idDefensivo', 'nomeDefensivo', 
            'nomePraga', 'idCultura', 'fkIdCultura', 'nomeCultura'
          ];
          for (final prop in props) {
            final value = _getProperty(prop);
            print('  • $prop: $value');
          }
        } catch (e) {
          print('  ❌ Erro ao acessar propriedades: $e');
        }
      }
      
      final idPraga = _getProperty('idPraga');
      print('🎯 idPraga extraído: "$idPraga" (tipo: ${idPraga.runtimeType})');
      
      // Debug do repositório de pragas
      print('📦 === DEBUG REPOSITÓRIO PRAGAS ===');
      final todasPragas = pragasRepository.getAll();
      print('📊 Total de pragas na box: ${todasPragas.length}');
      
      if (todasPragas.isNotEmpty) {
        print('🔍 Primeiras 3 pragas como exemplo:');
        for (int i = 0; i < 3 && i < todasPragas.length; i++) {
          final p = todasPragas[i];
          print('  ${i + 1}. ID: "${p.idReg}" | Nome: "${p.nomeComum}" | Científico: "${p.nomeCientifico}"');
        }
        
        // Verifica se existe uma praga com o idPraga exato
        if (idPraga != null) {
          final pragaExata = todasPragas.where((p) => p.idReg == idPraga).toList();
          print('🎯 Pragas com ID "$idPraga": ${pragaExata.length}');
          if (pragaExata.isNotEmpty) {
            print('✅ Praga encontrada: "${pragaExata.first.nomeComum}"');
          } else {
            print('❌ Nenhuma praga encontrada com ID "$idPraga"');
            // Procura IDs similares
            final similares = todasPragas.where((p) => p.idReg.contains(idPraga)).toList();
            print('🔍 IDs similares ($similares.length): ${similares.map((p) => '"${p.idReg}"').take(5).join(", ")}');
          }
        }
      }
      
      if (idPraga != null) {
        final praga = pragasRepository.getById(idPraga);
        print('🔍 Resultado getById("$idPraga"): ${praga != null ? '"${praga.nomeComum}"' : 'null'}');
        
        if (mounted) {
          setState(() {
            _pragaData = praga;
            _isLoadingPraga = false;
          });
        }
      } else {
        print('⚠️ idPraga é null - não há o que buscar');
        if (mounted) {
          setState(() {
            _isLoadingPraga = false;
          });
        }
      }
      
      print('🏁 === FIM DEBUG ===');
      
    } catch (e, stackTrace) {
      print('❌ Erro ao carregar dados da praga: $e');
      print('📚 Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoadingPraga = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: _buildCardDecoration(context),
          child: Row(
            children: [
              _buildAvatar(context),
              const SizedBox(width: SpacingTokens.lg),
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
    
    if (_pragaData?.nomeCientifico != null) {
      // Gera URL da imagem baseada no nome científico
      final nomeCientificoFormatted = _pragaData!.nomeCientifico
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^a-z_]'), '');
      final imageUrl = 'https://example.com/images/$nomeCientificoFormatted.jpg';
      
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
          child: Image.network(
            imageUrl,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.bug_report,
                color: theme.colorScheme.primary,
                size: 24,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
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

  /// Conteúdo principal com informações do diagnóstico
  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    
    // Dados da praga com formatação específica
    String nomeComumPraga = 'Praga não identificada';
    String nomeCientificoPraga = '';
    
    if (_pragaData != null) {
      // Primeira linha: nome comum da praga, se separado por vírgula ou ponto vírgula, apenas o primeiro valor
      final nomeComumCompleto = _pragaData!.nomeComum;
      if (nomeComumCompleto.contains(',')) {
        nomeComumPraga = nomeComumCompleto.split(',').first.trim();
      } else if (nomeComumCompleto.contains(';')) {
        nomeComumPraga = nomeComumCompleto.split(';').first.trim();
      } else {
        nomeComumPraga = nomeComumCompleto;
      }
      
      // Segunda linha: Nome científico da praga
      nomeCientificoPraga = _pragaData!.nomeCientifico;
    }
    
    // Terceira linha: Dosagem
    final dosagemEntity = _getProperty('dosagem');
    String dosagemFormatada = '';
    
    if (dosagemEntity != null) {
      dosagemFormatada = dosagemEntity.toString();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primeira linha: nome comum da praga
        Text(
          nomeComumPraga,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (nomeCientificoPraga.isNotEmpty) ...[
          const SizedBox(height: SpacingTokens.xs),
          // Segunda linha: Nome científico da praga
          Text(
            nomeCientificoPraga,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (dosagemFormatada.isNotEmpty) ...[
          const SizedBox(height: SpacingTokens.xs),
          // Terceira linha: Dosagem
          Text(
            dosagemFormatada,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }

  /// Ações do lado direito do item
  Widget _buildTrailingActions(BuildContext context) {
    final theme = Theme.of(context);
    
    return Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  /// Helper para extrair propriedades com fallbacks
  String? _getProperty(String primaryKey, [String? fallbackKey]) {
    try {
      if (widget.diagnostico is Map<String, dynamic>) {
        final map = widget.diagnostico as Map<String, dynamic>;
        return map[primaryKey]?.toString() ?? (fallbackKey != null ? map[fallbackKey]?.toString() : null);
      } else {
        // Tenta acessar como propriedade do objeto
        final primary = _getObjectProperty(widget.diagnostico, primaryKey);
        if (primary != null) return primary.toString();
        
        if (fallbackKey != null) {
          final fallback = _getObjectProperty(widget.diagnostico, fallbackKey);
          if (fallback != null) return fallback.toString();
        }
      }
    } catch (e) {
      // Ignora erros de acesso a propriedades
    }
    return null;
  }

  /// Helper para acessar propriedades de objeto dinamicamente
  dynamic _getObjectProperty(dynamic obj, String property) {
    try {
      switch (property) {
        case 'idPraga':
          return obj.idPraga;
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
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }
}

// ============================================================================
// MODAL DE DETALHES
// ============================================================================

/// Widget responsável pelo modal de detalhes do diagnóstico
/// 
/// Responsabilidade única: exibir detalhes completos de um diagnóstico em modal
/// - Layout responsivo com constraints adequados
/// - Informações detalhadas do diagnóstico
/// - Ações para navegar para defensivo ou diagnóstico detalhado
/// - Premium badges para features pagas
class DiagnosticoDefensivoDialogWidget extends StatelessWidget {
  final dynamic diagnostico;
  final String defensivoName;

  const DiagnosticoDefensivoDialogWidget({
    super.key,
    required this.diagnostico,
    required this.defensivoName,
  });

  /// Mostra o modal de detalhes
  static Future<void> show(
    BuildContext context,
    dynamic diagnostico,
    String defensivoName,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) => DiagnosticoDefensivoDialogWidget(
        diagnostico: diagnostico,
        defensivoName: defensivoName,
      ),
    );
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
            Flexible(
              child: _buildModernContent(context),
            ),
            _buildModernActions(context),
          ],
        ),
      ),
    );
  }

  /// Cabeçalho moderno baseado no mockup
  Widget _buildModernHeader(BuildContext context) {
    final theme = Theme.of(context);
    final nomeDefensivo = _getProperty('nomeDefensivo', 'nome') ?? 'Defensivo não identificado';
    final ingredienteAtivo = _getProperty('ingredienteAtivo') ?? 'Ingrediente ativo não especificado';
    
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
        ],
      ),
    );
  }

  /// Cabeçalho do modal com título e botão de fechar (método legacy)
  Widget _buildHeader(BuildContext context) {
    return _buildModernHeader(context);
  }

  /// Conteúdo moderno com seções organizadas
  Widget _buildModernContent(BuildContext context) {
    final dosagem = _getProperty('dosagem')?.toString() ?? '...';
    final aplicacaoTerrestre = _getProperty('aplicacaoTerrestre') ?? '...';
    final aplicacaoAerea = _getProperty('aplicacaoAerea') ?? '...';
    final intervalo = _getProperty('intervaloDias')?.toString() ?? '...';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildModernInfoItem(
            context,
            icon: Icons.medical_services,
            title: 'Dosagem',
            value: '$dosagem mg/L',
            isPremium: true,
          ),
          _buildModernInfoItem(
            context,
            icon: Icons.agriculture,
            title: 'Aplicação Terrestre',
            value: '$aplicacaoTerrestre L/ha',
            isPremium: true,
          ),
          _buildModernInfoItem(
            context,
            icon: Icons.flight,
            title: 'Aplicação Aérea',
            value: '$aplicacaoAerea L/ha',
            isPremium: true,
          ),
          _buildModernInfoItem(
            context,
            icon: Icons.schedule,
            title: 'Intervalo de Aplicação',
            value: '$intervalo dias',
            isPremium: true,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Conteúdo principal do modal (método legacy)
  Widget _buildContent(BuildContext context) {
    return _buildModernContent(context);
  }

  /// Constrói uma seção de informação
  Widget _buildInfoSection(String label, String value, BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
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
                  Icon(
                    Icons.diamond,
                    size: 12,
                    color: Colors.amber.shade700,
                  ),
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
                _navigateToDefensivo(context);
              },
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ações do modal (método legacy)
  Widget _buildActions(BuildContext context) {
    return _buildModernActions(context);
  }

  /// Navega para a página de detalhes do diagnóstico
  void _navigateToDetailedDiagnostic(BuildContext context) {
    final diagnosticoId = _getProperty('id');
    final nomeCultura = _getProperty('nomeCultura', 'cultura') ?? 'Não especificado';
    final nomeDefensivo = _getProperty('nomeDefensivo', 'nome') ?? 'Não especificado';
    final nomePraga = _getProperty('nomePraga', 'grupo') ?? 'Não especificado';
    
    if (diagnosticoId != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => DetalheDiagnosticoPage(
            diagnosticoId: diagnosticoId,
            cultura: nomeCultura,
            nomeDefensivo: nomeDefensivo,
            nomePraga: nomePraga,
          ),
        ),
      );
    }
  }

  /// Navega para a página de detalhes do defensivo
  void _navigateToDefensivo(BuildContext context) {
    final nomeDefensivo = _getProperty('nomeDefensivo', 'nome');
    
    if (nomeDefensivo != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => defensivo_page.DetalheDefensivoPage(
            defensivoName: nomeDefensivo,
            fabricante: 'Não especificado', // Fabricante não disponível no contexto
          ),
        ),
      );
    }
  }

  /// Helper para extrair propriedades com fallbacks
  String? _getProperty(String primaryKey, [String? fallbackKey]) {
    try {
      if (diagnostico is Map<String, dynamic>) {
        final map = diagnostico as Map<String, dynamic>;
        return map[primaryKey]?.toString() ?? (fallbackKey != null ? map[fallbackKey]?.toString() : null);
      } else {
        // Tenta acessar como propriedade do objeto
        final primary = _getObjectProperty(diagnostico, primaryKey);
        if (primary != null) return primary.toString();
        
        if (fallbackKey != null) {
          final fallback = _getObjectProperty(diagnostico, fallbackKey);
          if (fallback != null) return fallback.toString();
        }
      }
    } catch (e) {
      // Ignora erros de acesso a propriedades
    }
    return null;
  }

  /// Helper para acessar propriedades de objeto dinamicamente
  dynamic _getObjectProperty(dynamic obj, String property) {
    try {
      switch (property) {
        case 'id':
          return obj.id;
        case 'idDefensivo':
          return obj.idDefensivo;
        case 'nomeDefensivo':
          return obj.nomeDefensivo;
        case 'ingredienteAtivo':
          return obj.ingredienteAtivo;
        case 'nomeCultura':
          return obj.nomeCultura;
        case 'cultura':
          return obj.cultura;
        case 'nomePraga':
          return obj.nomePraga;
        case 'grupo':
          return obj.grupo;
        case 'dosagem':
          return obj.dosagem;
        case 'unidadeDosagem':
          return obj.unidadeDosagem;
        case 'modoAplicacao':
          return obj.modoAplicacao;
        case 'intervaloDias':
          return obj.intervaloDias;
        case 'observacoes':
          return obj.observacoes;
        case 'nome':
          return obj.nome;
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }
}