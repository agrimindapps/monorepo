// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../../constants/plantas_colors.dart';

/// Design tokens centralizados para o módulo app-plantas
/// Fornece um sistema de cores consistente e adaptável ao tema
class PlantasDesignTokens {
  // Impede instanciação da classe
  PlantasDesignTokens._();

  /// Sistema de cores primárias adaptáveis ao tema
  static Map<String, Color> cores(BuildContext context) {
    return {
      // === CORES PRIMÁRIAS ===
      'primaria': PlantasColors.primaryColor,
      'primariaDark': PlantasColors.primaryColor,
      'primariaLight': PlantasColors.primaryColor,

      // === CORES DE SUPERFÍCIE ===
      'fundo': PlantasColors.backgroundColor,
      'fundoSecundario': PlantasColors.surfaceColor,
      'fundoCard': PlantasColors.cardColor,
      'fundoElevado': PlantasColors.cardColor,
      'fundoModal': PlantasColors.surfaceColor,

      // === CORES DE TEXTO ===
      'texto': PlantasColors.textColor,
      'textoSecundario': PlantasColors.subtitleColor,
      'textoTerciario': PlantasColors.subtitleColor,
      'textoClaro': Colors.white,
      'textoInvertido': PlantasColors.textColor,

      // === CORES SEMÂNTICAS ===
      'sucesso': _getSemanticColor('success'),
      'sucessoClaro': _getSemanticColor('success').withValues(alpha: 0.2),

      'erro': PlantasColors.errorColor,
      'erroClaro': PlantasColors.errorColor.withValues(alpha: 0.2),

      'aviso': _getSemanticColor('warning'),
      'avisoClaro': _getSemanticColor('warning').withValues(alpha: 0.2),

      'info': _getSemanticColor('info'),
      'infoClaro': _getSemanticColor('info').withValues(alpha: 0.2),

      // === CORES DE BORDA E DIVISOR ===
      'borda': PlantasColors.borderColor,
      'bordaFoco': PlantasColors.primaryColor,
      'divisor': PlantasColors.borderColor,

      // === CORES DE SOMBRA E OVERLAY ===
      'sombra': PlantasColors.shadowColor,
      'overlay': ThemeManager().isDark.value
          ? Colors.black.withValues(alpha: 0.6)
          : Colors.black.withValues(alpha: 0.4),

      // === CORES DE ESTADO ===
      'desabilitado': PlantasColors.subtitleColor,
      'desabilitadoFundo': PlantasColors.borderColor,
      'hover': PlantasColors.subtitleColor.withValues(alpha: 0.04),
      'pressed': PlantasColors.subtitleColor.withValues(alpha: 0.08),
    };
  }

  /// Cores específicas para tipos de espaços (independentes do tema)
  static Map<String, Color> coresEspacos() {
    return {
      'interno': const Color(0xFF4CAF50), // Verde
      'externo': const Color(0xFF2196F3), // Azul
      'jardim': const Color(0xFF8BC34A), // Verde claro
      'varanda': const Color(0xFFFF9800), // Laranja
      'escritorio': const Color(0xFF9C27B0), // Roxo
      'cozinha': const Color(0xFFE91E63), // Rosa
      'banheiro': const Color(0xFF00BCD4), // Ciano
      'quarto': const Color(0xFF673AB7), // Roxo escuro
      'sala': const Color(0xFFFF5722), // Vermelho alaranjado
      'default': const Color(0xFF607D8B), // Cinza azulado
    };
  }

  /// Cores para status de tarefas (independentes do tema)
  static Map<String, Color> coresStatus() {
    return {
      'pendente': const Color(0xFFFF9800), // Laranja
      'concluida': const Color(0xFF4CAF50), // Verde
      'atrasada': const Color(0xFFF44336), // Vermelho
      'agendada': const Color(0xFF2196F3), // Azul
      'cancelada': const Color(0xFF9E9E9E), // Cinza
    };
  }

