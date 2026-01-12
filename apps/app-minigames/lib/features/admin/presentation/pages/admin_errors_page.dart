import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // MiniGames theme colors
  static const _backgroundColor = Color(0xFF0F0F1A);
  static const _cardColor = Color(0xFF1A1A2E);
  static const _accentColor = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
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
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ErrorLogFilters(
      status: _statusFilter,
      type: _typeFilter,
      severity: _severityFilter,
      limit: 100,
    );

    final errorsAsync = ref.watch(errorLogStreamProvider(filters));
    final countsAsync = ref.watch(errorLogCountsProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _cardColor,
        foregroundColor: _accentColor,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bug_report, size: 20, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text(
              'Painel de Erros Web',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: () => _showCleanupDialog(),
            tooltip: 'Limpar erros antigos',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(errorLogStreamProvider(filters));
              ref.invalidate(errorLogCountsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats cards
          _buildStatsSection(countsAsync),

          // Filters
          _buildFiltersSection(),

          // Error list
          Expanded(
            child: errorsAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(color: _accentColor),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Erro: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              data: (errors) => errors.isEmpty
                  ? _buildEmptyState()
                  : _buildErrorList(errors),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(AsyncValue<Map<ErrorStatus, int>> countsAsync) {
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
                _buildStatCard('Total', total, Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Novos',
                  counts[ErrorStatus.newError] ?? 0,
                  Colors.red,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Investigando',
                  counts[ErrorStatus.investigating] ?? 0,
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Corrigidos',
                  counts[ErrorStatus.fixed] ?? 0,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Ignorados',
                  counts[ErrorStatus.ignored] ?? 0,
                  Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
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
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
              dropdownColor: _cardColor,
              style: const TextStyle(color: Colors.white),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todos')),
                ...ErrorStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    )),
              ],
              onChanged: (value) => setState(() => _statusFilter = value),
            ),
          ),
          const SizedBox(width: 12),
          // Type filter
          Expanded(
            child: DropdownButtonFormField<ErrorType?>(
              value: _typeFilter,
              decoration: InputDecoration(
                labelText: 'Tipo',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
              dropdownColor: _cardColor,
              style: const TextStyle(color: Colors.white),
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
              onChanged: (value) => setState(() => _typeFilter = value),
            ),
          ),
          const SizedBox(width: 12),
          // Severity filter
          Expanded(
            child: DropdownButtonFormField<ErrorSeverity?>(
              value: _severityFilter,
              decoration: InputDecoration(
                labelText: 'Severidade',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
              dropdownColor: _cardColor,
              style: const TextStyle(color: Colors.white),
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
              onChanged: (value) => setState(() => _severityFilter = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '🎉 Tudo funcionando perfeitamente!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorList(List<ErrorLogEntity> errors) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: errors.length,
      itemBuilder: (context, index) {
        final error = errors[index];
        return _ErrorCard(
          error: error,
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
                  content:
                      Text('Severidade atualizada para ${newSeverity.displayName}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          onDelete: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: _cardColor,
                title: const Text('Confirmar exclusão',
                    style: TextStyle(color: Colors.white)),
                content: const Text(
                  'Deseja realmente excluir este erro?',
                  style: TextStyle(color: Colors.white70),
                ),
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
        backgroundColor: _cardColor,
        title: const Text('Limpar erros antigos',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Esta ação irá remover todos os erros com status "Corrigido", "Ignorado" ou "Não será corrigido" '
          'que foram criados há mais de 30 dias.\n\n'
          'Esta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.white70),
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
    required this.onStatusChanged,
    required this.onSeverityChanged,
    required this.onDelete,
  });

  final ErrorLogEntity error;
  final void Function(ErrorStatus status, String? notes) onStatusChanged;
  final void Function(ErrorSeverity severity) onSeverityChanged;
  final VoidCallback onDelete;

  @override
  State<_ErrorCard> createState() => _ErrorCardState();
}

class _ErrorCardState extends State<_ErrorCard> {
  bool _isExpanded = false;

  static const _cardColor = Color(0xFF1A1A2E);
  static const _backgroundColor = Color(0xFF0F0F1A);
  static const _accentColor = Color(0xFFFFD700);

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
      color: _cardColor,
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
                          style:
                              const TextStyle(fontSize: 12, color: Colors.purple),
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
                    color: Colors.white54,
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
              style: const TextStyle(
                color: Colors.white,
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
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Stack Trace',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16, color: _accentColor),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: widget.error.stackTrace!));
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
                        color: Colors.white.withValues(alpha: 0.7),
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
                  _buildMetaItem(Icons.link, widget.error.url!),
                // Game (using calculatorName field)
                if (widget.error.calculatorName != null)
                  _buildMetaItem(Icons.sports_esports, widget.error.calculatorName!),
                // Browser
                if (widget.error.browserInfo != null)
                  _buildMetaItem(Icons.web, widget.error.browserInfo!),
                // Screen size
                if (widget.error.screenSize != null)
                  _buildMetaItem(Icons.aspect_ratio, widget.error.screenSize!),
                // Session
                if (widget.error.sessionId != null)
                  _buildMetaItem(
                    Icons.fingerprint,
                    widget.error.sessionId!.substring(0, 8),
                  ),
              ],
            ),

            // Admin notes
            if (widget.error.adminNotes != null &&
                widget.error.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _accentColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note, color: _accentColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.error.adminNotes!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
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
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.white38),
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
      onPressed: isCurrentStatus ? null : () => _showNotesDialog(context, status),
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
        backgroundColor: _cardColor,
        title: Text(
          'Alterar para ${newStatus.displayName}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Adicione uma nota (opcional):',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Notas do administrador...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
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
                notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.black,
            ),
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
        backgroundColor: _cardColor,
        title: const Text('Alterar Severidade',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ErrorSeverity.values
              .map((severity) => ListTile(
                    leading:
                        Text(severity.emoji, style: const TextStyle(fontSize: 24)),
                    title: Text(severity.displayName,
                        style: const TextStyle(color: Colors.white)),
                    selected: widget.error.severity == severity,
                    selectedTileColor: _accentColor.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onSeverityChanged(severity);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}
