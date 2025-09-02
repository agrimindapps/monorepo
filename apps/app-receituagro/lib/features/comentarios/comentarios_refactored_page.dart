import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection_container.dart' as di;
import '../../core/interfaces/i_premium_service.dart';
import '../../core/widgets/modern_header_widget.dart';
import 'domain/entities/comentario_entity.dart';
import 'presentation/providers/comentarios_provider.dart';

/// **COMENTARIOS REFACTORED PAGE**
/// 
/// Refactored ComentariosPage with Clean Architecture principles
/// while maintaining Provider compatibility for backward compatibility.
/// 
/// This version demonstrates:
/// - Component decomposition
/// - Separation of concerns
/// - Clean state management
/// - Error handling improvements
/// 
/// Future migration to Riverpod can be done with comentarios_riverpod_page.dart

class ComentariosRefactoredPage extends StatelessWidget {
  final String? pkIdentificador;
  final String? ferramenta;

  const ComentariosRefactoredPage({
    super.key,
    this.pkIdentificador,
    this.ferramenta,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: di.sl<ComentariosProvider>(),
      child: _ComentariosRefactoredContent(
        pkIdentificador: pkIdentificador,
        ferramenta: ferramenta,
      ),
    );
  }
}

class _ComentariosRefactoredContent extends StatefulWidget {
  final String? pkIdentificador;
  final String? ferramenta;
  
  const _ComentariosRefactoredContent({
    this.pkIdentificador,
    this.ferramenta,
  });

  @override
  State<_ComentariosRefactoredContent> createState() => _ComentariosRefactoredContentState();
}

class _ComentariosRefactoredContentState extends State<_ComentariosRefactoredContent> {
  late final IPremiumService _premiumService;
  bool _dataInitialized = false;

