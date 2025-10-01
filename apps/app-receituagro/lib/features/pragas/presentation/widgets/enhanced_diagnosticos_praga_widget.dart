import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_lib;

import '../../../../core/theme/spacing_tokens.dart';
import '../../../../core/services/diagnostico_compatibility_service.dart';
import '../../../diagnosticos/domain/entities/diagnostico_entity.dart';
import '../providers/enhanced_diagnosticos_praga_provider.dart';
// import 'diagnostico_dialog_widget.dart'; // TODO: Criar versão para DiagnosticoEntity

/// Widget aprimorado para exibir diagnósticos relacionados à praga
/// 
/// Utiliza os novos serviços centralizados e o provider aprimorado para:
/// - Performance otimizada com cache inteligente
/// - Agrupamento consistente por cultura
/// - Validação de compatibilidade em tempo real
/// - Busca avançada por texto
/// - Estados de carregamento mais informativos
/// - Métricas de qualidade dos dados
class EnhancedDiagnosticosPragaWidget extends StatefulWidget {
  final String pragaName;
  final String? pragaId;

  const EnhancedDiagnosticosPragaWidget({
    super.key,
    required this.pragaName,
    this.pragaId,
  });

  @override
  State<EnhancedDiagnosticosPragaWidget> createState() => 
      _EnhancedDiagnosticosPragaWidgetState();
}

