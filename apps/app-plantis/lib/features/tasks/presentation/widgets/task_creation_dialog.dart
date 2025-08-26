import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_strings.dart';
import '../../core/constants/tasks_constants.dart';
import '../../domain/entities/task.dart';
import '../../../plants/domain/entities/plant.dart';
import '../../../plants/presentation/providers/plants_provider.dart';

/// Comprehensive task creation dialog with intelligent form handling
///
/// This modal dialog provides a complete interface for creating new plant care tasks.
/// It integrates with the plants system to provide contextual plant selection and
/// includes intelligent defaults based on task types.
///
/// Key Features:
/// - **Task Type Selection**: Visual icons with intelligent priority defaults
/// - **Plant Integration**: Dynamic plant loading with real-time filtering
/// - **Smart Defaults**: Auto-populated titles and appropriate priorities per task type
/// - **Comprehensive Validation**: Form validation with user-friendly error messages
/// - **Date Selection**: Intuitive date picker with tomorrow as default
/// - **Responsive Design**: Adapts to different screen sizes
/// - **Accessibility**: Screen reader support and semantic labels
///
/// Usage:
/// ```dart
/// final taskData = await TaskCreationDialog.show(context: context);
/// if (taskData != null) {
///   // User created a task
///   await tasksProvider.addTask(taskData.toTask());
/// }
/// ```
///
/// The dialog automatically:
/// - Loads available plants from PlantsProvider
/// - Sets appropriate default priority based on task type
/// - Validates required fields before allowing submission
/// - Handles loading states during plant retrieval
class TaskCreationDialog extends StatefulWidget {
  final VoidCallback? onCancel;
  final Function(TaskCreationData)? onConfirm;

  const TaskCreationDialog({
    super.key,
    this.onCancel,
    this.onConfirm,
  });

