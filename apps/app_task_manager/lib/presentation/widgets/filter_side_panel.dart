import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/task_filter.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_providers.dart';
import '../providers/task_providers.dart';
import '../pages/settings_page.dart';

class FilterSidePanel extends ConsumerStatefulWidget {
  final Function(TaskFilter filter, String? selectedTag) onFilterChanged;
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

class _FilterSidePanelState extends ConsumerState<FilterSidePanel> {
  late TaskFilter _selectedFilter;
  String? _selectedTag;
  List<String> _availableTags = [];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter;
    _selectedTag = widget.currentSelectedTag;
    _loadAvailableTags();
  }

  void _loadAvailableTags() {
    // Obter todas as tasks para extrair tags
    final tasksRequest = GetTasksRequest();
    ref.read(getTasksProvider(tasksRequest).future).then((tasks) {
      final tagsSet = <String>{};
      for (final task in tasks) {
        tagsSet.addAll(task.tags);
      }

      if (mounted) {
        setState(() {
          _availableTags = tagsSet.toList()..sort();
        });
      }
    }).catchError((error) {
      // Em caso de erro, manter lista vazia
      if (mounted) {
        setState(() {
          _availableTags = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // User Section
          _buildUserSection(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(),
                  const SizedBox(height: 20),
                  _buildTagsSection(),
                  const SizedBox(height: 20),
                  _buildActionsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection() {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value;
    final userDisplayName = user?.displayName ?? 'Usuário';
    final userEmail = user?.email ?? 'usuario@exemplo.com';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        16,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userDisplayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Settings Icon
          GestureDetector(
            onTap: () => _openSettings(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: TaskFilter.values.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 0.5,
            color: Theme.of(context).dividerColor,
            indent: 38,
          ),
          itemBuilder: (context, index) {
            final filter = TaskFilter.values[index];
            return _buildFilterTile(filter);
          },
        ),
      ],
    );
  }

  Widget _buildFilterTile(TaskFilter filter) {
    final isSelected = _selectedFilter == filter;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectFilter(filter),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          color: isSelected 
              ? filter.color.withValues(alpha: 0.08) 
              : Colors.transparent,
          child: Row(
            children: [
              Icon(
                filter.icon,
                color: isSelected ? filter.color : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  filter.displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    color: isSelected 
                        ? filter.color 
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: filter.color,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        if (_availableTags.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Text(
              'Nenhuma tag encontrada.\nCrie tarefas com tags para vê-las aqui.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Chip "Todas" no início
              _buildTagChip(null, isAllChip: true),
              // Tags específicas
              ..._availableTags.map((tag) => _buildTagChip(tag)),
            ],
          ),
      ],
    );
  }

  Widget _buildTagChip(String? tag, {bool isAllChip = false}) {
    final isSelected = isAllChip ? _selectedTag == null : _selectedTag == tag;
    final displayText = isAllChip ? 'Todas' : tag!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectTag(isAllChip ? null : tag),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryColor.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            border: isSelected
                ? Border.all(color: AppColors.primaryColor, width: 1)
                : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                displayText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primaryColor
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          height: 1,
          thickness: 0.5,
          color: Theme.of(context).dividerColor,
        ),
        const SizedBox(height: 16),
        
        // Botão de Configurações Rápidas
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openSettings(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: BorderSide(color: AppColors.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.settings, size: 20),
            label: const Text(
              'Configurações',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selectFilter(TaskFilter filter) {
    setState(() {
      _selectedFilter = filter;
      // Limpar tag selecionada ao mudar filtro
      if (filter != TaskFilter.all) {
        _selectedTag = null;
      }
    });

    widget.onFilterChanged(filter, _selectedTag);
  }

  void _selectTag(String? tag) {
    setState(() {
      _selectedTag = tag;
      // Se selecionar uma tag específica, voltar para "todas as tarefas"
      if (tag != null) {
        _selectedFilter = TaskFilter.all;
      }
    });

    widget.onFilterChanged(_selectedFilter, _selectedTag);
  }

  void _openSettings() {
    // Fechar o painel atual
    Navigator.of(context).pop();

    // Navegar para a página de configurações
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }
}