class _EnhancedDiagnosticosPragaWidgetState 
    extends State<EnhancedDiagnosticosPragaWidget> {
  late EnhancedDiagnosticosPragaProvider _provider;
  final TextEditingController _searchController = TextEditingController();
  bool _showCompatibilityIndicators = true;

  @override
  void initState() {
    super.initState();
    _provider = EnhancedDiagnosticosPragaProvider();
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await _provider.initialize();
    
    // Carrega dados baseado no que foi fornecido
    if (widget.pragaId?.isNotEmpty == true) {
      await _provider.loadDiagnosticos(widget.pragaId!);
    } else {
      // Se não temos pragaId, precisamos buscar pela praga primeiro
      // Para isso, este widget agora requer pragaId obrigatório
      debugPrint('⚠️ Enhanced widget requer pragaId para funcionar corretamente');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return provider_lib.ChangeNotifierProvider.value(
      value: _provider,
      child: RepaintBoundary(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildFilters(),
            Flexible(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói header com estatísticas
  Widget _buildHeader() {
    return provider_lib.Consumer<EnhancedDiagnosticosPragaProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;
        
        return Container(
          padding: const EdgeInsets.all(SpacingTokens.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnósticos para ${widget.pragaName}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (provider.hasData) ...[
                      const SizedBox(height: 4),
                      Text(
                        provider.hasFilters
                            ? '${stats.filtered} de ${stats.total} diagnósticos'
                            : '${stats.total} diagnósticos em ${stats.groups} culturas',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (provider.hasData) ...[
                _buildCacheIndicator(stats.cacheHitRate),
                const SizedBox(width: SpacingTokens.xs),
                IconButton(
                  icon: Icon(
                    _showCompatibilityIndicators
                        ? Icons.verified_outlined
                        : Icons.verified_outlined,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _showCompatibilityIndicators = !_showCompatibilityIndicators;
                    });
                  },
                  tooltip: _showCompatibilityIndicators 
                      ? 'Ocultar indicadores de compatibilidade'
                      : 'Mostrar indicadores de compatibilidade',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: provider.isLoading ? null : () => provider.refresh(),
                  tooltip: 'Atualizar dados',
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Constrói indicador de cache
  Widget _buildCacheIndicator(double hitRate) {
    final color = hitRate > 80 
        ? Colors.green 
        : hitRate > 50 
            ? Colors.orange 
            : Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            '${hitRate.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói área de filtros
  Widget _buildFilters() {
    return provider_lib.Consumer<EnhancedDiagnosticosPragaProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: SpacingTokens.xs,
          ),
          child: Column(
            children: [
              // Campo de busca
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar por defensivo, cultura ou ID...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.updateSearchQuery('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        provider.updateSearchQuery(value);
                      },
                    ),
                  ),
                  if (provider.hasFilters) ...[
                    const SizedBox(width: SpacingTokens.xs),
                    OutlinedButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        provider.clearFilters();
                      },
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Limpar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              // Dropdown de culturas
              if (provider.availableCulturas.length > 2) ...[
                const SizedBox(height: SpacingTokens.xs),
                DropdownButtonFormField<String>(
                  value: provider.selectedCultura,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por cultura',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: provider.availableCulturas.map((cultura) {
                    return DropdownMenuItem(
                      value: cultura,
                      child: Text(cultura),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.updateSelectedCultura(value);
                    }
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Constrói conteúdo principal
  Widget _buildContent() {
    return provider_lib.Consumer<EnhancedDiagnosticosPragaProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState();
        }

        if (provider.hasError) {
          return _buildErrorState(provider.errorMessage!, provider);
        }

        if (!provider.hasData) {
          return _buildEmptyState();
        }

        return _buildDiagnosticsList(provider);
      },
    );
  }

  /// Constrói estado de carregamento
  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: SpacingTokens.md),
            Text('Carregando diagnósticos...'),
          ],
        ),
      ),
    );
  }

  /// Constrói estado de erro
  Widget _buildErrorState(String error, EnhancedDiagnosticosPragaProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              'Erro ao carregar diagnósticos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.md),
            ElevatedButton.icon(
              onPressed: () => provider.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói estado vazio
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Theme.of(context).dividerColor,
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              'Nenhum diagnóstico encontrado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Não há diagnósticos disponíveis para esta praga.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói lista de diagnósticos agrupados
  Widget _buildDiagnosticsList(EnhancedDiagnosticosPragaProvider provider) {
    final groupedDiagnostics = provider.groupedDiagnosticos;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: SpacingTokens.xs,
        bottom: SpacingTokens.bottomNavSpace,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildGroupedWidgets(groupedDiagnostics),
      ),
    );
  }

  /// Constrói widgets agrupados por cultura
  List<Widget> _buildGroupedWidgets(Map<String, List<DiagnosticoEntity>> grouped) {
    final widgets = <Widget>[];

    grouped.forEach((cultura, diagnosticos) {
      // Cabeçalho da cultura
      widgets.add(_buildCultureHeader(cultura, diagnosticos.length));
      widgets.add(const SizedBox(height: SpacingTokens.sm));

      // Items de diagnósticos
      for (int i = 0; i < diagnosticos.length; i++) {
        final diagnostico = diagnosticos[i];
        widgets.add(_buildDiagnosticoItem(diagnostico));
        
        if (i < diagnosticos.length - 1) {
          widgets.add(const SizedBox(height: SpacingTokens.xs));
        }
      }
      
      widgets.add(const SizedBox(height: SpacingTokens.lg));
    });

    return widgets;
  }

  /// Constrói cabeçalho de cultura
  Widget _buildCultureHeader(String cultura, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.agriculture,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: SpacingTokens.xs),
          Expanded(
            child: Text(
              cultura,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói item de diagnóstico
  Widget _buildDiagnosticoItem(DiagnosticoEntity diagnostico) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showDiagnosticoDialog(diagnostico),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      diagnostico.displayDefensivo,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_showCompatibilityIndicators)
                    _buildCompatibilityIndicator(diagnostico),
                ],
              ),
              
              const SizedBox(height: SpacingTokens.xs),
              
              Text(
                'Dosagem: ${diagnostico.dosagem.displayDosagem}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              if (diagnostico.aplicacao.isValid) ...[
                const SizedBox(height: 2),
                Text(
                  'Aplicação: ${diagnostico.aplicacao.tiposDisponiveis.map((t) => t.displayName).join(', ')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              
              const SizedBox(height: SpacingTokens.xs),
              
              Row(
                children: [
                  _buildCompletudeChip(diagnostico.completude),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói indicador de compatibilidade
  Widget _buildCompatibilityIndicator(DiagnosticoEntity diagnostico) {
    return FutureBuilder<CompatibilityValidation?>(
      future: _provider.validateCompatibility(diagnostico),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          final validation = snapshot.data!;
          Color color;
          IconData icon;
          
          switch (validation.result) {
            case CompatibilityResult.success:
              color = Colors.green;
              icon = Icons.check_circle;
              break;
            case CompatibilityResult.warning:
              color = Colors.orange;
              icon = Icons.warning;
              break;
            case CompatibilityResult.failed:
            case CompatibilityResult.error:
              color = Colors.red;
              icon = Icons.error;
              break;
          }
          
          return Icon(icon, size: 16, color: color);
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  /// Constrói chip de completude
  Widget _buildCompletudeChip(DiagnosticoCompletude completude) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Color(completude.colorValue).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(completude.colorValue).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        completude.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(completude.colorValue),
        ),
      ),
    );
  }

  /// Mostra modal de detalhes do diagnóstico
  void _showDiagnosticoDialog(DiagnosticoEntity diagnostico) {
    // TODO: Implementar dialog para DiagnosticoEntity
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(diagnostico.displayDefensivo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cultura: ${diagnostico.displayCultura}'),
            Text('Praga: ${diagnostico.displayPraga}'),
            Text('Dosagem: ${diagnostico.dosagem.displayDosagem}'),
            Text('Completude: ${diagnostico.completude.displayName}'),
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
}