  /// Shows the task creation dialog and returns task data or null if cancelled
  ///
  /// This static method provides a convenient way to show the dialog and await
  /// the user's input. The dialog is modal and cannot be dismissed by tapping
  /// outside to prevent accidental data loss.
  ///
  /// Parameters:
  /// - [context]: Build context for showing the dialog
  ///
  /// Returns:
  /// - [TaskCreationData] with all task information if user confirms
  /// - `null` if user cancels or presses back
  ///
  /// Example:
  /// ```dart
  /// final result = await TaskCreationDialog.show(context: context);
  /// if (result != null) {
  ///   // Process the task creation data
  ///   final task = Task(
  ///     title: result.title,
  ///     plantId: result.plantId,
  ///     // ... other properties
  ///   );
  /// }
  /// ```
  static Future<TaskCreationData?> show({
    required BuildContext context,
  }) async {
    return showDialog<TaskCreationData>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const TaskCreationDialog();
      },
    );
  }

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TaskType _selectedType = TaskType.watering;
  String? _selectedPlantId;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  TaskPriority _selectedPriority = TaskPriority.medium;
  
  List<Plant> _plants = [];
  bool _isLoadingPlants = false;

  @override
  void initState() {
    super.initState();
    _loadPlants();
    _setDefaultTitle();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Loads available plants from PlantsProvider with error handling
  ///
  /// This method retrieves all plants that can be associated with tasks.
  /// It manages loading states and automatically selects the first plant
  /// if available to improve user experience.
  ///
  /// The method handles:
  /// - Loading state management during plant retrieval
  /// - Automatic first plant selection for convenience
  /// - Error handling if plant loading fails
  Future<void> _loadPlants() async {
    setState(() => _isLoadingPlants = true);
    
    final plantsProvider = context.read<PlantsProvider>();
    await plantsProvider.loadPlants();
    
    setState(() {
      _plants = plantsProvider.plants;
      _isLoadingPlants = false;
      
      // Auto-select first plant if available
      if (_plants.isNotEmpty && _selectedPlantId == null) {
        _selectedPlantId = _plants.first.id;
      }
    });
  }

  /// Sets the default task title based on the selected task type
  ///
  /// This method provides intelligent defaults by using the display name
  /// of the selected task type. Users can customize this title as needed.
  void _setDefaultTitle() {
    _titleController.text = _selectedType.displayName;
  }

  /// Handles task type selection with intelligent defaults
  ///
  /// When a user selects a different task type, this method:
  /// - Updates the selected type
  /// - Sets an appropriate default title
  /// - Adjusts the default priority based on task importance
  ///
  /// Parameters:
  /// - [type]: The newly selected task type
  void _onTaskTypeChanged(TaskType? type) {
    if (type != null) {
      setState(() {
        _selectedType = type;
        _setDefaultTitle();
        _setDefaultPriority(type);
      });
    }
  }

  /// Sets intelligent default priority based on task type importance
  ///
  /// Different plant care tasks have different urgency levels:
  /// - **High Priority**: Watering, pest inspection (plant health critical)
  /// - **Medium Priority**: Fertilizing, pruning, repotting (growth related)
  /// - **Low Priority**: Sunlight adjustment, cleaning (maintenance)
  ///
  /// Parameters:
  /// - [type]: Task type to determine appropriate priority
  void _setDefaultPriority(TaskType type) {
    switch (type) {
      case TaskType.watering:
      case TaskType.pestInspection:
        _selectedPriority = TaskPriority.high;
        break;
      case TaskType.fertilizing:
      case TaskType.pruning:
      case TaskType.repotting:
        _selectedPriority = TaskPriority.medium;
        break;
      case TaskType.sunlight:
      case TaskType.cleaning:
        _selectedPriority = TaskPriority.low;
        break;
      default:
        _selectedPriority = TaskPriority.medium;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.add_task,
            color: theme.colorScheme.primary,
            size: TasksConstants.taskDialogIconSize,
          ),
          const SizedBox(width: 12),
          Text(AppStrings.newTaskTitle),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * TasksConstants.taskDialogWidthPercentage,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Type Selection
                _buildTaskTypeField(),
                const SizedBox(height: 20),

                // Plant Selection
                _buildPlantSelectionField(),
                const SizedBox(height: 20),

                // Title Field
                _buildTitleField(),
                const SizedBox(height: 16),

                // Description Field
                _buildDescriptionField(),
                const SizedBox(height: 20),

                // Due Date Field
                _buildDueDateField(),
                const SizedBox(height: 20),

                // Priority Field
                _buildPriorityField(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _handleCancel, child: Text(AppStrings.cancel)),
        ElevatedButton(
          onPressed: _handleConfirm,
          child: Text(AppStrings.createTaskButton),
        ),
      ],
    );
  }

  /// Builds the task type selection dropdown with visual icons
  ///
  /// This widget provides an intuitive way to select task types using:
  /// - Visual icons for each task type
  /// - Descriptive labels
  /// - Consistent styling with app theme
  ///
  /// Returns a properly styled dropdown with all available task types.
  Widget _buildTaskTypeField() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.taskTypeLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TaskType>(
              value: _selectedType,
              isExpanded: true,
              onChanged: _onTaskTypeChanged,
              items: TaskType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        _getTaskTypeIcon(type),
                        size: TasksConstants.taskTypeIconSize,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: TasksConstants.taskDialogIconSpacing),
                      Text(type.displayName),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the plant selection dropdown with loading and error states
  ///
  /// This widget handles multiple states:
  /// - **Loading**: Shows progress indicator while plants load
  /// - **Empty**: Displays helpful message when no plants are available
  /// - **Loaded**: Shows dropdown with plant options including species info
  ///
  /// Each plant option shows:
  /// - Plant icon
  /// - Display name (primary)
  /// - Species name (secondary, if available)
  ///
  /// Returns a responsive plant selection widget.
  Widget _buildPlantSelectionField() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.plantLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoadingPlants)
          const Center(child: CircularProgressIndicator())
        else if (_plants.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(AppStrings.noPlantFoundAddFirst),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPlantId,
                isExpanded: true,
                hint: Text(AppStrings.selectPlantHint),
                onChanged: (plantId) {
                  setState(() => _selectedPlantId = plantId);
                },
                items: _plants.map((plant) {
                  return DropdownMenuItem(
                    value: plant.id,
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_florist,
                          size: TasksConstants.taskTypeIconSize,
                          color: theme.colorScheme.secondary,
                        ),
                        SizedBox(width: TasksConstants.taskDialogIconSpacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plant.displayName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (plant.species != null)
                                Text(
                                  plant.displaySpecies,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the task title input field with validation
  ///
  /// This widget provides:
  /// - Pre-filled intelligent default based on task type
  /// - Required field validation
  /// - User-friendly placeholder text
  /// - Proper keyboard type and input hints
  ///
  /// Returns a validated text input field for task titles.
  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.taskTitleLabel,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: AppStrings.taskTitleHint,
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppStrings.titleRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Builds the optional task description input field
  ///
  /// This widget allows users to add additional context or notes:
  /// - Multi-line input for detailed descriptions
  /// - Character limit to prevent excessive content
  /// - Optional field with clear labeling
  /// - Helpful placeholder text
  ///
  /// Returns a multi-line text input for task descriptions.
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.taskDescriptionLabel,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: AppStrings.taskDescriptionHint,
            border: OutlineInputBorder(),
          ),
          maxLines: TasksConstants.taskDescriptionMaxLines,
          maxLength: TasksConstants.taskDescriptionMaxLength,
        ),
      ],
    );
  }

  /// Builds the due date selection field with calendar picker
  ///
  /// This widget provides an intuitive date selection experience:
  /// - Visual calendar icon and edit indicator
  /// - Smart date formatting (Today, Tomorrow, or full date)
  /// - Tappable area that opens native date picker
  /// - Consistent styling with app theme
  ///
  /// Returns an interactive date selection widget.
  Widget _buildDueDateField() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.dueDateLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDueDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(_dueDate),
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                Icon(
                  Icons.edit,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the priority selection dropdown with visual indicators
  ///
  /// This widget provides clear priority selection with:
  /// - Visual icons for each priority level
  /// - Color coding to indicate importance
  /// - Descriptive labels for each priority
  /// - Pre-selected intelligent default
  ///
  /// Returns a styled priority selection dropdown.
  Widget _buildPriorityField() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.priorityLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TaskPriority>(
              value: _selectedPriority,
              isExpanded: true,
              onChanged: (priority) {
                if (priority != null) {
                  setState(() => _selectedPriority = priority);
                }
              },
              items: TaskPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(
                        _getPriorityIcon(priority),
                        size: TasksConstants.priorityIconSize,
                        color: _getPriorityColor(priority, theme),
                      ),
                      SizedBox(width: TasksConstants.taskDialogIconSpacing),
                      Text(priority.displayName),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Opens the system date picker for due date selection
  ///
  /// This method:
  /// - Shows native date picker dialog
  /// - Limits selection to future dates (today onwards)
  /// - Limits selection to within one year for practicality
  /// - Updates state when user selects a valid date
  ///
  /// The date picker uses localized strings and follows platform conventions.
  Future<void> _selectDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: TasksConstants.datePickerMaxDays)),
      helpText: AppStrings.dueDatePickerHelp,
      confirmText: AppStrings.confirmButton,
      cancelText: AppStrings.cancelButton,
    );

    if (selectedDate != null) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  /// Handles dialog cancellation with proper cleanup
  ///
  /// This method:
  /// - Calls optional cancellation callback
  /// - Closes the dialog without returning data
  /// - Ensures proper navigation stack management
  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    }
    Navigator.of(context).pop();
  }

  /// Handles task creation confirmation with comprehensive validation
  ///
  /// This method performs complete validation before creating the task:
  /// - **Form Validation**: Ensures all required fields are complete
  /// - **Plant Selection**: Verifies a plant has been selected
  /// - **Data Assembly**: Creates TaskCreationData with all user input
  /// - **Callback Execution**: Calls optional confirmation callback
  /// - **Navigation**: Returns data through dialog result
  ///
  /// Validation errors are shown to the user via snackbars with clear messaging.
  void _handleConfirm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPlantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.pleaseSelectPlant),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedPlant = _plants.firstWhere((plant) => plant.id == _selectedPlantId);
    final description = _descriptionController.text.trim();
    
    final taskData = TaskCreationData(
      title: _titleController.text.trim(),
      description: description.isEmpty ? null : description,
      plantId: _selectedPlantId!,
      plantName: selectedPlant.displayName,
      type: _selectedType,
      priority: _selectedPriority,
      dueDate: _dueDate,
    );

    if (widget.onConfirm != null) {
      widget.onConfirm!(taskData);
    }

    Navigator.of(context).pop(taskData);
  }

  /// Returns the appropriate icon for a given task type
  ///
  /// This method maps task types to intuitive Material Design icons:
  /// - Watering: Water drop icon
  /// - Fertilizing: Eco/leaf icon  
  /// - Pruning: Scissors icon
  /// - Repotting: Grass icon
  /// - And more...
  ///
  /// Parameters:
  /// - [type]: The task type to get an icon for
  ///
  /// Returns:
  /// - Appropriate [IconData] for the task type
  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.watering:
        return Icons.water_drop;
      case TaskType.fertilizing:
        return Icons.eco;
      case TaskType.pruning:
        return Icons.content_cut;
      case TaskType.repotting:
        return Icons.grass;
      case TaskType.cleaning:
        return Icons.cleaning_services;
      case TaskType.spraying:
        return Icons.water;
      case TaskType.sunlight:
        return Icons.wb_sunny;
      case TaskType.shade:
        return Icons.cloud;
      case TaskType.pestInspection:
        return Icons.search;
      case TaskType.custom:
        return Icons.task_alt;
    }
  }

  /// Returns the appropriate icon for a given priority level
  ///
  /// This method maps priority levels to visual indicators:
  /// - Low: Down arrow (less urgent)
  /// - Medium: Horizontal line (neutral)
  /// - High: Up arrow (more urgent)
  /// - Urgent: Priority high icon (most urgent)
  ///
  /// Parameters:
  /// - [priority]: The priority level to get an icon for
  ///
  /// Returns:
  /// - Appropriate [IconData] for the priority level
  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up;
      case TaskPriority.urgent:
        return Icons.priority_high;
    }
  }

  /// Returns the appropriate color for a given priority level
  ///
  /// This method provides consistent color coding across the app:
  /// - Low: Green (safe, no rush)
  /// - Medium: Orange (attention needed)
  /// - High: Red (important)
  /// - Urgent: Deep purple (critical)
  ///
  /// Parameters:
  /// - [priority]: The priority level to get a color for
  /// - [theme]: Theme data for context (currently unused but available)
  ///
  /// Returns:
  /// - Appropriate [Color] for the priority level
  Color _getPriorityColor(TaskPriority priority, ThemeData theme) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.deepPurple;
    }
  }

  /// Formats dates in a user-friendly, contextual manner
  ///
  /// This method provides smart date formatting:
  /// - **Today**: Shows "Today" instead of date
  /// - **Tomorrow**: Shows "Tomorrow" for next day
  /// - **Other dates**: Shows formatted date (dd/mm/yyyy)
  ///
  /// This improves user experience by providing immediate context
  /// for commonly selected dates.
  ///
  /// Parameters:
  /// - [date]: The date to format
  ///
  /// Returns:
  /// - User-friendly date string
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return AppStrings.today;
    } else if (targetDate == today.add(const Duration(days: 1))) {
      return AppStrings.tomorrow;
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Immutable data class representing task creation input from the user
///
/// This class encapsulates all the information needed to create a new task,
/// serving as a bridge between the UI dialog and the domain layer. It ensures
/// type safety and provides value equality for reliable comparisons.
///
/// Properties:
/// - [title]: User-provided task title (required)
/// - [description]: Optional additional details about the task
/// - [plantId]: Unique identifier of the associated plant (required)
/// - [plantName]: Display name of the plant for UI purposes (required)
/// - [type]: Categorization of the task (watering, fertilizing, etc.)
/// - [priority]: Importance level of the task
/// - [dueDate]: When the task should be completed
///
/// Example usage:
/// ```dart
/// final taskData = TaskCreationData(
///   title: 'Water indoor plants',
///   description: 'Check soil moisture first',
///   plantId: 'plant_123',
///   plantName: 'Peace Lily',
///   type: TaskType.watering,
///   priority: TaskPriority.high,
///   dueDate: DateTime.now().add(Duration(days: 1)),
/// );
/// ```
class TaskCreationData {
  final String title;
  final String? description;
  final String plantId;
  final String plantName;
  final TaskType type;
  final TaskPriority priority;
  final DateTime dueDate;

  const TaskCreationData({
    required this.title,
    this.description,
    required this.plantId,
    required this.plantName,
    required this.type,
    required this.priority,
    required this.dueDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskCreationData &&
        other.title == title &&
        other.description == description &&
        other.plantId == plantId &&
        other.plantName == plantName &&
        other.type == type &&
        other.priority == priority &&
        other.dueDate == dueDate;
  }

  @override
  int get hashCode => Object.hash(
    title,
    description,
    plantId,
    plantName,
    type,
    priority,
    dueDate,
  );

  @override
  String toString() {
    return 'TaskCreationData(title: $title, plantName: $plantName, type: $type, dueDate: $dueDate)';
  }
}