import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/diagnostico_entity_resolver_drift.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../diagnosticos/domain/entities/diagnostico_entity.dart';
import '../providers/enhanced_diagnosticos_praga_notifier.dart';

/// Widget aprimorado para exibir diagnósticos relacionados à praga
///
/// Utiliza os novos serviços centralizados e o notifier aprimorado para:
/// - Performance otimizada com cache inteligente
/// - Agrupamento consistente por cultura
/// - Validação de compatibilidade em tempo real
/// - Busca avançada por texto
/// - Estados de carregamento mais informativos
/// - Métricas de qualidade dos dados
class EnhancedDiagnosticosPragaWidget extends ConsumerStatefulWidget {
  final String pragaName;
  final String? pragaId;

  const EnhancedDiagnosticosPragaWidget({
    super.key,
    required this.pragaName,
    this.pragaId,
  });

  @override
  ConsumerState<EnhancedDiagnosticosPragaWidget> createState() =>
      _EnhancedDiagnosticosPragaWidgetState();
}

class _EnhancedDiagnosticosPragaWidgetState
    extends ConsumerState<EnhancedDiagnosticosPragaWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
  }

  Future<void> _initializeProvider() async {
    final notifier = ref.read(
      enhancedDiagnosticosPragaProvider.notifier,
    );
    await notifier.initialize();
    if (widget.pragaId?.isNotEmpty == true) {
      await notifier.loadDiagnosticos(widget.pragaId!);
    } else {
      debugPrint(
        '⚠️ Enhanced widget requer pragaId para funcionar corretamente',
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(enhancedDiagnosticosPragaProvider);

    return RepaintBoundary(
      child: asyncState.when(
        data: (state) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, state),
            _buildFilters(context, state),
            Flexible(child: _buildContent(context, state)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
    );
  }

  /// Constrói header com estatísticas
  Widget _buildHeader(
    BuildContext context,
    EnhancedDiagnosticosPragaState state,
  ) {
    final stats = state.stats;

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
                if (state.hasData) ...[
                  const SizedBox(height: 4),
                  Text(
                    state.hasFilters
                        ? '${stats.filtered} de ${stats.total} diagnósticos'
                        : '${stats.total} diagnósticos em ${stats.groups} culturas',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (state.hasData) ...[
            _buildCacheIndicator(stats.cacheHitRate),
            const SizedBox(width: SpacingTokens.xs),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: state.isLoading
                  ? null
                  : () => ref
                      .read(
                        enhancedDiagnosticosPragaProvider.notifier,
                      )
                      .refresh(),
              tooltip: 'Atualizar dados',
            ),
          ],
        ],
      ),
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
  Widget _buildFilters(
    BuildContext context,
    EnhancedDiagnosticosPragaState state,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      child: Column(
        children: [
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
                              ref
                                  .read(
                                    enhancedDiagnosticosPragaProvider
                                        .notifier,
                                  )
                                  .updateSearchQuery('');
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
                    ref
                        .read(
                          enhancedDiagnosticosPragaProvider.notifier,
                        )
                        .updateSearchQuery(value);
                  },
                ),
              ),
              if (state.hasFilters) ...[
                const SizedBox(width: SpacingTokens.xs),
                OutlinedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    ref
                        .read(
                          enhancedDiagnosticosPragaProvider.notifier,
                        )
                        .clearFilters();
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
          if (state.availableCulturas.length > 2) ...[
            const SizedBox(height: SpacingTokens.xs),
            DropdownButtonFormField<String>(
              initialValue: state.selectedCultura,
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
              items: state.availableCulturas.map((String cultura) {
                return DropdownMenuItem(value: cultura, child: Text(cultura));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(enhancedDiagnosticosPragaProvider.notifier)
                      .updateSelectedCultura(value);
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  /// Constrói conteúdo principal
  Widget _buildContent(
    BuildContext context,
    EnhancedDiagnosticosPragaState state,
  ) {
    if (state.isLoading) {
      return _buildLoadingState();
    }

    if (state.hasError) {
      return _buildErrorState(context, state.errorMessage!);
    }

    if (!state.hasData) {
      return _buildEmptyState(context);
    }

    return _buildDiagnosticsList(context, state);
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
  Widget _buildErrorState(BuildContext context, String error) {
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
              onPressed: () => ref
                  .read(enhancedDiagnosticosPragaProvider.notifier)
                  .refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói estado vazio
  Widget _buildEmptyState(BuildContext context) {
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
  Widget _buildDiagnosticsList(
    BuildContext context,
    EnhancedDiagnosticosPragaState state,
  ) {
    final groupedDiagnostics = state.groupedDiagnosticos;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: SpacingTokens.xs,
        bottom: SpacingTokens.bottomNavSpace,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildGroupedWidgets(context, groupedDiagnostics),
      ),
    );
  }

  /// Constrói widgets agrupados por cultura
  List<Widget> _buildGroupedWidgets(
    BuildContext context,
    Map<String, List<DiagnosticoEntity>> grouped,
  ) {
    final widgets = <Widget>[];

    grouped.forEach((cultura, diagnosticos) {
      widgets.add(_buildCultureHeader(context, cultura, diagnosticos.length));
      widgets.add(const SizedBox(height: SpacingTokens.sm));
      for (int i = 0; i < diagnosticos.length; i++) {
        final diagnostico = diagnosticos[i];
        widgets.add(_buildDiagnosticoItem(context, diagnostico));

        if (i < diagnosticos.length - 1) {
          widgets.add(const SizedBox(height: SpacingTokens.xs));
        }
      }

      widgets.add(const SizedBox(height: SpacingTokens.lg));
    });

    return widgets;
  }

  /// Constrói cabeçalho de cultura
  Widget _buildCultureHeader(BuildContext context, String cultura, int count) {
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
  Widget _buildDiagnosticoItem(
    BuildContext context,
    DiagnosticoEntity diagnostico,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showDiagnosticoDialog(context, diagnostico),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: FutureBuilder<String?>(
                      future: DiagnosticoEntityResolver.instance
                          .resolveDefensivoNome(diagnostico.idDefensivo),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'Carregando...',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        );
                      },
                    ),
                  ),
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
  void _showDiagnosticoDialog(
    BuildContext context,
    DiagnosticoEntity diagnostico,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: FutureBuilder<String?>(
          future: DiagnosticoEntityResolver.instance
              .resolveDefensivoNome(diagnostico.idDefensivo),
          builder: (context, snapshot) =>
              Text(snapshot.data ?? 'Carregando...'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String?>(
              future: DiagnosticoEntityResolver.instance
                  .resolveCulturaNome(diagnostico.idCultura),
              builder: (context, snapshot) =>
                  Text('Cultura: ${snapshot.data ?? 'Carregando...'}'),
            ),
            FutureBuilder<String?>(
              future: DiagnosticoEntityResolver.instance
                  .resolvePragaNome(diagnostico.idPraga),
              builder: (context, snapshot) =>
                  Text('Praga: ${snapshot.data ?? 'Carregando...'}'),
            ),
            Text('Dosagem: ${diagnostico.dosagem.displayDosagem}'),
            Text('Completude: ${diagnostico.completude.displayName}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
