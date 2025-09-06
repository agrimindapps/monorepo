import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/interfaces/i_premium_service.dart';
import '../../domain/entities/comentario_entity.dart';
import '../dialogs/dialogs.dart';
import '../riverpod_providers/comentarios_providers.dart';
import '../widgets/widgets.dart';

/// **COMENTARIOS CLEAN PAGE - RIVERPOD VERSION**
/// 
/// Refactored ComentariosPage following Clean Architecture principles with Riverpod.
/// This page demonstrates the complete separation of concerns and proper state management.
/// 
/// ## Architecture Highlights:
/// 
/// ### 🏗️ Clean Architecture Layers:
/// - **Presentation Layer**: This widget + Riverpod providers  
/// - **Domain Layer**: Use cases handle business logic
/// - **Data Layer**: Repositories abstract data sources
/// 
/// ### 🔄 State Management:
/// - **Riverpod StateNotifier**: Manages complex state with business logic
/// - **Computed Providers**: Derived state calculated automatically
/// - **Granular Rebuilds**: Only affected widgets rebuild on state changes
/// 
/// ### 🧩 Component Composition:
/// - **Single Responsibility**: Each widget has one clear purpose
/// - **Reusable Components**: Widgets can be used independently
/// - **Testable Architecture**: Easy to unit test individual components
/// 
/// ## Features:
/// 
/// - ✅ **Premium Integration**: Seamless premium/free tier handling
/// - ✅ **Loading States**: Skeleton loading with smooth animations  
/// - ✅ **Error Handling**: User-friendly error messages with retry
/// - ✅ **Empty States**: Contextual empty state messages
/// - ✅ **CRUD Operations**: Add, view, and delete comentarios
/// - ✅ **Filtering**: Context and tool-based filtering
/// - ✅ **Search**: Real-time search functionality
/// - ✅ **Responsive Design**: Adapts to different screen sizes
/// 
/// ## Usage:
/// 
/// ```dart
/// // General comentarios view
/// ComentariosCleanPage()
/// 
/// // Context-specific view  
/// ComentariosCleanPage(
///   pkIdentificador: 'def_123',
///   ferramenta: 'defensivos',
/// )
/// ```

class ComentariosCleanPage extends ConsumerStatefulWidget {
  /// Optional context identifier for filtering comentarios
  final String? pkIdentificador;
  
  /// Optional tool/feature identifier for filtering comentarios
  final String? ferramenta;

  const ComentariosCleanPage({
    super.key,
    this.pkIdentificador,
    this.ferramenta,
  });

  @override
  ConsumerState<ComentariosCleanPage> createState() => _ComentariosCleanPageState();
}

class _ComentariosCleanPageState extends ConsumerState<ComentariosCleanPage> {
  late final IPremiumService _premiumService;
  bool _hasInitialized = false;

  // ========================================================================
  // LIFECYCLE METHODS
  // ========================================================================

