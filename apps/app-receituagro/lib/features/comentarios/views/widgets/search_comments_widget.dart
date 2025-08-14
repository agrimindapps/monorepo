import 'package:flutter/material.dart';
import '../../constants/comentarios_design_tokens.dart';

class SearchCommentsWidget extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String hintText;

  const SearchCommentsWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.onClear,
    this.hintText = 'Buscar comentários...',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: ComentariosDesignTokens.getCardDecoration(context),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(
            ComentariosDesignTokens.searchIcon,
            color: ComentariosDesignTokens.primaryColor,
          ),
          suffixIcon: controller?.text.isNotEmpty == true
              ? IconButton(
                  icon: const Icon(ComentariosDesignTokens.clearIcon),
                  onPressed: onClear,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 14.0,
          ),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}