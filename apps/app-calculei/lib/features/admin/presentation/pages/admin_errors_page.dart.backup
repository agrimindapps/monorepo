import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Dashboard administrativo para gerenciar logs de erros web
/// 
/// Mostra lista de erros em tempo real com filtros
/// Permite atualizar status, severidade e adicionar notas
class AdminErrorsPage extends ConsumerStatefulWidget {
  const AdminErrorsPage({super.key});

  @override
  ConsumerState<AdminErrorsPage> createState() => _AdminErrorsPageState();
}

class _AdminErrorsPageState extends ConsumerState<AdminErrorsPage> {
  ErrorStatus? _statusFilter;
  ErrorType? _typeFilter;
  ErrorSeverity? _severityFilter;

  @override
  void initState() {
    super.initState();
    // Verificar se está autenticado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        context.go('/admin');
      }
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Colors.red;
    
    // Get current filters
    final filters = ErrorLogFilters(
      status: _statusFilter,
      type: _typeFilter,
      severity: _severityFilter,
      limit: 100,
    );
    
    // Watch error stream
    final errorsAsync = ref.watch(errorLogStreamProvider(filters));
    final countsAsync = ref.watch(errorLogCountsProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Painel de Erros Web'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/dashboard'),
        ),
        actions: [
          // Cleanup button
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: () => _showCleanupDialog(),
            tooltip: 'Limpar erros antigos',
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(errorLogStreamProvider(filters));
              ref.invalidate(errorLogCountsProvider);
            },
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats cards
          _buildStatsSection(countsAsync, primaryColor, isDark),
          
          // Filters
          _buildFiltersSection(primaryColor, isDark),
          
          // Error list
          Expanded(
            child: errorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Erro: $error', style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              data: (errors) => errors.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildErrorList(errors, primaryColor, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    AsyncValue<Map<ErrorStatus, int>> countsAsync,
    Color primaryColor,
    bool isDark,
  ) {
    return countsAsync.when(
      loading: () => const SizedBox(height: 100),
      error: (_, __) => const SizedBox(height: 100),
      data: (counts) {
        final total = counts.values.fold(0, (a, b) => a + b);
        return Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatCard('Total', total, Colors.blue, isDark),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Novos',
                  counts[ErrorStatus.newError] ?? 0,
                  Colors.red,
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Investigando',
                  counts[ErrorStatus.investigating] ?? 0,
                  Colors.orange,
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Corrigidos',
                  counts[ErrorStatus.fixed] ?? 0,
                  Colors.green,
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Ignorados',
                  counts[ErrorStatus.ignored] ?? 0,
                  Colors.grey,
                  isDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, int count, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252545) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252545) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          // Status filter
          Expanded(
            child: DropdownButtonFormField<ErrorStatus?>(
              value: _statusFilter,
              decoration: InputDecoration(
                labelText: 'Status',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownColor: isDark ? const Color(0xFF252545) : Colors.white,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todos')),
                ...ErrorStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                )),
              ],
              onChanged: (value) {
                setState(() => _statusFilter = value);
              },
            ),
          ),
          const SizedBox(width: 12),
          // Type filter
          Expanded(
            child: DropdownButtonFormField<ErrorType?>(
              value: _typeFilter,
              decoration: InputDecoration(
                labelText: 'Tipo',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownColor: isDark ? const Color(0xFF252545) : Colors.white,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todos')),
                ...ErrorType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Text(type.emoji),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                )),
              ],
              onChanged: (value) {
                setState(() => _typeFilter = value);
              },
            ),
          ),
          const SizedBox(width: 12),
          // Severity filter
          Expanded(
            child: DropdownButtonFormField<ErrorSeverity?>(
              value: _severityFilter,
              decoration: InputDecoration(
                labelText: 'Severidade',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownColor: isDark ? const Color(0xFF252545) : Colors.white,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas')),
                ...ErrorSeverity.values.map((severity) => DropdownMenuItem(
                  value: severity,
                  child: Row(
                    children: [
                      Text(severity.emoji),
                      const SizedBox(width: 8),
                      Text(severity.displayName),
                    ],
                  ),
                )),
              ],
              onChanged: (value) {
                setState(() => _severityFilter = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum erro encontrado',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '🎉 Tudo funcionando perfeitamente!',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorList(
    List<ErrorLogEntity> errors,
    Color primaryColor,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: errors.length,
      itemBuilder: (context, index) {
        final error = errors[index];
        return _ErrorCard(
          error: error,
          isDark: isDark,
          onStatusChanged: (newStatus, notes) async {
            final actions = ref.read(errorLogActionsProvider.notifier);
            final success = await actions.updateStatus(
              error.id,
              newStatus,
              adminNotes: notes,
            );
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Status atualizado para ${newStatus.displayName}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          onSeverityChanged: (newSeverity) async {
            final actions = ref.read(errorLogActionsProvider.notifier);
            final success = await actions.updateSeverity(error.id, newSeverity);
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Severidade atualizada para ${newSeverity.displayName}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          onDelete: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirmar exclusão'),
                content: const Text('Deseja realmente excluir este erro?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Excluir'),
                  ),
                ],
              ),
            );

            if (confirmed == true && mounted) {
              final actions = ref.read(errorLogActionsProvider.notifier);
              final success = await actions.delete(error.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro excluído'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  void _showCleanupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar erros antigos'),
        content: const Text(
          'Esta ação irá remover todos os erros com status "Corrigido", "Ignorado" ou "Não será corrigido" '
          'que foram criados há mais de 30 dias.\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final actions = ref.read(errorLogActionsProvider.notifier);
              final count = await actions.cleanup(30);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$count erros removidos'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}

/// Card individual de erro
class _ErrorCard extends StatefulWidget {
  const _ErrorCard({
    required this.error,
    required this.isDark,
    required this.onStatusChanged,
    required this.onSeverityChanged,
    required this.onDelete,
  });

  final ErrorLogEntity error;
  final bool isDark;
  final void Function(ErrorStatus status, String? notes) onStatusChanged;
  final void Function(ErrorSeverity severity) onSeverityChanged;
  final VoidCallback onDelete;

  @override
  State<_ErrorCard> createState() => _ErrorCardState();
}

class _ErrorCardState extends State<_ErrorCard> {
  bool _isExpanded = false;

  Color get _statusColor {
    switch (widget.error.status) {
      case ErrorStatus.newError:
        return Colors.red;
      case ErrorStatus.investigating:
        return Colors.orange;
      case ErrorStatus.fixed:
        return Colors.green;
      case ErrorStatus.ignored:
        return Colors.grey;
      case ErrorStatus.wontFix:
        return Colors.blueGrey;
    }
  }

  Color get _severityColor {
    switch (widget.error.severity) {
      case ErrorSeverity.low:
        return Colors.green;
      case ErrorSeverity.medium:
        return Colors.yellow.shade700;
      case ErrorSeverity.high:
        return Colors.orange;
      case ErrorSeverity.critical:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: widget.isDark ? const Color(0xFF252545) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _severityColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.error.errorType.emoji),
                      const SizedBox(width: 4),
                      Text(
                        widget.error.errorType.displayName,
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Severity badge
                GestureDetector(
                  onTap: () => _showSeverityDialog(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _severityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.error.severity.emoji),
                        const SizedBox(width: 4),
                        Text(
                          widget.error.severity.displayName,
                          style: TextStyle(fontSize: 12, color: _severityColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.error.status.displayName,
                    style: TextStyle(fontSize: 12, color: _statusColor),
                  ),
                ),
                const Spacer(),
                // Occurrences
                if (widget.error.occurrences > 1) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.repeat, color: Colors.purple, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.error.occurrences}x',
                          style: const TextStyle(fontSize: 12, color: Colors.purple),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Expand/collapse button
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.isDark ? Colors.white54 : Colors.black45,
                  ),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  tooltip: _isExpanded ? 'Recolher' : 'Expandir',
                ),
                // Delete button
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  onPressed: widget.onDelete,
                  tooltip: 'Excluir',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Error message
            Text(
              widget.error.message,
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black87,
                fontSize: 14,
                height: 1.4,
                fontFamily: 'monospace',
              ),
              maxLines: _isExpanded ? null : 2,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
            ),
            
            // Stack trace (expanded)
            if (_isExpanded && widget.error.stackTrace != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isDark ? Colors.white10 : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Stack Trace',
                          style: TextStyle(
                            color: widget.isDark ? Colors.white60 : Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: widget.error.stackTrace!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Stack trace copiado')),
                            );
                          },
                          tooltip: 'Copiar',
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.error.stackTrace!,
                      style: TextStyle(
                        color: widget.isDark ? Colors.white70 : Colors.black54,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),

            // Metadata row
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                // Date
                _buildMetaItem(
                  Icons.calendar_today,
                  DateFormat('dd/MM/yyyy HH:mm').format(widget.error.createdAt),
                ),
                // URL
                if (widget.error.url != null)
                  _buildMetaItem(
                    Icons.link,
                    widget.error.url!,
                  ),
                // Calculator
                if (widget.error.calculatorName != null)
                  _buildMetaItem(
                    Icons.calculate,
                    widget.error.calculatorName!,
                  ),
                // Browser
                if (widget.error.browserInfo != null)
                  _buildMetaItem(
                    Icons.web,
                    widget.error.browserInfo!,
                  ),
                // Screen size
                if (widget.error.screenSize != null)
                  _buildMetaItem(
                    Icons.aspect_ratio,
                    widget.error.screenSize!,
                  ),
                // Session
                if (widget.error.sessionId != null)
                  _buildMetaItem(
                    Icons.fingerprint,
                    widget.error.sessionId!.substring(0, 8),
                  ),
              ],
            ),
            
            // Admin notes
            if (widget.error.adminNotes != null && widget.error.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note, color: Colors.teal, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.error.adminNotes!,
                        style: TextStyle(
                          color: widget.isDark ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _buildStatusButton(
                    context,
                    ErrorStatus.investigating,
                    'Investigar',
                    Icons.search,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusButton(
                    context,
                    ErrorStatus.fixed,
                    'Corrigido',
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusButton(
                    context,
                    ErrorStatus.ignored,
                    'Ignorar',
                    Icons.block,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: widget.isDark ? Colors.white38 : Colors.black38,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: widget.isDark ? Colors.white38 : Colors.black38,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    ErrorStatus status,
    String label,
    IconData icon,
  ) {
    final isCurrentStatus = widget.error.status == status;
    final color = _getStatusButtonColor(status);

    return OutlinedButton.icon(
      onPressed: isCurrentStatus
          ? null
          : () => _showNotesDialog(context, status),
      style: OutlinedButton.styleFrom(
        foregroundColor: isCurrentStatus ? Colors.white : color,
        backgroundColor: isCurrentStatus ? color : Colors.transparent,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Color _getStatusButtonColor(ErrorStatus status) {
    switch (status) {
      case ErrorStatus.newError:
        return Colors.red;
      case ErrorStatus.investigating:
        return Colors.orange;
      case ErrorStatus.fixed:
        return Colors.green;
      case ErrorStatus.ignored:
        return Colors.grey;
      case ErrorStatus.wontFix:
        return Colors.blueGrey;
    }
  }

  void _showNotesDialog(BuildContext context, ErrorStatus newStatus) {
    final notesController = TextEditingController(text: widget.error.adminNotes);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alterar para ${newStatus.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Adicione uma nota (opcional):'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Notas do administrador...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onStatusChanged(
                newStatus,
                notesController.text.trim().isEmpty ? null : notesController.text.trim(),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showSeverityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Severidade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ErrorSeverity.values.map((severity) => ListTile(
            leading: Text(severity.emoji, style: const TextStyle(fontSize: 24)),
            title: Text(severity.displayName),
            selected: widget.error.severity == severity,
            onTap: () {
              Navigator.of(context).pop();
              widget.onSeverityChanged(severity);
            },
          )).toList(),
        ),
      ),
    );
  }
}
