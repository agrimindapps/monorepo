import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../../core/data/models/diagnostico_hive.dart';
import '../../../../../core/data/models/pragas_hive.dart';
import '../../../../../core/data/repositories/cultura_hive_repository.dart';
import '../../../../../core/data/repositories/pragas_hive_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/services/receituagro_navigation_service.dart';
import '../../../../../core/theme/spacing_tokens.dart';
import '../../../../../core/widgets/praga_image_widget.dart';
import '../../../../diagnosticos/presentation/providers/diagnosticos_notifier.dart';

/// Componentes modulares para exibição de diagnósticos em páginas de defensivos
///
/// Este arquivo contém todos os widgets auxiliares necessários para replicar
/// a funcionalidade e visual dos diagnósticos da página de pragas, adaptados
/// para funcionar com defensivos.

/// Widget responsável pelos filtros de diagnósticos
///
/// Responsabilidade única: renderizar e gerenciar filtros de pesquisa e cultura
/// - Campo de busca por texto
/// - Dropdown de seleção de cultura
/// - Layout responsivo e design consistente
class DiagnosticoDefensivoFilterWidget extends ConsumerStatefulWidget {
  final List<String>? availableCulturas;

  const DiagnosticoDefensivoFilterWidget({super.key, this.availableCulturas});

  @override
  ConsumerState<DiagnosticoDefensivoFilterWidget> createState() =>
      _DiagnosticoDefensivoFilterWidgetState();
}

