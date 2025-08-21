import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/services/diagnostico_integration_service.dart';
import '../../core/di/injection_container.dart';
import '../../core/repositories/cultura_hive_repository.dart';
import '../../core/repositories/pragas_hive_repository.dart';
import '../../core/repositories/fitossanitario_hive_repository.dart';
import '../DetalheDiagnostico/widgets/diagnostico_relacional_card_widget.dart';
import 'widgets/filtro_multiplo_widget.dart';
import 'widgets/estatisticas_busca_widget.dart';

/// Página de busca avançada que permite filtrar diagnósticos
/// por múltiplas categorias (cultura, praga, defensivo) simultaneamente
class BuscaAvancadaDiagnosticosPage extends StatefulWidget {
  const BuscaAvancadaDiagnosticosPage({super.key});

  @override
  State<BuscaAvancadaDiagnosticosPage> createState() => _BuscaAvancadaDiagnosticosPageState();
}

class _BuscaAvancadaDiagnosticosPageState extends State<BuscaAvancadaDiagnosticosPage> {
  final DiagnosticoIntegrationService _integrationService = sl<DiagnosticoIntegrationService>();
  final CulturaHiveRepository _culturaRepo = sl<CulturaHiveRepository>();
  final PragasHiveRepository _pragasRepo = sl<PragasHiveRepository>();
  final FitossanitarioHiveRepository _fitossanitarioRepo = sl<FitossanitarioHiveRepository>();
  
  // Estados da busca
  bool isLoading = false;
  bool hasError = false;
  bool hasSearched = false;
  String? _errorMessage;
  
  // Filtros selecionados
  String? _culturaIdSelecionada;
  String? _pragaIdSelecionada;
  String? _defensivoIdSelecionado;
  
  // Resultados
  List<DiagnosticoDetalhado> _resultados = [];
  
