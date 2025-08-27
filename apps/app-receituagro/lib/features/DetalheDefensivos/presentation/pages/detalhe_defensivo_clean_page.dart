import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/modern_header_widget.dart';
import '../../../comentarios/presentation/providers/comentarios_provider.dart';
import '../../../navigation/bottom_nav_wrapper.dart';
import '../../di/defensivo_details_di.dart';
import '../providers/defensivo_details_provider.dart';
import '../providers/diagnosticos_provider.dart';
import '../providers/tab_controller_provider.dart';
import '../widgets/defensivo_info_cards_widget.dart';
import '../widgets/diagnosticos_tab_widget.dart';
import '../widgets/optimized_tab_bar_widget.dart';

/// Página refatorada seguindo Clean Architecture
/// Responsabilidade única: coordenar providers e widgets especializados
class DetalheDefensivoCleanPage extends StatefulWidget {
  final String defensivoName;
  final String fabricante;

  const DetalheDefensivoCleanPage({
    super.key,
    required this.defensivoName,
    required this.fabricante,
  });

  @override
  State<DetalheDefensivoCleanPage> createState() => _DetalheDefensivoCleanPageState();
}

class _DetalheDefensivoCleanPageState extends State<DetalheDefensivoCleanPage>
    with TickerProviderStateMixin {
  
  late DefensivoDetailsProvider _defensivoDetailsProvider;
  late DiagnosticosProvider _diagnosticosProvider;
  late TabControllerProvider _tabControllerProvider;

  @override
  void initState() {
    super.initState();
    
    // Garantir que DI está inicializada
    initDefensivoDetailsDI();
    
    // Inicializar providers
    _defensivoDetailsProvider = sl<DefensivoDetailsProvider>();
    _diagnosticosProvider = sl<DiagnosticosProvider>();
    _tabControllerProvider = sl<TabControllerProvider>();
    
    // Inicializar tab controller
    _tabControllerProvider.initializeTabController(this);
    
    // Carregar dados
    _loadInitialData();
  }

  @override
  void dispose() {
    // Não é necessário dispose manual dos providers - Provider cuida disso
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // Carregar detalhes do defensivo
    await _defensivoDetailsProvider.loadDefensivoDetails(widget.defensivoName);
    
    // Se defensivo carregado com sucesso, carregar diagnósticos
    if (_defensivoDetailsProvider.defensivo != null) {
      await _diagnosticosProvider.loadDiagnosticos(
        _defensivoDetailsProvider.defensivo!.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _defensivoDetailsProvider),
        ChangeNotifierProvider.value(value: _diagnosticosProvider),
        ChangeNotifierProvider.value(value: _tabControllerProvider),
      ],
      child: BottomNavWrapper(
        selectedIndex: 0,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: Consumer<DefensivoDetailsProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return _buildLoadingState();
                          }

                          if (provider.hasError || provider.defensivo == null) {
                            return _buildErrorState();
                          }

                          return _buildContent();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<DefensivoDetailsProvider>(
      builder: (context, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return ModernHeaderWidget(
          title: widget.defensivoName,
          subtitle: widget.fabricante,
          leftIcon: Icons.shield_outlined,
          rightIcon: provider.isFavorited ? Icons.favorite : Icons.favorite_border,
          isDark: isDark,
          showBackButton: true,
          showActions: true,
          onBackPressed: () => Navigator.of(context).pop(),
          onRightIconPressed: () => provider.toggleFavorite(),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);

    return Center(
      child: Container(
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
                    color: Colors.green.withOpacity(0.3),
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

  Widget _buildErrorState() {
    return Consumer<DefensivoDetailsProvider>(
      builder: (context, provider, child) {
        final theme = Theme.of(context);

        return Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.15),
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
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
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
                  provider.errorMessage.isNotEmpty 
                    ? provider.errorMessage 
                    : 'Não foi possível carregar as informações do defensivo.',
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
                      onPressed: () => _loadInitialData(),
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
                      icon: const Icon(Icons.arrow_back),
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
      },
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        const OptimizedTabBarWidget(),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(
              left: 8,
              right: 8,
              top: 4,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Consumer<TabControllerProvider>(
              builder: (context, tabProvider, child) {
                return TabBarView(
                  controller: tabProvider.tabController,
                  children: [
                    _buildInformacoesTab(),
                    _buildDiagnosticoTab(),
                    _buildTecnologiaTab(),
                    _buildComentariosTab(),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInformacoesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Consumer<DefensivoDetailsProvider>(
        builder: (context, provider, child) {
          if (provider.defensivo == null) {
            return const SizedBox();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefensivoInfoCardsWidget(defensivo: provider.defensivo!),
              const SizedBox(height: 80), // Espaço para bottom navigation
            ],
          );
        },
      ),
    );
  }

  Widget _buildDiagnosticoTab() {
    return DiagnosticosTabWidget(defensivoName: widget.defensivoName);
  }

  Widget _buildTecnologiaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildApplicationInfoSection(
            'Tecnologia',
            _getTecnologiaContent(),
            Icons.precision_manufacturing_outlined,
          ),
          const SizedBox(height: 24),
          _buildApplicationInfoSection(
            'Embalagens',
            _getEmbalagensContent(),
            Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 24),
          _buildApplicationInfoSection(
            'Manejo Integrado',
            _getManejoIntegradoContent(),
            Icons.integration_instructions_outlined,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildComentariosTab() {
    // Usar o provider de comentários existente
    return ChangeNotifierProvider(
      create: (context) => sl<ComentariosProvider>()
        ..loadComentarios(),
      child: Consumer<ComentariosProvider>(
        builder: (context, comentariosProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Usar widgets de comentários existentes ou criar novos
                if (comentariosProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (comentariosProvider.comentarios.isEmpty)
                  _buildEmptyCommentsState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comentariosProvider.comentarios.length,
                    itemBuilder: (context, index) {
                      final comentario = comentariosProvider.comentarios[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(comentario.conteudo),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCommentsState() {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_comment_outlined,
                size: 48,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhum comentário ainda',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Compartilhe sua experiência com este defensivo.\nSua opinião ajuda outros produtores!',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    return Consumer<TabControllerProvider>(
      builder: (context, tabProvider, child) {
        // Só mostra o FAB na tab de comentários (índice 3)
        if (tabProvider.selectedTabIndex != 3) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          onPressed: () {
            // Implementar adição de comentários
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Adicionar comentário')),
            );
          },
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          tooltip: 'Adicionar comentário',
          child: const Icon(Icons.add),
        );
      },
    );
  }

  // Métodos helper para conteúdo de tecnologia (reusando do código original)
  String _getTecnologiaContent() {
    return 'MINISTÉRIO DA AGRICULTURA, PECUÁRIA E ABASTECIMENTO - MAPA\n\n'
        'INSTRUÇÕES DE USO:\n\n'
        '${widget.defensivoName} é um herbicida à base do ingrediente ativo Indaziflam, '
        'indicado para o controle pré-emergente das plantas daninhas nas culturas da '
        'cana-de-açúcar (cana planta e cana soca), café e citros.\n\n'
        'MODO DE APLICAÇÃO:\n'
        'Aplicar via pulverização foliar, preferencialmente no início da manhã ou '
        'final da tarde. Utilizar equipamentos de proteção individual adequados.\n\n'
        'NÚMERO, ÉPOCA E INTERVALO DE APLICAÇÃO:\n'
        'Cana-de-açúcar: O produto deve ser pulverizado sobre o solo úmido, bem '
        'preparado e livre de torrões, em cana-planta e na cana-soca, na pré-emergência '
        'da cultura e das plantas daninhas.';
  }

  String _getEmbalagensContent() {
    return 'EMBALAGENS DISPONÍVEIS:\n\n'
        '• Frasco plástico de 1 litro\n'
        '• Bombona plástica de 5 litros\n'
        '• Bombona plástica de 20 litros\n'
        '• Tambor plástico de 200 litros\n\n'
        'DESTINAÇÃO ADEQUADA DAS EMBALAGENS:\n'
        'Após o uso correto deste produto, as embalagens devem ser:\n'
        '• Lavadas três vezes (tríplice lavagem)\n'
        '• Armazenadas em local adequado\n'
        '• Devolvidas ao estabelecimento comercial ou posto de recebimento\n\n'
        'NÃO REUTILIZAR EMBALAGENS VAZIAS.\n'
        'Esta embalagem deve ser reciclada em instalação autorizada.';
  }

  String _getManejoIntegradoContent() {
    return 'MANEJO INTEGRADO DE PRAGAS (MIP):\n\n'
        'O ${widget.defensivoName} deve ser utilizado dentro de um programa de '
        'Manejo Integrado de Pragas, que inclui:\n\n'
        '• Monitoramento regular da cultura\n'
        '• Uso de métodos de controle biológico quando possível\n'
        '• Rotação de produtos com diferentes modos de ação\n'
        '• Preservação de inimigos naturais\n'
        '• Práticas culturais adequadas\n\n'
        'RESISTÊNCIA:\n'
        'Para evitar o desenvolvimento de populações resistentes, recomenda-se:\n'
        '• Não repetir aplicações do mesmo produto\n'
        '• Alternar com produtos de diferentes grupos químicos\n'
        '• Respeitar intervalos de aplicação\n'
        '• Monitorar a eficácia do controle';
  }

  Widget _buildApplicationInfoSection(String title, String content, IconData icon) {
    final theme = Theme.of(context);

    if (content.isEmpty) {
      return const SizedBox.shrink();
    }

    const accentColor = Color(0xFF4CAF50);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da seção
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withOpacity(0.8),
                  accentColor.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Conteúdo da seção
          Container(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              content,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}