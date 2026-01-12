import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Dashboard administrativo para gerenciar feedbacks
/// 
/// Mostra lista de feedbacks em tempo real com filtros
/// Permite atualizar status e adicionar notas
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  FeedbackStatus? _statusFilter;
  FeedbackType? _typeFilter;

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
    final primaryColor = Colors.teal;
    
    // Get current filters
    final filters = FeedbackFilters(
      status: _statusFilter,
      type: _typeFilter,
      limit: 100,
    );
    
    // Watch feedback stream
    final feedbacksAsync = ref.watch(feedbackStreamProvider(filters));
    final countsAsync = ref.watch(feedbackCountsProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Painel de Feedbacks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(feedbackStreamProvider(filters));
              ref.invalidate(feedbackCountsProvider);
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
          
          // Feedback list
          Expanded(
            child: feedbacksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Erro: $error', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              data: (feedbacks) => feedbacks.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildFeedbackList(feedbacks, primaryColor, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    AsyncValue<Map<FeedbackStatus, int>> countsAsync,
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
                  'Pendentes',
                  counts[FeedbackStatus.pending] ?? 0,
                  Colors.orange,
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Revisados',
                  counts[FeedbackStatus.reviewed] ?? 0,
                  Colors.purple,
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Resolvidos',
                  counts[FeedbackStatus.resolved] ?? 0,
                  Colors.green,
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Arquivados',
                  counts[FeedbackStatus.archived] ?? 0,
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
            child: DropdownButtonFormField<FeedbackStatus?>(
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
                ...FeedbackStatus.values.map((status) => DropdownMenuItem(
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
            child: DropdownButtonFormField<FeedbackType?>(
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
                ...FeedbackType.values.map((type) => DropdownMenuItem(
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
            Icons.inbox_outlined,
            size: 64,
            color: isDark ? Colors.white30 : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum feedback encontrado',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackList(
    List<FeedbackEntity> feedbacks,
    Color primaryColor,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: feedbacks.length,
      itemBuilder: (context, index) {
        final feedback = feedbacks[index];
        return _FeedbackCard(
          feedback: feedback,
          isDark: isDark,
          onStatusChanged: (newStatus, notes) async {
            final actions = ref.read(feedbackActionsProvider.notifier);
            final success = await actions.updateStatus(
              feedback.id,
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
          onDelete: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirmar exclusão'),
                content: const Text('Deseja realmente excluir este feedback?'),
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
              final actions = ref.read(feedbackActionsProvider.notifier);
              final success = await actions.delete(feedback.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feedback excluído'),
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
}

/// Card individual de feedback
class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.feedback,
    required this.isDark,
    required this.onStatusChanged,
    required this.onDelete,
  });

  final FeedbackEntity feedback;
  final bool isDark;
  final void Function(FeedbackStatus status, String? notes) onStatusChanged;
  final VoidCallback onDelete;

  Color get _statusColor {
    switch (feedback.status) {
      case FeedbackStatus.pending:
        return Colors.orange;
      case FeedbackStatus.reviewed:
        return Colors.purple;
      case FeedbackStatus.resolved:
        return Colors.green;
      case FeedbackStatus.archived:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF252545) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _statusColor.withValues(alpha: 0.3),
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
                      Text(feedback.type.emoji),
                      const SizedBox(width: 4),
                      Text(
                        feedback.type.displayName,
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
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
                    feedback.status.displayName,
                    style: TextStyle(fontSize: 12, color: _statusColor),
                  ),
                ),
                const Spacer(),
                // Rating
                if (feedback.rating != null) ...[
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 2),
                  Text(
                    feedback.rating!.toStringAsFixed(0),
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Delete button
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  onPressed: onDelete,
                  tooltip: 'Excluir',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              feedback.message,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Metadata row
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                // Date
                _buildMetaItem(
                  Icons.calendar_today,
                  DateFormat('dd/MM/yyyy HH:mm').format(feedback.createdAt),
                ),
                // Platform
                if (feedback.platform != null)
                  _buildMetaItem(
                    _platformIcon(feedback.platform!),
                    feedback.platform!,
                  ),
                // Calculator
                if (feedback.calculatorName != null)
                  _buildMetaItem(
                    Icons.calculate,
                    feedback.calculatorName!,
                  ),
                // Email
                if (feedback.userEmail != null)
                  _buildMetaItem(
                    Icons.email,
                    feedback.userEmail!,
                  ),
              ],
            ),
            
            // Admin notes
            if (feedback.adminNotes != null && feedback.adminNotes!.isNotEmpty) ...[
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
                        feedback.adminNotes!,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
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
                    FeedbackStatus.reviewed,
                    'Revisar',
                    Icons.visibility,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusButton(
                    context,
                    FeedbackStatus.resolved,
                    'Resolver',
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusButton(
                    context,
                    FeedbackStatus.archived,
                    'Arquivar',
                    Icons.archive,
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
          color: isDark ? Colors.white38 : Colors.black38,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
      ],
    );
  }

  IconData _platformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'web':
        return Icons.web;
      case 'macos':
        return Icons.laptop_mac;
      case 'windows':
        return Icons.desktop_windows;
      default:
        return Icons.device_unknown;
    }
  }

  Widget _buildStatusButton(
    BuildContext context,
    FeedbackStatus status,
    String label,
    IconData icon,
  ) {
    final isCurrentStatus = feedback.status == status;
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

  Color _getStatusButtonColor(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.pending:
        return Colors.orange;
      case FeedbackStatus.reviewed:
        return Colors.purple;
      case FeedbackStatus.resolved:
        return Colors.green;
      case FeedbackStatus.archived:
        return Colors.grey;
    }
  }

  void _showNotesDialog(BuildContext context, FeedbackStatus newStatus) {
    final notesController = TextEditingController(text: feedback.adminNotes);
    
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
              onStatusChanged(
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
}
