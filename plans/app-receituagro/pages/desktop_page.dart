// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../core/themes/manager.dart';
import '../router.dart';

class DesktopPageMain extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;

  const DesktopPageMain({super.key, this.navigatorKey});

  @override
  State<DesktopPageMain> createState() => _DesktopPageMainState();
}

class _DesktopPageMainState extends State<DesktopPageMain> {
  late final GlobalKey<NavigatorState> _navigatorKey;
  bool _isMenuExpanded = true;
  bool _isMenuVisibleContent = true;
  int _selectedIndex = 0;
  int? _hoveredIndex;

  // Mapeamento de índices para rotas
  final List<String> _desktopRoutes = [
    AppRoutes.defensivosHome,     // 0: Defensivos
    AppRoutes.culturasListar,     // 1: Culturas
    AppRoutes.pragasHome,         // 2: Pragas
    AppRoutes.pragasHome,         // 3: Pragas (Nova) - mesma rota por enquanto
    AppRoutes.favoritos,          // 4: Favoritos
    AppRoutes.defensivosAgrupados, // 5: Fabricantes
    AppRoutes.defensivosAgrupados, // 6: Ingredientes Ativos
    AppRoutes.defensivosAgrupados, // 7: Classe Agronômica
    AppRoutes.defensivosAgrupados, // 8: Modo de Ação
    AppRoutes.config,             // 9: Configurações
    '/receituagro/promo',         // 10: Promo - rota customizada
    '/receituagro/login',         // 11: Login - rota customizada
  ];

  // Argumentos específicos para rotas agrupadas
  Map<String, dynamic>? _getRouteArguments(int index) {
    switch (index) {
      case 5: // Fabricantes
        return {'tipoAgrupamento': 'fabricantes', 'textoFiltro': ''};
      case 6: // Ingredientes Ativos
        return {'tipoAgrupamento': 'ingredienteAtivo', 'textoFiltro': ''};
      case 7: // Classe Agronômica
        return {'tipoAgrupamento': 'classeAgronomica', 'textoFiltro': ''};
      case 8: // Modo de Ação
        return {'tipoAgrupamento': 'modoAcao', 'textoFiltro': ''};
      default:
        return null;
    }
  }

  // Método para gerar rotas baseado no GetX e Flutter Navigator (similar ao mobile)
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    // Primeiro, tenta encontrar a rota no GetX
    final getxRoute = AppPages.routes.firstWhereOrNull(
        (route) => route.name == settings.name);
    
    if (getxRoute != null) {
      // Se encontrou no GetX, cria uma MaterialPageRoute com a página do GetX
      return MaterialPageRoute(
        builder: (_) {
          // Executa bindings se existirem
          if (getxRoute.binding != null) {
            getxRoute.binding!.dependencies();
          }
          return getxRoute.page();
        },
        settings: settings,
        fullscreenDialog: false,
      );
    }
    