  @override
  void initState() {
    super.initState();
    _premiumService = di.sl<IPremiumService>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (_dataInitialized) return;
    
    final provider = context.read<ComentariosProvider>();
    await provider.ensureDataLoaded(
      context: widget.pkIdentificador,
      tool: widget.ferramenta,
    );
    
    if (mounted) {
      setState(() {
        _dataInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _HeaderSection(
              pkIdentificador: widget.pkIdentificador,
              ferramenta: widget.ferramenta,
              isDark: isDark,
            ),
            Expanded(
              child: _BodySection(
                pkIdentificador: widget.pkIdentificador,
                ferramenta: widget.ferramenta,
                premiumService: _premiumService,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _FloatingActionButtonSection(
        pkIdentificador: widget.pkIdentificador,
        ferramenta: widget.ferramenta,
        premiumService: _premiumService,
      ),
    );
  }
}

// ============================================================================
// DECOMPOSED SECTIONS
// ============================================================================

/// Header section with modern design
class _HeaderSection extends StatelessWidget {
  final String? pkIdentificador;
  final String? ferramenta;
  final bool isDark;

  const _HeaderSection({
    required this.pkIdentificador,
    required this.ferramenta,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ComentariosProvider>(
      builder: (context, provider, child) {
        return ModernHeaderWidget(
          title: 'Comentários',
          subtitle: _buildSubtitle(provider),
          leftIcon: Icons.comment_outlined,
          showBackButton: false,
          showActions: true,
          isDark: isDark,
          rightIcon: Icons.info_outline,
          onRightIconPressed: () => _showInfoDialog(context),
        );
      },
    );
  }

  String _buildSubtitle(ComentariosProvider provider) {
    if (provider.isLoading) {
      return 'Carregando comentários...';
    }
    
    final total = provider.totalCount;
    final filtered = provider.comentarios.length;
    
    if (pkIdentificador != null || ferramenta != null) {
      return filtered > 0 
          ? '$filtered comentários para este contexto' 
          : 'Nenhum comentário neste contexto';
    }
    
    return total > 0 ? '$total comentários' : 'Suas anotações pessoais';
  }

  void _showInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre Comentários'),
        content: const Text(
          'Use esta seção para criar anotações pessoais sobre suas experiências '
          'com culturas, pragas e defensivos. Seus comentários ficam salvos '
          'localmente e podem ser filtrados por contexto.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}

/// Body section with state management
class _BodySection extends StatelessWidget {
  final String? pkIdentificador;
  final String? ferramenta;
  final IPremiumService premiumService;

  const _BodySection({
    required this.pkIdentificador,
    required this.ferramenta,
    required this.premiumService,
  });

  @override
  Widget build(BuildContext context) {
    if (!premiumService.isPremium) {
      return _PremiumRestrictionWidget(premiumService: premiumService);
    }

    return Consumer<ComentariosProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.error != null) {
          return _ErrorWidget(
            error: provider.error!,
            onRetry: () => _retry(context, provider),
          );
        }
        
        final comentarios = provider.comentarios;
        
        if (comentarios.isEmpty) {
          return const _EmptyStateWidget();
        }
        
        return _ComentariosListWidget(
          comentarios: comentarios,
          onDelete: (comentario) => _deleteComentario(context, comentario, provider),
        );
      },
    );
  }

  Future<void> _retry(BuildContext context, ComentariosProvider provider) async {
    await provider.ensureDataLoaded(
      context: pkIdentificador,
      tool: ferramenta,
    );
  }

  void _deleteComentario(
    BuildContext context, 
    ComentarioEntity comentario,
    ComentariosProvider provider,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Comentário'),
        content: const Text(
          'Tem certeza que deseja excluir este comentário? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.deleteComentario(comentario.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

/// Premium restriction widget
class _PremiumRestrictionWidget extends StatelessWidget {
  final IPremiumService premiumService;

  const _PremiumRestrictionWidget({required this.premiumService});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        margin: const EdgeInsets.all(24.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFB74D)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.diamond,
              size: 48,
              color: Color(0xFFFF9800),
            ),
            const SizedBox(height: 16),
            const Text(
              'Comentários não disponíveis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Este recurso está disponível apenas para assinantes do app.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFBF360C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: premiumService.navigateToPremium,
                icon: const Icon(Icons.rocket_launch, color: Colors.white),
                label: const Text(
                  'Desbloquear Agora',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error widget with retry functionality
class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar comentários',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }
}

/// Empty state widget
class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.comment_outlined,
              size: 48,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nenhum comentário ainda',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione suas anotações pessoais',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Comentarios list widget
class _ComentariosListWidget extends StatelessWidget {
  final List<ComentarioEntity> comentarios;
  final Function(ComentarioEntity) onDelete;

  const _ComentariosListWidget({
    required this.comentarios,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: comentarios.length,
      itemBuilder: (context, index) {
        final comentario = comentarios[index];
        return _ComentarioCard(
          comentario: comentario,
          onDelete: () => onDelete(comentario),
        );
      },
    );
  }
}

/// Individual comentario card
class _ComentarioCard extends StatelessWidget {
  final ComentarioEntity comentario;
  final VoidCallback onDelete;

  const _ComentarioCard({
    required this.comentario,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          _buildContent(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8F9FA),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getOriginIcon(),
              size: 16,
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comentario.ferramenta,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                if (comentario.pkIdentificador.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${comentario.pkIdentificador}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            _formatDate(comentario.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: 18,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            onSelected: (value) {
              if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Text('Excluir', style: TextStyle(color: Colors.red.shade600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Text(
        comentario.conteudo,
        style: TextStyle(
          fontSize: 15,
          height: 1.4,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  IconData _getOriginIcon() {
    switch (comentario.ferramenta.toLowerCase()) {
      case 'defensivos':
        return Icons.shield_outlined;
      case 'pragas':
        return Icons.bug_report_outlined;
      case 'diagnóstico':
        return Icons.medical_services_outlined;
      default:
        return Icons.comment_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'Agora';
    }
  }
}

/// Floating Action Button section
class _FloatingActionButtonSection extends StatelessWidget {
  final String? pkIdentificador;
  final String? ferramenta;
  final IPremiumService premiumService;

  const _FloatingActionButtonSection({
    required this.pkIdentificador,
    required this.ferramenta,
    required this.premiumService,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ComentariosProvider>(
      builder: (context, provider, child) {
        return FloatingActionButton(
          onPressed: provider.isOperating || !premiumService.isPremium 
              ? null 
              : () => _onAddComentario(context, provider),
          backgroundColor: !premiumService.isPremium ? Colors.grey : null,
          child: !premiumService.isPremium 
              ? const Icon(Icons.lock) 
              : const Icon(Icons.add),
        );
      },
    );
  }

  void _onAddComentario(BuildContext context, ComentariosProvider provider) {
    showDialog<void>(
      context: context,
      builder: (context) => _AddCommentDialog(
        origem: ferramenta ?? 'Comentários',
        itemName: pkIdentificador != null ? 'Item $pkIdentificador' : 'Comentário direto',
        onSave: (content) async {
          final comentario = _createComentarioFromContent(content);
          await provider.addComentario(comentario);
        },
      ),
    );
  }

  ComentarioEntity _createComentarioFromContent(String content) {
    final now = DateTime.now();
    return ComentarioEntity(
      id: 'TEMP_${now.millisecondsSinceEpoch}',
      idReg: 'REG_${now.millisecondsSinceEpoch}',
      titulo: 'Comentário',
      conteudo: content,
      ferramenta: ferramenta ?? 'Comentários',
      pkIdentificador: pkIdentificador ?? '',
      status: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}

/// Simple add comment dialog
class _AddCommentDialog extends StatefulWidget {
  final String origem;
  final String itemName;
  final Future<void> Function(String content) onSave;

  const _AddCommentDialog({
    required this.origem,
    required this.itemName,
    required this.onSave,
  });

  @override
  State<_AddCommentDialog> createState() => _AddCommentDialogState();
}

class _AddCommentDialogState extends State<_AddCommentDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Comentário'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Para: ${widget.itemName}'),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Digite seu comentário...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    final content = _controller.text.trim();
    if (content.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comentário deve ter pelo menos 5 caracteres'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.onSave(content);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}