  @override
  void initState() {
    super.initState();
    _premiumService = di.sl<IPremiumService>();
    
    // Initialize data loading after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  /// Initialize data loading with proper context and tool filters
  Future<void> _initializeData() async {
    if (_hasInitialized) return;
    
    final notifier = ref.read(comentariosStateProvider.notifier);
    await notifier.initialize(
      pkIdentificador: widget.pkIdentificador,
      ferramenta: widget.ferramenta,
    );
    
    _hasInitialized = true;
  }

  // ========================================================================
  // BUILD METHODS
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            children: [
              _buildHeader(isDark),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(comentariosStateProvider);
        final filteredComentarios = ref.watch(comentariosFilteredProvider);

        if (state.isLoading && !state.hasLoaded) {
          return ComentariosHeaderWidget.loading(
            isDark: isDark,
            onInfoPressed: _showInfoDialog,
          );
        }

        return ComentariosHeaderWidget.loaded(
          totalCount: state.totalComentariosCount,
          filteredCount: filteredComentarios.length,
          filterContext: widget.pkIdentificador,
          filterTool: widget.ferramenta,
          isDark: isDark,
          onInfoPressed: _showInfoDialog,
        );
      },
    );
  }

  Widget _buildBody() {
    // Check premium access first
    if (!_premiumService.isPremium) {
      return ComentariosPremiumWidget(
        onUpgradePressed: _handlePremiumUpgrade,
      );
    }

    // Show state-based content
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(comentariosStateProvider);
        final filteredComentarios = ref.watch(comentariosFilteredProvider);

        // Loading state
        if (state.isLoading && !state.hasLoaded) {
          return const ComentariosLoadingWidget(
            itemCount: 5,
            showHeader: true,
          );
        }

        // Error state
        if (state.hasError) {
          return ComentariosErrorWidget.generic(
            error: state.error!,
            onRetry: _handleRetry,
          );
        }

        // Empty state
        if (filteredComentarios.isEmpty) {
          return ComentariosEmptyStateWidget.filtered(
            filterContext: widget.pkIdentificador,
            filterTool: widget.ferramenta,
          );
        }

        // Content state
        return ComentariosListWidget.optimized(
          comentarios: filteredComentarios,
          onComentarioTap: _handleComentarioTap,
          onComentarioDelete: _handleComentarioDelete,
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    if (!_premiumService.isPremium) {
      return ComentariosFabWidget.locked(
        onPremiumRequired: _handlePremiumUpgrade,
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final isOperating = ref.watch(
          comentariosStateProvider.select((state) => state.isOperating),
        );

        return ComentariosFabWidget.premium(
          isOperating: isOperating,
          onPressed: _handleAddComentario,
        );
      },
    );
  }

  // ========================================================================
  // EVENT HANDLERS
  // ========================================================================

  /// Handle add comentario button press
  void _handleAddComentario() {
    showDialog<void>(
      context: context,
      builder: (context) => AddComentarioDialog(
        origem: widget.ferramenta ?? 'Comentários',
        itemName: widget.pkIdentificador != null 
            ? 'Item ${widget.pkIdentificador}' 
            : 'Comentário direto',
        pkIdentificador: widget.pkIdentificador,
        ferramenta: widget.ferramenta,
        onSave: _handleSaveComentario,
      ),
    );
  }

  /// Handle save comentario from dialog
  Future<void> _handleSaveComentario(String content) async {
    final comentario = _createComentarioFromContent(content);
    
    try {
      await ref.read(comentariosStateProvider.notifier).addComentario(comentario);
      
      if (mounted) {
        _showSuccessMessage('Comentário adicionado com sucesso');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Erro ao adicionar comentário: $e');
      }
    }
  }

  /// Handle comentario tap (for future expansion)
  void _handleComentarioTap(ComentarioEntity comentario) {
    // Could navigate to detailed view, edit, etc.
    // For now, just show a brief info
    _showInfoMessage('Comentário de ${comentario.ferramenta}');
  }

  /// Handle comentario deletion
  void _handleComentarioDelete(ComentarioEntity comentario) {
    showDialog<void>(
      context: context,
      builder: (context) => DeleteComentarioDialog(
        comentario: comentario,
        onConfirm: () => _confirmDeleteComentario(comentario.id),
      ),
    );
  }

  /// Confirm comentario deletion
  Future<void> _confirmDeleteComentario(String comentarioId) async {
    try {
      await ref.read(comentariosStateProvider.notifier).deleteComentario(comentarioId);
      
      if (mounted) {
        _showSuccessMessage('Comentário excluído com sucesso');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Erro ao excluir comentário: $e');
      }
    }
  }

  /// Handle premium upgrade
  void _handlePremiumUpgrade() {
    _premiumService.navigateToPremium();
  }

  /// Handle retry after error
  Future<void> _handleRetry() async {
    await ref.read(comentariosStateProvider.notifier).loadComentariosWithFilters(
      pkIdentificador: widget.pkIdentificador,
      ferramenta: widget.ferramenta,
    );
  }

  /// Show info dialog
  void _showInfoDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => const ComentariosInfoDialog(),
    );
  }

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  /// Create ComentarioEntity from dialog content
  ComentarioEntity _createComentarioFromContent(String content) {
    final now = DateTime.now();
    return ComentarioEntity(
      id: 'TEMP_${now.millisecondsSinceEpoch}',
      idReg: 'REG_${now.millisecondsSinceEpoch}',
      titulo: _extractTitleFromContent(content),
      conteudo: content,
      ferramenta: widget.ferramenta ?? 'Comentários',
      pkIdentificador: widget.pkIdentificador ?? '',
      status: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Extract a reasonable title from content
  String _extractTitleFromContent(String content) {
    final lines = content.trim().split('\n');
    if (lines.isNotEmpty) {
      final firstLine = lines.first.trim();
      if (firstLine.length > 5 && firstLine.length <= 50) {
        return firstLine;
      }
    }
    
    // Fallback to truncated content
    if (content.length > 30) {
      return '${content.substring(0, 30)}...';
    }
    
    return 'Comentário';
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show info message
  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ========================================================================
  // FACTORY CONSTRUCTORS
  // ========================================================================

  /// Factory constructor for general comentarios view
  static ComentariosCleanPage general() {
    return const ComentariosCleanPage();
  }

  /// Factory constructor for context-specific view
  static ComentariosCleanPage forContext({
    required String pkIdentificador,
    String? ferramenta,
  }) {
    return ComentariosCleanPage(
      pkIdentificador: pkIdentificador,
      ferramenta: ferramenta,
    );
  }

  /// Factory constructor for tool-specific view
  static ComentariosCleanPage forTool({
    required String ferramenta,
  }) {
    return ComentariosCleanPage(
      ferramenta: ferramenta,
    );
  }
}