    // Rotas customizadas específicas do desktop (promo, login)
    if (settings.name == '/receituagro/promo') {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Promo Page - Em desenvolvimento'),
          ),
        ),
        settings: settings,
      );
    }
    
    if (settings.name == '/receituagro/login') {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Login Page - Em desenvolvimento'),
          ),
        ),
        settings: settings,
      );
    }
    
    // Se não encontrou, retorna null (rota não encontrada)
    return null;
  }

  @override
  void initState() {
    super.initState();
    _navigatorKey = widget.navigatorKey ?? GlobalKey<NavigatorState>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // Adicionado widget Material como ancestral
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isMenuExpanded ? 280 : 72,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: ThemeManager().isDark.value
                        ? const Color(0xFF18181B)
                        : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                    border: Border(
                      right: BorderSide(
                        color: ThemeManager().isDark.value
                            ? Colors.grey.shade900
                            : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // App Logo/Title Section
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: ThemeManager().isDark.value
                                    ? const Color(0xFF222228)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.agriculture,
                                size: 26,
                                color: ThemeManager().isDark.value
                                    ? Colors.green.shade600
                                    : Colors.green.shade700,
                              ),
                            ),
                          ),
                          if (_isMenuVisibleContent) const SizedBox(width: 6),
                          if (_isMenuVisibleContent)
                            Text(
                              'Receituagro',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: ThemeManager().isDark.value
                                    ? Colors.green.shade600
                                    : Colors.green.shade700,
                              ),
                            ),
                          if (_isMenuVisibleContent) const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Navigation Menu - Principal (Scrollable)
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGroupTitle('PRINCIPAL', Icons.home),
                              _buildNavItem(0, Icons.shield, 'Defensivos'),
                              _buildNavItem(1, Icons.eco, 'Culturas'),
                              _buildNavItem(2, Icons.bug_report, 'Pragas'),
                              _buildNavItem(
                                  3, Icons.bug_report, 'Pragas (Nova)'),
                              _buildNavItem(4, Icons.favorite, 'Favoritos'),

                              // Novo grupo DEFENSIVOS
                              _buildDivider(),
                              _buildGroupTitle(
                                  'DEFENSIVOS', Icons.shield_outlined),
                              _buildNavItem(
                                  5, FontAwesome.industry_solid, 'Fabricantes'),
                              _buildNavItem(6, FontAwesome.vial_solid,
                                  'Ingredientes Ativos'),
                              _buildNavItem(7, FontAwesome.flask_solid,
                                  'Classe Agronômica'),
                              _buildNavItem(8, FontAwesome.biohazard_solid,
                                  'Modo de Ação'),
                            ],
                          ),
                        ),
                      ),
                      // Navigation Menu - Sistema (Fixed at bottom)                              _buildDivider(),
                      _buildGroupTitle('SISTEMA', Icons.settings),
                      _buildNavItem(9, Icons.settings, 'Configurações'),
                      _buildNavItem(10, Icons.web, 'Promo'),
                      _buildNavItem(11, Icons.login, 'Login'),
                      _buildThemeToggle(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Menu Toggle Button
                Positioned(
                  bottom: 20,
                  right: -15,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: ThemeManager().isDark.value
                          ? const Color(0xFF18181B)
                          : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      border: Border.all(
                        color: ThemeManager().isDark.value
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 16,
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
                      icon: AnimatedRotation(
                        turns: _isMenuExpanded ? 0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          _isMenuExpanded
                              ? Icons.chevron_left
                              : Icons.chevron_right,
                          color: ThemeManager().isDark.value
                              ? Colors.green.shade600
                              : Colors.green.shade700,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content Area
          Expanded(
            child: Navigator(
              key: _navigatorKey,
              initialRoute: AppRoutes.defensivosHome,
              onGenerateRoute: _onGenerateRoute,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _isMenuVisibleContent ? 12 : 8,
          vertical: 8,
        ),
        child: Divider(
          color: ThemeManager().isDark.value
              ? Colors.grey.shade800
              : Colors.grey.shade200,
          height: 1,
          thickness: 1,
        ),
      ),
    );
  }

  Widget _buildGroupTitle(String title, IconData icon) {
    if (!_isMenuVisibleContent) {
      return Obx(
        () => Divider(
          color: ThemeManager().isDark.value
              ? Colors.grey.shade800
              : Colors.grey.shade200,
          height: 16,
          thickness: 1,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 12,
            color: ThemeManager().isDark.value
                ? Colors.grey.shade400
                : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: ThemeManager().isDark.value
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _selectedIndex == index;
    final bool isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() => _hoveredIndex = index);
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _hoveredIndex = null);
        }
      },
      child: InkWell(
        onTap: () {
          if (mounted) {
            setState(() {
              _selectedIndex = index;
            });
            
            // Navegar usando Navigator com rotas
            final route = _desktopRoutes[index];
            final arguments = _getRouteArguments(index);
            
            if (arguments != null) {
              _navigatorKey.currentState?.pushNamedAndRemoveUntil(
                route,
                (route) => false,
                arguments: arguments,
              );
            } else {
              _navigatorKey.currentState?.pushNamedAndRemoveUntil(
                route,
                (route) => false,
              );
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(
            horizontal: _isMenuVisibleContent ? 8 : 6,
            vertical: 3,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _isMenuVisibleContent ? 12 : 6,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (ThemeManager().isDark.value
                    ? Colors.green.withAlpha(38)
                    : Colors.green.shade50)
                : isHovered
                    ? (ThemeManager().isDark.value
                        ? Colors.grey.shade800.withAlpha(128)
                        : Colors.grey.shade100)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: ThemeManager().isDark.value
                        ? Colors.green.shade600
                        : Colors.green.shade300,
                    width: 1,
                  )
                : isHovered
                    ? Border.all(
                        color: ThemeManager().isDark.value
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        width: 1,
                      )
                    : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? (ThemeManager().isDark.value
                        ? Colors.green.shade600
                        : Colors.green.shade700)
                    : isHovered
                        ? (ThemeManager().isDark.value
                            ? Colors.grey.shade300
                            : Colors.grey.shade800)
                        : null,
              ),
              if (_isMenuVisibleContent) const SizedBox(width: 10),
              if (_isMenuVisibleContent)
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected || isHovered
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? (ThemeManager().isDark.value
                              ? Colors.green.shade600
                              : Colors.green.shade700)
                          : isHovered
                              ? (ThemeManager().isDark.value
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade800)
                              : null,
                    ),
                  ),
                ),
              if (_isMenuVisibleContent && isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeManager().isDark.value
                        ? Colors.green.shade600
                        : Colors.green.shade700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _isMenuVisibleContent ? 8 : 6,
        vertical: 3,
      ),
      child: InkWell(
        onTap: () {
          ThemeManager().toggleTheme();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: _isMenuVisibleContent ? 12 : 6,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                ThemeManager().isDark.value
                    ? Icons.light_mode
                    : Icons.dark_mode,
                size: 18,
                color: ThemeManager().isDark.value
                    ? Colors.green.shade600
                    : Colors.green.shade700,
              ),
              if (_isMenuVisibleContent) const SizedBox(width: 10),
              if (_isMenuVisibleContent)
                Expanded(
                  child: Text(
                    ThemeManager().isDark.value ? 'Tema Claro' : 'Tema Escuro',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ThemeManager().isDark.value
                          ? Colors.green.shade600
                          : Colors.green.shade700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
