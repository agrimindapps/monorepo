// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../services/auth_service.dart';
import '../services/subscription_service.dart';
import 'calc/calculadoras_page.dart';
import 'dashboard/views/dashboard_page.dart';
import 'database/views/database_page.dart';
import 'login_web_page.dart';
import 'medicamentos/lista_medicamento/views/lista_medicamento_page.dart';
import 'meupet/animal_page/views/animal_page_view.dart';
import 'meupet/consulta_page/index.dart';
import 'meupet/despesas_page/index.dart';
import 'meupet/lembretes_page/index.dart';
import 'meupet/medicamentos_page/index.dart';
import 'meupet/peso_page/peso_page_view.dart';
import 'meupet/vacina_page/views/vacina_page_view.dart';
import 'options_page.dart';

import 'promo_page.dart'; // Importando a página promocional
import 'racas/racas_seletor/views/racas_seletor_page.dart'; // Importando a nova página de login web

class DesktopPageMain extends StatefulWidget {
  const DesktopPageMain({super.key});

  @override
  State<DesktopPageMain> createState() => _DesktopPageMainState();
}

class _DesktopPageMainState extends State<DesktopPageMain> {
  final PageController _pageControllerDesktop = PageController();
  bool _isMenuExpanded = true;
  bool _isMenuVisibleContent = true;
  int _selectedIndex = 0; // Adicionado para rastrear o item selecionado
  late Future<void> _initializationFuture;

