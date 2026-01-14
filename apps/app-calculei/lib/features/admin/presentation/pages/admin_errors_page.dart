import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/admin_layout.dart';

/// Dashboard administrativo para gerenciar logs de erros web
///
/// Design profissional inspirado no Firebase Crashlytics com:
/// - Cards de estatísticas elegantes
/// - Tabela de problemas com tendências
/// - Filtros intuitivos
/// - Detalhes expansíveis
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
  bool _sortAscending = false;
  final _searchController = TextEditingController();

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

            const SizedBox(height: 24),

            // Problems Section
            _buildProblemsSection(errorsAsync, isDark),
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

  // ════════════════════════════════════════════════════════════════════════════
  // STATS OVERVIEW - Cards elegantes com indicadores
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStatsOverview(
    AsyncValue<Map<ErrorStatus, int>> countsAsync,
    bool isDark,
  ) {
    return countsAsync.when(
      loading: () => _buildStatsLoading(isDark),
      error: (_, __) => const SizedBox.shrink(),
      data: (counts) {
        final total = counts.values.fold(0, (a, b) => a + b);
        final newCount = counts[ErrorStatus.newError] ?? 0;
        final investigating = counts[ErrorStatus.investigating] ?? 0;
        final fixed = counts[ErrorStatus.fixed] ?? 0;
        final ignored = counts[ErrorStatus.ignored] ?? 0;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;

            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'Total de Erros',
                      value: total,
                      icon: Icons.bug_report_outlined,
                      color: const Color(0xFF4285F4),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      label: 'Novos',
                      value: newCount,
                      icon: Icons.fiber_new_outlined,
                      color: const Color(0xFFEA4335),
                      isDark: isDark,
                      highlight: newCount > 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      label: 'Investigando',
                      value: investigating,
                      icon: Icons.search_outlined,
                      color: const Color(0xFFFBBC04),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      label: 'Corrigidos',
                      value: fixed,
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF34A853),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      label: 'Ignorados',
                      value: ignored,
                      icon: Icons.do_not_disturb_alt_outlined,
                      color: const Color(0xFF9AA0A6),
                      isDark: isDark,
                    ),
                  ),
                ],
              );
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatCard(
                  label: 'Total',
                  value: total,
                  icon: Icons.bug_report_outlined,
                  color: const Color(0xFF4285F4),
                  isDark: isDark,
                  compact: true,
                ),
                _buildStatCard(
                  label: 'Novos',
                  value: newCount,
                  icon: Icons.fiber_new_outlined,
                  color: const Color(0xFFEA4335),
                  isDark: isDark,
                  compact: true,
                  highlight: newCount > 0,
                ),
                _buildStatCard(
                  label: 'Investigando',
                  value: investigating,
                  icon: Icons.search_outlined,
                  color: const Color(0xFFFBBC04),
                  isDark: isDark,
                  compact: true,
                ),
                _buildStatCard(
                  label: 'Corrigidos',
                  value: fixed,
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF34A853),
                  isDark: isDark,
                  compact: true,
                ),
                _buildStatCard(
                  label: 'Ignorados',
                  value: ignored,
                  icon: Icons.do_not_disturb_alt_outlined,
                  color: const Color(0xFF9AA0A6),
                  isDark: isDark,
                  compact: true,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    required bool isDark,
    bool highlight = false,
    bool compact = false,
  }) {
    final bgColor = isDark ? const Color(0xFF1E1E2D) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      constraints: compact ? const BoxConstraints(minWidth: 120) : null,
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? color.withValues(alpha: 0.5)
              : (isDark ? Colors.white10 : Colors.grey.shade200),
          width: highlight ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: highlight
                ? color.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: highlight ? 20 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.all(compact ? 8 : 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: compact ? 20 : 24),
          ),
          SizedBox(width: compact ? 12 : 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    color: textColor,
                    fontSize: compact ? 24 : 32,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: compact ? 12 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsLoading(bool isDark) {
    return Row(
      children: List.generate(
        5,
        (i) => Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(right: i < 4 ? 16 : 0),
            height: 100,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PROBLEMS SECTION - Tabela profissional de erros
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildProblemsSection(
    AsyncValue<List<ErrorLogEntity>> errorsAsync,
    bool isDark,
  ) {
    final bgColor = isDark ? const Color(0xFF1E1E2D) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.grey.shade200;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com título e busca
          _buildProblemsHeader(isDark),

          Divider(height: 1, color: borderColor),

          // Filtros
          _buildFiltersBar(isDark),

          Divider(height: 1, color: borderColor),

          // Lista de erros
          errorsAsync.when(
            loading: () => _buildListLoading(isDark),
            error: (error, _) => _buildListError(error, isDark),
            data: (errors) {
              final filteredErrors = _filterErrors(errors);
              if (filteredErrors.isEmpty) {
                return _buildEmptyState(isDark);
              }
              return _buildErrorsList(filteredErrors, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProblemsHeader(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: const Color(0xFFEA4335),
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Problemas',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Search field
          Container(
            width: 250,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Pesquisar...',
                hintStyle: TextStyle(color: subtextColor, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: subtextColor, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 12),
          // Sort button
          Tooltip(
            message: _sortAscending
                ? 'Mais antigos primeiro'
                : 'Mais recentes primeiro',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _sortAscending = !_sortAscending),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: subtextColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersBar(bool isDark) {
    final hasFilters =
        _statusFilter != null || _typeFilter != null || _severityFilter != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Clear filters button
          if (hasFilters) ...[
            _buildClearFiltersButton(isDark),
            const SizedBox(width: 12),
            Container(
              width: 1,
              height: 24,
              color: isDark ? Colors.white10 : Colors.grey.shade300,
            ),
            const SizedBox(width: 12),
          ],

          // Status filters
          _buildFilterChip(
            'Todos',
            _statusFilter == null,
            () => setState(() => _statusFilter = null),
            isDark,
          ),
          ...ErrorStatus.values.map(
            (s) => _buildFilterChip(
              s.displayName,
              _statusFilter == s,
              () =>
                  setState(() => _statusFilter = _statusFilter == s ? null : s),
              isDark,
              color: _getStatusColor(s),
            ),
          ),

          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 24,
            color: isDark ? Colors.white10 : Colors.grey.shade300,
          ),
          const SizedBox(width: 8),

          // Severity filters
          ...ErrorSeverity.values.map(
            (s) => _buildFilterChip(
              s.displayName,
              _severityFilter == s,
              () => setState(
                () => _severityFilter = _severityFilter == s ? null : s,
              ),
              isDark,
              color: _getSeverityColor(s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearFiltersButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() {
          _statusFilter = null;
          _typeFilter = null;
          _severityFilter = null;
        }),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.close, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                'Limpar filtros',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark, {
    Color? color,
  }) {
    final chipColor = color ?? (isDark ? Colors.white : Colors.black87);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? chipColor.withValues(alpha: 0.15)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? chipColor.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? chipColor
                    : (isDark ? Colors.white70 : Colors.black54),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<ErrorLogEntity> _filterErrors(List<ErrorLogEntity> errors) {
    var filtered = errors;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = errors
          .where(
            (e) =>
                e.message.toLowerCase().contains(query) ||
                (e.stackTrace?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    filtered.sort(
      (a, b) => _sortAscending
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt),
    );

    return filtered;
  }

  Widget _buildErrorsList(List<ErrorLogEntity> errors, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: errors.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: isDark ? Colors.white10 : Colors.grey.shade200,
      ),
      itemBuilder: (context, index) => _ErrorCard(
        error: errors[index],
        isDark: isDark,
        onStatusChanged: (status, notes) =>
            _updateErrorStatus(errors[index], status, notes),
        onSeverityChanged: (severity) =>
            _updateErrorSeverity(errors[index], severity),
        onDelete: () => _deleteError(errors[index]),
      ),
    );
  }

  Widget _buildListLoading(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isDark ? Colors.white54 : Colors.black38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Carregando erros...',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black38,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListError(Object error, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar logs',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black38,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF34A853).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 48,
                color: const Color(0xFF34A853),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum erro encontrado',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seu aplicativo está funcionando perfeitamente!',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black38,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ACTIONS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _updateErrorStatus(
    ErrorLogEntity error,
    ErrorStatus status,
    String? notes,
  ) async {
    try {
      await ref
          .read(errorLogServiceProvider)
          .updateErrorStatus(error.id, status, adminNotes: notes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateErrorSeverity(
    ErrorLogEntity error,
    ErrorSeverity severity,
  ) async {
    try {
      await ref
          .read(errorLogServiceProvider)
          .updateErrorSeverity(error.id, severity);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteError(ErrorLogEntity error) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este erro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(errorLogServiceProvider).deleteError(error.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showCleanupDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _CleanupDialog(
        onCleanup: (days) async {
          final result = await ref
              .read(errorLogServiceProvider)
              .cleanupOldErrors(days);
          
          if (!mounted) return;
          
          result.fold(
            (failure) {
              final message = failure.message;
              // Check for index error to show a more helpful message
              if (message.contains('requires an index')) {
                // Extract the URL if possible, or just show a friendly message
                final urlRegex = RegExp(r'https://console\.firebase\.google\.com[^\s]+');
                final match = urlRegex.firstMatch(message);
                final url = match?.group(0);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Requer índice no Firestore!'),
                        if (url != null) ...[
                          const SizedBox(height: 4),
                          const Text('Clique no link abaixo para criar:', style: TextStyle(fontSize: 12)),
                          SelectableText(
                            url, 
                            style: const TextStyle(
                              color: Colors.white, 
                              decoration: TextDecoration.underline,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 10),
                    action: SnackBarAction(
                      label: 'Copiar Link',
                      textColor: Colors.white,
                      onPressed: () {
                         if (url != null) {
                           // Use clipboard if available or just leave the text selectable
                           // For now, simpler is better
                         }
                      },
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro: $message'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            (count) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$count erros removidos'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(ErrorStatus status) {
    switch (status) {
      case ErrorStatus.newError:
        return const Color(0xFFEA4335);
      case ErrorStatus.investigating:
        return const Color(0xFFFBBC04);
      case ErrorStatus.fixed:
        return const Color(0xFF34A853);
      case ErrorStatus.ignored:
        return const Color(0xFF9AA0A6);
      case ErrorStatus.wontFix:
        return const Color(0xFF5F6368);
    }
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return const Color(0xFF4285F4);
      case ErrorSeverity.medium:
        return const Color(0xFFFBBC04);
      case ErrorSeverity.high:
        return const Color(0xFFEA4335);
      case ErrorSeverity.critical:
        return const Color(0xFF9C27B0);
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// ERROR CARD WIDGET
// ════════════════════════════════════════════════════════════════════════════════

class _ErrorCard extends StatefulWidget {
  final ErrorLogEntity error;
  final bool isDark;
  final void Function(ErrorStatus, String?) onStatusChanged;
  final void Function(ErrorSeverity) onSeverityChanged;
  final VoidCallback onDelete;

  const _ErrorCard({
    required this.error,
    required this.isDark,
    required this.onStatusChanged,
    required this.onSeverityChanged,
    required this.onDelete,
  });

  @override
  State<_ErrorCard> createState() => _ErrorCardState();
}

class _ErrorCardState extends State<_ErrorCard> {
  bool _isExpanded = false;
  bool _isHovered = false;

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copiado!'),
          behavior: SnackBarBehavior.floating,
          width: 200,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.error;
    final isDark = widget.isDark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _isHovered
            ? (isDark
                  ? Colors.white.withValues(alpha: 0.02)
                  : Colors.grey.shade50)
            : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with badges and actions
              Row(
                children: [
                  // Type badge
                  _buildBadge(
                    label: error.errorType.displayName,
                    color: _getTypeColor(error.errorType),
                    icon: _getTypeIcon(error.errorType),
                  ),
                  const SizedBox(width: 8),
                  // Severity badge
                  _buildBadge(
                    label: error.severity.displayName,
                    color: _getSeverityColor(error.severity),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  _buildBadge(
                    label: error.status.displayName,
                    color: _getStatusColor(error.status),
                    filled: true,
                  ),
                  const Spacer(),
                  // Actions
                  if (_isHovered || _isExpanded) ...[
                    _buildActionButton(
                      icon: Icons.edit_outlined,
                      tooltip: 'Alterar status',
                      onPressed: _showStatusDialog,
                    ),
                    _buildActionButton(
                      icon: Icons.flag_outlined,
                      tooltip: 'Alterar severidade',
                      onPressed: _showSeverityDialog,
                    ),
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      tooltip: 'Excluir',
                      onPressed: widget.onDelete,
                      color: Colors.red,
                    ),
                  ],
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: subtextColor,
                    ),
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Error message title
              Text(
                _getErrorTitle(error.message),
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                maxLines: _isExpanded ? null : 2,
                overflow: _isExpanded ? null : TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Error message preview
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error.message,
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        height: 1.5,
                      ),
                      maxLines: _isExpanded ? null : 3,
                      overflow: _isExpanded ? null : TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: InkWell(
                      onTap: () => _copyToClipboard(error.message, 'Mensagem'),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black45 : Colors.white54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(Icons.copy, size: 14, color: subtextColor),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Metadata row
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildMetaItem(
                    Icons.access_time,
                    _formatDate(error.createdAt),
                  ),
                  _buildMetaItem(Icons.computer, error.platform),
                  if (error.sessionId != null)
                    _buildMetaItem(
                      Icons.fingerprint,
                      error.sessionId!.substring(0, 8),
                    ),
                  if (error.occurrences > 1)
                    _buildMetaItem(
                      Icons.repeat,
                      '${error.occurrences} ocorrências',
                    ),
                ],
              ),

              // Expanded content
              if (_isExpanded) ...[
                const SizedBox(height: 16),

                // Stack trace
                if (error.stackTrace != null &&
                    error.stackTrace!.isNotEmpty) ...[
                  _buildExpandedSection(
                    title: 'Stack Trace',
                    icon: Icons.code,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black38
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            error.stackTrace!,
                            style: TextStyle(
                              color: subtextColor,
                              fontSize: 12,
                              fontFamily: 'monospace',
                              height: 1.5,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: InkWell(
                            onTap: () => _copyToClipboard(
                              error.stackTrace!,
                              'Stack trace',
                            ),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black45 : Colors.white54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.copy,
                                    size: 14,
                                    color: subtextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Copiar',
                                    style: TextStyle(
                                      color: subtextColor,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Admin notes
                if (error.adminNotes != null &&
                    error.adminNotes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildExpandedSection(
                    title: 'Notas do Admin',
                    icon: Icons.note,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        error.adminNotes!,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        label: 'Investigar',
                        icon: Icons.search,
                        color: const Color(0xFFFBBC04),
                        onPressed: () => widget.onStatusChanged(
                          ErrorStatus.investigating,
                          null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionButton(
                        label: 'Marcar Corrigido',
                        icon: Icons.check_circle,
                        color: const Color(0xFF34A853),
                        onPressed: () =>
                            widget.onStatusChanged(ErrorStatus.fixed, null),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionButton(
                        label: 'Ignorar',
                        icon: Icons.do_not_disturb,
                        color: const Color(0xFF9AA0A6),
                        onPressed: () =>
                            widget.onStatusChanged(ErrorStatus.ignored, null),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color color,
    IconData? icon,
    bool filled = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: filled ? null : Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: filled ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: color ?? (widget.isDark ? Colors.white54 : Colors.black38),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    final color = widget.isDark ? Colors.white38 : Colors.black38;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _buildExpandedSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final textColor = widget.isDark ? Colors.white70 : Colors.black54;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _getErrorTitle(String message) {
    final lines = message.split('\n');
    return lines.first.length > 100
        ? '${lines.first.substring(0, 100)}...'
        : lines.first;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getTypeColor(ErrorType type) {
    switch (type) {
      case ErrorType.exception:
        return const Color(0xFFEA4335);
      case ErrorType.assertion:
        return const Color(0xFFFBBC04);
      case ErrorType.network:
        return const Color(0xFF4285F4);
      case ErrorType.timeout:
        return const Color(0xFF9C27B0);
      case ErrorType.parsing:
        return const Color(0xFF00BCD4);
      case ErrorType.render:
        return const Color(0xFFFF5722);
      case ErrorType.state:
        return const Color(0xFF795548);
      case ErrorType.navigation:
        return const Color(0xFF607D8B);
      case ErrorType.other:
        return const Color(0xFF9AA0A6);
    }
  }

  IconData _getTypeIcon(ErrorType type) {
    switch (type) {
      case ErrorType.exception:
        return Icons.error_outline;
      case ErrorType.assertion:
        return Icons.warning_amber;
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.timeout:
        return Icons.timer_off;
      case ErrorType.parsing:
        return Icons.code;
      case ErrorType.render:
        return Icons.brush;
      case ErrorType.state:
        return Icons.memory;
      case ErrorType.navigation:
        return Icons.navigation;
      case ErrorType.other:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(ErrorStatus status) {
    switch (status) {
      case ErrorStatus.newError:
        return const Color(0xFFEA4335);
      case ErrorStatus.investigating:
        return const Color(0xFFFBBC04);
      case ErrorStatus.fixed:
        return const Color(0xFF34A853);
      case ErrorStatus.ignored:
        return const Color(0xFF9AA0A6);
      case ErrorStatus.wontFix:
        return const Color(0xFF5F6368);
    }
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return const Color(0xFF4285F4);
      case ErrorSeverity.medium:
        return const Color(0xFFFBBC04);
      case ErrorSeverity.high:
        return const Color(0xFFEA4335);
      case ErrorSeverity.critical:
        return const Color(0xFF9C27B0);
    }
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _StatusDialog(
        currentStatus: widget.error.status,
        onStatusChanged: widget.onStatusChanged,
      ),
    );
  }

  void _showSeverityDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _SeverityDialog(
        currentSeverity: widget.error.severity,
        onSeverityChanged: widget.onSeverityChanged,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// DIALOGS
// ════════════════════════════════════════════════════════════════════════════════

class _StatusDialog extends StatefulWidget {
  final ErrorStatus currentStatus;
  final void Function(ErrorStatus, String?) onStatusChanged;

  const _StatusDialog({
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  State<_StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<_StatusDialog> {
  late ErrorStatus _selectedStatus;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Alterar Status'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ErrorStatus.values.map((status) {
                final isSelected = status == _selectedStatus;
                final color = _getStatusColor(status);
                return ChoiceChip(
                  label: Text(status.displayName),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedStatus = status),
                  selectedColor: color.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? color : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onStatusChanged(
              _selectedStatus,
              _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            );
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Color _getStatusColor(ErrorStatus status) {
    switch (status) {
      case ErrorStatus.newError:
        return const Color(0xFFEA4335);
      case ErrorStatus.investigating:
        return const Color(0xFFFBBC04);
      case ErrorStatus.fixed:
        return const Color(0xFF34A853);
      case ErrorStatus.ignored:
        return const Color(0xFF9AA0A6);
      case ErrorStatus.wontFix:
        return const Color(0xFF5F6368);
    }
  }
}

class _SeverityDialog extends StatelessWidget {
  final ErrorSeverity currentSeverity;
  final void Function(ErrorSeverity) onSeverityChanged;

  const _SeverityDialog({
    required this.currentSeverity,
    required this.onSeverityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Alterar Severidade'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: ErrorSeverity.values.map((severity) {
          final isSelected = severity == currentSeverity;
          final color = _getSeverityColor(severity);
          return ListTile(
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            title: Text(severity.displayName),
            selected: isSelected,
            onTap: () {
              Navigator.pop(context);
              onSeverityChanged(severity);
            },
          );
        }).toList(),
      ),
    );
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return const Color(0xFF4285F4);
      case ErrorSeverity.medium:
        return const Color(0xFFFBBC04);
      case ErrorSeverity.high:
        return const Color(0xFFEA4335);
      case ErrorSeverity.critical:
        return const Color(0xFF9C27B0);
    }
  }
}

class _CleanupDialog extends StatefulWidget {
  final Future<void> Function(int days) onCleanup;

  const _CleanupDialog({required this.onCleanup});

  @override
  State<_CleanupDialog> createState() => _CleanupDialogState();
}

class _CleanupDialogState extends State<_CleanupDialog> {
  int _selectedDays = 30;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Limpar Erros Antigos'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Remover erros mais antigos que:'),
          const SizedBox(height: 16),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 7, label: Text('7 dias')),
              ButtonSegment(value: 30, label: Text('30 dias')),
              ButtonSegment(value: 90, label: Text('90 dias')),
            ],
            selected: {_selectedDays},
            onSelectionChanged: (value) =>
                setState(() => _selectedDays = value.first),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() => _isLoading = true);
                  await widget.onCleanup(_selectedDays);
                  if (mounted) Navigator.pop(context);
                },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Limpar'),
        ),
      ],
    );
  }
}
