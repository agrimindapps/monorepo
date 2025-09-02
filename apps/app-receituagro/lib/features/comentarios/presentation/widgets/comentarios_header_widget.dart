import 'package:flutter/material.dart';

import '../../../core/widgets/modern_header_widget.dart';

/// **COMENTARIOS HEADER WIDGET**
/// 
/// Specialized header widget for the Comentarios feature.
/// Provides contextual information about the current comentarios view.
/// 
/// ## Features:
/// 
/// - **Dynamic Subtitle**: Shows current count and context information
/// - **Loading State**: Displays loading message during data fetch
/// - **Filter Awareness**: Reflects applied filters in subtitle
/// - **Info Action**: Optional info button for feature explanation
/// - **Consistent Design**: Follows app-receituagro design system

class ComentariosHeaderWidget extends StatelessWidget {
  final bool isLoading;
  final int totalCount;
  final int filteredCount;
  final String? filterContext;
  final String? filterTool;
  final bool isDark;
  final VoidCallback? onInfoPressed;

  const ComentariosHeaderWidget({
    super.key,
    required this.isLoading,
    required this.totalCount,
    required this.filteredCount,
    this.filterContext,
    this.filterTool,
    required this.isDark,
    this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ModernHeaderWidget(
      title: 'Comentários',
      subtitle: _buildSubtitle(),
      leftIcon: Icons.comment_outlined,
      showBackButton: false,
      showActions: true,
      isDark: isDark,
      rightIcon: Icons.info_outline,
      onRightIconPressed: onInfoPressed,
    );
  }

  String _buildSubtitle() {
    if (isLoading) {
      return 'Carregando comentários...';
    }

    // Build contextual subtitle based on filters
    if (_hasFilters) {
      return _buildFilteredSubtitle();
    }

    // General subtitle
    return _buildGeneralSubtitle();
  }

  bool get _hasFilters {
    return (filterContext?.isNotEmpty == true) || (filterTool?.isNotEmpty == true);
  }

  String _buildFilteredSubtitle() {
    final parts = <String>[];
    
    // Add count information
    if (filteredCount > 0) {
      parts.add('$filteredCount comentários');
    } else {
      parts.add('Nenhum comentário');
    }

    // Add context information
    if (_hasFilters) {
      final filterParts = <String>[];
      
      if (filterContext?.isNotEmpty == true) {
        filterParts.add('contexto específico');
      }
      
      if (filterTool?.isNotEmpty == true) {
        filterParts.add(filterTool!.toLowerCase());
      }
      
      if (filterParts.isNotEmpty) {
        parts.add('para ${filterParts.join(' e ')}');
      }
    }

    return parts.join(' ');
  }

  String _buildGeneralSubtitle() {
    if (totalCount > 0) {
      return '$totalCount comentários';
    } else {
      return 'Suas anotações pessoais';
    }
  }

  /// Factory constructor for loading state
  static ComentariosHeaderWidget loading({
    required bool isDark,
    VoidCallback? onInfoPressed,
  }) {
    return ComentariosHeaderWidget(
      isLoading: true,
      totalCount: 0,
      filteredCount: 0,
      isDark: isDark,
      onInfoPressed: onInfoPressed,
    );
  }

  /// Factory constructor for empty state
  static ComentariosHeaderWidget empty({
    required bool isDark,
    String? filterContext,
    String? filterTool,
    VoidCallback? onInfoPressed,
  }) {
    return ComentariosHeaderWidget(
      isLoading: false,
      totalCount: 0,
      filteredCount: 0,
      filterContext: filterContext,
      filterTool: filterTool,
      isDark: isDark,
      onInfoPressed: onInfoPressed,
    );
  }

  /// Factory constructor for loaded state
  static ComentariosHeaderWidget loaded({
    required int totalCount,
    required int filteredCount,
    required bool isDark,
    String? filterContext,
    String? filterTool,
    VoidCallback? onInfoPressed,
  }) {
    return ComentariosHeaderWidget(
      isLoading: false,
      totalCount: totalCount,
      filteredCount: filteredCount,
      filterContext: filterContext,
      filterTool: filterTool,
      isDark: isDark,
      onInfoPressed: onInfoPressed,
    );
  }
}