  // Adicionar mapa para rastrear itens com hover
  final Map<int, bool> _hoveredItems = {};
  bool _isToggleHovered = false;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Inicializa serviços de autenticação e assinatura
      Get.put(AuthService());
      Get.put(SubscriptionService());
    } catch (e) {
      debugPrint('Erro na inicialização de serviços: $e');
    }
  }

  Widget _buildPageDesktop(int index) {
    debugPrint('Index: $index');
    switch (index) {
      case 0:
        return const RacasSeletorPage();
      case 1:
        return const ListaMedicamentoPage();
      case 2:
        return const AnimalPageView();
      case 3:
        return const PesoPageView();
      case 4:
        return const ConsultaPageView();
      case 5:
        return const DespesasPageView();
      case 6:
        return const LembretesPageView();
      case 7:
        return const MedicamentosPageView();
      case 8:
        return const VacinaPageView();
      case 9:
        return const OptionsVetPage();
      case 10:
        return const DashboardPage();
      case 11:
        return const DatabasePage();
      case 12:
        return const CalculadorasPage();
      case 13:
        return const PetiVetiPromoPage(); // Página promocional
      case 14:
        return const PetiVetiLoginWebPage(); // Página de login web
      default:
        return const RacasSeletorPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menu de navegação com grupos
            Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isMenuExpanded ? 260 : 58, // Reduzido a largura
                  height: constraints.maxHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(
                        color: Colors.grey.shade300, // Cinza mais escuro
                        width: 1,
                      ),
                    ),
                    // Adicionando sombra sutil para elevação do menu
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: 0.07), // Sombra mais acentuada
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Logo section com feedback hover
                      const SizedBox(height: 8), // Reduzido espaçamento
                      _buildLogoSection(),

                      const SizedBox(height: 16), // Reduzido espaçamento

                      // Conteúdo do menu com rolagem
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Grupo: Banco de Dados
                              _buildGroupTitle('BANCO DE DADOS', Icons.storage),
                              _buildNavItem(0, Icons.pets_outlined, 'Raças'),
                              _buildNavItem(1, Icons.article_outlined, 'Bulas'),

                              _buildDivider(),

                              // Grupo: Meu Pet
                              _buildGroupTitle('MEU PET', Icons.pets),
                              _buildNavItem(2, Icons.pets, 'Animais'),
                              _buildNavItem(3, Icons.monitor_weight, 'Peso'),
                              _buildNavItem(
                                  4, Icons.medical_services, 'Consultas'),
                              _buildNavItem(5, Icons.payments, 'Despesas'),
                              _buildNavItem(
                                  6, Icons.notifications_active, 'Lembretes'),
                              _buildNavItem(
                                  7, Icons.medication, 'Medicamentos'),
                              _buildNavItem(8, Icons.vaccines, 'Vacinas'),
                              _buildNavItem(10, Icons.line_axis, 'Dashboard'),

                              _buildDivider(),

                              // Grupo: Marketing
                              _buildGroupTitle('MARKETING', Icons.campaign),
                              _buildNavItem(
                                  13, Icons.public, 'Página Promocional'),
                            ],
                          ),
                        ),
                      ),

                      // Divisor antes do grupo Sistema
                      _buildDivider(),

                      // Grupo Sistema (fixo na parte inferior)
                      _buildGroupTitle('SISTEMA', Icons.settings),
                      _buildNavItem(12, Icons.calculate, 'Calculadoras'),
                      _buildNavItem(11, Icons.data_object, 'Database View'),
                      _buildNavItem(
                          9, Icons.settings_outlined, 'Configurações'),
                      _buildNavItem(14, Icons.login, 'Login Web'),

                      const SizedBox(
                          height: 40), // Reduzido espaço para o botão de toggle
                    ],
                  ),
                ),

                // Toggle Button posicionado na borda com feedback visual aprimorado
                Positioned(
                  bottom: 15, // Ajustado para ficar mais próximo da borda
                  right: -12,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _isToggleHovered = true),
                    onExit: (_) => setState(() => _isToggleHovered = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28, // Reduzido tamanho
                      height: 28, // Reduzido tamanho
                      decoration: BoxDecoration(
                        color: _isToggleHovered
                            ? Colors.purple.shade50
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isToggleHovered
                              ? Colors.purple.shade300
                              : Colors.grey.shade300, // Escurecido
                          width: _isToggleHovered ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                                alpha: _isToggleHovered
                                    ? 0.18
                                    : 0.12), // Mais escuro
                            spreadRadius: _isToggleHovered ? 2 : 1,
                            blurRadius: _isToggleHovered ? 3 : 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        splashRadius: 14, // Reduzido tamanho
                        onPressed: () {
                          setState(() {
                            _isMenuExpanded = !_isMenuExpanded;
                            if (!_isMenuExpanded) {
                              _isMenuVisibleContent = false;
                            } else {
                              Future.delayed(const Duration(milliseconds: 150),
                                  () {
                                setState(() {
                                  _isMenuVisibleContent = true;
                                });
                              });
                            }
                          });
                        },
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return RotationTransition(
                              turns: animation,
                              child: child,
                            );
                          },
                          child: Icon(
                            _isMenuExpanded
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                            key: ValueKey<bool>(_isMenuExpanded),
                            color: _isToggleHovered
                                ? Colors.purple.shade700
                                : Colors.purple.shade500, // Mais escuro
                            size: 14, // Reduzido tamanho
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content Area permanece o mesmo
            Expanded(
              child: PageView.custom(
                controller: _pageControllerDesktop,
                physics: const NeverScrollableScrollPhysics(),
                childrenDelegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return KeyedSubtree(
                      key: PageStorageKey('page_$index'),
                      child: _buildPageDesktop(index),
                    );
                  },
                  childCount: 20, // Aumentado para incluir as novas páginas
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Novo método para o logo com feedback visual
  Widget _buildLogoSection() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Ação para voltar ao dashboard ou tela inicial
          setState(() {
            _selectedIndex = 10; // Dashboard
          });
          _pageControllerDesktop.jumpToPage(10);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 4), // Reduzido padding
          child: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 24, // Reduzido tamanho
                height: 24, // Reduzido tamanho
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.pets,
                  size: 24, // Reduzido tamanho
                  color: Colors.purple.shade700,
                ),
              ),
              if (_isMenuVisibleContent) ...[
                const SizedBox(width: 6),
                Text(
                  'PetiVeti',
                  style: TextStyle(
                    fontSize: 15, // Reduzido tamanho
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800, // Mais escuro
                  ),
                ),
                const Spacer(),
                // Botão de informações sem tooltip
                IconButton(
                  iconSize: 15, // Reduzido tamanho
                  padding: EdgeInsets.zero,
                  splashRadius: 14, // Reduzido tamanho
                  icon: Icon(
                    Icons.info_outline,
                    color: Colors.purple.shade400, // Mais escuro
                  ),
                  onPressed: () {
                    // Mostrar dialog com informações do app
                    _showAppInfo(context);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.pets,
              color: Colors.purple.shade700,
            ),
            const SizedBox(width: 10),
            const Text('PetiVeti'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aplicativo para gerenciamento de saúde e cuidados com pets.'),
            SizedBox(height: 16),
            Text('Versão: 1.0.0'),
            Text('© 2025 PetiVeti. Todos os direitos reservados.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  // Método para criar divisores entre grupos
  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _isMenuVisibleContent ? 10 : 6, // Reduzido padding
        vertical: 6, // Reduzido padding
      ),
      child: Divider(
        color: Colors.grey.shade300, // Mais escuro
        height: 1,
        thickness: 1,
      ),
    );
  }

  // Método para criar títulos de grupo
  Widget _buildGroupTitle(String title, IconData icon) {
    if (!_isMenuVisibleContent) {
      return Divider(
          color: Colors.grey[300], height: 12); // Mais escuro e reduzido altura
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 6, 15, 4), // Reduzido padding
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.grey[700]), // Mais escuro
          const SizedBox(width: 6), // Reduzido espaçamento
          Text(
            title,
            style: TextStyle(
              fontSize: 10, // Reduzido tamanho
              fontWeight: FontWeight.w600,
              color: Colors.grey[700], // Mais escuro
              letterSpacing: 0.7, // Ajustado letter spacing
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir os itens do menu com feedback visual ao passar o mouse, sem tooltips e mais denso
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final isHovered = _hoveredItems[index] ?? false;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredItems[index] = true),
      onExit: (_) => setState(() => _hoveredItems[index] = false),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          _pageControllerDesktop.jumpToPage(index);
        },
        borderRadius: BorderRadius.circular(6), // Reduzido radius
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(
            horizontal: _isMenuVisibleContent ? 5 : 4, // Reduzido margin
            vertical: 2, // Reduzido margin vertical
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _isMenuVisibleContent ? 10 : 5, // Reduzido padding
            vertical: 6, // Reduzido padding vertical
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.purple.shade50
                : (isHovered ? Colors.grey.shade100 : Colors.transparent),
            borderRadius: BorderRadius.circular(6), // Reduzido radius
            border: isSelected
                ? Border.all(
                    color: Colors.purple.shade400, width: 1) // Mais escuro
                : (isHovered
                    ? Border.all(color: Colors.grey.shade400, width: 1)
                    : null), // Mais escuro
            // Sombra sutil no hover para efeito de elevação
            boxShadow: isHovered && !isSelected
                ? [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: 0.08), // Mais escuro
                      spreadRadius: 0,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Ícone com animação de cor
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(2),
                decoration: isSelected || isHovered
                    ? BoxDecoration(
                        color: (isSelected
                            ? Colors.purple.withValues(alpha: 0.12)
                            : Colors.grey
                                .withValues(alpha: 0.12)), // Mais escuro
                        borderRadius: BorderRadius.circular(4),
                      )
                    : null,
                child: Icon(
                  icon,
                  size: 17, // Reduzido tamanho
                  color: isSelected
                      ? Colors.purple.shade800 // Mais escuro
                      : (isHovered
                          ? Colors.purple.shade500
                          : Colors.grey[800]), // Mais escuro
                ),
              ),
              if (_isMenuVisibleContent) ...[
                const SizedBox(width: 8), // Reduzido espaçamento
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.purple.shade800 // Mais escuro
                          : (isHovered
                              ? Colors.purple.shade500
                              : Colors.grey[800]), // Mais escuro
                      fontSize: 13, // Mantido tamanho por legibilidade
                      fontWeight: isSelected || isHovered
                          ? FontWeight.w600
                          : FontWeight.w500, // Um pouco mais espesso
                    ),
                    child: Text(label),
                  ),
                ),
                // Indicador de item selecionado com animação
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isSelected ? 5 : 0, // Reduzido tamanho
                  height: isSelected ? 5 : 0, // Reduzido tamanho
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.purple.shade800
                        : Colors.transparent, // Mais escuro
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
