import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/admin_layout.dart';

/// Dashboard administrativo para gerenciar feedbacks
/// 
/// Design profissional inspirado no Firebase Crashlytics com:
/// - Cards de estatísticas elegantes
/// - Filtros intuitivos com chips
/// - Cards expandíveis com detalhes
/// - Ações rápidas
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  FeedbackStatus? _statusFilter;
  FeedbackType? _typeFilter;
  String _searchQuery = '';
  bool _sortAscending = false;
  final _searchController = TextEditingController();

  // Calculei theme colors
  static const _primaryColor = Color(0xFF009688); // Teal
  static const _cardColor = Color(0xFF252545);

  // Google Material colors for stats
  static const _googleBlue = Color(0xFF4285F4);
  static const _googleRed = Color(0xFFEA4335);
  static const _googleYellow = Color(0xFFFBBC04);
  static const _googleGreen = Color(0xFF34A853);
  static const _googleGrey = Color(0xFF9AA0A6);
  static const _googlePurple = Color(0xFF9334E6);

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
            
            const SizedBox(height: 24),
            
            // Feedbacks Section
            _buildFeedbacksSection(feedbacksAsync, isDark),
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
    AsyncValue<Map<FeedbackStatus, int>> countsAsync,
    bool isDark,
  ) {
    return countsAsync.when(
      loading: () => _buildStatsLoading(isDark),
      error: (_, __) => const SizedBox.shrink(),
      data: (counts) {
        final total = counts.values.fold(0, (a, b) => a + b);
        final pending = counts[FeedbackStatus.pending] ?? 0;
        final reviewed = counts[FeedbackStatus.reviewed] ?? 0;
        final resolved = counts[FeedbackStatus.resolved] ?? 0;
        final archived = counts[FeedbackStatus.archived] ?? 0;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: _buildStatCard(
                    label: 'Total de Feedbacks',
                    value: total,
                    icon: Icons.feedback_outlined,
                    color: _googleBlue,
                    isDark: isDark,
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(
                    label: 'Pendentes',
                    value: pending,
                    icon: Icons.pending_outlined,
                    color: _googleYellow,
                    isDark: isDark,
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(
                    label: 'Revisados',
                    value: reviewed,
                    icon: Icons.visibility_outlined,
                    color: _googlePurple,
                    isDark: isDark,
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(
                    label: 'Resolvidos',
                    value: resolved,
                    icon: Icons.check_circle_outlined,
                    color: _googleGreen,
                    isDark: isDark,
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(
                    label: 'Arquivados',
                    value: archived,
                    icon: Icons.archive_outlined,
                    color: _googleGrey,
                    isDark: isDark,
                  )),
                ],
              );
            } else {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        label: 'Total',
                        value: total,
                        icon: Icons.feedback_outlined,
                        color: _googleBlue,
                        isDark: isDark,
                        compact: true,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(
                        label: 'Pendentes',
                        value: pending,
                        icon: Icons.pending_outlined,
                        color: _googleYellow,
                        isDark: isDark,
                        compact: true,
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        label: 'Revisados',
                        value: reviewed,
                        icon: Icons.visibility_outlined,
                        color: _googlePurple,
                        isDark: isDark,
                        compact: true,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(
                        label: 'Resolvidos',
                        value: resolved,
                        icon: Icons.check_circle_outlined,
                        color: _googleGreen,
                        isDark: isDark,
                        compact: true,
                      )),
                    ],
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Widget _buildStatsLoading(bool isDark) {
    return Row(
      children: List.generate(5, (index) => Expanded(
        child: AnimatedContainer(duration: const Duration(milliseconds: 300), 
          height: 100,
          margin: EdgeInsets.only(left: index > 0 ? 16 : 0),
          decoration: BoxDecoration(
            color: isDark ? _cardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _primaryColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildStatCard({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    required bool isDark,
    bool compact = false,
  }) {
    return AnimatedContainer(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, 
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        color: isDark ? _cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: compact ? 20 : 24),
              ),
            ],
          ),
          SizedBox(height: compact ? 12 : 16),
          Text(
            '$value',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: compact ? 28 : 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: compact ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // FEEDBACKS SECTION - Lista com filtros e cards expandíveis
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildFeedbacksSection(
    AsyncValue<List<FeedbackEntity>> feedbacksAsync,
    bool isDark,
  ) {
    return AnimatedContainer(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, 
      decoration: BoxDecoration(
        color: isDark ? _cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildSectionHeader(isDark),
          
          // Search and Filters
          _buildFiltersBar(isDark),
          
          // Feedbacks List
          feedbacksAsync.when(
            loading: () => Container(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: CircularProgressIndicator(color: _primaryColor),
              ),
            ),
            error: (error, _) => Container(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: _googleRed, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar feedbacks',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$error',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (feedbacks) {
              // Apply search filter
              var filtered = _searchQuery.isEmpty
                  ? feedbacks
                  : feedbacks.where((f) =>
                      f.message.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (f.userEmail?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                      (f.calculatorName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
                    ).toList();

              // Apply sorting
              filtered.sort((a, b) => _sortAscending 
                  ? a.createdAt.compareTo(b.createdAt) 
                  : b.createdAt.compareTo(a.createdAt));

              if (filtered.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _FeedbackCard(
                  feedback: filtered[index],
                  isDark: isDark,
                  primaryColor: _primaryColor,
                  onStatusChanged: (newStatus, notes) async {
                    final actions = ref.read(feedbackActionsProvider.notifier);
                    final success = await actions.updateStatus(
                      filtered[index].id,
                      newStatus,
                      adminNotes: notes,
                    );
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Status atualizado para ${newStatus.displayName}'),
                          backgroundColor: _googleGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  },
                  onDelete: () => _confirmDelete(context, filtered[index], isDark),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark) {
    return AnimatedContainer(duration: const Duration(milliseconds: 300), 
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.feedback_outlined,
              color: _primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feedbacks Recebidos',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gerencie os feedbacks dos usuários',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersBar(bool isDark) {
    return AnimatedContainer(duration: const Duration(milliseconds: 300), 
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search
          TextField(
            controller: _searchController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'Buscar por mensagem, email ou calculadora...',
              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
              prefixIcon: Icon(
                Icons.search,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? _cardColor : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),
          // Sort option
          Row(
            children: [
              Text(
                'Ordenar por data:',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => setState(() => _sortAscending = !_sortAscending),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        _sortAscending ? 'Mais antigos' : 'Mais recentes',
                        style: TextStyle(
                          color: _primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                        color: _primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status filters
                _buildFilterChip(
                  label: 'Todos',
                  isSelected: _statusFilter == null,
                  onTap: () => setState(() => _statusFilter = null),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                ...FeedbackStatus.values.map((status) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    label: status.displayName,
                    isSelected: _statusFilter == status,
                    onTap: () => setState(() => _statusFilter = status),
                    color: _getStatusColor(status),
                    isDark: isDark,
                  ),
                )),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 24,
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
                const SizedBox(width: 8),
                // Type filters
                _buildFilterChip(
                  label: 'Todos tipos',
                  isSelected: _typeFilter == null,
                  onTap: () => setState(() => _typeFilter = null),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                ...FeedbackType.values.map((type) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    label: '${type.emoji} ${type.displayName}',
                    isSelected: _typeFilter == type,
                    onTap: () => setState(() => _typeFilter = type),
                    isDark: isDark,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    Color? color,
  }) {
    final chipColor = color ?? _primaryColor;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? chipColor.withValues(alpha: 0.15)
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? chipColor : Colors.transparent,
              width: 1.5,
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
    );
  }

  Color _getStatusColor(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.pending:
        return _googleYellow;
      case FeedbackStatus.reviewed:
        return _googlePurple;
      case FeedbackStatus.resolved:
        return _googleGreen;
      case FeedbackStatus.archived:
        return _googleGrey;
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 48,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum feedback encontrado',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tente ajustar os filtros ou termo de busca'
                  : 'Os feedbacks aparecerão aqui quando forem enviados',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    FeedbackEntity feedback,
    bool isDark,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? _cardColor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _googleRed),
            const SizedBox(width: 12),
            Text(
              'Confirmar exclusão',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
          ],
        ),
        content: Text(
          'Deseja realmente excluir este feedback? Esta ação não pode ser desfeita.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: TextStyle(color: _primaryColor)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _googleRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
          SnackBar(
            content: const Text('Feedback excluído com sucesso'),
            backgroundColor: _googleGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}

/// Card individual de feedback com design profissional
class _FeedbackCard extends StatefulWidget {
  const _FeedbackCard({
    required this.feedback,
    required this.isDark,
    required this.primaryColor,
    required this.onStatusChanged,
    required this.onDelete,
  });

  final FeedbackEntity feedback;
  final bool isDark;
  final Color primaryColor;
  final void Function(FeedbackStatus status, String? notes) onStatusChanged;
  final VoidCallback onDelete;

  @override
  State<_FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<_FeedbackCard> {
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

  static const _cardColor = Color(0xFF252545);
  static const _googleBlue = Color(0xFF4285F4);
  static const _googleRed = Color(0xFFEA4335);
  static const _googleYellow = Color(0xFFFBBC04);
  static const _googleGreen = Color(0xFF34A853);
  static const _googleGrey = Color(0xFF9AA0A6);
  static const _googlePurple = Color(0xFF9334E6);

  Color get _statusColor {
    switch (widget.feedback.status) {
      case FeedbackStatus.pending:
        return _googleYellow;
      case FeedbackStatus.reviewed:
        return _googlePurple;
      case FeedbackStatus.resolved:
        return _googleGreen;
      case FeedbackStatus.archived:
        return _googleGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isDark ? _cardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? _statusColor.withValues(alpha: 0.5)
                : _statusColor.withValues(alpha: 0.2),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: _statusColor.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content (always visible)
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _googleBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.feedback.type.emoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                widget.feedback.type.displayName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _googleBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.feedback.status.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: _statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Rating
                        if (widget.feedback.rating != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  widget.feedback.rating!.toStringAsFixed(0),
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // Expand indicator
                        Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: widget.isDark ? Colors.white38 : Colors.black38,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Message
                    Text(
                      widget.feedback.message,
                      style: TextStyle(
                        color: widget.isDark ? Colors.white : Colors.black87,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      maxLines: _isExpanded ? null : 3,
                      overflow: _isExpanded ? null : TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),

                    // Metadata row
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _buildMetaItem(
                          Icons.access_time,
                          DateFormat('dd/MM/yyyy HH:mm').format(widget.feedback.createdAt),
                        ),
                        if (widget.feedback.platform != null)
                          _buildMetaItem(
                            _platformIcon(widget.feedback.platform!),
                            widget.feedback.platform!,
                          ),
                        if (widget.feedback.calculatorName != null)
                          _buildMetaItem(
                            Icons.calculate,
                            widget.feedback.calculatorName!,
                          ),
                        if (widget.feedback.userEmail != null)
                          _buildMetaItem(
                            Icons.email_outlined,
                            widget.feedback.userEmail!,
                            isCopyable: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content
            if (_isExpanded) ...[
              // Admin notes
              if (widget.feedback.adminNotes != null && widget.feedback.adminNotes!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note_alt_outlined, color: widget.primaryColor, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notas do Admin',
                              style: TextStyle(
                                color: widget.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.feedback.adminNotes!,
                              style: TextStyle(
                                color: widget.isDark ? Colors.white70 : Colors.black54,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Action buttons
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.visibility_outlined,
                      label: 'Revisar',
                      color: _googlePurple,
                      isActive: widget.feedback.status == FeedbackStatus.reviewed,
                      onTap: () => _showNotesDialog(FeedbackStatus.reviewed),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.check_circle_outline,
                      label: 'Resolver',
                      color: _googleGreen,
                      isActive: widget.feedback.status == FeedbackStatus.resolved,
                      onTap: () => _showNotesDialog(FeedbackStatus.resolved),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.archive_outlined,
                      label: 'Arquivar',
                      color: _googleGrey,
                      isActive: widget.feedback.status == FeedbackStatus.archived,
                      onTap: () => _showNotesDialog(FeedbackStatus.archived),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      label: 'Excluir',
                      color: _googleRed,
                      isActive: false,
                      onTap: widget.onDelete,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text, {bool isCopyable = false}) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: widget.isDark ? Colors.white38 : Colors.black38),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: widget.isDark ? Colors.white38 : Colors.black38,
            decoration: isCopyable ? TextDecoration.underline : null,
            decorationStyle: TextDecorationStyle.dotted,
          ),
        ),
        if (isCopyable) ...[
          const SizedBox(width: 4),
          Icon(Icons.copy, size: 10, color: widget.isDark ? Colors.white38 : Colors.black38),
        ],
      ],
    );

    if (!isCopyable) return content;

    return InkWell(
      onTap: () => _copyToClipboard(text, text),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: content,
      ),
    );
  }

  IconData _platformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android': return Icons.android;
      case 'ios': return Icons.phone_iphone;
      case 'web': return Icons.language;
      case 'macos': return Icons.laptop_mac;
      case 'windows': return Icons.desktop_windows;
      default: return Icons.device_unknown;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? color : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: isActive ? 1.0 : 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isActive ? Colors.white : color,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotesDialog(FeedbackStatus newStatus) {
    final notesController = TextEditingController(text: widget.feedback.adminNotes);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark ? _cardColor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(_getStatusIcon(newStatus), color: _getStatusColor(newStatus)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Alterar para ${newStatus.displayName}',
                style: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adicione uma nota (opcional):',
              style: TextStyle(
                color: widget.isDark ? Colors.white60 : Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Notas do administrador...',
                hintStyle: TextStyle(
                  color: widget.isDark ? Colors.white38 : Colors.black38,
                ),
                filled: true,
                fillColor: widget.isDark ? Colors.black26 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: widget.primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onStatusChanged(
                newStatus,
                notesController.text.trim().isEmpty ? null : notesController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(newStatus),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.pending: return Icons.pending_outlined;
      case FeedbackStatus.reviewed: return Icons.visibility_outlined;
      case FeedbackStatus.resolved: return Icons.check_circle_outline;
      case FeedbackStatus.archived: return Icons.archive_outlined;
    }
  }

  Color _getStatusColor(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.pending: return _googleYellow;
      case FeedbackStatus.reviewed: return _googlePurple;
      case FeedbackStatus.resolved: return _googleGreen;
      case FeedbackStatus.archived: return _googleGrey;
    }
  }
}
