import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/di/injection_container.dart';
import '../../core/extensions/diagnostico_detalhado_extension.dart';
import '../../core/repositories/cultura_hive_repository.dart';
import '../../core/services/diagnostico_integration_service.dart';
import '../../core/widgets/modern_header_widget.dart';
import 'widgets/cultura_selector_widget.dart';
import 'widgets/estatisticas_cultura_widget.dart';
import 'widgets/praga_por_cultura_card_widget.dart';

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
  
  // Estados da página
  bool isLoading = false;
  bool hasError = false;
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
      isLoading = true;
      hasError = false;
      _errorMessage = null;
    });
    
    try {
      final pragasDaCultura = await _integrationService.getPragasPorCultura(_culturaIdSelecionada!);
      
      if (mounted) {
        setState(() {
          isLoading = false;
          _pragasPorCultura = pragasDaCultura;
          _aplicarFiltros();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
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
                      if (_culturaIdSelecionada == null)
                        SliverToBoxAdapter(child: _buildEstadoInicial())
                      else if (isLoading)
                        SliverToBoxAdapter(child: _buildLoadingState())
                      else if (hasError)
                        SliverToBoxAdapter(child: _buildErrorState())
                      else if (_pragasPorCultura.isEmpty)
                        SliverToBoxAdapter(child: _buildEstadoVazio())
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
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final pragaPorCultura = _pragasPorCultura[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: PragaPorCulturaCardWidget(
                                  pragaPorCultura: pragaPorCultura,
                                  onTap: () => _navegarParaDetalhes(pragaPorCultura),
                                  onVerDefensivos: () => _verDefensivosDaPraga(pragaPorCultura),
                                ),
                              );
                            },
                            childCount: _pragasPorCultura.length,
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
      showActions: _pragasPorCultura.isNotEmpty,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: _mostrarOpcoesOrdenacao,
      additionalActions: [
        if (_pragasPorCultura.isNotEmpty)
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

  Widget _buildEstadoInicial() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade200,
                  Colors.red.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FontAwesomeIcons.bug,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Explorar Pragas por Cultura',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Selecione uma cultura acima para ver todas as pragas que a atacam, junto com os defensivos disponíveis para cada uma.',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD32F2F), Color(0xFFFF5722)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
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
            'Carregando pragas da cultura...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Integrando dados de diagnósticos e defensivos',
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
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
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
            'Erro ao carregar pragas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Verifique sua conexão e tente novamente',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _carregarPragasDaCultura,
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

  Widget _buildEstadoVazio() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration,
              size: 40,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhuma praga encontrada!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Esta cultura não possui pragas registradas em nossa base de dados ou não há diagnósticos disponíveis.',
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

  void _navegarParaDetalhes(PragaPorCultura pragaPorCultura) {
    // Navigator.pushNamed(
    //   context,
    //   '/praga-detalhes',
    //   arguments: pragaPorCultura.praga.idReg,
    // );
    print('Navegar para detalhes da praga: ${pragaPorCultura.praga.idReg}');
  }

  void _verDefensivosDaPraga(PragaPorCultura pragaPorCultura) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Defensivos para ${pragaPorCultura.praga.nomeComum ?? pragaPorCultura.praga.nomeCientifico}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: pragaPorCultura.defensivosRelacionados.length,
                itemBuilder: (context, index) {
                  final defensivo = pragaPorCultura.defensivosRelacionados[index];
                  return ListTile(
                    leading: const Icon(FontAwesomeIcons.vial, color: Colors.blue),
                    title: Text(defensivo),
                    subtitle: const Text('Defensivo disponível'),
                    onTap: () {
                      Navigator.of(context).pop();
                      // Navegar para detalhes do defensivo
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarOpcoesOrdenacao() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros e Ordenação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ordenar por:', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildOpcaoOrdenacao('Nível de Ameaça', 'ameaca'),
            _buildOpcaoOrdenacao('Nome da Praga', 'nome'),
            _buildOpcaoOrdenacao('Quantidade de Diagnósticos', 'diagnosticos'),
            const SizedBox(height: 16),
            const Text('Filtrar por:', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildOpcaoFiltro('Todas as Pragas', 'todos'),
            _buildOpcaoFiltro('Apenas Críticas', 'criticas'),
            _buildOpcaoFiltro('Apenas Normais', 'normais'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcaoOrdenacao(String label, String valor) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: valor,
      groupValue: _ordenacao,
      onChanged: (value) {
        setState(() {
          _ordenacao = value!;
          _aplicarFiltros();
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildOpcaoFiltro(String label, String valor) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: valor,
      groupValue: _filtroTipo,
      onChanged: (value) {
        setState(() {
          _filtroTipo = value!;
          _aplicarFiltros();
        });
        Navigator.of(context).pop();
      },
    );
  }
}