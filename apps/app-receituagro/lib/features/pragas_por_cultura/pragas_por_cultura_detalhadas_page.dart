import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/di/injection_container.dart';
import '../../core/extensions/diagnostico_detalhado_extension.dart';
import '../../core/repositories/cultura_hive_repository.dart';
import '../../core/services/diagnostico_integration_service.dart';
import '../../core/widgets/modern_header_widget.dart';
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

class _PragasPorCulturaDetalhadasPageState extends State<PragasPorCulturaDetalhadasPage> {
  final DiagnosticoIntegrationService _integrationService = sl<DiagnosticoIntegrationService>();
  final CulturaHiveRepository _culturaRepo = sl<CulturaHiveRepository>();
  
  // Estado da página
  PragasCulturaState _currentState = PragasCulturaState.initial;
  String? _errorMessage;
  
  // Dados
  String? _culturaIdSelecionada;
  String? _nomeCulturaSelecionada;
  List<PragaPorCultura> _pragasPorCultura = [];
  List<Map<String, String>> _culturas = [];
  
  // Filtros
  String _ordenacao = 'ameaca'; // ameaca, nome, diagnosticos
  String _filtroTipo = 'todos'; // todos, criticas, normais

  @override
  void initState() {
    super.initState();
    _culturaIdSelecionada = widget.culturaIdInicial;
    _carregarCulturas();
    if (_culturaIdSelecionada != null) {
      _carregarPragasDaCultura();
    }
  }

  void _carregarCulturas() {
    try {
      final culturas = _culturaRepo.getAll();
      _culturas = culturas.map((c) => {
        'id': c.idReg,
        'nome': c.cultura,
      }).toList()..sort((a, b) => a['nome']!.compareTo(b['nome']!));
      
      // Se há cultura selecionada, buscar o nome
      if (_culturaIdSelecionada != null) {
        final cultura = _culturas.firstWhere(
          (c) => c['id'] == _culturaIdSelecionada,
          orElse: () => {'nome': 'Cultura não encontrada'},
        );
        _nomeCulturaSelecionada = cultura['nome'];
      }
      
      if (mounted) setState(() {});
    } catch (e) {
      print('Erro ao carregar culturas: $e');
    }
  }

  void _carregarPragasDaCultura() async {
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
          return (a.praga.nomeComum ?? a.praga.nomeCientifico)
              .compareTo(b.praga.nomeComum ?? b.praga.nomeCientifico);
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
    _carregarPragasDaCultura();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
                        // Seletor de cultura
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
                        
                        // Conteúdo principal
                        if (_culturaIdSelecionada == null || _currentState != PragasCulturaState.initial)
                          SliverToBoxAdapter(
                            child: PragasCulturaStateHandler(
                              state: _culturaIdSelecionada == null 
                                  ? PragasCulturaState.initial 
                                  : _currentState,
                              errorMessage: _errorMessage,
                              onRetry: _carregarPragasDaCultura,
                            ),
                          )
                        else ...[
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
                                  _aplicarFiltros();
                                }),
                                onFiltroTipoChanged: (valor) => setState(() {
                                  _filtroTipo = valor;
                                  _aplicarFiltros();
                                }),
                              ),
                            ),
                          ),
                          
                          // Lista de pragas
                          PragasListView(
                            pragasPorCultura: _pragasPorCultura,
                            onPragaTap: _navegarParaDetalhes,
                            onVerDefensivos: _verDefensivosDaPraga,
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
          _aplicarFiltros();
        });
      },
      onFiltroTipoChanged: (valor) {
        setState(() {
          _filtroTipo = valor;
          _aplicarFiltros();
        });
      },
    );
  }

}