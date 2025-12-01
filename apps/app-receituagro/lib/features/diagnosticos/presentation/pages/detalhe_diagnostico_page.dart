import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../../../../core/widgets/praga_image_widget.dart';
import '../providers/detalhe_diagnostico_notifier.dart';

class DetalheDiagnosticoPage extends ConsumerStatefulWidget {
  final String diagnosticoId;
  final String nomeDefensivo;
  final String nomePraga;
  final String cultura;

  const DetalheDiagnosticoPage({
    super.key,
    required this.diagnosticoId,
    required this.nomeDefensivo,
    required this.nomePraga,
    required this.cultura,
  });

  @override
  ConsumerState<DetalheDiagnosticoPage> createState() => _DetalheDiagnosticoPageState();
}

class _DetalheDiagnosticoPageState extends ConsumerState<DetalheDiagnosticoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Validação: redireciona para página principal se parâmetros inválidos
      if (_hasInvalidParameters()) {
        _redirectToHome();
        return;
      }

      final notifier = ref.read(detalheDiagnosticoProvider.notifier);
      await notifier.loadDiagnosticoData(widget.diagnosticoId);
      await notifier.loadFavoritoState(widget.diagnosticoId);
      await notifier.loadPremiumStatus();
    });
  }

  /// Verifica se os parâmetros são inválidos (null, undefined, vazios)
  bool _hasInvalidParameters() {
    return widget.diagnosticoId.isEmpty ||
           widget.nomeDefensivo.isEmpty ||
           widget.nomePraga.isEmpty ||
           widget.cultura.isEmpty;
  }

  /// Redireciona para a página principal
  void _redirectToHome() {
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final asyncState = ref.watch(detalheDiagnosticoProvider);

    return asyncState.when(
      data: (state) => ColoredBox(
            color: theme.scaffoldBackgroundColor,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    children: [
                      _buildModernHeader(state, isDark),
                      Expanded(
                        child: state.isLoading
                            ? _buildLoadingState()
                            : state.hasError
                                ? _buildErrorState(state)
                                : _buildContent(state),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Erro: $error')),
    );
  }

  Widget _buildModernHeader(DetalheDiagnosticoState state, bool isDark) {
    return ModernHeaderWidget(
      title: 'Diagnóstico',
      subtitle: 'Detalhes do diagnóstico',
      leftIcon: Icons.medical_services_outlined,
      rightIcon: state.isFavorited ? Icons.favorite : Icons.favorite_border,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: () => _toggleFavorito(),
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8.0),
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
              'Carregando diagnóstico...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aguarde enquanto buscamos as informações',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(DetalheDiagnosticoState state) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
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
              'Erro ao carregar diagnóstico',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Dados do diagnóstico não encontrados',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(detalheDiagnosticoProvider.notifier).loadDiagnosticoData(widget.diagnosticoId),
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
      ),
    );
  }

  Widget _buildContent(DetalheDiagnosticoState state) {
    // Prefer resolved names from data map if available, otherwise use widget params
    final resolvedNomePraga = state.diagnosticoData['nomePraga'] ?? widget.nomePraga;
    final resolvedNomeDefensivo = state.diagnosticoData['nomeDefensivo'] ?? widget.nomeDefensivo;
    final resolvedCultura = state.diagnosticoData['nomeCultura'] ?? widget.cultura;
    
    // Build unified list items
    final listItems = _buildUnifiedListItems(state, resolvedNomePraga, resolvedNomeDefensivo, resolvedCultura);
    
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: listItems.length,
      itemBuilder: (context, index) => listItems[index],
    );
  }

  /// Build unified list of items with section headers
  List<Widget> _buildUnifiedListItems(
    DetalheDiagnosticoState state,
    String nomePraga,
    String nomeDefensivo,
    String cultura,
  ) {
    final theme = Theme.of(context);
    final items = <Widget>[];
    final data = state.diagnosticoData;
    
    // === IMAGEM DO DIAGNÓSTICO ===
    items.add(_buildImageSection(nomePraga, nomeDefensivo, cultura, data));
    items.add(const SizedBox(height: 16));
    
    // === INFORMAÇÕES GERAIS ===
    items.add(_buildSectionHeader(theme, 'Informações Gerais'));
    items.add(_buildInfoTile(theme, Icons.science, 'Ingrediente Ativo', data['ingredienteAtivo'] ?? 'N/A'));
    items.add(_buildInfoTile(theme, Icons.warning, 'Classificação Toxicológica', data['classificacaoToxicologica'] ?? 'N/A'));
    items.add(_buildInfoTile(theme, Icons.eco, 'Classificação Ambiental', data['classificacaoAmbiental'] ?? 'N/A'));
    items.add(_buildInfoTile(theme, Icons.agriculture, 'Classe Agronômica', data['classeAgronomica'] ?? 'N/A'));
    
    // === DETALHES DO DIAGNÓSTICO ===
    items.add(const SizedBox(height: 8));
    items.add(_buildSectionHeader(theme, 'Detalhes do Diagnóstico'));
    items.add(_buildInfoTile(theme, Icons.science_outlined, 'Formulação', data['formulacao'] ?? 'N/A'));
    items.add(_buildInfoTile(theme, Icons.bolt, 'Modo de Ação', data['modoAcao'] ?? 'N/A'));
    items.add(_buildInfoTile(theme, Icons.verified, 'Registro MAPA', data['mapa'] ?? 'N/A'));
    
    // === INSTRUÇÕES DE APLICAÇÃO ===
    items.add(const SizedBox(height: 8));
    items.add(_buildSectionHeader(theme, 'Instruções de Aplicação'));
    items.add(_buildInfoTile(theme, Icons.medication, 'Dosagem', data['dosagem'] ?? 'N/A'));
    items.add(_buildInfoTile(theme, Icons.agriculture, 'Vazão Terrestre', data['vazaoTerrestre'] ?? 'N/A'));
    items.add(_buildInfoTile(theme, Icons.flight, 'Vazão Aérea', data['vazaoAerea'] ?? 'N/A'));
    items.add(_buildInfoTile(theme, Icons.schedule, 'Intervalo de Aplicação', data['intervaloAplicacao'] ?? 'N/A'));
    items.add(_buildInfoTile(theme, Icons.shield, 'Intervalo de Segurança', data['intervaloSeguranca'] ?? 'N/A'));
    
    // === TECNOLOGIA DE APLICAÇÃO (se disponível) ===
    if (data['tecnologia']?.isNotEmpty ?? false) {
      items.add(const SizedBox(height: 8));
      items.add(_buildSectionHeader(theme, 'Tecnologia de Aplicação'));
      items.add(_buildTecnologiaCard(theme, data['tecnologia']!));
    }
    
    // Espaço final
    items.add(const SizedBox(height: 80));
    
    return items;
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildInfoTile(ThemeData theme, IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String nomePraga, String nomeDefensivo, String cultura, Map<String, String> data) {
    final theme = Theme.of(context);
    final nomeCientifico = data['nomeCientifico'] ?? nomePraga;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth - 24;
              final imageHeight = availableWidth * 0.5;

              return PragaImageWidget(
                nomeCientifico: nomeCientifico,
                width: double.infinity,
                height: imageHeight,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(10),
                errorWidget: Container(
                  width: double.infinity,
                  height: imageHeight,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            nomePraga,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (data['nomeCientifico'] != null && data['nomeCientifico'] != 'N/A') ...[
            const SizedBox(height: 2),
            Text(
              data['nomeCientifico']!,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '$nomeDefensivo - $cultura',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTecnologiaCard(ThemeData theme, String tecnologia) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.psychology,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tecnologia,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorito() async {
    final itemData = {
      'id': widget.diagnosticoId,
      'nomeDefensivo': widget.nomeDefensivo,
      'nomePraga': widget.nomePraga,
      'cultura': widget.cultura,
    };

    final notifier = ref.read(detalheDiagnosticoProvider.notifier);
    final success = await notifier.toggleFavorito(widget.diagnosticoId, itemData);

    if (!success && mounted) {
      final state = ref.read(detalheDiagnosticoProvider).value;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao ${state?.isFavorited == true ? 'adicionar' : 'remover'} favorito'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  

}
