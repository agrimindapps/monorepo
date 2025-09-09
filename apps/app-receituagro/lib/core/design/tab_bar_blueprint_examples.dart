/// Exemplos Práticos de Implementação - TabBar Blueprint
///
/// Demonstra como aplicar o blueprint padronizado em cenários reais,
/// mostrando a migração das TabBars existentes para o padrão unificado.
///
/// **Cenários demonstrados:**
/// 1. Migração da TabBar de Favoritos (já implementada)
/// 2. Nova TabBar para Detalhes da Praga
/// 3. Nova TabBar para Detalhes do Defensivo  
/// 4. Nova TabBar para Lista de Pragas por Cultura
library tab_bar_examples;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'tab_bar_blueprint.dart';

/// # EXEMPLO 1: TabBar de Favoritos (Migração)
///
/// Demonstra como a TabBar atual de favoritos pode ser migrada
/// para usar o blueprint padronizado, mantendo funcionalidade idêntica.
class FavoritosTabBarExample extends StatelessWidget {
  final TabController tabController;
  
  const FavoritosTabBarExample({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    // === IMPLEMENTAÇÃO ATUAL (favoritos_tabs_widget.dart) ===
    // return Container(
    //   margin: const EdgeInsets.symmetric(horizontal: 0.0),
    //   decoration: BoxDecoration(
    //     color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
    //     borderRadius: BorderRadius.circular(20),
    //   ),
    //   child: TabBar(
    //     controller: tabController,
    //     tabs: _buildCompactTabs(),
    //     labelColor: Colors.white,
    //     unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
    //     indicator: BoxDecoration(
    //       color: const Color(0xFF4CAF50),
    //       borderRadius: BorderRadius.circular(16),
    //     ),
    //     // ... mais configurações
    //   ),
    // );

    // === NOVA IMPLEMENTAÇÃO COM BLUEPRINT ===
    return TabBarFactories.forFavoritos(
      tabController: tabController,
    );
    
    // OU, para mais controle:
    // return StandardTabBarWidget(
    //   tabController: tabController,
    //   containerMargin: const EdgeInsets.symmetric(horizontal: 0.0),
    //   tabs: const [
    //     TabBarItemData(
    //       icon: FontAwesomeIcons.shield,
    //       text: 'Defensivos',
    //       tooltip: 'Defensivos favoritos',
    //     ),
    //     TabBarItemData(
    //       icon: FontAwesomeIcons.bug,
    //       text: 'Pragas',
    //       tooltip: 'Pragas favoritas',
    //     ),
    //     TabBarItemData(
    //       icon: FontAwesomeIcons.magnifyingGlass,
    //       text: 'Diagnósticos',
    //       tooltip: 'Diagnósticos favoritos',
    //     ),
    //   ],
    // );
  }
}

/// # EXEMPLO 2: TabBar para Detalhes da Praga
///
/// Nova implementação padronizada para substituir TabBars
/// customizadas existentes na página de detalhes de pragas.
class PragaDetalhesTabBarExample extends StatelessWidget {
  final TabController tabController;
  
  const PragaDetalhesTabBarExample({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    // === IMPLEMENTAÇÃO ANTERIOR (custom_tab_bar_widget.dart) ===
    // return Container(
    //   margin: const EdgeInsets.symmetric(horizontal: 16.0),
    //   decoration: BoxDecoration(
    //     color: theme.colorScheme.primaryContainer,
    //     borderRadius: BorderRadius.circular(12),
    //   ),
    //   child: TabBar(
    //     controller: tabController,
    //     indicator: BoxDecoration(
    //       color: theme.colorScheme.primary,
    //       borderRadius: BorderRadius.circular(8),
    //     ),
    //     // ... configurações hardcoded
    //   ),
    // );

    // === NOVA IMPLEMENTAÇÃO PADRONIZADA ===
    return TabBarFactories.forPragaDetails(
      tabController: tabController,
    );
    
    // Resultado: TabBar consistente com favoritos, mas adaptada para pragas
    // - Mesmo visual e comportamento de animação
    // - Ícones e textos específicos para pragas  
    // - Margem ajustada para contexto de página de detalhes
  }
}

/// # EXEMPLO 3: TabBar Responsiva
///
/// Demonstra como implementar TabBar que se adapta ao tamanho da tela,
/// mantendo a consistência visual em diferentes dispositivos.
class ResponsiveTabBarExample extends StatelessWidget {
  final TabController tabController;
  final List<TabBarItemData> tabs;
  
  const ResponsiveTabBarExample({
    super.key,
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        // Adapta comportamento baseado no tamanho da tela
        if (screenWidth < 400) {
          // Mobile pequeno: versão compacta
          return ResponsiveTabBarVariants.compact(
            tabController: tabController,
            tabs: tabs,
          );
        } else if (screenWidth > 800) {
          // Tablet/Desktop: versão expandida  
          return ResponsiveTabBarVariants.expanded(
            tabController: tabController,
            tabs: tabs,
          );
        } else {
          // Mobile padrão: implementação normal
          return StandardTabBarWidget(
            tabController: tabController,
            tabs: tabs,
          );
        }
      },
    );
  }
}

/// # EXEMPLO 4: TabBar com Customização de Cores
///
/// Demonstra como aplicar cores customizadas mantendo
/// a estrutura e comportamento padronizados.
class CustomColorTabBarExample extends StatelessWidget {
  final TabController tabController;
  
