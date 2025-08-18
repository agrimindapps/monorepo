import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/services/diagnostico_integration_service.dart';
import '../../core/extensions/diagnostico_detalhado_extension.dart';
import '../../core/di/injection_container.dart';
import 'widgets/defensivo_completo_card_widget.dart';
import 'widgets/filtros_defensivos_widget.dart';
import 'widgets/comparacao_defensivos_widget.dart';

/// Página que mostra defensivos com informações completas
/// Integra dados de FitossanitarioHive + FitossanitarioInfoHive + DiagnosticoHive
/// Permite comparar defensivos e ver todos os seus usos relacionados
class DefensivosAgrupadosDetalhadosPage extends StatefulWidget {
  const DefensivosAgrupadosDetalhadosPage({super.key});

  @override
  State<DefensivosAgrupadosDetalhadosPage> createState() => _DefensivosAgrupadosDetalhadosPageState();
}

class _DefensivosAgrupadosDetalhadosPageState extends State<DefensivosAgrupadosDetalhadosPage> {
  final DiagnosticoIntegrationService _integrationService = sl<DiagnosticoIntegrationService>();
  
  // Estados da página
  bool isLoading = false;
  bool hasError = false;
  String? _errorMessage;
  
  // Filtros
  String _ordenacao = 'prioridade'; // prioridade, nome, fabricante, usos
  String _filtroToxicidade = 'todos';
  String _filtroTipo = 'todos'; // fungicida, inseticida, herbicida, etc.
  bool _apenasComercializados = true;
  bool _apenasElegiveis = false;
  
  // Dados
  List<DefensivoCompleto> _defensivos = [];
  List<DefensivoCompleto> _defensivosFiltrados = [];
  List<DefensivoCompleto> _defensivosSelecionados = [];
  
  // View mode
  bool _modoComparacao = false;

  @override
  void initState() {
    super.initState();
    _carregarDefensivos();
  }

  void _carregarDefensivos() async {
    setState(() {
      isLoading = true;
      hasError = false;
      _errorMessage = null;
    });
    
    try {
      final defensivos = await _integrationService.getDefensivosCompletos();
      
      if (mounted) {
        setState(() {
          isLoading = false;
          _defensivos = defensivos;
          _aplicarFiltros();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          _errorMessage = 'Erro ao carregar defensivos: $e';
        });
      }
    }
  }

  void _aplicarFiltros() {
    var filtrados = List<DefensivoCompleto>.from(_defensivos);
    
    // Filtro por comercialização
    if (_apenasComercializados) {
      filtrados = filtrados.where((d) => d.isComercializado).toList();
    }
    
    // Filtro por elegibilidade
    if (_apenasElegiveis) {
      filtrados = filtrados.where((d) => d.isElegivel).toList();
    }
    
    // Filtro por toxicidade
    if (_filtroToxicidade != 'todos') {
      filtrados = filtrados.where((d) {
        final toxico = d.defensivo.toxico?.toLowerCase() ?? '';
        switch (_filtroToxicidade) {
          case 'baixa': return toxico.contains('iv') || toxico.contains('4');
          case 'media': return toxico.contains('iii') || toxico.contains('3');
          case 'alta': return toxico.contains('ii') || toxico.contains('2');
          case 'extrema': return toxico.contains('i') && !toxico.contains('ii') && !toxico.contains('iii') && !toxico.contains('iv');
          default: return true;
        }
      }).toList();
    }
    
    // Filtro por tipo/classe agronômica
    if (_filtroTipo != 'todos') {
      filtrados = filtrados.where((d) {
        final classe = d.defensivo.classeAgronomica?.toLowerCase() ?? '';
        return classe.contains(_filtroTipo);
      }).toList();
    }
    
    // Ordenação
    filtrados.sort((a, b) {
      switch (_ordenacao) {
        case 'nome':
          return (a.defensivo.nomeComum ?? '').compareTo(b.defensivo.nomeComum ?? '');
        case 'fabricante':
          return (a.defensivo.fabricante ?? '').compareTo(b.defensivo.fabricante ?? '');
        case 'usos':
          return b.quantidadeDiagnosticos.compareTo(a.quantidadeDiagnosticos);
        case 'prioridade':
        default:
          return b.nivelPrioridade.compareTo(a.nivelPrioridade);
      }
    });
    
    setState(() {
      _defensivosFiltrados = filtrados;
    });
  }

  void _toggleModoComparacao() {
    setState(() {
      _modoComparacao = !_modoComparacao;
      if (!_modoComparacao) {
        _defensivosSelecionados.clear();
      }
    });
  }

