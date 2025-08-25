// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../const/bottom_navigator_const.dart';
import '../controllers/bottom_navigator_controller.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({
    super.key,
    this.navigatorKey,
    this.onTabSelected,
    this.overrideIndex,
  });

  final GlobalKey<NavigatorState>? navigatorKey;
  final void Function(int)? onTabSelected;
  final int? overrideIndex; // Permite sobrescrever o índice do controlador global

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Animation<double>> _animations = [];
  late BottomNavigatorController _controller;

  @override
  void initState() {
    super.initState();
    
    // Inicializa ou obtém o controlador global
    try {
      _controller = Get.find<BottomNavigatorController>();
    } catch (e) {
      _controller = Get.put(BottomNavigatorController());
    }
    
    // Atualiza o índice após o build para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.overrideIndex == null) {
        _controller.updateFromCurrentRoute();
      } else {
        _controller.setActiveIndex(widget.overrideIndex!);
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Criar animações para cada item do menu
    for (int i = 0; i < itensMenuBottom.length; i++) {
      final Animation<double> animation = Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(
            0.0,
            1.0,
            curve: Curves.elasticOut,
          ),
        ),
      );
      _animations.add(animation);
    }

    _animationController.forward();
  }

  @override
  void didUpdateWidget(BottomNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.overrideIndex != oldWidget.overrideIndex) {
      // Move as atualizações para após o build para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.overrideIndex != null) {
          _controller.setActiveIndex(widget.overrideIndex!);
        }
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void marcaItemSelecionado(int index) {
    if (_controller.selectedIndex == index) return;
    
    // Atualiza o controlador global
    _controller.setActiveIndex(index);

    // Notifica o callback se existir
    widget.onTabSelected?.call(index);

    // Resetar e iniciar a animação
    _animationController.reset();
    _animationController.forward();

    // Vibração leve para feedback tátil
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final currentIndex = _controller.selectedIndex;
      
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              iconSize: 24,
              elevation: 8,
              backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ??
                  theme.cardColor,
              selectedItemColor: const Color(0xFF2E7D32),
              unselectedItemColor:
                  theme.bottomNavigationBarTheme.unselectedItemColor ??
                      theme.disabledColor,
              items: <BottomNavigationBarItem>[
                for (int i = 0; i < itensMenuBottom.length; i++)
                  BottomNavigationBarItem(
                    icon: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: currentIndex == i ? _animations[i].value : 1.0,
                          child: Icon(itensMenuBottom[i]['icon']),
                        );
                      },
                    ),
                    activeIcon: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(itensMenuBottom[i]['icon']),
                    ),
                    label: itensMenuBottom[i]['label'],
                  ),
              ],
              currentIndex: currentIndex,
              enableFeedback: true,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal,
                color: theme.bottomNavigationBarTheme.unselectedItemColor ??
                    theme.disabledColor,
              ),
              onTap: (index) {
                marcaItemSelecionado(index);
                // Checa se deve usar navegação ou deixar o pai lidar com a mudança
                if (widget.onTabSelected != null) {
                  // Se há callback, deixa o pai lidar com a navegação
                  widget.onTabSelected!(index);
                } else if (widget.navigatorKey?.currentState != null) {
                  // Usa Navigator padrão se disponível
                  final targetRoute = itensMenuBottom[index]['page'];

                  // Limpa o stack completamente e navega para nova rota
                  try {
                    widget.navigatorKey!.currentState!.pushNamedAndRemoveUntil(
                      targetRoute,
                      (route) => false, // Remove todas as rotas
                    );
                  } catch (e) {
                    debugPrint('Navigator navigation failed: $e');
                    // Fallback para GetX com ID
                    Get.offAllNamed(targetRoute, id: 1);
                  }
                } else {
                  // Usa o controlador para navegação padrão
                  _controller.navigateToIndex(index);
                }
              },
            ),
          ),
          //_altBanner(),
        ],
      );
    });
  }

}
