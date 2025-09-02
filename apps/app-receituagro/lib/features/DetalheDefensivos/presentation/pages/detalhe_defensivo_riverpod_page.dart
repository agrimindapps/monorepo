import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../../../navigation/bottom_nav_wrapper.dart';
import '../providers/defensivo_details_provider.dart';
import '../providers/diagnosticos_provider.dart';

/// Página de detalhes do defensivo refatorada com Clean Architecture + Riverpod
/// 
/// Esta página implementa os princípios de Clean Architecture e SOLID:
/// - Single Responsibility: Apenas exibe a UI
/// - Open/Closed: Extensível via widgets compostos
/// - Liskov Substitution: Usa abstrações (providers)
/// - Interface Segregation: Providers específicos por responsabilidade
/// - Dependency Inversion: Depende de abstrações, não implementações
class DetalheDefensivoRiverpodPage extends ConsumerStatefulWidget {
  final String defensivoName;
  final String fabricante;

  const DetalheDefensivoRiverpodPage({
    super.key,
    required this.defensivoName,
    required this.fabricante,
  });

  @override
  ConsumerState<DetalheDefensivoRiverpodPage> createState() => 
      _DetalheDefensivoRiverpodPageState();
}

class _DetalheDefensivoRiverpodPageState 
    extends ConsumerState<DetalheDefensivoRiverpodPage> 
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Carrega os dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Carrega os dados necessários para a página
  Future<void> _loadData() async {
    final defensivoNotifier = ref.read(defensivoDetailsNotifierProvider.notifier);
    final diagnosticosNotifier = ref.read(diagnosticosNotifierProvider.notifier);

    // Carrega detalhes do defensivo
    await defensivoNotifier.loadDefensivoDetails(
      nome: widget.defensivoName,
    );

    // Se conseguiu carregar o defensivo, carrega os diagnósticos
    final defensivo = ref.read(currentDefensivoProvider);
    if (defensivo != null) {
      await diagnosticosNotifier.loadDiagnosticos(defensivo.idReg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(isLoadingDefensivoProvider);
    final error = ref.watch(defensivoErrorProvider);
    final defensivo = ref.watch(currentDefensivoProvider);

    return BottomNavWrapper(
      selectedIndex: 0, // Defensivos é o índice 0
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: _buildBody(context, isLoading, error, defensivo),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói o header da página
  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFavorited = ref.watch(isFavoritedProvider);
    
    return ModernHeaderWidget(
      title: widget.defensivoName,
      subtitle: widget.fabricante,
      leftIcon: Icons.shield_outlined,
      rightIcon: isFavorited ? Icons.favorite : Icons.favorite_border,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: _toggleFavorito,
    );
  }

  /// Alterna o status de favorito
  void _toggleFavorito() {
    final notifier = ref.read(defensivoDetailsNotifierProvider.notifier);
    notifier.toggleFavorito();
  }

  /// Constrói o corpo da página
  Widget _buildBody(
    BuildContext context,
    bool isLoading,
    String? error,
    dynamic defensivo,
  ) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (error != null) {
      return _buildErrorState(context, error);
    }

    if (defensivo == null) {
      return _buildErrorState(context, 'Defensivo não encontrado');
    }

    return _buildContent(context);
  }

  /// Widget de loading
  Widget _buildLoadingState(BuildContext context) {
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
              'Carregando detalhes...',
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

  /// Widget de erro
  Widget _buildErrorState(BuildContext context, String errorMessage) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.15),
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
                FontAwesomeIcons.triangleExclamation,
                size: 32,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erro ao carregar detalhes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(FontAwesomeIcons.arrowLeft),
                  label: const Text('Voltar'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói o conteúdo principal da página
  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _wrapTabContent(_buildInformacoesTab(), 'informacoes'),
                _wrapTabContent(_buildDiagnosticoTab(), 'diagnostico'),
                _wrapTabContent(_buildTecnologiaTab(), 'tecnologia'),
                _wrapTabContent(_buildComentariosTab(), 'comentarios'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Constrói a tab bar customizada
  Widget _buildTabBar() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 8, bottom: 4, left: 8, right: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade100, Colors.green.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200.withValues(alpha: 0.5),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: _buildTabsWithIcons(),
        indicator: BoxDecoration(
          color: Colors.green.shade700,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.green.shade800,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  /// Constrói as tabs com ícones
  List<Widget> _buildTabsWithIcons() {
    final tabData = [
      {'icon': FontAwesomeIcons.info, 'text': 'Informações'},
      {'icon': FontAwesomeIcons.magnifyingGlass, 'text': 'Diagnóstico'},
      {'icon': FontAwesomeIcons.gear, 'text': 'Tecnologia'},
      {'icon': FontAwesomeIcons.comment, 'text': 'Comentários'},
    ];

    return tabData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return Tab(
        child: AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            final isActive = _tabController.index == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? null : 40,
              child: Row(
                mainAxisSize: isActive ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(data['icon'] as IconData, size: isActive ? 18 : 16),
                  if (isActive) ...[
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        data['text'] as String,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    }).toList();
  }

  /// Envolve o conteúdo da tab com scroll
  Widget _wrapTabContent(Widget content, String type) {
    return Container(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            key: ValueKey('$type-content'),
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: content,
            ),
          );
        },
      ),
    );
  }

  /// Tab de informações (simplificada para demonstração)
  Widget _buildInformacoesTab() {
    final defensivo = ref.watch(currentDefensivoProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (defensivo != null) ...[
            _buildInfoCard('Ingrediente Ativo', defensivo.ingredienteAtivo),
            const SizedBox(height: 16),
            _buildInfoCard('Nome Técnico', defensivo.nomeTecnico),
            const SizedBox(height: 16),
            _buildInfoCard('Fabricante', defensivo.fabricante),
          ] else ...[
            const Text('Dados não disponíveis'),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  /// Tab de diagnósticos (simplificada)
  Widget _buildDiagnosticoTab() {
    final diagnosticos = ref.watch(diagnosticosListProvider);
    final isLoading = ref.watch(isLoadingDiagnosticosProvider);
    
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (diagnosticos.isEmpty) {
      return const Center(child: Text('Nenhum diagnóstico encontrado'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: diagnosticos.length,
      itemBuilder: (context, index) {
        final diagnostico = diagnosticos[index];
        return Card(
          child: ListTile(
            title: Text(diagnostico.nome),
            subtitle: Text('${diagnostico.cultura} - ${diagnostico.dosagem}'),
            leading: const Icon(Icons.agriculture),
          ),
        );
      },
    );
  }

  /// Tabs de tecnologia e comentários (placeholder)
  Widget _buildTecnologiaTab() {
    return const Center(child: Text('Tecnologia - Em desenvolvimento'));
  }

  Widget _buildComentariosTab() {
    return const Center(child: Text('Comentários - Em desenvolvimento'));
  }

  /// Card de informação simples
  Widget _buildInfoCard(String label, String value) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}