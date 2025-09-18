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
      color: isDark ? const Color(0xFF1C1C1E) : theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Search bar with grid button
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? const Color(0xFF2C2C2E)
                            : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        isDark
                            ? Border.all(
                              color: Colors.grey.withValues(alpha: 0.1),
                            )
                            : Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.3,
                              ),
                            ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? Colors.black.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.06),
                        blurRadius: isDark ? 6 : 8,
                        offset: const Offset(0, 2),
                        spreadRadius: isDark ? 0 : 1,
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: onSearchChanged,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Buscar plantas...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
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

              const SizedBox(width: 8),

              // Grouped by spaces toggle button
              GestureDetector(
                onTap: () {
                  final newMode = viewMode == ViewMode.groupedBySpaces 
                      ? ViewMode.list 
                      : ViewMode.groupedBySpaces;
                  onViewModeChanged(newMode);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: viewMode == ViewMode.groupedBySpaces
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : (isDark
                            ? const Color(0xFF2C2C2E)
                            : theme.colorScheme.surface),
                    borderRadius: BorderRadius.circular(12),
                    border: viewMode == ViewMode.groupedBySpaces
                        ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3))
                        : (isDark
                            ? Border.all(
                              color: Colors.grey.withValues(alpha: 0.1),
                            )
                            : Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.3,
                              ),
                            )),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? Colors.black.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.06),
                        blurRadius: isDark ? 6 : 8,
                        offset: const Offset(0, 2),
                        spreadRadius: isDark ? 0 : 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.category,
                    color: viewMode == ViewMode.groupedBySpaces
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Grid/List toggle button (only show when not grouped)
              if (viewMode != ViewMode.groupedBySpaces)
                GestureDetector(
                  onTap: () {
                    final newMode =
                        viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
                    onViewModeChanged(newMode);
                  },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? const Color(0xFF2C2C2E)
                            : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        isDark
                            ? Border.all(
                              color: Colors.grey.withValues(alpha: 0.1),
                            )
                            : Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.3,
                              ),
                            ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? Colors.black.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.06),
                        blurRadius: isDark ? 6 : 8,
                        offset: const Offset(0, 2),
                        spreadRadius: isDark ? 0 : 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    viewMode == ViewMode.grid
                        ? Icons.view_list
                        : Icons.grid_view,
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