  /// Gradientes adaptativos
  static Map<String, LinearGradient> gradientes(BuildContext context) {
    final cores = PlantasDesignTokens.cores(context);
    final isDark = ThemeManager().isDark.value;

    return {
      'primario': LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cores['primaria']!,
          cores['primariaDark']!,
        ],
      ),
      'fundo': LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          cores['fundo']!,
          cores['fundoSecundario']!,
        ],
      ),
      'sucesso': LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cores['sucesso']!,
          cores['sucesso']!.withValues(alpha: 0.8),
        ],
      ),
      'premium': LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFFFFD700), // Dourado
                const Color(0xFFFFB300), // Dourado escuro
              ]
            : [
                const Color(0xFFFFB300), // Dourado escuro
                const Color(0xFFFF8F00), // Âmbar
              ],
      ),
    };
  }

  /// Dimensões e espaçamentos padrão
  static const Map<String, double> dimensoes = {
    // Paddings
    'paddingXS': 4.0,
    'paddingS': 8.0,
    'paddingM': 16.0,
    'paddingL': 24.0,
    'paddingXL': 32.0,

    // Margins
    'marginXS': 4.0,
    'marginS': 8.0,
    'marginM': 16.0,
    'marginL': 24.0,
    'marginXL': 32.0,

    // Border Radius
    'radiusXS': 4.0,
    'radiusS': 8.0,
    'radiusM': 12.0,
    'radiusL': 16.0,
    'radiusXL': 24.0,
    'radiusCircular': 50.0,

    // Elevations
    'elevationS': 2.0,
    'elevationM': 4.0,
    'elevationL': 8.0,
    'elevationXL': 16.0,

    // Icon Sizes
    'iconXS': 16.0,
    'iconS': 20.0,
    'iconM': 24.0,
    'iconL': 32.0,
    'iconXL': 48.0,

    // Heights
    'buttonHeight': 48.0,
    'inputHeight': 56.0,
    'appBarHeight': 56.0,
    'bottomNavHeight': 60.0,
  };

  /// Text Styles adaptáveis ao tema
  static Map<String, TextStyle> textStyles(BuildContext context) {
    final cores = PlantasDesignTokens.cores(context);
    final textTheme = Theme.of(context).textTheme;

    return {
      // Headers
      'h1': textTheme.headlineLarge?.copyWith(
            color: cores['texto'],
            fontWeight: FontWeight.bold,
          ) ??
          TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: cores['texto'],
          ),

      'h2': textTheme.headlineMedium?.copyWith(
            color: cores['texto'],
            fontWeight: FontWeight.w600,
          ) ??
          TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: cores['texto'],
          ),

      'h3': textTheme.headlineSmall?.copyWith(
            color: cores['texto'],
            fontWeight: FontWeight.w600,
          ) ??
          TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: cores['texto'],
          ),

      // Body
      'bodyLarge': textTheme.bodyLarge?.copyWith(
            color: cores['texto'],
          ) ??
          TextStyle(
            fontSize: 16,
            color: cores['texto'],
          ),

      'bodyMedium': textTheme.bodyMedium?.copyWith(
            color: cores['texto'],
          ) ??
          TextStyle(
            fontSize: 14,
            color: cores['texto'],
          ),

      'bodySmall': textTheme.bodySmall?.copyWith(
            color: cores['textoSecundario'],
          ) ??
          TextStyle(
            fontSize: 12,
            color: cores['textoSecundario'],
          ),

      // Labels
      'labelLarge': textTheme.labelLarge?.copyWith(
            color: cores['texto'],
            fontWeight: FontWeight.w500,
          ) ??
          TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: cores['texto'],
          ),

      'labelMedium': textTheme.labelMedium?.copyWith(
            color: cores['textoSecundario'],
          ) ??
          TextStyle(
            fontSize: 12,
            color: cores['textoSecundario'],
          ),

      // Especiais
      'button': TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: cores['textoClaro'],
      ),

      'caption': TextStyle(
        fontSize: 10,
        color: cores['textoTerciario'],
      ),
    };
  }

  /// Box Decorations pré-definidas
  static Map<String, BoxDecoration> decorations(BuildContext context) {
    final cores = PlantasDesignTokens.cores(context);

    return {
      'card': BoxDecoration(
        color: cores['fundoCard'],
        borderRadius: BorderRadius.circular(dimensoes['radiusM']!),
        border: Border.all(
          color: cores['borda']!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cores['sombra']!,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      'cardElevated': BoxDecoration(
        color: cores['fundoElevado'],
        borderRadius: BorderRadius.circular(dimensoes['radiusL']!),
        boxShadow: [
          BoxShadow(
            color: cores['sombra']!,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      'input': BoxDecoration(
        color: cores['fundoSecundario'],
        borderRadius: BorderRadius.circular(dimensoes['radiusS']!),
        border: Border.all(
          color: cores['borda']!,
          width: 1,
        ),
      ),
      'inputFocused': BoxDecoration(
        color: cores['fundoSecundario'],
        borderRadius: BorderRadius.circular(dimensoes['radiusS']!),
        border: Border.all(
          color: cores['bordaFoco']!,
          width: 2,
        ),
      ),
    };
  }

  /// Métodos de conveniência para cores específicas
  static Color corPrimaria(BuildContext context) {
    return PlantasColors.primaryColor;
  }

  static Color corFundo(BuildContext context) {
    return PlantasColors.backgroundColor;
  }

  static Color corTexto(BuildContext context) {
    return PlantasColors.textColor;
  }

  static Color corSucesso(BuildContext context) {
    return const Color(0xFF4CAF50);
  }

  static Color corErro(BuildContext context) {
    return const Color(0xFFF44336);
  }

  static Color corAviso(BuildContext context) {
    return const Color(0xFFFF9800);
  }

  /// Verifica se o tema atual é escuro
  static bool isDarkMode(BuildContext context) {
    return ThemeManager().isDark.value;
  }

  /// Retorna cores semânticas adaptáveis ao tema
  static Color _getSemanticColor(String type) {
    final isDark = ThemeManager().isDark.value;

    switch (type) {
      case 'success':
        return isDark
            ? const Color(0xFF4CAF50) // Verde mais claro para tema escuro
            : const Color(0xFF2E7D32); // Verde mais escuro para tema claro
      case 'warning':
        return isDark
            ? const Color(0xFFFFB74D) // Laranja mais claro para tema escuro
            : const Color(0xFFE65100); // Laranja mais escuro para tema claro
      case 'info':
        return isDark
            ? const Color(0xFF64B5F6) // Azul mais claro para tema escuro
            : const Color(0xFF1565C0); // Azul mais escuro para tema claro
      default:
        return isDark ? Colors.white : Colors.black;
    }
  }
}
