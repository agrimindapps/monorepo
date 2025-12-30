import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// PetiVeti Page Header - Reusable header component for internal pages
///
/// Provides consistent styling across all internal pages with:
/// - Primary color background with rounded corners
/// - Icon, title and subtitle
/// - Optional back button
/// - Optional action widgets
class PetivetiPageHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final String? semanticLabel;
  final String? semanticHint;
  /// Rota de fallback para navegação quando não há página anterior
  /// Por padrão vai para /activities
  final String fallbackRoute;

  const PetivetiPageHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
    this.semanticLabel,
    this.semanticHint,
    this.fallbackRoute = '/activities',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 9,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (showBackButton) ...[
              _buildBackButton(context),
              const SizedBox(width: 8),
            ],
            Semantics(
              label: semanticLabel ?? 'Seção de $title',
              hint: semanticHint ?? 'Página para gerenciar $title',
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 19,
                ),
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
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Semantics(
      label: 'Voltar',
      hint: 'Retornar para a página anterior',
      button: true,
      child: InkWell(
        onTap: onBackPressed ?? () {
          // Tenta usar o Navigator.pop se houver histórico
          // Caso contrário, usa GoRouter para ir para a rota de fallback
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go(fallbackRoute);
          }
        },
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
