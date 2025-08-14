import 'package:flutter/material.dart';
import '../../constants/comentarios_design_tokens.dart';

class EmptyCommentsState extends StatelessWidget {
  const EmptyCommentsState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        padding: ComentariosDesignTokens.defaultPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ComentariosDesignTokens.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                ComentariosDesignTokens.commentIcon,
                size: 40,
                color: ComentariosDesignTokens.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum comentário ainda',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Suas anotações pessoais aparecerão aqui',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}