import 'package:flutter/material.dart';
import '../providers/plants_provider.dart';

class PlantsAppBar extends StatelessWidget {
  final int plantsCount;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onViewModeChanged;

  const PlantsAppBar({
    super.key,
    required this.plantsCount,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      color: isDark ? const Color(0xFF000000) : theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Header with title and badge
          Row(
            children: [
              Text(
                'Minhas Plantas',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              // Badge with plant count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.secondary),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  plantsCount == 1 
                      ? '$plantsCount planta' 
                      : '$plantsCount plantas',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Search bar with grid button
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: isDark ? null : Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  child: TextField(
                    onChanged: onSearchChanged,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Buscar plantas...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Grid/List toggle button
              GestureDetector(
                onTap: () {
                  final newMode = viewMode == ViewMode.grid 
                      ? ViewMode.list 
                      : ViewMode.grid;
                  onViewModeChanged(newMode);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: isDark ? null : Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  child: Icon(
                    viewMode == ViewMode.grid ? Icons.grid_view : Icons.view_list,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}