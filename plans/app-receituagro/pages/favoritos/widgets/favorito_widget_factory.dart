// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../models/favorito_model.dart';
import '../controller/favoritos_controller.dart';
import 'defensivo_favorito_grid_item.dart';
import 'defensivo_favorito_list_item.dart';
import 'favorito_diagnostico_grid_item.dart';
import 'favorito_diagnostico_list_item.dart';
import 'praga_favorito_grid_item.dart';
import 'praga_favorito_list_item.dart';

/// Abstract interface for creating favorito widgets
/// Follows Factory Pattern to eliminate switch statements
abstract class FavoritoWidgetBuilder {
  Widget buildGridWidget(
    dynamic item,
    FavoritosController controller,
    Color cardColor,
    Color borderColor,
    Color iconColor,
    bool isDark,
  );

  Widget buildListWidget(
    dynamic item,
    FavoritosController controller,
    Color iconColor,
    bool isDark,
  );

  bool canHandle(dynamic item);
  String get expectedType;
}

/// Factory for Defensivos widgets
class DefensivoWidgetBuilder implements FavoritoWidgetBuilder {
  @override
  Widget buildGridWidget(
    dynamic item,
    FavoritosController controller,
    Color cardColor,
    Color borderColor,
    Color iconColor,
    bool isDark,
  ) {
    if (item is! FavoritoDefensivoModel) {
      throw ArgumentError('Expected FavoritoDefensivoModel, got ${item.runtimeType}');
    }

    return DefensivoFavoritoGridItem(
      defensivo: item,
      onTap: () => controller.goToDefensivoDetails(item),
      isDark: isDark,
    );
  }

  @override
  Widget buildListWidget(
    dynamic item,
    FavoritosController controller,
    Color iconColor,
    bool isDark,
  ) {
    if (item is! FavoritoDefensivoModel) {
      throw ArgumentError('Expected FavoritoDefensivoModel, got ${item.runtimeType}');
    }

    return DefensivoFavoritoListItem(
      defensivo: item,
      onTap: () => controller.goToDefensivoDetails(item),
      isDark: isDark,
    );
  }

  @override
  bool canHandle(dynamic item) => item is FavoritoDefensivoModel;

  @override
  String get expectedType => 'FavoritoDefensivoModel';
}

/// Factory for Pragas widgets
class PragaWidgetBuilder implements FavoritoWidgetBuilder {
  @override
  Widget buildGridWidget(
    dynamic item,
    FavoritosController controller,
    Color cardColor,
    Color borderColor,
    Color iconColor,
    bool isDark,
  ) {
    if (item is! FavoritoPragaModel) {
      throw ArgumentError('Expected FavoritoPragaModel, got ${item.runtimeType}');
    }

    return PragaFavoritoGridItem(
      praga: item,
      onTap: () => controller.goToPragaDetails(item),
      isDark: isDark,
    );
  }

  @override
  Widget buildListWidget(
    dynamic item,
    FavoritosController controller,
    Color iconColor,
    bool isDark,
  ) {
    if (item is! FavoritoPragaModel) {
      throw ArgumentError('Expected FavoritoPragaModel, got ${item.runtimeType}');
    }

    return PragaFavoritoListItem(
      praga: item,
      onTap: () => controller.goToPragaDetails(item),
      isDark: isDark,
    );
  }

  @override
  bool canHandle(dynamic item) => item is FavoritoPragaModel;

  @override
  String get expectedType => 'FavoritoPragaModel';
}

/// Factory for Diagnosticos widgets
class DiagnosticoWidgetBuilder implements FavoritoWidgetBuilder {
  @override
  Widget buildGridWidget(
    dynamic item,
    FavoritosController controller,
    Color cardColor,
    Color borderColor,
    Color iconColor,
    bool isDark,
  ) {
    if (item is! FavoritoDiagnosticoModel) {
      throw ArgumentError('Expected FavoritoDiagnosticoModel, got ${item.runtimeType}');
    }

    return FavoritoDiagnosticoGridItem(
      diagnostico: item,
      onTap: () => controller.goToDiagnosticoDetails(item),
      isDark: isDark,
    );
  }

  @override
  Widget buildListWidget(
    dynamic item,
    FavoritosController controller,
    Color iconColor,
    bool isDark,
  ) {
    if (item is! FavoritoDiagnosticoModel) {
      throw ArgumentError('Expected FavoritoDiagnosticoModel, got ${item.runtimeType}');
    }

    return FavoritoDiagnosticoListItem(
      diagnostico: item,
      onTap: () => controller.goToDiagnosticoDetails(item),
      isDark: isDark,
    );
  }

  @override
  bool canHandle(dynamic item) => item is FavoritoDiagnosticoModel;

  @override
  String get expectedType => 'FavoritoDiagnosticoModel';
}

/// Main Factory that manages all widget builders
/// Eliminates switch statements using polymorphism
class FavoritoWidgetFactory {
  static final Map<int, FavoritoWidgetBuilder> _builders = {
    0: DefensivoWidgetBuilder(),
    1: PragaWidgetBuilder(),
    2: DiagnosticoWidgetBuilder(),
  };

  /// Build grid widget using appropriate factory
  static Widget buildGridWidget(
    dynamic item,
    int tabIndex,
    FavoritosController controller,
    Color cardColor,
    Color borderColor,
    Color iconColor,
    bool isDark,
  ) {
    final builder = _builders[tabIndex];
    
    if (builder == null) {
      return _buildErrorWidget(
        'Tab index inválido: $tabIndex',
        isGrid: true,
      );
    }

    if (!builder.canHandle(item)) {
      return _buildErrorWidget(
        'Esperado: ${builder.expectedType}, encontrado: ${_getTypeName(item)}',
        isGrid: true,
      );
    }

    try {
      return builder.buildGridWidget(item, controller, cardColor, borderColor, iconColor, isDark);
    } catch (e) {
      return _buildErrorWidget(
        'Erro ao construir widget: $e',
        isGrid: true,
      );
    }
  }

  /// Build list widget using appropriate factory
  static Widget buildListWidget(
    dynamic item,
    int tabIndex,
    FavoritosController controller,
    Color iconColor,
    bool isDark,
  ) {
    final builder = _builders[tabIndex];
    
    if (builder == null) {
      return _buildErrorWidget(
        'Tab index inválido: $tabIndex',
        isGrid: false,
      );
    }

    if (!builder.canHandle(item)) {
      return _buildErrorWidget(
        'Esperado: ${builder.expectedType}, encontrado: ${_getTypeName(item)}',
        isGrid: false,
      );
    }

    try {
      return builder.buildListWidget(item, controller, iconColor, isDark);
    } catch (e) {
      return _buildErrorWidget(
        'Erro ao construir widget: $e',
        isGrid: false,
      );
    }
  }

  /// Helper method to get type name
  static String _getTypeName(dynamic item) {
    if (item == null) return 'null';
    return item.runtimeType.toString();
  }

  /// Build error widget with consistent styling
  static Widget _buildErrorWidget(String errorMessage, {required bool isGrid}) {
    
    if (isGrid) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Erro de Tipo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade600,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Erro de Tipo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
