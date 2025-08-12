// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/task_grouping.dart';

class TaskGroupingSidePanel extends StatefulWidget {
  final Function(TaskGrouping grouping) onGroupingChanged;
  final TaskGrouping currentGrouping;

  const TaskGroupingSidePanel({
    super.key,
    required this.onGroupingChanged,
    required this.currentGrouping,
  });

  @override
  State<TaskGroupingSidePanel> createState() => _TaskGroupingSidePanelState();
}

class _TaskGroupingSidePanelState extends State<TaskGroupingSidePanel> {
  late TaskGrouping _selectedGrouping;

  @override
  void initState() {
    super.initState();
    _selectedGrouping = widget.currentGrouping;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 16,
              16,
              16,
            ),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE1E1E1), width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Agrupar Tarefas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGroupingSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupingSection() {
    final groupings = [
      {
        'grouping': TaskGrouping.none,
        'description': 'Listar todas as tarefas sem agrupamento',
        'color': const Color(0xFF666666),
      },
      {
        'grouping': TaskGrouping.date,
        'description': 'Agrupar por data de vencimento',
        'color': const Color(0xFF4CAF50),
      },
      {
        'grouping': TaskGrouping.priority,
        'description': 'Agrupar por nível de prioridade',
        'color': const Color(0xFFFF9800),
      },
      {
        'grouping': TaskGrouping.status,
        'description': 'Agrupar por status de conclusão',
        'color': const Color(0xFF2196F3),
      },
      {
        'grouping': TaskGrouping.tags,
        'description': 'Agrupar por tags e categorias',
        'color': const Color(0xFF9C27B0),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecione como agrupar suas tarefas:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groupings.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            thickness: 0.5,
            color: Color(0xFFE1E1E1),
            indent: 40,
          ),
          itemBuilder: (context, index) {
            final grouping = groupings[index];
            return _buildGroupingTile(
              grouping: grouping['grouping'] as TaskGrouping,
              description: grouping['description'] as String,
              color: grouping['color'] as Color,
            );
          },
        ),
      ],
    );
  }

  Widget _buildGroupingTile({
    required TaskGrouping grouping,
    required String description,
    required Color color,
  }) {
    final isSelected = _selectedGrouping == grouping;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectGrouping(grouping),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
          color:
              isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border:
                      isSelected ? Border.all(color: color, width: 1.5) : null,
                ),
                child: Icon(
                  grouping.icon,
                  color: isSelected ? color : Colors.grey[600],
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grouping.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? color : const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? color.withValues(alpha: 0.8)
                            : const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectGrouping(TaskGrouping grouping) {
    setState(() {
      _selectedGrouping = grouping;
    });

    widget.onGroupingChanged(grouping);
  }
}
