import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/enums/task_filter.dart';
import '../../core/theme/app_colors.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/tasks/domain/task_entity.dart';
import '../../features/tasks/presentation/providers/task_notifier.dart';
import '../providers/auth_providers.dart';

class FilterSidePanel extends ConsumerStatefulWidget {
  final void Function(TaskFilter filter, String? selectedTag) onFilterChanged;
  final TaskFilter currentFilter;
  final String? currentSelectedTag;

  const FilterSidePanel({
    super.key,
    required this.onFilterChanged,
    required this.currentFilter,
    this.currentSelectedTag,
  });

  @override
  ConsumerState<FilterSidePanel> createState() => _FilterSidePanelState();
}

class _FilterSidePanelState extends ConsumerState<FilterSidePanel>
    with TickerProviderStateMixin {
  late TaskFilter _selectedFilter;
  String? _selectedTag;
  List<String> _availableTags = [];
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter;
    _selectedTag = widget.currentSelectedTag;
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _loadAvailableTags();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _loadAvailableTags() {
    const tasksRequest = GetTasksRequest();
    ref
        .read<Future<List<TaskEntity>>>(getTasksFutureProvider(tasksRequest).future)
        .then((List<TaskEntity> tasks) {
          final tagsSet = <String>{};
          for (final task in tasks) {
            tagsSet.addAll(task.tags);
          }

          if (mounted) {
            setState(() {
              _availableTags = tagsSet.toList()..sort();
            });
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _availableTags = [];
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(4, 0),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.08),
                blurRadius: 40,
                offset: const Offset(8, 0),
              ),
            ],
          ),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildModernUserSection(),
                  _buildQuickStatsSection(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModernFilterSection(),
                          const SizedBox(height: 32),
                          _buildModernTagsSection(),
                          const SizedBox(height: 32),
                          _buildModernActionsSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernUserSection() {
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final userDisplayName = user?.displayName ?? 'Usuário';
    final userEmail = user?.email ?? 'usuario@exemplo.com';
    final userInitials = _getUserInitials(userDisplayName);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryVariant,
            AppColors.primaryColor.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _openSettings(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      userInitials,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, $userDisplayName! 👋',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openSettings(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getUserInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  Widget _buildQuickStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Consumer(
        builder: (context, WidgetRef ref, child) {
          return FutureBuilder<List<TaskEntity>>(
            future: ref.read(getTasksFutureProvider(const GetTasksRequest()).future),
            builder: (context, snapshot) {
              final tasks = snapshot.data ?? <TaskEntity>[];
              final pendingCount =
                  tasks.where((t) => t.status.name == 'pending').length;
              final completedCount =
                  tasks.where((t) => t.status.name == 'completed').length;
              final totalCount = tasks.length;

              return Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.pending_actions,
                      label: 'Pendentes',
                      value: pendingCount.toString(),
                      color: AppColors.warning,
                    ),
                  ),
                  Container(width: 1, height: 32, color: AppColors.divider),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.check_circle,
                      label: 'Completas',
                      value: completedCount.toString(),
                      color: AppColors.success,
                    ),
                  ),
                  Container(width: 1, height: 32, color: AppColors.divider),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.list_alt,
                      label: 'Total',
                      value: totalCount.toString(),
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildModernFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Filtros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...TaskFilter.values.asMap().entries.map((entry) {
          final index = entry.key;
          final filter = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < TaskFilter.values.length - 1 ? 8 : 0,
            ),
            child: _buildModernFilterTile(filter),
          );
        }),
      ],
    );
  }

  Widget _buildModernFilterTile(TaskFilter filter) {
    final isSelected = _selectedFilter == filter;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color:
            isSelected
                ? filter.color.withValues(alpha: 0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border:
            isSelected
                ? Border.all(
                  color: filter.color.withValues(alpha: 0.3),
                  width: 1.5,
                )
                : Border.all(
                  color: AppColors.divider.withValues(alpha: 0.3),
                  width: 1,
                ),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: filter.color.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectFilter(filter),
          borderRadius: BorderRadius.circular(12),
          splashColor: filter.color.withValues(alpha: 0.1),
          highlightColor: filter.color.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? filter.color.withValues(alpha: 0.15)
                            : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    filter.icon,
                    color: isSelected ? filter.color : AppColors.textSecondary,
                    size: 18,
                  ),
                ),

                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filter.displayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color:
                              isSelected
                                  ? filter.color
                                  : Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        filter.description,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child:
                      isSelected
                          ? Container(
                            key: const ValueKey('selected'),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: filter.color,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          )
                          : Container(
                            key: const ValueKey('unselected'),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.divider,
                                width: 1.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Tags',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            if (_availableTags.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_availableTags.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_availableTags.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.05),
                  AppColors.secondary.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  color: AppColors.secondary.withValues(alpha: 0.6),
                  size: 32,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Nenhuma tag encontrada',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Crie tarefas com tags para organizá-las melhor',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildModernTagChip(null, isAllChip: true),
              ..._availableTags.map((tag) => _buildModernTagChip(tag)),
            ],
          ),
      ],
    );
  }

  Widget _buildModernTagChip(String? tag, {bool isAllChip = false}) {
    final isSelected = isAllChip ? _selectedTag == null : _selectedTag == tag;
    final displayText = isAllChip ? 'Todas' : tag!;
    final chipColor = isAllChip ? AppColors.secondary : _getTagColor(tag);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectTag(isAllChip ? null : tag),
          borderRadius: BorderRadius.circular(20),
          splashColor: chipColor.withValues(alpha: 0.1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient:
                  isSelected
                      ? LinearGradient(
                        colors: [
                          chipColor.withValues(alpha: 0.15),
                          chipColor.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : null,
              color:
                  isSelected
                      ? null
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border.all(
                color:
                    isSelected
                        ? chipColor.withValues(alpha: 0.4)
                        : AppColors.divider.withValues(alpha: 0.5),
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: chipColor.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? chipColor
                            : AppColors.textSecondary.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: chipColor.withValues(alpha: 0.3),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ]
                            : null,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isSelected
                            ? chipColor
                            : Theme.of(context).textTheme.bodyMedium?.color,
                    letterSpacing: 0.1,
                  ),
                ),
                if (isSelected && !isAllChip) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.check_circle, size: 14, color: chipColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTagColor(String? tag) {
    if (tag == null) return AppColors.primaryColor;
    final colors = [
      AppColors.primaryColor,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF673AB7), // Deep Purple
      const Color(0xFF3F51B5), // Indigo
      const Color(0xFF009688), // Teal
      const Color(0xFF4CAF50), // Green
    ];

    return colors[tag.hashCode % colors.length];
  }

  Widget _buildModernActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.divider.withValues(alpha: 0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.settings_outlined,
                label: 'Configurações',
                color: AppColors.primaryColor,
                onTap: () => _openSettings(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.logout_outlined,
                label: 'Sair',
                color: AppColors.error,
                onTap: () => _handleLogout(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildActionButton(
            icon: Icons.help_outline,
            label: 'Ajuda e Suporte',
            color: AppColors.secondary,
            onTap: () => _showHelpDialog(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.08),
                color.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await ref.read(authProvider.notifier).signOut();
      if (mounted) {
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showHelpDialog() {
    showDialog<dynamic>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ajuda e Suporte'),
            content: const Text(
              'Para suporte, entre em contato conosco através do email: '
              'suporte@taskolist.com\n\n'
              'Ou visite nossa página de ajuda para mais informações.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  void _selectFilter(TaskFilter filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter != TaskFilter.all) {
        _selectedTag = null;
      }
    });

    widget.onFilterChanged(filter, _selectedTag);
  }

  void _selectTag(String? tag) {
    setState(() {
      _selectedTag = tag;
      if (tag != null) {
        _selectedFilter = TaskFilter.all;
      }
    });

    widget.onFilterChanged(_selectedFilter, _selectedTag);
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute<dynamic>(builder: (context) => const SettingsPage()),
    );
  }
}
