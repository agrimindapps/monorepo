// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/auth_controller.dart';
import '../dependency_injection.dart';

enum TaskFilter {
  today,
  overdue,
  starred,
  week,
  all,
}

class TaskFilterSidePanel extends StatefulWidget {
  final Function(TaskFilter filter, String? selectedTag) onFilterChanged;
  final TaskFilter currentFilter;
  final String? currentSelectedTag;

  const TaskFilterSidePanel({
    super.key,
    required this.onFilterChanged,
    required this.currentFilter,
    this.currentSelectedTag,
  });

  @override
  State<TaskFilterSidePanel> createState() => _TaskFilterSidePanelState();
}

class _TaskFilterSidePanelState extends State<TaskFilterSidePanel> {
  late TaskFilter _selectedFilter;
  String? _selectedTag;
  List<String> _availableTags = [];
  StreamSubscription? _tagsSubscription;

  @override
  void initState() {
    super.initState();
    // Inicializar com os valores atuais passados pelo widget pai
    _selectedFilter = widget.currentFilter;
    _selectedTag = widget.currentSelectedTag;
    _loadAvailableTags();
  }

  void _loadAvailableTags() {
    // Usar stream para carregar tags dinamicamente
    _tagsSubscription = DependencyContainer.instance.taskRepository.tasksStream.listen((tasks) {
      final tagsSet = <String>{};
      for (final task in tasks) {
        tagsSet.addAll(task.tags);
      }

      if (mounted) {
        setState(() {
          _availableTags = tagsSet.toList()..sort();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 0),
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
                  _buildExitModuleSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF4CAF50),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
        ),
      ),
      child: Obx(() {
        final authController = Get.find<TodoistAuthController>();
        final user = authController.currentUser;
        final isGuest = authController.isGuestMode;

        return Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isGuest
                      ? const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 24,
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGuest
                          ? 'Modo Convidado'
                          : (user?.displayName ?? 'Usuário'),
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
                      isGuest
                          ? 'Dados salvos localmente'
                          : (user?.email ?? 'email@exemplo.com'),
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
        );
      }),
    );
  }

  Widget _buildFilterSection() {
    final filters = [
      {
        'icon': Icons.list_alt,
        'title': 'Todas as tarefas',
        'filter': TaskFilter.all,
        'color': const Color(0xFF666666),
      },
      {
        'icon': Icons.today,
        'title': 'Hoje',
        'filter': TaskFilter.today,
        'color': const Color(0xFF4CAF50),
      },
      {
        'icon': Icons.schedule,
        'title': 'Vencidas',
        'filter': TaskFilter.overdue,
        'color': Colors.red,
      },
      {
        'icon': Icons.star,
        'title': 'Favoritas',
        'filter': TaskFilter.starred,
        'color': const Color(0xFFFFB84D),
      },
      {
        'icon': Icons.date_range,
        'title': 'Esta semana',
        'filter': TaskFilter.week,
        'color': const Color(0xFF3A5998),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filters.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            thickness: 0.5,
            color: Color(0xFFE1E1E1),
            indent: 38,
          ),
          itemBuilder: (context, index) {
            final filter = filters[index];
            return _buildFilterTile(
              icon: filter['icon'] as IconData,
              title: filter['title'] as String,
              filter: filter['filter'] as TaskFilter,
              color: filter['color'] as Color,
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterTile({
    required IconData icon,
    required String title,
    required TaskFilter filter,
    required Color color,
  }) {
    final isSelected = _selectedFilter == filter;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectFilter(filter),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          color:
              isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? color : const Color(0xFF666666),
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                    color: isSelected ? color : const Color(0xFF2C2C2C),
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: color,
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
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 12),
        if (_availableTags.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE1E1E1)),
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF9F9F9),
            ),
            child: const Text(
              'Nenhuma tag encontrada.\nCrie tarefas com tags para vê-las aqui.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
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
              // Adicionar chip "Todas" no início
              _buildTagChip(null, isAllChip: true),
              // Depois as tags específicas
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
                ? const Color(0xFF3A5998).withValues(alpha: 0.1)
                : const Color(0xFFF1F1F1),
            border: isSelected
                ? Border.all(color: const Color(0xFF3A5998), width: 1)
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
                      ? const Color(0xFF3A5998)
                      : const Color(0xFF666666),
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
                      ? const Color(0xFF3A5998)
                      : const Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
        ),
      ),
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
      // Se selecionar "Todas" (tag == null), manter o filtro atual
      if (tag != null) {
        _selectedFilter = TaskFilter.all;
      }
    });

    widget.onFilterChanged(_selectedFilter, _selectedTag);
  }

  Widget _buildExitModuleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          height: 1,
          thickness: 0.5,
          color: Color(0xFFE1E1E1),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showExitModuleConfirmation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
            icon: const Icon(Icons.exit_to_app, size: 20),
            label: const Text(
              'Sair do Módulo',
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

  void _showExitModuleConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do Módulo'),
        content: const Text(
          'Tem certeza de que deseja sair do Todoist e retornar ao menu principal?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fechar diálogo
              Navigator.pop(context); // Fechar sidebar
              _exitModule();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _exitModule() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/app-select',
      (route) => false,
    );
  }

  void _openSettings() {
    // Fechar o painel atual
    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurações'),
        content: Obx(() {
          final authController = Get.find<TodoistAuthController>();
          if (authController.isGuestMode) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Você está no modo convidado.\n\nDeseja fazer login com uma conta?',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        authController.exitGuestMode();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Fazer Login'),
                    ),
                  ),
                ],
              );
          } else {
            return const Text('Mais opções de configurações em breve...');
          }
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Cancel the tags subscription to prevent memory leaks
    _tagsSubscription?.cancel();
    super.dispose();
  }
}