class _DiagnosticoDefensivoFilterWidgetState
    extends ConsumerState<DiagnosticoDefensivoFilterWidget> {
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final diagnosticosAsync = ref.watch(diagnosticosNotifierProvider);

    return RepaintBoundary(
      child: diagnosticosAsync.when(
        data: (diagnosticosState) {
          // Usa culturas passadas ou extrai dos diagnósticos como fallback
          final List<String> availableCulturas;
          if (widget.availableCulturas != null &&
              widget.availableCulturas!.isNotEmpty) {
            // Usa culturas resolvidas do agrupamento (inclui resolução via repositório)
            availableCulturas = ['Todas', ...widget.availableCulturas!];
          } else {
            // Fallback: extrai diretamente dos diagnósticos (pode não ter todas)
            final diagnosticosParaCulturas =
                diagnosticosState.searchQuery.isNotEmpty
                    ? diagnosticosState.searchResults
                    : diagnosticosState.filteredDiagnosticos;

            final culturasFromDiagnosticos =
                diagnosticosParaCulturas
                    .map((d) => d.nomeCultura)
                    .where((cultura) => cultura != null && cultura.isNotEmpty)
                    .cast<String>()
                    .toSet()
                    .toList()
                  ..sort();

            availableCulturas =
                culturasFromDiagnosticos.isEmpty
                    ? ['Todas']
                    : ['Todas', ...culturasFromDiagnosticos];
          }

          // CORREÇÃO: Usar contexto ou default para selectedCultura
          final selectedCultura = diagnosticosState.contextoCultura ?? 'Todas';

          return Container(
            padding: const EdgeInsets.all(SpacingTokens.sm),
            child: Row(
              children: [
                Expanded(
                  flex: _isSearchFocused ? 2 : 1,
                  child: _SearchField(
                    focusNode: _searchFocusNode,
                    onChanged: (query) {
                      // CORREÇÃO: Usar searchByPattern que já existe e funciona
                      ref
                          .read(diagnosticosNotifierProvider.notifier)
                          .searchByPattern(query);
                    },
                  ),
                ),
                if (!_isSearchFocused) ...[
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    flex: 1,
                    child: _CultureDropdown(
                      value: selectedCultura,
                      cultures: availableCulturas,
                      onChanged: (cultura) {
                        // CORREÇÃO: Filtrar localmente ao invés de recarregar
                        if (cultura == 'Todas') {
                          // Limpar apenas o contexto de cultura, mantendo defensivo
                          ref
                              .read(diagnosticosNotifierProvider.notifier)
                              .filterByCultura(null);
                        } else {
                          // Filtrar localmente pela cultura selecionada
                          ref
                              .read(diagnosticosNotifierProvider.notifier)
                              .filterByCultura(cultura);
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading:
            () => Container(
              padding: const EdgeInsets.all(SpacingTokens.sm),
              child: const Center(child: CircularProgressIndicator()),
            ),
        error:
            (error, _) => Container(
              padding: const EdgeInsets.all(SpacingTokens.sm),
              child: const _SearchField(focusNode: null, onChanged: null),
            ),
      ),
    );
  }
}

/// Campo de busca personalizado
class _SearchField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const _SearchField({required this.onChanged, required this.focusNode});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        decoration: const InputDecoration(
          hintText: 'Localizar',
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
          Icons.agriculture,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        items: [
          DropdownMenuItem<String>(
            value: 'Todas',
            child: Text(
              'Todas',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...cultures
              .where((culture) => culture != 'Todas')
              .map<DropdownMenuItem<String>>((String culture) {
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
              }),
        ],
      ),
    );
  }
}

/// Widget para gerenciamento de estados da lista de diagnósticos
class DiagnosticoDefensivoStateManager extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final diagnosticosAsync = ref.watch(diagnosticosNotifierProvider);

    return diagnosticosAsync.when(
      data: (diagnosticosState) {
        if (diagnosticosState.isLoading) {
          return const DiagnosticoDefensivoLoadingWidget();
        }

        if (diagnosticosState.hasError) {
          return DiagnosticoDefensivoErrorWidget(
            errorMessage: diagnosticosState.errorMessage ?? 'Erro desconhecido',
            onRetry: onRetry,
          );
        }

        // CORREÇÃO: Usar searchResults quando há busca ativa, senão usar filteredDiagnosticos
        final diagnosticosParaExibir =
            diagnosticosState.searchQuery.isNotEmpty
                ? diagnosticosState.searchResults
                : diagnosticosState.filteredDiagnosticos;

        if (diagnosticosParaExibir.isEmpty) {
          return DiagnosticoDefensivoEmptyWidget(defensivoName: defensivoName);
        }

        return builder(diagnosticosParaExibir);
      },
      loading: () => const DiagnosticoDefensivoLoadingWidget(),
      error:
          (error, _) => DiagnosticoDefensivoErrorWidget(
            errorMessage: error.toString(),
            onRetry: onRetry,
          ),
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
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
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
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
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
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      final culturaRepository = sl<CulturaHiveRepository>();
      for (final diagnostic in widget.diagnosticos!) {
        final idCultura = _getProperty(diagnostic, 'idCultura');
        if (idCultura != null) {
          final culturaData = await culturaRepository.getById(idCultura);
          if (culturaData != null &&
              culturaData.cultura.toLowerCase() ==
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

    if (widget.diagnostico is DiagnosticoHive) {
      final diagnosticoHive = widget.diagnostico as DiagnosticoHive;
      nomeComumPraga = diagnosticoHive.nomePraga ?? 'Praga não identificada';
    } else {
      final nomePragaModel = _getProperty('nomePraga') ?? _getProperty('grupo');
      if (nomePragaModel != null &&
          nomePragaModel.isNotEmpty &&
          nomePragaModel != 'Não especificado') {
        nomeComumPraga = nomePragaModel;
      } else if (_pragaData != null) {
        final nomeComumCompleto = _pragaData!.nomeComum;
        if (nomeComumCompleto.contains(',')) {
          nomeComumPraga = nomeComumCompleto.split(',').first.trim();
        } else if (nomeComumCompleto.contains(';')) {
          nomeComumPraga = nomeComumCompleto.split(';').first.trim();
        } else {
          nomeComumPraga = nomeComumCompleto;
        }
      }
    }

    if (_pragaData != null) {
      nomeCientificoPraga = _pragaData!.nomeCientifico;
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

    if (_pragaData?.nomeCientifico != null) {
      final imagePath =
          'assets/imagens/bigsize/${_pragaData!.nomeCientifico}.jpg';

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
      if (widget.diagnostico is Map<String, dynamic>) {
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
        final pragaRepository = sl<PragasHiveRepository>();
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
            return widget.diagnostico.id?.toString();
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
    print('🔍 [DEBUG] _navigateToDetailedDiagnostic chamado');
    final diagnosticoId = _getProperty('id');
    final nomePraga = _getProperty('nomePraga', 'grupo') ?? 'Não especificado';
    final cultura = _getProperty('cultura') ?? 'Não especificada';

    print('🔍 [DEBUG] diagnosticoId: $diagnosticoId');
    print('🔍 [DEBUG] nomePraga: $nomePraga');
    print('🔍 [DEBUG] cultura: $cultura');
    print('🔍 [DEBUG] defensivoName: ${widget.defensivoName}');

    if (diagnosticoId != null) {
      print(
        '✅ [DEBUG] Navegando para DetalheDiagnosticoPage via rota nomeada...',
      );
      Navigator.of(context).pushNamed(
        '/detalhe-diagnostico',
        arguments: {
          'diagnosticoId': diagnosticoId,
          'nomeDefensivo': widget.defensivoName,
          'nomePraga': nomePraga,
          'cultura': cultura,
        },
      );
    } else {
      print('❌ [DEBUG] diagnosticoId é null - não navegando');
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
