import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/admin_layout.dart';

/// Página administrativa para visualizar logs de erros do CantinhoVerde
/// 
/// Recursos:
/// - Visualização de erros em tempo real
/// - Filtros por status, tipo e severidade
/// - Estatísticas agregadas
/// - Cleanup de logs antigos
/// - Visualização de stack traces
class AdminErrorsPage extends ConsumerStatefulWidget {
  const AdminErrorsPage({super.key});

  @override
  ConsumerState<AdminErrorsPage> createState() => _AdminErrorsPageState();
}

class _AdminErrorsPageState extends ConsumerState<AdminErrorsPage> {
  ErrorStatus? _statusFilter;
  ErrorType? _typeFilter;
  ErrorSeverity? _severityFilter;
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

    final filters = ErrorLogFilters(
      status: _statusFilter,
      type: _typeFilter,
      severity: _severityFilter,
      limit: 100,
    );

    final errorsAsync = ref.watch(errorLogStreamProvider(filters));
    final countsAsync = ref.watch(errorLogCountsProvider);

    return AdminLayout(
      currentRoute: '/admin/errors',
      title: 'Logs de Erros',
      actions: [
        _buildHeaderAction(
          icon: Icons.cleaning_services_outlined,
          tooltip: 'Limpar erros antigos',
          onPressed: _showCleanupDialog,
          isDark: isDark,
        ),
        _buildHeaderAction(
          icon: Icons.refresh_outlined,
          tooltip: 'Atualizar',
          onPressed: () {
            ref.invalidate(errorLogStreamProvider(filters));
            ref.invalidate(errorLogCountsProvider);
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

            // Errors List
            _buildErrorsList(errorsAsync, isDark),
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
    AsyncValue<Map<ErrorStatus, int>> countsAsync,
    bool isDark,
  ) {
    return countsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (counts) {
        final total = counts.values.fold(0, (a, b) => a + b);
        final newErrors = counts[ErrorStatus.newError] ?? 0;
        final investigating = counts[ErrorStatus.investigating] ?? 0;
        final fixed = counts[ErrorStatus.fixed] ?? 0;

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
                      Icons.bug_report_outlined,
                      Colors.blue,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Novos',
                      newErrors.toString(),
                      Icons.error_outline,
                      Colors.red,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Investigando',
                      investigating.toString(),
                      Icons.search_outlined,
                      Colors.orange,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Corrigidos',
                      fixed.toString(),
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
                        Icons.bug_report_outlined,
                        Colors.blue,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Novos',
                        newErrors.toString(),
                        Icons.error_outline,
                        Colors.red,
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
                        'Investigando',
                        investigating.toString(),
                        Icons.search_outlined,
                        Colors.orange,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Corrigidos',
                        fixed.toString(),
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
        DropdownButton<ErrorStatus?>(
          value: _statusFilter,
          hint: const Text('Filtrar por Status'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todos os Status')),
            ...ErrorStatus.values.map((status) {
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

        // Severity filter
        DropdownButton<ErrorSeverity?>(
          value: _severityFilter,
          hint: const Text('Filtrar por Severidade'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todas Severidades')),
            ...ErrorSeverity.values.map((severity) {
              return DropdownMenuItem(
                value: severity,
                child: Text(severity.displayName),
              );
            }),
          ],
          onChanged: (value) {
            setState(() => _severityFilter = value);
          },
        ),

        const SizedBox(width: 8),

        // Type filter
        DropdownButton<ErrorType?>(
          value: _typeFilter,
          hint: const Text('Filtrar por Tipo'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todos os Tipos')),
            ...ErrorType.values.map((type) {
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

  Widget _buildErrorsList(
    AsyncValue<List<ErrorLogEntity>> errorsAsync,
    bool isDark,
  ) {
    return errorsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Text('Erro: $error'),
      ),
      data: (errors) {
        if (errors.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: _primaryColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum erro encontrado! 🎉',
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
          itemCount: errors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildErrorCard(errors[index], isDark);
          },
        );
      },
    );
  }

  Widget _buildErrorCard(ErrorLogEntity error, bool isDark) {
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
                error.errorType.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error.message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildSeverityChip(error.severity, isDark),
            ],
          ),

          const SizedBox(height: 12),

          // Metadata
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildMetadata(
                Icons.access_time,
                _formatDate(error.createdAt),
                isDark,
              ),
              _buildMetadata(
                Icons.repeat,
                '${error.occurrences}x',
                isDark,
              ),
              if (error.url != null)
                _buildMetadata(
                  Icons.link,
                  error.url!,
                  isDark,
                ),
              _buildMetadata(
                Icons.label_outline,
                error.errorType.displayName,
                isDark,
              ),
            ],
          ),

          // Stack trace preview (se existir)
          if (error.stackTrace != null) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              title: const Text(
                'Stack Trace',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    error.stackTrace!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Actions
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusChip(error.status, isDark),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showUpdateStatusDialog(error),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Atualizar'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _copyToClipboard(
                  '${error.message}\n\n${error.stackTrace ?? ""}',
                ),
                icon: const Icon(Icons.copy_outlined, size: 16),
                label: const Text('Copiar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ErrorStatus status, bool isDark) {
    Color color;
    switch (status) {
      case ErrorStatus.newError:
        color = Colors.red;
        break;
      case ErrorStatus.investigating:
        color = Colors.orange;
        break;
      case ErrorStatus.fixed:
        color = _primaryColor;
        break;
      case ErrorStatus.ignored:
      case ErrorStatus.wontFix:
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

  Widget _buildSeverityChip(ErrorSeverity severity, bool isDark) {
    Color color;
    switch (severity) {
      case ErrorSeverity.low:
        color = Colors.blue;
        break;
      case ErrorSeverity.medium:
        color = Colors.orange;
        break;
      case ErrorSeverity.high:
        color = Colors.deepOrange;
        break;
      case ErrorSeverity.critical:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        severity.displayName.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
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
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
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

  void _showUpdateStatusDialog(ErrorLogEntity error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atualizar Status do Erro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ErrorStatus.values.map((status) {
            return RadioListTile<ErrorStatus>(
              title: Text(status.displayName),
              value: status,
              groupValue: error.status,
              onChanged: (value) async {
                if (value != null) {
                  final service = ref.read(errorLogServiceProvider);
                  await service.updateErrorStatus(error.id, value);
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

  void _showCleanupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Logs Antigos'),
        content: const Text(
          'Deseja remover todos os erros com mais de 30 dias?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final service = ref.read(errorLogServiceProvider);
              await service.deleteOldErrors(30);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logs antigos removidos com sucesso'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Limpar'),
          ),
        ],
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
