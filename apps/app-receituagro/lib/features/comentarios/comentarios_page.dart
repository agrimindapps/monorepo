import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection_container.dart' as di;
import '../../core/interfaces/i_premium_service.dart';
import '../../core/widgets/modern_header_widget.dart';
import 'constants/comentarios_design_tokens.dart';
import 'domain/entities/comentario_entity.dart';
import 'presentation/providers/comentarios_provider.dart';
import 'views/widgets/premium_upgrade_widget.dart';

class ComentariosPage extends StatelessWidget {
  final String? pkIdentificador;
  final String? ferramenta;

  const ComentariosPage({
    super.key,
    this.pkIdentificador,
    this.ferramenta,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: di.sl<ComentariosProvider>(),
      child: _ComentariosPageContent(
        pkIdentificador: pkIdentificador,
        ferramenta: ferramenta,
      ),
    );
  }
}

class _ComentariosPageContent extends StatefulWidget {
  final String? pkIdentificador;
  final String? ferramenta;
  
  const _ComentariosPageContent({
    this.pkIdentificador,
    this.ferramenta,
  });

  @override
  State<_ComentariosPageContent> createState() => _ComentariosPageContentState();
}

class _ComentariosPageContentState extends State<_ComentariosPageContent> {
  bool _dataInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize data loading in initState instead of build method
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
            _buildModernHeader(context, isDark),
            Expanded(
              child: Consumer<ComentariosProvider>(
                builder: (context, provider, child) {
                  // Verificar se o usuário é premium usando o service real
                  final premiumService = di.sl<IPremiumService>();
                  final isPremium = premiumService.isPremium;
                  
                  if (!isPremium) {
                    return PremiumUpgradeWidget.noPermission(
                      onUpgrade: () => premiumService.navigateToPremium(),
                    );
                  }
                  
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (provider.error != null) {
                    return Center(
                      child: Text('Erro: ${provider.error}'),
                    );
                  }
                  
                  final comentariosParaMostrar = provider.comentarios;
                  
                  if (comentariosParaMostrar.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return _buildComentariosList(comentariosParaMostrar);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<ComentariosProvider>(
        builder: (context, provider, child) {
          // Verificar se o usuário é premium usando o service real
          final premiumService = di.sl<IPremiumService>();
          final isPremium = premiumService.isPremium;
          
          return FloatingActionButton(
            onPressed: provider.isOperating || !isPremium ? null : () => _onAddComentario(context, provider),
            backgroundColor: !isPremium ? Colors.grey : null,
            child: !isPremium ? const Icon(Icons.lock) : const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    return Consumer<ComentariosProvider>(
      builder: (context, provider, child) {
        String subtitle;
        if (provider.isLoading) {
          subtitle = 'Carregando comentários...';
        } else {
          final total = provider.totalCount;
          final filtered = provider.comentarios.length;
          
          if (widget.pkIdentificador != null || widget.ferramenta != null) {
            // Comentários filtrados por contexto
            subtitle = filtered > 0 ? '$filtered comentários para este contexto' : 'Nenhum comentário neste contexto';
          } else {
            // Todos os comentários
            subtitle = total > 0 ? '$total comentários' : 'Suas anotações pessoais';
          }
        }
        
        return ModernHeaderWidget(
          title: 'Comentários',
          subtitle: subtitle,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
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
          const SizedBox(height: 16),
          const Text(
            'Nenhum comentário ainda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione suas anotações pessoais',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComentariosList(List<ComentarioEntity> comentarios) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: comentarios.length,
      itemBuilder: (context, index) {
        final comentario = comentarios[index];
        return _buildComentarioCard(comentario, context);
      },
    );
  }

  Widget _buildComentarioCard(ComentarioEntity comentario, BuildContext context) {
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
          // Header do comentário
          Container(
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
                    _getOriginIcon(comentario.ferramenta),
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
                      _deleteComentario(context, comentario);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Excluir',
                            style: TextStyle(
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Conteúdo do comentário
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Text(
              comentario.conteudo,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getOriginIcon(String origem) {
    switch (origem.toLowerCase()) {
      case 'defensivos':
        return Icons.shield_outlined;
      case 'pragas':
        return Icons.bug_report_outlined;
      case 'diagnóstico':
        return Icons.medical_services_outlined;
      case 'comentários':
      case 'comentário direto':
        return Icons.comment_outlined;
      default:
        return Icons.note_outlined;
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

  void _onAddComentario(BuildContext context, ComentariosProvider provider) {
    showDialog<void>(
      context: context,
      builder: (context) => AddCommentDialog(
        origem: widget.ferramenta ?? 'Comentários',
        itemName: widget.pkIdentificador != null ? 'Item ${widget.pkIdentificador}' : 'Comentário direto',
        pkIdentificador: widget.pkIdentificador,
        ferramenta: widget.ferramenta,
        onSave: (content) async {
          // Criar entidade a partir do conteúdo
          final comentario = _createComentarioFromContent(content);
          await provider.addComentario(comentario);
        },
        onCancel: () {
          // Callback opcional para cancelamento
        },
      ),
    );
  }

  void _deleteComentario(BuildContext context, ComentarioEntity comentario) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Comentário'),
        content: const Text('Tem certeza que deseja excluir este comentário? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Busca o provider atual
              final provider = context.read<ComentariosProvider>();
              provider.deleteComentario(comentario.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
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

  /// Helper method to create ComentarioEntity from content
  ComentarioEntity _createComentarioFromContent(String content) {
    final now = DateTime.now();
    return ComentarioEntity(
      id: 'TEMP_${now.millisecondsSinceEpoch}',
      idReg: 'REG_${now.millisecondsSinceEpoch}',
      titulo: 'Comentário', // Pode ser melhorado para extrair título do conteúdo
      conteudo: content,
      ferramenta: widget.ferramenta ?? 'Comentários',
      pkIdentificador: widget.pkIdentificador ?? '',
      status: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class AddCommentDialog extends StatefulWidget {
  final String? origem;
  final String? itemName;
  final String? pkIdentificador;
  final String? ferramenta;
  final Future<void> Function(String content)? onSave;
  final VoidCallback? onCancel;
  
  const AddCommentDialog({
    super.key,
    this.origem,
    this.itemName,
    this.pkIdentificador,
    this.ferramenta,
    this.onSave,
    this.onCancel,
  });

  @override
  State<AddCommentDialog> createState() => _AddCommentDialogState();
}

class _AddCommentDialogState extends State<AddCommentDialog> {
  final TextEditingController _commentController = TextEditingController();
  final ValueNotifier<String> _contentNotifier = ValueNotifier<String>('');
  static const int _maxLength = ComentariosDesignTokens.maxCommentLength;
  static const int _minLength = ComentariosDesignTokens.minCommentLength;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    if (mounted) {
      _contentNotifier.value = _commentController.text;
    }
  }

  @override
  void dispose() {
    // Remove listener before disposing to prevent memory leaks
    _commentController.removeListener(_onContentChanged);
    _commentController.dispose();
    _contentNotifier.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ComentariosDesignTokens.dialogBorderRadius),
      ),
      insetPadding: ComentariosDesignTokens.defaultPadding,
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: ComentariosDesignTokens.maxDialogHeight),
        decoration: BoxDecoration(
          color: isDark ? ComentariosDesignTokens.dialogBackgroundDark : Colors.white,
          borderRadius: BorderRadius.circular(ComentariosDesignTokens.dialogBorderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context, theme, isDark),
            
            // Origin Info (if available)
            if (widget.origem != null || widget.itemName != null)
              _buildOriginInfo(context, theme, isDark),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: _buildCommentForm(theme, isDark),
              ),
            ),
            
            // Actions
            _buildActions(context, theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 12, top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? ComentariosDesignTokens.dialogHeaderDark : ComentariosDesignTokens.dialogHeaderLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(ComentariosDesignTokens.dialogBorderRadius),
          topRight: Radius.circular(ComentariosDesignTokens.dialogBorderRadius),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ComentariosDesignTokens.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.add,
              color: ComentariosDesignTokens.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Adicionar Comentário',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildOriginInfo(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8F9FA),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.origem != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getOriginIcon(widget.origem!),
                  size: 16,
                  color: const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.origem!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          if (widget.itemName != null) ...[
            if (widget.origem != null) const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.label_outline,
                  size: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.itemName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getOriginIcon(String origem) {
    switch (origem.toLowerCase()) {
      case 'defensivos':
        return Icons.shield_outlined;
      case 'pragas':
        return Icons.bug_report_outlined;
      case 'diagnóstico':
        return Icons.medical_services_outlined;
      case 'comentários':
        return Icons.comment_outlined;
      default:
        return Icons.comment_outlined;
    }
  }


  Widget _buildCommentForm(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Comentário',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Semantics(
            label: 'Campo de texto para comentário',
            hint: 'Digite seu comentário aqui, mínimo $_minLength caracteres, máximo $_maxLength caracteres',
            textField: true,
            child: TextField(
              controller: _commentController,
              maxLines: null,
              expands: true,
              maxLength: _maxLength,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Digite seu comentário aqui...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF4CAF50),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(8.0),
                counterText: '',
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<String>(
          valueListenable: _contentNotifier,
          builder: (context, content, child) {
            return Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${content.length}/$_maxLength',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: content.length > _maxLength
                      ? Colors.red
                      : isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                ),
              ),
            );
          },
        ),
      ],
    );
  }


  Widget _buildActions(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: ValueListenableBuilder<String>(
        valueListenable: _contentNotifier,
        builder: (context, content, child) {
          final trimmedContent = content.trim();
          final canSave = trimmedContent.length >= _minLength && 
                         trimmedContent.length <= _maxLength;
          
          return Row(
            children: [
              Expanded(
                child: Semantics(
                  label: 'Botão cancelar',
                  hint: 'Cancela a criação do comentário e fecha o diálogo',
                  button: true,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      widget.onCancel?.call();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                    ),
                    label: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      side: BorderSide(
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Semantics(
                  label: 'Botão salvar comentário',
                  hint: canSave 
                      ? 'Salva o comentário e fecha o diálogo'
                      : 'Comentário deve ter entre $_minLength e $_maxLength caracteres',
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: canSave ? () => _saveComment(context, trimmedContent) : null,
                    icon: const Icon(
                      Icons.check,
                      size: 18,
                    ),
                    label: const Text(
                      'Salvar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      disabledForegroundColor: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade500,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _saveComment(BuildContext context, String content) async {
    if (widget.onSave != null) {
      // Aplica padding se o conteúdo for muito curto
      String contentToSave = content;
      if (content.length < _minLength) {
        contentToSave = content.padRight(_minLength, ' ');
      }
      
      try {
        await widget.onSave!(contentToSave);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar comentário: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Fallback para demonstração
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}