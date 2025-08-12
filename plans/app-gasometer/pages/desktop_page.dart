// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/themes/manager.dart';
import '../services/config_service.dart';
import 'about/index.dart';
import 'cadastros/abastecimento_page/widgets/abastecimento_page_widget.dart';
import 'cadastros/database_page.dart';
import 'cadastros/despesas_page/widgets/despesas_page_widget.dart';
import 'cadastros/manutencoes_page/widgets/manutencoes_page_widget.dart';
import 'cadastros/odometro_page/widgets/odometro_page_widget.dart';
import 'cadastros/veiculos_page/widgets/veiculos_page_widget.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'promo_page.dart';
import 'resultados/estatisticas_veiculos_page.dart';
import 'resultados/graficos_page.dart';

class DesktopPageMain extends StatefulWidget {
  const DesktopPageMain({super.key});

  @override
  State<DesktopPageMain> createState() => _DesktopPageMainState();
}

class _DesktopPageMainState extends State<DesktopPageMain> {
  final PageController _pageControllerDesktop = PageController();
  bool _isMenuExpanded = true;
  bool _isMenuVisibleContent = true;
  int _selectedIndex = 0;
  int? _hoveredIndex;
  bool _showingPromoPage = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb && !Get.isRegistered<ConfigService>()) {
      Get.putAsync(() => ConfigService().init());
    }
  }

  Widget _buildPageDesktop(int index) {
    if (_showingPromoPage) {
      return const PromoCarPage();
    }

    switch (index) {
      case 0:
        return const VeiculosPage();
      case 1:
        return const AbastecimentoPage();
      case 2:
        return const OdometroPage();
      case 3:
        return const ManutencoesPage();
      case 4:
        return const DespesasPage();
      case 5:
        return const OptionsPage();
      case 6:
        return const HomePageCar();
      case 7:
        return const GraficosCarPage();
      case 8:
        _showingPromoPage = true;
        return const PromoCarPage();
      case 9:
        return const EstatisticasVeiculosPage();
      case 10:
        return const DatabaseContentPage();
      case 11:
        return const LoginPage();
      default:
        return const VeiculosPage();
    }
  }

  void _togglePromoMode() async {
    if (!kIsWeb) return;

    await ConfigService.to.togglePromoMode();

    setState(() {
      _showingPromoPage = ConfigService.to.isPromoMode;
      if (_showingPromoPage) {
        _selectedIndex = 8;
      }
    });
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
        Obx(
          () => Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isMenuExpanded ? 320 : 72,
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
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 26,
                              height: 26,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.car_rental,
                                size: 26,
                                color: ThemeManager().isDark.value
                                    ? Colors.amber.shade600
                                    : Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ),
                        if (_isMenuVisibleContent) const SizedBox(width: 6),
                        if (_isMenuVisibleContent)
                          Text(
                            'GasOMeter',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: ThemeManager().isDark.value
                                  ? Colors.amber.shade600
                                  : Colors.blue.shade800,
                            ),
                          ),
                        if (_isMenuVisibleContent) const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildGroupTitle(
                                'GERENCIAMENTO', Icons.directions_car),
                            _buildNavItem(
                                0, Icons.directions_car_outlined, 'Veículos'),
                            _buildNavItem(
                              1,
                              Icons.local_gas_station_outlined,
                              'Abastecimentos',
                            ),
                            _buildNavItem(2, Icons.speed_outlined, 'Odômetro'),
                            _buildNavItem(
                                3, Icons.build_outlined, 'Manutenções'),
                            _buildNavItem(
                                4, Icons.receipt_outlined, 'Despesas'),
                            _buildDivider(),
                            _buildGroupTitle('RESULTADOS', Icons.analytics),
                            _buildNavItem(7, Icons.bar_chart, 'Gráficos'),
                            _buildNavItem(
                                9, Icons.summarize_outlined, 'Estatísticas'),
                          ],
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildGroupTitle('SISTEMA', Icons.settings),
                    _buildNavItem(10, Icons.data_object, 'Database'),
                    _buildNavItem(6, Icons.ac_unit_sharp, 'Promo Page'),
                    _buildNavItem(6, Icons.sync_outlined, 'Sincronizar'),
                    _buildNavItem(5, Icons.settings_outlined, 'Configurações'),
                    _buildNavItem(11, Icons.login, 'Login'),
                    _buildThemeToggle(),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
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
                          Future.delayed(const Duration(milliseconds: 150), () {
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
                            ? Colors.amber.shade600
                            : Colors.blue.shade800,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
              childCount: 20,
            ),
          ),
        ),
      ],
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
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: InkWell(
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
                    ? Colors.amber.withAlpha(38)
                    : Colors.blue.shade50)
                : isHovered
                    ? (ThemeManager().isDark.value
                        ? Colors.grey.shade800.withAlpha(128)
                        : Colors.grey.shade100)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: ThemeManager().isDark.value
                        ? Colors.amber.shade600
                        : Colors.blue.shade300,
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
                        ? Colors.amber.shade600
                        : Colors.blue.shade700)
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
                              ? Colors.amber.shade600
                              : Colors.blue.shade700)
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
                        ? Colors.amber.shade600
                        : Colors.blue.shade700,
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
                    ? Colors.amber.shade600
                    : Colors.blue.shade700,
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
                          ? Colors.amber.shade600
                          : Colors.blue.shade700,
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
