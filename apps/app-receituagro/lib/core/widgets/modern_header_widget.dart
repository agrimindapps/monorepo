import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import '../navigation/app_navigation_provider.dart';

class ModernHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leftIcon;
  final IconData? rightIcon;
  final VoidCallback? onRightIconPressed;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final bool showActions;
  final bool isDark;
  final List<Widget>? additionalActions;

  const ModernHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leftIcon,
    this.rightIcon,
    this.onRightIconPressed,
    this.onBackPressed,
    this.showBackButton = false,
    this.showActions = false,
    required this.isDark,
    this.additionalActions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2E7D32),
                  const Color(0xFF1B5E20),
                ]
              : [
                  const Color(0xFF4CAF50),
                  const Color(0xFF388E3C),
                ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.2),
            blurRadius: 9,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: () => _handleBackPress(context),
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_outlined,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                leftIcon,
                color: Colors.white,
                size: 19,
              ),
            ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (showActions) ...[
            const SizedBox(width: 13),
            if (additionalActions != null) ...[
              ...additionalActions!.map((action) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: action,
                    ),
                  )),
            ],
            if (rightIcon != null || onRightIconPressed != null)
              GestureDetector(
                onTap: onRightIconPressed,
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    rightIcon ?? Icons.more_vert,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Manipula o clique do botão voltar com detecção automática do sistema de navegação
  void _handleBackPress(BuildContext context) {
    // Se há callback customizado fornecido, usa ele primeiro
    if (onBackPressed != null) {
      onBackPressed!();
      return;
    }

    // Detecta automaticamente qual sistema de navegação usar
    _intelligentNavigationBack(context);
  }

  /// Sistema inteligente de navegação que detecta automaticamente a melhor abordagem
  void _intelligentNavigationBack(BuildContext context) {
    try {
      // Tenta usar AppNavigationProvider primeiro (sistema preferido)
      final appNavProvider = context.read<AppNavigationProvider>();
      
      // Se tem páginas na pilha do AppNavigationProvider, use ele
      if (appNavProvider.pageStack.length > 1) {
        final success = appNavProvider.goBack();
        if (success) {
          return; // Sucesso com AppNavigationProvider
        }
      }
    } catch (e) {
      // AppNavigationProvider não disponível no contexto, continua para fallback
    }

    // Fallback 1: Tenta usar AppNavigationProvider via GetIt
    try {
      final appNavProvider = GetIt.instance<AppNavigationProvider>();
      if (appNavProvider.pageStack.length > 1) {
        final success = appNavProvider.goBack();
        if (success) {
          return; // Sucesso com GetIt
        }
      }
    } catch (e) {
      // GetIt não tem AppNavigationProvider configurado, continua
    }

    // Fallback 2: Verifica se pode fazer pop na pilha tradicional do Navigator
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    // Fallback 3: Se nada funcionar, tenta voltar para a página principal
    try {
      final appNavProvider = GetIt.instance<AppNavigationProvider>();
      appNavProvider.goBackToMain();
    } catch (e) {
      // Último recurso: não faz nada para evitar crash
      debugPrint('⚠️ ModernHeaderWidget: Não foi possível navegar de volta - $e');
    }
  }
}
