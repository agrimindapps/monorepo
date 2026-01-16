import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/admin_layout.dart';

/// Dashboard administrativo para gerenciar feedbacks do CantinhoVerde
/// 
/// Recursos:
/// - Visualização de feedbacks em tempo real
/// - Filtros por status e tipo
/// - Estatísticas agregadas
/// - Atualização de status e notas admin
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  FeedbackStatus? _statusFilter;
  FeedbackType? _typeFilter;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  // Plantis theme colors
  static const _primaryColor = Color(0xFF4CAF50);
  static const _cardColor = Color(0xFF1A1A2E);

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filters = FeedbackFilters(
      status: _statusFilter,
      type: _typeFilter,
      limit: 100,
    );

    final feedbacksAsync = ref.watch(feedbackStreamProvider(filters));
    final countsAsync = ref.watch(feedbackCountsProvider);

    return AdminLayout(
      currentRoute: '/admin/dashboard',
      title: 'Feedbacks',
      actions: [
        _buildHeaderAction(
          icon: Icons.refresh_outlined,
          tooltip: 'Atualizar',
          onPressed: () {
            ref.invalidate(feedbackStreamProvider(filters));
            ref.invalidate(feedbackCountsProvider);
          },
          isDark: isDark,
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Overview
            _buildStatsOverview(countsAsync, isDark),

            const SizedBox(height: 32),

            // Filters
            _buildFilters(isDark),

            const SizedBox(height: 24),

            // Feedbacks List
            _buildFeedbacksList(feedbacksAsync, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 22,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(
    AsyncValue<Map<FeedbackStatus, int>> countsAsync,
    bool isDark,
  ) {
    return countsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (counts) {
        final total = counts.values.fold(0, (a, b) => a + b);
        final pending = counts[FeedbackStatus.pending] ?? 0;
        final reviewed = counts[FeedbackStatus.reviewed] ?? 0;
        final resolved = counts[FeedbackStatus.resolved] ?? 0;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;

            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total',
                      total.toString(),
                      Icons.chat_bubble_outline,
                      Colors.blue,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Pendentes',
                      pending.toString(),
                      Icons.pending_outlined,
                      Colors.orange,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Revisados',
                      reviewed.toString(),
                      Icons.visibility_outlined,
                      Colors.purple,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Resolvidos',
                      resolved.toString(),
                      Icons.check_circle_outline,
                      _primaryColor,
                      isDark,
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        total.toString(),
                        Icons.chat_bubble_outline,
                        Colors.blue,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pendentes',
                        pending.toString(),
                        Icons.pending_outlined,
                        Colors.orange,
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Revisados',
                        reviewed.toString(),
                        Icons.visibility_outlined,
                        Colors.purple,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Resolvidos',
                        resolved.toString(),
                        Icons.check_circle_outline,
                        _primaryColor,
                        isDark,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.1))
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Status filter
        DropdownButton<FeedbackStatus?>(
          value: _statusFilter,
          hint: const Text('Filtrar por Status'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todos os Status')),
            ...FeedbackStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.displayName),
              );
            }),
          ],
          onChanged: (value) {
            setState(() => _statusFilter = value);
          },
        ),

        const SizedBox(width: 8),

        // Type filter
        DropdownButton<FeedbackType?>(
          value: _typeFilter,
          hint: const Text('Filtrar por Tipo'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todos os Tipos')),
            ...FeedbackType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Row(
                  children: [
                    Text(type.emoji),
                    const SizedBox(width: 8),
                    Text(type.displayName),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() => _typeFilter = value);
          },
        ),
      ],
    );
  }

  Widget _buildFeedbacksList(
    AsyncValue<List<FeedbackEntity>> feedbacksAsync,
    bool isDark,
  ) {
    return feedbacksAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Text('Erro: $error'),
      ),
      data: (feedbacks) {
        if (feedbacks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: isDark ? Colors.white24 : Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum feedback encontrado',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: feedbacks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildFeedbackCard(feedbacks[index], isDark);
          },
        );
      },
    );
  }

  Widget _buildFeedbackCard(FeedbackEntity feedback, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.1))
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                feedback.type.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                feedback.type.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _buildStatusChip(feedback.status, isDark),
            ],
          ),

          const SizedBox(height: 12),

          // Message
          Text(
            feedback.message,
            style: const TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 12),

          // Metadata
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildMetadata(
                Icons.access_time,
                _formatDate(feedback.createdAt),
                isDark,
              ),
              if (feedback.platform != null)
                _buildMetadata(
                  Icons.devices,
                  feedback.platform!,
                  isDark,
                ),
              if (feedback.userEmail != null)
                _buildMetadata(
                  Icons.email_outlined,
                  feedback.userEmail!,
                  isDark,
                ),
            ],
          ),

          // Actions
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _showUpdateStatusDialog(feedback),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Atualizar Status'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _copyToClipboard(feedback.message),
                icon: const Icon(Icons.copy_outlined, size: 16),
                label: const Text('Copiar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(FeedbackStatus status, bool isDark) {
    Color color;
    switch (status) {
      case FeedbackStatus.pending:
        color = Colors.orange;
        break;
      case FeedbackStatus.reviewed:
        color = Colors.purple;
        break;
      case FeedbackStatus.resolved:
        color = _primaryColor;
        break;
      case FeedbackStatus.archived:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMetadata(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? Colors.white54 : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    if (diff.inDays < 7) return '${diff.inDays}d atrás';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showUpdateStatusDialog(FeedbackEntity feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atualizar Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: FeedbackStatus.values.map((status) {
            return RadioListTile<FeedbackStatus>(
              title: Text(status.displayName),
              value: status,
              groupValue: feedback.status,
              onChanged: (value) async {
                if (value != null) {
                  final service = ref.read(feedbackServiceProvider);
                  await service.updateFeedbackStatus(feedback.id, value);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copiado para área de transferência')),
    );
  }
}
