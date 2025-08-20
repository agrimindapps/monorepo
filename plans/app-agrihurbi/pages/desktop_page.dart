// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import 'auth/login_page.dart'; // Adicionando import da página de login
import 'calc/calculos_page.dart';
import 'config_page.dart';
import 'home_agricultura_page.dart';
import 'home_pecuaria_page.dart';
import 'pluviometro/home_page.dart';
import 'promo/promo_page.dart';
import 'settings_page.dart';

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

  // Mapa para rastrear o estado de hover dos itens de menu
  final Map<int, bool> _hoveredItems = {};

  // Mapa para rastrear o estado de hover dos títulos de grupo
  final Map<String, bool> _hoveredGroups = {};

  // Controle de hover para o botão de toggle
  bool _isToggleHovered = false;

  Widget _buildPageDesktop(int index) {
    switch (index) {
      case 0:
        return const AgriculturaHomepage();
      case 1:
        return const PecuariaHomepage();
      case 2:
        return const CalculosPage();
      case 3:
        return const PluviometriaHome();
      case 4:
        return const ConfigPage();
      case 5:
        return const PromoPage();
      case 6:
        return const LoginPage(); // Nova página de login
      case 7:
        return const SettingsPage(); // Nova página de configurações avançadas
      default:
        return const PecuariaHomepage();
    }
  }

  @override
  void dispose() {
    _pageControllerDesktop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Menu de navegação com grupos
        Obx(
          () => Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isMenuExpanded ? 280 : 68, // Reduzindo a largura
                height: double.infinity,
                decoration: BoxDecoration(
                  color: ThemeManager().isDark.value
                      ? const Color(0xFF18181B)
                      : Colors.white,
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
                    // Logo section
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(
                              14, 6, 6, 6), // Reduzido padding
                          child: Image.asset(
                            'assets/imagens/others/logo.png',
                            width: 28, // Reduzido tamanho
                            height: 28, // Reduzido tamanho
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.agriculture,
                              size: 28, // Reduzido tamanho
                              color: ThemeManager().isDark.value
                                  ? Colors.green.shade600
                                  : Colors.green.shade800,
                            ),
                          ),
                        ),
                        if (_isMenuVisibleContent) ...[
                          const SizedBox(width: 6), // Reduzido espaçamento
                          Text(
                            'AgriHurbi',
                            style: TextStyle(
                              fontSize: 16, // Reduzido tamanho da fonte
                              fontWeight: FontWeight.bold,
                              color: ThemeManager().isDark.value
                                  ? Colors.green.shade600
                                  : Colors.green.shade800,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20), // Reduzido espaçamento

                    // Conteúdo do menu com rolagem
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Grupo 1: Agricultura
                            _buildGroupTitle('AGRICULTURA', Icons.agriculture),
                            _buildNavItem(0, Icons.grass, 'Culturas'),

                            _buildDivider(), // Divisor entre grupos

                            // Grupo 2: Pecuária
                            _buildGroupTitle('PECUÁRIA', Icons.pets),
                            _buildNavItem(1, Icons.pets_outlined, 'Animais'),

                            _buildDivider(), // Divisor entre grupos

                            // Grupo 3: Cálculos
                            _buildGroupTitle('CÁLCULOS', Icons.calculate),
                            _buildNavItem(2, Icons.calculate_outlined,
                                'Calculadora Agrícola'),

                            _buildDivider(), // Divisor entre grupos

                            // Grupo 4: Ferramentas
                            _buildGroupTitle('FERRAMENTAS', Icons.build),
                            _buildNavItem(
                                3, Icons.handyman_outlined, 'Implementos'),
                            _buildNavItem(
                                3, Icons.water_drop_outlined, 'Pluviômetro'),
                          ],
                        ),
                      ),
                    ),

                    // Divisor antes do grupo Sistema
                    _buildDivider(),

                    // Grupo 5: Sistema (fixo na parte inferior)
                    _buildGroupTitle('SISTEMA', Icons.settings),
                    _buildNavItem(4, Icons.settings_outlined, 'Configurações'),
                    _buildNavItem(4, Icons.person_outline, 'Perfil'),
                    _buildNavItem(7, Icons.tune, 'Configurações Avançadas'),
                    _buildNavItem(5, Icons.public, 'Página Promocional'),
                    _buildNavItem(
                        6, Icons.login, 'Login'), // Adicionando item de login

                    const SizedBox(height: 60), // Espaço para o botão de toggle
                  ],
                ),
              ),
              // Toggle Button posicionado na borda
              Positioned(
                bottom: 20, // Ajustado para ficar mais próximo da borda
                right: -15,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isToggleHovered = true),
                  onExit: (_) => setState(() => _isToggleHovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32, // Reduzido tamanho
                    height: 32, // Reduzido tamanho
                    decoration: BoxDecoration(
                      color: _isToggleHovered
                          ? (ThemeManager().isDark.value
                              ? Colors.grey.shade900
                              : Colors.green.shade50)
                          : (ThemeManager().isDark.value
                              ? Colors.black
                              : const Color(0xFFF7FAFC)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isToggleHovered
                            ? (ThemeManager().isDark.value
                                ? Colors.green.shade700
                                : Colors.green.shade300)
                            : (ThemeManager().isDark.value
                                ? Colors.grey.shade900
                                : Colors.grey.shade200),
                        width: _isToggleHovered ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isToggleHovered
                              ? Colors.grey.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: _isToggleHovered ? 2 : 1,
                          blurRadius: _isToggleHovered ? 3 : 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 16, // Reduzido tamanho
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
                      icon: AnimatedScale(
                        scale: _isToggleHovered ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: AnimatedRotation(
                          turns: _isMenuExpanded ? 0 : 0.5,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            _isMenuExpanded
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                            color: _isToggleHovered
                                ? (ThemeManager().isDark.value
                                    ? Colors.green.shade500
                                    : Colors.green.shade700)
                                : (ThemeManager().isDark.value
                                    ? Colors.green.shade600
                                    : Colors.green.shade800),
                            size: _isToggleHovered ? 18 : 16,
                          ),
                        ),
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
              childCount: 8,
            ),
          ),
        ),
      ],
    );
  }

  // Método para criar divisores entre grupos
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

  // Método para criar títulos de grupo
  Widget _buildGroupTitle(String title, IconData icon) {
    if (!_isMenuVisibleContent) {
      return Obx(
        () => Divider(
          color: ThemeManager().isDark.value
              ? Colors.grey.shade800
              : Colors.grey.shade200,
          height: 16, // Reduzido altura
          thickness: 1,
        ),
      );
    }

    final bool isHovered = _hoveredGroups[title] ?? false;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredGroups[title] = true),
      onExit: (_) => setState(() => _hoveredGroups[title] = false),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 6), // Reduzido padding
        child: Row(
          children: [
            AnimatedScale(
              scale: isHovered ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                icon,
                size: 12, // Reduzido tamanho
                color: isHovered
                    ? (ThemeManager().isDark.value
                        ? Colors.green.shade500
                        : Colors.green.shade700)
                    : (ThemeManager().isDark.value
                        ? Colors.grey.shade400
                        : Colors.grey.shade600),
              ),
            ),
            const SizedBox(width: 8), // Reduzido espaçamento
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11, // Reduzido tamanho da fonte
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8, // Adicionado letter spacing
                color: isHovered
                    ? (ThemeManager().isDark.value
                        ? Colors.green.shade500
                        : Colors.green.shade700)
                    : (ThemeManager().isDark.value
                        ? Colors.grey.shade400
                        : Colors.grey.shade600),
              ),
              child: Text(title),
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir os itens do menu
  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _selectedIndex == index;
    final bool isHovered = _hoveredItems[index] ?? false;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredItems[index] = true),
      onExit: (_) => setState(() => _hoveredItems[index] = false),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          _pageControllerDesktop.jumpToPage(index);
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
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.green.shade50)
                : isHovered
                    ? (ThemeManager().isDark.value
                        ? Colors.green.withValues(alpha: 0.08)
                        : Colors.green.shade50.withValues(alpha: 0.6))
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
                            ? Colors.green.shade900.withValues(alpha: 0.3)
                            : Colors.green.shade200,
                        width: 1,
                      )
                    : null,
          ),
          child: Row(
            children: [
              AnimatedScale(
                scale: isHovered && !isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  icon,
                  size: 18,
                  color: (isSelected || isHovered)
                      ? (ThemeManager().isDark.value
                          ? Colors.green.shade600
                          : Colors.green.shade700)
                      : null,
                ),
              ),
              if (_isMenuVisibleContent) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: (isSelected || isHovered)
                          ? (ThemeManager().isDark.value
                              ? Colors.green.shade600
                              : Colors.green.shade700)
                          : null,
                    ),
                  ),
                ),
                if (isSelected)
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
            ],
          ),
        ),
      ),
    );
  }
}
