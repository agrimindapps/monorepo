import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart';
import '../../core/extensions/diagnostico_detalhado_extension.dart';
import '../../core/repositories/cultura_hive_repository.dart';
import '../../core/services/diagnostico_integration_service.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../pragas/widgets/praga_cultura_tab_bar_widget.dart';
import 'widgets/cultura_selector_widget.dart';
import 'widgets/defensivos_bottom_sheet.dart';
import 'widgets/estatisticas_cultura_widget.dart';
import 'widgets/filtros_ordenacao_dialog.dart';
import 'widgets/pragas_cultura_state_handler.dart';
import 'widgets/pragas_list_view.dart';

/// Página que mostra pragas agrupadas por cultura
/// Integra dados de PragasHive + CulturaHive + DiagnosticoHive + FitossanitarioHive
/// Permite explorar pragas de uma cultura específica e seus tratamentos
class PragasPorCulturaDetalhadasPage extends StatefulWidget {
  final String? culturaIdInicial;

  const PragasPorCulturaDetalhadasPage({
    super.key,
    this.culturaIdInicial,
  });

  @override
  State<PragasPorCulturaDetalhadasPage> createState() => _PragasPorCulturaDetalhadasPageState();
}

class _PragasPorCulturaDetalhadasPageState extends State<PragasPorCulturaDetalhadasPage> 
    with TickerProviderStateMixin {
  final DiagnosticoIntegrationService _integrationService = sl<DiagnosticoIntegrationService>();
  final CulturaHiveRepository _culturaRepo = sl<CulturaHiveRepository>();
  
  // Tab Controller
  late TabController _tabController;
  
  // Estado da página
  PragasCulturaState _currentState = PragasCulturaState.initial;
  String? _errorMessage;
  
  // Dados
  String? _culturaIdSelecionada;
  String? _nomeCulturaSelecionada;
  List<PragaPorCultura> _pragasPorCultura = [];
  List<Map<String, String>> _culturas = [];
  
  // Dados separados por tipos (para as tabs)
  List<PragaPorCultura> _plantasDaninhas = [];
  List<PragaPorCultura> _doencas = [];
  List<PragaPorCultura> _insetos = [];
  
  // Filtros
  String _ordenacao = 'ameaca'; // ameaca, nome, diagnosticos
  String _filtroTipo = 'todos'; // todos, criticas, normais

  @override
  void initState() {
    super.initState();
    _culturaIdSelecionada = widget.culturaIdInicial;
    
    // Inicializar TabController com 3 tabs
    _tabController = TabController(length: 3, vsync: this);
    
    debugPrint('=== INIT PRAGAS POR CULTURA ===');
    debugPrint('Cultura ID inicial: ${widget.culturaIdInicial}');
    _initializeData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _carregarCulturas();
    if (_culturaIdSelecionada != null) {
      await _carregarPragasDaCultura();
    }
  }

  Future<void> _carregarCulturas() async {
    try {
      final result = await _culturaRepo.getAll();
      if (result.isSuccess) {
        final culturas = result.data!;
        _culturas = culturas.map((c) => {
          'id': c.idReg,
          'nome': c.cultura,
        }).toList()..sort((a, b) => a['nome']!.compareTo(b['nome']!));
        
        // Se há cultura selecionada, buscar o nome
        if (_culturaIdSelecionada != null) {
          final cultura = _culturas.firstWhere(
            (c) => c['id'] == _culturaIdSelecionada,
            orElse: () => {
              'id': _culturaIdSelecionada!,
              'nome': 'Cultura não encontrada',
            },
          );
          _nomeCulturaSelecionada = cultura['nome'];
          debugPrint('=== CULTURA SELECIONADA ===');
          debugPrint('ID: $_culturaIdSelecionada');
          debugPrint('Nome: $_nomeCulturaSelecionada');
          debugPrint('Culturas disponíveis: ${_culturas.length}');
          
          // Verificar se realmente encontrou a cultura
          if (cultura['nome'] == 'Cultura não encontrada') {
            debugPrint('AVISO: Cultura com ID $_culturaIdSelecionada não foi encontrada');
            // Tentar definir como a primeira cultura se existir
            if (_culturas.isNotEmpty) {
              debugPrint('Selecionando primeira cultura disponível: ${_culturas.first['nome']}');
              _culturaIdSelecionada = _culturas.first['id'];
              _nomeCulturaSelecionada = _culturas.first['nome'];
            }
          }
        }
        
        if (mounted) {
          setState(() {
            debugPrint('=== CULTURAS CARREGADAS ===');
            debugPrint('_culturaIdSelecionada: $_culturaIdSelecionada');
            debugPrint('_nomeCulturaSelecionada: $_nomeCulturaSelecionada');
            debugPrint('_currentState: $_currentState');
          });
        }
      } else {
        debugPrint('Erro ao carregar culturas: ${result.error}');
      }
    } catch (e) {
      debugPrint('Erro ao carregar culturas: $e');
    }
  }

  Future<void> _carregarPragasDaCultura() async {
    if (_culturaIdSelecionada == null) return;

    setState(() {
      _currentState = PragasCulturaState.loading;
      _errorMessage = null;
    });
    
    try {
      final pragasDaCultura = await _integrationService.getPragasPorCultura(_culturaIdSelecionada!);
      
      if (mounted) {
        setState(() {
          _pragasPorCultura = pragasDaCultura;
          _currentState = pragasDaCultura.isEmpty 
              ? PragasCulturaState.empty 
              : PragasCulturaState.initial;
          _separarPragasPorTipo();
          _aplicarFiltros();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentState = PragasCulturaState.error;
          _errorMessage = 'Erro ao carregar pragas: $e';
        });
      }
    }
  }

  void _separarPragasPorTipo() {
    // Separar as pragas por tipo baseado no tipoPraga
    _plantasDaninhas = _pragasPorCultura.where((p) => p.praga.tipoPraga == '3').toList();
    _doencas = _pragasPorCultura.where((p) => p.praga.tipoPraga == '2').toList();
    _insetos = _pragasPorCultura.where((p) => p.praga.tipoPraga == '1').toList();
    
    // Aplicar ordenação a cada lista
    _aplicarOrdenacaoALista(_plantasDaninhas);
    _aplicarOrdenacaoALista(_doencas);
    _aplicarOrdenacaoALista(_insetos);
  }

  void _aplicarOrdenacaoALista(List<PragaPorCultura> lista) {
    lista.sort((a, b) {
      switch (_ordenacao) {
        case 'nome':
          final aNome = a.praga.nomeComum ?? a.praga.nomeCientifico;
          final bNome = b.praga.nomeComum ?? b.praga.nomeCientifico;
          return aNome.compareTo(bNome);
        case 'diagnosticos':
          return b.quantidadeDiagnosticos.compareTo(a.quantidadeDiagnosticos);
        case 'ameaca':
        default:
          // Ordenar por criticidade primeiro, depois por quantidade de diagnósticos
          if (a.isCritica != b.isCritica) {
            return a.isCritica ? -1 : 1;
          }
          return b.quantidadeDiagnosticos.compareTo(a.quantidadeDiagnosticos);
      }
    });
  }

  void _aplicarFiltros() {
    var filtradas = List<PragaPorCultura>.from(_pragasPorCultura);
    
    // Filtro por tipo
    if (_filtroTipo != 'todos') {
      if (_filtroTipo == 'criticas') {
        filtradas = filtradas.where((p) => p.isCritica).toList();
      } else if (_filtroTipo == 'normais') {
        filtradas = filtradas.where((p) => !p.isCritica).toList();
      }
    }
    
    // Ordenação
    filtradas.sort((a, b) {
      switch (_ordenacao) {
        case 'nome':
          final aNome = a.praga.nomeComum ?? a.praga.nomeCientifico;
          final bNome = b.praga.nomeComum ?? b.praga.nomeCientifico;
          return aNome.compareTo(bNome);
        case 'diagnosticos':
          return b.quantidadeDiagnosticos.compareTo(a.quantidadeDiagnosticos);
        case 'ameaca':
        default:
          // Ordenar por criticidade primeiro, depois por quantidade de diagnósticos
          if (a.isCritica != b.isCritica) {
            return a.isCritica ? -1 : 1;
          }
          return b.quantidadeDiagnosticos.compareTo(a.quantidadeDiagnosticos);
      }
    });
    
    setState(() {
      _pragasPorCultura = filtradas;
    });
  }

  void _selecionarCultura(String culturaId) {
    final cultura = _culturas.firstWhere((c) => c['id'] == culturaId);
    setState(() {
      _culturaIdSelecionada = culturaId;
      _nomeCulturaSelecionada = cultura['nome'];
      _pragasPorCultura.clear();
    });
    _carregarPragasDaCultura(); // Fire and forget - will handle errors internally
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Debug do estado atual
    debugPrint('=== BUILD PRAGAS POR CULTURA ===');
    debugPrint('_culturaIdSelecionada: $_culturaIdSelecionada');
    debugPrint('_nomeCulturaSelecionada: $_nomeCulturaSelecionada');
    debugPrint('_currentState: $_currentState');
    debugPrint('_pragasPorCultura.length: ${_pragasPorCultura.length}');
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                children: [
                  _buildModernHeader(isDark),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        // Seletor de cultura (sempre visível)
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            child: CulturaSelectorWidget(
                              culturas: _culturas,
                              culturaIdSelecionada: _culturaIdSelecionada,
                              onCulturaChanged: _selecionarCultura,
                            ),
                          ),
                        ),
                        
                        // Conteúdo principal baseado no estado
                        if (_culturaIdSelecionada == null)
                          // Mostrar estado inicial quando nenhuma cultura está selecionada
                          SliverToBoxAdapter(
                            child: PragasCulturaStateHandler(
                              state: PragasCulturaState.initial,
                              errorMessage: null,
                              onRetry: _carregarPragasDaCultura,
                            ),
                          )
                        else if (_nomeCulturaSelecionada == null || _currentState == PragasCulturaState.loading)
                          // Mostrar loading quando cultura está selecionada mas nome ainda não foi carregado
                          SliverToBoxAdapter(
                            child: PragasCulturaStateHandler(
                              state: PragasCulturaState.loading,
                              errorMessage: null,
                              onRetry: _carregarPragasDaCultura,
                            ),
                          )
                        else if (_currentState == PragasCulturaState.error)
                          // Mostrar erro quando houve erro no carregamento
                          SliverToBoxAdapter(
                            child: PragasCulturaStateHandler(
                              state: PragasCulturaState.error,
                              errorMessage: _errorMessage,
                              onRetry: _carregarPragasDaCultura,
                            ),
                          )
                        else if (_currentState == PragasCulturaState.empty)
                          // Mostrar estado vazio quando não há pragas para a cultura
                          SliverToBoxAdapter(
                            child: PragasCulturaStateHandler(
                              state: PragasCulturaState.empty,
                              errorMessage: null,
                              onRetry: _carregarPragasDaCultura,
                            ),
                          )
                        else if (_currentState == PragasCulturaState.initial || _pragasPorCultura.isNotEmpty) ...[
                          // Estatísticas da cultura
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              child: EstatisticasCulturaWidget(
                                nomeCultura: _nomeCulturaSelecionada!,
                                pragasPorCultura: _pragasPorCultura,
                                ordenacao: _ordenacao,
                                filtroTipo: _filtroTipo,
                                onOrdenacaoChanged: (valor) => setState(() {
                                  _ordenacao = valor;
                                  _separarPragasPorTipo();
                                }),
                                onFiltroTipoChanged: (valor) => setState(() {
                                  _filtroTipo = valor;
                                  _separarPragasPorTipo();
                                }),
                              ),
                            ),
                          ),
                          
                          // Tab Bar
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              child: PragaCulturaTabBarWidget(
                                tabController: _tabController,
                                onTabTap: (index) {
                                  // Tab já é trocada automaticamente pelo TabController
                                },
                                isDark: isDark,
                              ),
                            ),
                          ),
                          
                          // Tab Content
                          SliverFillRemaining(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildTabContent(_plantasDaninhas, 'Plantas Daninhas'),
                                _buildTabContent(_doencas, 'Doenças'),
                                _buildTabContent(_insetos, 'Insetos'),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDark) {
    final titulo = _nomeCulturaSelecionada != null 
        ? 'Pragas - $_nomeCulturaSelecionada'
        : 'Pragas por Cultura';
    
    final subtitulo = _pragasPorCultura.isNotEmpty 
        ? '${_pragasPorCultura.length} praga(s) encontrada(s)'
        : 'Selecione uma cultura para explorar';

    return ModernHeaderWidget(
      title: titulo,
      subtitle: subtitulo,
      leftIcon: FontAwesomeIcons.bug,
      rightIcon: Icons.sort,
      isDark: isDark,
      showBackButton: true,
      showActions: _pragasPorCultura.isNotEmpty && _currentState == PragasCulturaState.initial,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: () => _mostrarOpcoesOrdenacao(),
      additionalActions: [
        if (_pragasPorCultura.isNotEmpty && _currentState == PragasCulturaState.initial)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_pragasPorCultura.where((p) => p.isCritica).length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }


  void _navegarParaDetalhes(PragaPorCultura pragaPorCultura) {
    // Navigator.pushNamed(
    //   context,
    //   '/praga-detalhes',
    //   arguments: pragaPorCultura.praga.idReg,
    // );
    print('Navegar para detalhes da praga: ${pragaPorCultura.praga.idReg}');
  }

  void _verDefensivosDaPraga(PragaPorCultura pragaPorCultura) {
    DefensivosBottomSheet.show(
      context,
      pragaPorCultura,
      onDefensivoTap: () {
        // Implementar navegação para detalhes do defensivo
        print('Navegar para detalhes do defensivo');
      },
    );
  }

  void _mostrarOpcoesOrdenacao() {
    FiltrosOrdenacaoDialog.show(
      context,
      ordenacaoAtual: _ordenacao,
      filtroTipoAtual: _filtroTipo,
      onOrdenacaoChanged: (valor) {
        setState(() {
          _ordenacao = valor;
          _separarPragasPorTipo();
        });
      },
      onFiltroTipoChanged: (valor) {
        setState(() {
          _filtroTipo = valor;
          _separarPragasPorTipo();
        });
      },
    );
  }

  /// Constrói o conteúdo de cada tab
  Widget _buildTabContent(List<PragaPorCultura> pragasList, String tipoNome) {
    if (pragasList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma praga do tipo "$tipoNome" encontrada',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'para a cultura selecionada',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Cabeçalho da tab com estatísticas
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconByTipo(tipoNome),
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tipoNome,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${pragasList.length} praga(s) • ${pragasList.where((p) => p.isCritica).length} crítica(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Lista de pragas para esta tab
        PragasListView(
          pragasPorCultura: pragasList,
          onPragaTap: _navegarParaDetalhes,
          onVerDefensivos: _verDefensivosDaPraga,
        ),
      ],
    );
  }

  /// Retorna o ícone apropriado para cada tipo de praga
  IconData _getIconByTipo(String tipoNome) {
    switch (tipoNome) {
      case 'Plantas Daninhas':
        return Icons.grass_outlined;
      case 'Doenças':
        return Icons.coronavirus_outlined;
      case 'Insetos':
        return Icons.bug_report_outlined;
      default:
        return Icons.pest_control_outlined;
    }
  }

}