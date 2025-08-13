// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

class DefensivoAppBarWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final double fontSize;
  final bool isFavorite;
  final VoidCallback onBackPressed;
  final VoidCallback onFavoriteToggle;
  final Function(double) onFontSizeChanged;

  const DefensivoAppBarWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fontSize,
    required this.isFavorite,
    required this.onBackPressed,
    required this.onFavoriteToggle,
    required this.onFontSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: _buildLiquidGlassDecoration(context, isDark),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _buildBackButton(context, isDark),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTitleSection(context, isDark),
          ),
          const SizedBox(width: 8),
          _buildActions(context, isDark),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return Container(
      decoration: _buildGlassButtonDecoration(context, isDark),
      child: IconButton(
        icon: Icon(
          FontAwesome.arrow_left_solid,
          color: _getTextColor(context, isDark).withValues(alpha: 0.9),
          size: 20,
        ),
        onPressed: onBackPressed,
        tooltip: 'Voltar',
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Detalhes do Defensivo',
          style: TextStyle(
            color: _getTextColor(context, isDark),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFontSizeControls(context, isDark),
        const SizedBox(width: 10),
        _buildFavoriteButton(context, isDark),
      ],
    );
  }

  Widget _buildFontSizeControls(BuildContext context, bool isDark) {
    return Container(
      decoration: _buildGlassButtonDecoration(context, isDark),
      child: PopupMenuButton<double>(
        tooltip: 'Ajustar tamanho da fonte',
        position: PopupMenuPosition.under,
        offset: const Offset(0, 10),
        onSelected: (double size) {
          onFontSizeChanged(size);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<double>>[
          _buildPopupMenuItem(12, 'Pequena', context, isDark),
          _buildPopupMenuItem(14, 'Normal', context, isDark),
          _buildPopupMenuItem(16, 'Grande', context, isDark),
          _buildPopupMenuItem(18, 'Maior', context, isDark),
          _buildPopupMenuItem(20, 'Muito grande', context, isDark),
        ],
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            FontAwesome.text_height_solid,
            color: _getTextColor(context, isDark).withValues(alpha: 0.9),
            size: 20,
          ),
        ),
      ),
    );
  }

  PopupMenuEntry<double> _buildPopupMenuItem(
      double value, String text, BuildContext context, bool isDark) {
    final currentFontSize = fontSize;
    return PopupMenuItem<double>(
      value: value,
      child: Row(
        children: [
          Icon(
            Icons.check,
            color: currentFontSize == value
                ? _getPrimaryColor()
                : Colors.transparent,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: _getTextColor(context, isDark),
              fontWeight: currentFontSize == value
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: isFavorite
          ? _buildGlassFavoriteDecoration(context, isDark)
          : _buildGlassButtonDecoration(context, isDark),
      child: IconButton(
        splashRadius: 20,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            isFavorite
                ? FontAwesome.heart_solid
                : FontAwesome.heart,
            key: ValueKey(isFavorite),
            color: isFavorite
                ? _getPrimaryColor().withValues(alpha: 0.9)
                : _getSubtitleColor(context, isDark).withValues(alpha: 0.8),
            size: 20,
          ),
        ),
        onPressed: onFavoriteToggle,
        tooltip: isFavorite
            ? 'Remover dos favoritos'
            : 'Adicionar aos favoritos',
      ),
    );
  }

  // Helper methods for styling
  Color _getTextColor(BuildContext context, bool isDark) {
    return isDark ? Colors.white : Colors.grey.shade800;
  }

  Color _getSubtitleColor(BuildContext context, bool isDark) {
    return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  Color _getPrimaryColor() {
    // Using green color as the app's predominant color
    return const Color(0xFF2E7D32);
  }

  /// Decoração principal do app bar com efeito Liquid Glass
  BoxDecoration _buildLiquidGlassDecoration(BuildContext context, bool isDark) {
    return BoxDecoration(
      // Vidro translúcido com blur
      color: isDark 
          ? Colors.black.withValues(alpha: 0.15)
          : Colors.white.withValues(alpha: 0.15),
      // Gradiente sutil para efeito vítreo
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.2),
          isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.1),
        ],
      ),
      // Removido: border para efeito mais limpo
      // Blur effect seria aplicado via BackdropFilter no widget pai
    );
  }

  /// Decoração dos botões com efeito de vidro
  BoxDecoration _buildGlassButtonDecoration(BuildContext context, bool isDark) {
    return BoxDecoration(
      // Vidro translúcido
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.2),
      // Botões totalmente arredondados (circulares)
      borderRadius: BorderRadius.circular(50),
      // Removido: border para efeito mais limpo
      // Sombra suave para profundidade
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        // Highlight para efeito brilhante
        BoxShadow(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.6),
          blurRadius: 4,
          offset: const Offset(0, -1),
        ),
      ],
    );
  }

  /// Decoração especial para botão favorito ativo
  BoxDecoration _buildGlassFavoriteDecoration(BuildContext context, bool isDark) {
    return BoxDecoration(
      // Vidro com tint da cor primária (verde)
      color: _getPrimaryColor().withValues(alpha: 0.15),
      // Botão favorito totalmente arredondado (circular)
      borderRadius: BorderRadius.circular(50),
      // Removido: border para efeito mais limpo
      // Sombra com cor primária
      boxShadow: [
        BoxShadow(
          color: _getPrimaryColor().withValues(alpha: 0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        // Highlight brilhante
        BoxShadow(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.8),
          blurRadius: 6,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }
}