  const CustomColorTabBarExample({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return StandardTabBarWidget(
      tabController: tabController,
      // Customização de cores mantendo estrutura padrão
      customIndicatorColor: const Color(0xFF2196F3), // Azul customizado
      customBackgroundColor: Colors.blue.withValues(alpha: 0.1),
      tabs: const [
        TabBarItemData(
          icon: Icons.analytics_outlined,
          text: 'Analytics',
          tooltip: 'Dados analíticos',
        ),
        TabBarItemData(
          icon: Icons.trending_up,
          text: 'Tendências',
          tooltip: 'Tendências do mercado',
        ),
        TabBarItemData(
          icon: Icons.insights,
          text: 'Insights',
          tooltip: 'Insights personalizados',
        ),
      ],
    );
  }
}

/// # EXEMPLO 5: Integração com Existing Page Structure
///
/// Mostra como integrar a TabBar padronizada em uma página completa,
/// substituindo implementações customizadas existentes.
class ExamplePageWithStandardizedTabBar extends StatefulWidget {
  const ExamplePageWithStandardizedTabBar({super.key});

  @override
  State<ExamplePageWithStandardizedTabBar> createState() =>
      _ExamplePageWithStandardizedTabBarState();
}

class _ExamplePageWithStandardizedTabBarState
    extends State<ExamplePageWithStandardizedTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Praga'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // === HEADER DA PÁGINA ===
          Container(
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lagarta do Cartucho',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Spodoptera frugiperda',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          // === TABBAR PADRONIZADA ===
          // Substitui implementações customizadas inconsistentes
          TabBarFactories.forPragaDetails(
            tabController: _tabController,
          ),
          
          // === CONTEÚDO DAS TABS ===
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Tab 1: Informações
                Center(
                  child: Text(
                    'Informações básicas sobre a praga',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                // Tab 2: Diagnósticos
                Center(
                  child: Text(
                    'Diagnósticos relacionados',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                // Tab 3: Comentários  
                Center(
                  child: Text(
                    'Comentários e observações',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// # EXEMPLO 6: Migration Helper
///
/// Utilitário para facilitar migração de TabBars existentes
/// para o padrão padronizado.
class TabBarMigrationHelper {
  TabBarMigrationHelper._();
  
  /// Converte TabBar customizada existente para padrão blueprint
  /// 
  /// **Uso:**
  /// ```dart
  /// // Antes:
  /// CustomTabBarWidget(tabController: _controller)
  /// 
  /// // Depois:
  /// TabBarMigrationHelper.migrateToStandard(
  ///   tabController: _controller,
  ///   context: MigrationContext.pragaDetails,
  /// )
  /// ```
  static Widget migrateToStandard({
    required TabController tabController,
    required MigrationContext context,
    EdgeInsets? customMargin,
    Color? customIndicatorColor,
  }) {
    switch (context) {
      case MigrationContext.favoritos:
        return TabBarFactories.forFavoritos(tabController: tabController);
        
      case MigrationContext.pragaDetails:
        return TabBarFactories.forPragaDetails(tabController: tabController);
        
      case MigrationContext.defensivoDetails:
        return TabBarFactories.forDefensivoDetails(tabController: tabController);
        
      case MigrationContext.pragasCultura:
        return TabBarFactories.forPragasCultura(tabController: tabController);
        
      case MigrationContext.custom:
        // Para casos que precisam de configuração específica
        return StandardTabBarWidget(
          tabController: tabController,
          containerMargin: customMargin,
          customIndicatorColor: customIndicatorColor,
          tabs: _getDefaultTabsForCustom(),
        );
    }
  }
  
  static List<TabBarItemData> _getDefaultTabsForCustom() {
    return const [
      TabBarItemData(
        icon: Icons.info_outline,
        text: 'Info',
        tooltip: 'Informações',
      ),
      TabBarItemData(
        icon: Icons.search,
        text: 'Busca',
        tooltip: 'Buscar conteúdo',
      ),
    ];
  }
}

/// Contextos de migração disponíveis
enum MigrationContext {
  favoritos,
  pragaDetails,
  defensivoDetails,
  pragasCultura,
  custom,
}

/// # RESUMO DE BENEFÍCIOS DOS EXEMPLOS
///
/// ## 🎯 Consistência Visual
/// Todos os exemplos seguem exatamente o mesmo padrão visual:
/// - Container com borderRadius 20dp
/// - Indicador verde (4CAF50) com borderRadius 16dp  
/// - Animação de texto aparecendo apenas na tab ativa
/// - Ícones com tamanho 16dp e cores dinâmicas
///
/// ## ⚡ Facilidade de Implementação
/// - Factories pré-configuradas para casos comuns
/// - Migration helpers para converter código existente
/// - APIs claras e intuitivas
///
/// ## 🔧 Flexibilidade Mantida
/// - Customização de cores quando necessário
/// - Comportamento responsivo built-in
/// - Estrutura extensível para novos contextos
///
/// ## 📱 Excelente UX
/// - Animações fluidas e consistentes
/// - Comportamento previsível em todas as telas
/// - Acessibilidade garantida por padrão
/// - Tooltips informativos
class ExamplesOverview {
  ExamplesOverview._();
}