  void _toggleSelecaoDefensivo(DefensivoCompleto defensivo) {
    setState(() {
      if (_defensivosSelecionados.contains(defensivo)) {
        _defensivosSelecionados.remove(defensivo);
      } else if (_defensivosSelecionados.length < 3) {
        _defensivosSelecionados.add(defensivo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Máximo de 3 defensivos para comparação')),
        );
      }
    });
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
                  child: isLoading
                      ? _buildLoadingState()
                      : hasError
                          ? _buildErrorState()
                          : _buildContent(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _modoComparacao && _defensivosSelecionados.length >= 2
          ? FloatingActionButton.extended(
              onPressed: _mostrarComparacao,
              icon: const Icon(Icons.compare_arrows),
              label: Text('Comparar (${_defensivosSelecionados.length})'),
              backgroundColor: theme.colorScheme.primary,
            )
          : null,
    );
  }

  Widget _buildModernHeader(bool isDark) {
    final subtitulo = _modoComparacao 
        ? 'Modo comparação - ${_defensivosSelecionados.length}/3 selecionados'
        : '${_defensivosFiltrados.length} defensivo(s) encontrado(s)';

    return ModernHeaderWidget(
      title: 'Defensivos Detalhados',
      subtitle: subtitulo,
      leftIcon: Icons.medical_services,
      rightIcon: _modoComparacao ? Icons.close : Icons.compare_arrows,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: _toggleModoComparacao,
      additionalActions: [
        IconButton(
          icon: const Icon(Icons.sort, color: Colors.white),
          onPressed: _mostrarOpcoesOrdenacao,
        ),
        if (_defensivosFiltrados.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_defensivosFiltrados.length}',
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
                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
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
            'Carregando defensivos...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Integrando dados de múltiplas fontes',
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
            'Erro ao carregar defensivos',
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
            onPressed: _carregarDefensivos,
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

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        // Filtros
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: FiltrosDefensivosWidget(
              ordenacao: _ordenacao,
              filtroToxicidade: _filtroToxicidade,
              filtroTipo: _filtroTipo,
              apenasComercializados: _apenasComercializados,
              apenasElegiveis: _apenasElegiveis,
              onOrdenacaoChanged: (valor) => setState(() {
                _ordenacao = valor;
                _aplicarFiltros();
              }),
              onToxicidadeChanged: (valor) => setState(() {
                _filtroToxicidade = valor;
                _aplicarFiltros();
              }),
              onTipoChanged: (valor) => setState(() {
                _filtroTipo = valor;
                _aplicarFiltros();
              }),
              onComercializadosChanged: (valor) => setState(() {
                _apenasComercializados = valor;
                _aplicarFiltros();
              }),
              onElegiveisChanged: (valor) => setState(() {
                _apenasElegiveis = valor;
                _aplicarFiltros();
              }),
            ),
          ),
        ),
        
        // Lista de defensivos
        if (_defensivosFiltrados.isEmpty)
          SliverToBoxAdapter(child: _buildEstadoVazio())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final defensivo = _defensivosFiltrados[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DefensivoCompletoCardWidget(
                    defensivoCompleto: defensivo,
                    modoComparacao: _modoComparacao,
                    isSelecionado: _defensivosSelecionados.contains(defensivo),
                    onTap: () => _navegarParaDetalhes(defensivo),
                    onSelecaoChanged: _modoComparacao 
                        ? () => _toggleSelecaoDefensivo(defensivo)
                        : null,
                  ),
                );
              },
              childCount: _defensivosFiltrados.length,
            ),
          ),
      ],
    );
  }

  Widget _buildEstadoVazio() {
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
              color: Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 40,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum defensivo encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros para encontrar mais resultados.',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _filtroToxicidade = 'todos';
                _filtroTipo = 'todos';
                _apenasComercializados = false;
                _apenasElegiveis = false;
                _aplicarFiltros();
              });
            },
            icon: const Icon(Icons.clear),
            label: const Text('Limpar Filtros'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _navegarParaDetalhes(DefensivoCompleto defensivo) {
    // Navigator.pushNamed(
    //   context,
    //   '/defensivo-detalhes',
    //   arguments: defensivo.defensivo.idReg,
    // );
    print('Navegar para detalhes do defensivo: ${defensivo.defensivo.idReg}');
  }

  void _mostrarComparacao() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ComparacaoDefensivosWidget(
          defensivos: _defensivosSelecionados,
          onFechar: () {
            Navigator.of(context).pop();
            setState(() {
              _modoComparacao = false;
              _defensivosSelecionados.clear();
            });
          },
        ),
      ),
    );
  }

  void _mostrarOpcoesOrdenacao() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ordenar por'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOpcaoOrdenacao('Prioridade', 'prioridade'),
            _buildOpcaoOrdenacao('Nome', 'nome'),
            _buildOpcaoOrdenacao('Fabricante', 'fabricante'),
            _buildOpcaoOrdenacao('Quantidade de Usos', 'usos'),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcaoOrdenacao(String label, String valor) {
    return RadioListTile<String>(
      title: Text(label),
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
}