  // Dados para dropdowns
  List<Map<String, String>> _culturas = [];
  List<Map<String, String>> _pragas = [];
  List<Map<String, String>> _defensivos = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosDropdowns();
  }

  void _carregarDadosDropdowns() async {
    try {
      // Carregar culturas
      final culturas = _culturaRepo.getAll();
      _culturas = culturas.map((c) => {
        'id': c.idReg,
        'nome': c.cultura,
      }).toList()..sort((a, b) => a['nome']!.compareTo(b['nome']!));
      
      // Carregar pragas
      final pragas = _pragasRepo.getAll();
      _pragas = pragas.map((p) => {
        'id': p.idReg,
        'nome': p.nomeComum ?? p.nomeCientifico,
      }).toList()..sort((a, b) => a['nome']!.compareTo(b['nome']!));
      
      // Carregar defensivos
      final defensivos = _fitossanitarioRepo.getAll();
      _defensivos = defensivos.map((d) => {
        'id': d.idReg,
        'nome': d.nomeComum ?? d.nomeTecnico,
      }).toList()..sort((a, b) => a['nome']!.compareTo(b['nome']!));
      
      if (mounted) setState(() {});
    } catch (e) {
      print('Erro ao carregar dados dos dropdowns: $e');
    }
  }

  void _realizarBusca() async {
    if (_culturaIdSelecionada == null && 
        _pragaIdSelecionada == null && 
        _defensivoIdSelecionado == null) {
      _mostrarAlerta('Selecione pelo menos um filtro para realizar a busca');
      return;
    }

    setState(() {
      isLoading = true;
      hasError = false;
      _errorMessage = null;
    });
    
    try {
      final resultados = await _integrationService.buscarComFiltros(
        culturaId: _culturaIdSelecionada,
        pragaId: _pragaIdSelecionada,
        defensivoId: _defensivoIdSelecionado,
      );
      
      if (mounted) {
        setState(() {
          isLoading = false;
          hasSearched = true;
          _resultados = resultados;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          _errorMessage = 'Erro ao realizar busca: $e';
        });
      }
    }
  }

  void _limparFiltros() {
    setState(() {
      _culturaIdSelecionada = null;
      _pragaIdSelecionada = null;
      _defensivoIdSelecionado = null;
      _resultados.clear();
      hasSearched = false;
      hasError = false;
    });
    
    // Limpar cache do serviço para resultados mais atualizados
    _integrationService.clearCache();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              children: [
                _buildModernHeader(isDark),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // Seção de filtros
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          child: FiltroMultiploWidget(
                            culturas: _culturas,
                            pragas: _pragas,
                            defensivos: _defensivos,
                            culturaIdSelecionada: _culturaIdSelecionada,
                            pragaIdSelecionada: _pragaIdSelecionada,
                            defensivoIdSelecionado: _defensivoIdSelecionado,
                            onCulturaChanged: (id) => setState(() => _culturaIdSelecionada = id),
                            onPragaChanged: (id) => setState(() => _pragaIdSelecionada = id),
                            onDefensivoChanged: (id) => setState(() => _defensivoIdSelecionado = id),
                            onBuscarPressed: _realizarBusca,
                            onLimparPressed: _limparFiltros,
                            isLoading: isLoading,
                          ),
                        ),
                      ),
                      
                      // Seção de estatísticas (se há resultados)
                      if (hasSearched && _resultados.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: EstatisticasBuscaWidget(
                              resultados: _resultados,
                              filtros: {
                                if (_culturaIdSelecionada != null) 
                                  'Cultura': _culturas.firstWhere((c) => c['id'] == _culturaIdSelecionada)['nome']!,
                                if (_pragaIdSelecionada != null) 
                                  'Praga': _pragas.firstWhere((p) => p['id'] == _pragaIdSelecionada)['nome']!,
                                if (_defensivoIdSelecionado != null) 
                                  'Defensivo': _defensivos.firstWhere((d) => d['id'] == _defensivoIdSelecionado)['nome']!,
                              },
                            ),
                          ),
                        ),
                      
                      // Seção de resultados
                      if (isLoading)
                        SliverToBoxAdapter(child: _buildLoadingState())
                      else if (hasError)
                        SliverToBoxAdapter(child: _buildErrorState())
                      else if (hasSearched)
                        _buildResultados()
                      else
                        SliverToBoxAdapter(child: _buildEstadoInicial()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDark) {
    final filtrosAtivos = [
      if (_culturaIdSelecionada != null) 'Cultura',
      if (_pragaIdSelecionada != null) 'Praga', 
      if (_defensivoIdSelecionado != null) 'Defensivo',
    ].join(', ');
    
    final subtitulo = filtrosAtivos.isNotEmpty 
        ? 'Filtros: $filtrosAtivos'
        : 'Configure os filtros e realize sua busca';

    return ModernHeaderWidget(
      title: 'Busca Avançada',
      subtitle: subtitulo,
      leftIcon: Icons.search,
      rightIcon: hasSearched ? Icons.clear_all : Icons.filter_list,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: hasSearched ? _limparFiltros : null,
      additionalActions: [
        if (_resultados.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_resultados.length}',
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

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Realizando busca avançada...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Processando filtros e integrando dados relacionais',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Erro na busca',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Verifique os filtros e tente novamente',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _realizarBusca,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoInicial() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.searchengin,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Busca Avançada de Diagnósticos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Configure os filtros acima e realize uma busca para encontrar diagnósticos específicos.\n\nVocê pode combinar filtros por cultura, praga e defensivo simultaneamente.',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildExemplosCarousel(theme),
        ],
      ),
    );
  }

  Widget _buildExemplosCarousel(ThemeData theme) {
    final exemplos = [
      {
        'titulo': 'Por Cultura',
        'descricao': 'Encontre todas as pragas que atacam uma cultura específica',
        'icon': FontAwesomeIcons.seedling,
        'color': Colors.green,
      },
      {
        'titulo': 'Por Praga',
        'descricao': 'Veja todos os defensivos disponíveis para uma praga',
        'icon': FontAwesomeIcons.bug,
        'color': Colors.red,
      },
      {
        'titulo': 'Por Defensivo',
        'descricao': 'Descubra todos os usos de um defensivo específico',
        'icon': FontAwesomeIcons.vial,
        'color': Colors.blue,
      },
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: exemplos.length,
        itemBuilder: (context, index) {
          final exemplo = exemplos[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (exemplo['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (exemplo['color'] as Color).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      exemplo['icon'] as IconData,
                      size: 20,
                      color: exemplo['color'] as Color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      exemplo['titulo'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    exemplo['descricao'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultados() {
    if (_resultados.isEmpty) {
      return SliverToBoxAdapter(child: _buildEstadoSemResultados());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final diagnostico = _resultados[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DiagnosticoRelacionalCardWidget(
              diagnosticoDetalhado: diagnostico,
              onTap: () => _navegarParaDetalhes(diagnostico),
            ),
          );
        },
        childCount: _resultados.length,
      ),
    );
  }

  Widget _buildEstadoSemResultados() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 40,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum resultado encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros ou remover algumas restrições para encontrar mais resultados.',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _limparFiltros,
            icon: const Icon(Icons.clear),
            label: const Text('Limpar Filtros'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _navegarParaDetalhes(DiagnosticoDetalhado diagnostico) {
    // Navigator.pushNamed(
    //   context,
    //   '/diagnostico-detalhado',
    //   arguments: diagnostico.diagnostico.idReg,
    // );
    print('Navegar para detalhes: ${diagnostico.diagnostico.idReg}');
  }

  void _mostrarAlerta(String mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atenção'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}