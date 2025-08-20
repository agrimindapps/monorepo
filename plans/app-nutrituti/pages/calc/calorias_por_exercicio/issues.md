# Issues - Calorias por Exercício Module

## HIGH COMPLEXITY ISSUES

### 1. Limited Activity Database & Calculation Accuracy
**Category**: Data/Accuracy | **Priority**: High | **Effort**: High

**Problem**: The activity repository contains only 8 hardcoded exercises with fixed MET values, making calculations inaccurate for different body weights and intensities.

**Current State**:
```dart
// Only 8 activities with simple value multipliers
AtividadeFisicaModel(id: 1, text: 'Caminhada leve (3-4 km/h)', value: 3.5),
AtividadeFisicaModel(id: 2, text: 'Caminhada rápida (5-6 km/h)', value: 5.5),
// ... limited variety
```

**Issues**:
- No body weight consideration in calorie calculation
- Fixed MET values don't account for individual variations
- Missing popular activities (yoga, pilates, swimming styles, etc.)
- No intensity levels for same activity

**Improvement**:
```dart
class EnhancedCalorieCalculator {
  // Implement proper MET-based calculation: Calories = MET × weight(kg) × time(hours)
  double calculateCalories({
    required double met,
    required double weightKg,
    required double durationMinutes,
    double? intensityMultiplier,
  }) {
    final hours = durationMinutes / 60;
    final baseCalories = met * weightKg * hours;
    return baseCalories * (intensityMultiplier ?? 1.0);
  }
}

class ComprehensiveActivityRepository {
  Map<String, List<ActivityLevel>> categorizedActivities = {
    'Cardio': [
      ActivityLevel('Walking', lightMET: 3.0, moderateMET: 4.0, vigorousMET: 5.0),
      ActivityLevel('Running', lightMET: 6.0, moderateMET: 9.5, vigorousMET: 12.0),
    ],
    'Strength': [
      ActivityLevel('Weight lifting', lightMET: 3.0, moderateMET: 5.0, vigorousMET: 6.0),
    ],
    // ... expanded database
  };
}
```

### 2. Architectural Over-Engineering for Simple Functionality
**Category**: Architecture | **Priority**: High | **Effort**: High

**Problem**: Complex MVC pattern with multiple layers for what could be a simple calculation widget.

**Current Issues**:
- Unnecessary repository pattern for static data
- Over-abstracted model layer for simple data structures
- Multiple widget files for basic form/result display

**Simplification Strategy**:
```dart
// Consolidated approach
class CaloriesCalculatorWidget extends StatefulWidget {
  @override
  State<CaloriesCalculatorWidget> createState() => _CaloriesCalculatorWidgetState();
}

class _CaloriesCalculatorWidgetState extends State<CaloriesCalculatorWidget> {
  static const activities = <String, double>{
    'Walking (3-4 km/h)': 3.5,
    'Running (8-10 km/h)': 11.0,
    // ... inline constants
  };
  
  // Direct state management without controller
  String selectedActivity = activities.keys.first;
  int duration = 0;
  double? result;
  
  void calculateCalories() {
    if (duration > 0) {
      setState(() {
        result = activities[selectedActivity]! * duration;
      });
    }
  }
}
```

### 3. Missing User Context & Personalization
**Category**: User Experience | **Priority**: High | **Effort**: High

**Problem**: No consideration of user's personal data (weight, age, fitness level) that significantly affects calorie burn.

**Enhancement**:
```dart
class UserProfileService {
  static const String weightKey = 'user_weight';
  static const String ageKey = 'user_age';
  static const String fitnessLevelKey = 'fitness_level';
  
  Future<UserProfile?> getUserProfile() async {
    // Retrieve from SharedPreferences or local storage
  }
  
  double calculatePersonalizedCalories({
    required Activity activity,
    required int duration,
    required UserProfile profile,
  }) {
    double baseMET = activity.met;
    
    // Adjust for fitness level
    double fitnessMultiplier = switch (profile.fitnessLevel) {
      FitnessLevel.beginner => 0.9,
      FitnessLevel.intermediate => 1.0,
      FitnessLevel.advanced => 1.1,
    };
    
    // Age adjustment
    double ageMultiplier = profile.age > 40 ? 0.95 : 1.0;
    
    return baseMET * profile.weight * (duration / 60) * fitnessMultiplier * ageMultiplier;
  }
}

class UserProfileSetupDialog extends StatefulWidget {
  // Allow users to input/update their profile
}
```

## MEDIUM COMPLEXITY ISSUES

### 4. Inconsistent Validation & Error Handling
**Category**: Validation | **Priority**: Medium | **Effort**: Medium

**Problem**: Basic validation with inconsistent error messaging and no comprehensive input sanitization.

**Issues**:
```dart
// Current limited validation
void calcular(BuildContext context) {
  if (tempoController.text.isEmpty) {
    _exibirMensagem(context, 'Tempo não informado.');
    return;
  }
  // No validation for reasonable time limits, negative values, etc.
}
```

**Enhanced Validation**:
```dart
class ExerciseInputValidator {
  static ValidationResult validateDuration(String input) {
    if (input.isEmpty) {
      return ValidationResult.error('Duration is required');
    }
    
    final duration = int.tryParse(input);
    if (duration == null) {
      return ValidationResult.error('Please enter a valid number');
    }
    
    if (duration <= 0) {
      return ValidationResult.error('Duration must be greater than 0');
    }
    
    if (duration > 1440) { // 24 hours
      return ValidationResult.warning('Duration over 24 hours seems excessive');
    }
    
    if (duration > 480) { // 8 hours
      return ValidationResult.warning('Long duration exercise - please ensure this is correct');
    }
    
    return ValidationResult.success();
  }
  
  static ValidationResult validateActivity(AtividadeFisicaModel? activity) {
    if (activity == null) {
      return ValidationResult.error('Please select an activity');
    }
    return ValidationResult.success();
  }
}
```

### 5. Missing Exercise History & Analytics
**Category**: Feature Enhancement | **Priority**: Medium | **Effort**: Medium

**Problem**: No persistence of calculations or historical data for user insights.

**Implementation**:
```dart
class ExerciseHistoryService {
  static const String historyKey = 'exercise_history';
  
  Future<void> saveExerciseSession(ExerciseSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getExerciseHistory();
    history.add(session);
    
    // Keep only last 100 sessions
    if (history.length > 100) {
      history.removeAt(0);
    }
    
    final jsonHistory = history.map((e) => e.toJson()).toList();
    await prefs.setString(historyKey, jsonEncode(jsonHistory));
  }
  
  Future<ExerciseStats> calculateWeeklyStats() async {
    final history = await getExerciseHistory();
    final weekAgo = DateTime.now().subtract(Duration(days: 7));
    
    final weeklyExercises = history.where((session) => 
      session.date.isAfter(weekAgo)).toList();
    
    return ExerciseStats(
      totalMinutes: weeklyExercises.fold(0, (sum, session) => sum + session.duration),
      totalCalories: weeklyExercises.fold(0.0, (sum, session) => sum + session.calories),
      sessionsCount: weeklyExercises.length,
      favoriteActivity: _findMostFrequentActivity(weeklyExercises),
    );
  }
}

class ExerciseHistoryWidget extends StatelessWidget {
  // Display recent exercises and weekly statistics
}
```

### 6. Inadequate Share Functionality
**Category**: User Experience | **Priority**: Medium | **Effort**: Medium

**Problem**: Basic text sharing without formatting, context, or additional useful information.

**Enhanced Sharing**:
```dart
class ExerciseShareService {
  static String generateDetailedShareText({
    required String activity,
    required int duration,
    required double calories,
    required DateTime date,
    UserProfile? profile,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('🏃‍♂️ Exercise Session Summary');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📅 Date: ${DateFormat('MMM dd, yyyy HH:mm').format(date)}');
    buffer.writeln('🏋️ Activity: $activity');
    buffer.writeln('⏱️ Duration: $duration minutes');
    buffer.writeln('🔥 Calories Burned: ${calories.toInt()} kcal');
    
    if (profile != null) {
      buffer.writeln('👤 Weight: ${profile.weight} kg');
      final caloriesPerKg = calories / profile.weight;
      buffer.writeln('📊 Efficiency: ${caloriesPerKg.toStringAsFixed(1)} kcal/kg');
    }
    
    buffer.writeln('');
    buffer.writeln('💡 Tip: Consistency is key! Keep tracking your progress.');
    buffer.writeln('📱 Calculated with fNutriTuti');
    
    return buffer.toString();
  }
  
  static Future<void> shareWithImage({
    required ExerciseSession session,
    required BuildContext context,
  }) async {
    // Generate infographic image with session data
    final image = await _generateExerciseInfographic(session);
    await Share.shareXFiles([XFile.fromData(image, mimeType: 'image/png')]);
  }
}
```

### 7. Limited Accessibility Features
**Category**: Accessibility | **Priority**: Medium | **Effort**: Medium

**Problem**: Missing accessibility support for users with disabilities.

**Implementation**:
```dart
class AccessibleCaloriesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Exercise calories calculator',
      child: Column(
        children: [
          Semantics(
            label: 'Select exercise type',
            hint: 'Choose from available exercise options',
            child: DropdownButtonFormField<Activity>(
              // ... dropdown implementation
            ),
          ),
          Semantics(
            label: 'Exercise duration in minutes',
            hint: 'Enter how long you exercised',
            textField: true,
            child: TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              // ... field implementation
            ),
          ),
          Semantics(
            label: 'Calculate calories burned',
            hint: 'Tap to calculate calories based on your input',
            button: true,
            child: ElevatedButton(
              onPressed: calculateCalories,
              child: Text('Calculate'),
            ),
          ),
          if (result != null)
            Semantics(
              label: 'Calculation result',
              value: 'You burned ${result!.toInt()} calories',
              child: ResultDisplay(result: result!),
            ),
        ],
      ),
    );
  }
}
```

## LOW COMPLEXITY ISSUES

### 8. Hardcoded UI Strings & Missing Internationalization
**Category**: Localization | **Priority**: Low | **Effort**: Low

**Problem**: All text strings are hardcoded in Portuguese, preventing internationalization.

**Solution**:
```dart
// Create localization files
class CaloriesStrings {
  static const calculateButton = 'calculate_button';
  static const clearButton = 'clear_button';
  static const activityLabel = 'activity_label';
  static const durationLabel = 'duration_label';
  static const resultTitle = 'result_title';
  static const caloriesBurned = 'calories_burned';
  
  static Map<String, String> ptBR = {
    calculateButton: 'Calcular',
    clearButton: 'Limpar',
    activityLabel: 'Atividade Física:',
    durationLabel: 'Tempo (min)',
    resultTitle: 'Resultado',
    caloriesBurned: 'Calorias Consumidas: {calories} kCal',
  };
  
  static Map<String, String> enUS = {
    calculateButton: 'Calculate',
    clearButton: 'Clear',
    activityLabel: 'Physical Activity:',
    durationLabel: 'Duration (min)',
    resultTitle: 'Result',
    caloriesBurned: 'Calories Burned: {calories} kCal',
  };
}
```

### 9. Inconsistent Code Style & Documentation
**Category**: Code Quality | **Priority**: Low | **Effort**: Low

**Problem**: Inconsistent naming conventions and missing documentation.

**Improvements**:
```dart
/// Service responsible for calculating calories burned during physical activities
/// 
/// This service uses MET (Metabolic Equivalent of Task) values to estimate
/// calorie expenditure based on activity type and duration.
/// 
/// Example usage:
/// ```dart
/// final service = CalorieCalculationService();
/// final calories = service.calculateCalories(
///   activity: Activities.walking,
///   durationMinutes: 30,
/// );
/// ```
class CalorieCalculationService {
  /// Calculates calories burned for a given activity and duration
  /// 
  /// [activity] The physical activity being performed
  /// [durationMinutes] Duration of the activity in minutes
  /// [userWeight] Optional user weight for more accurate calculation
  /// 
  /// Returns the estimated calories burned as a double
  double calculateCalories({
    required PhysicalActivity activity,
    required int durationMinutes,
    double? userWeight,
  }) {
    // Implementation with proper variable naming
    final baseMetValue = activity.metabolicEquivalent;
    final durationInHours = durationMinutes / 60.0;
    final effectiveWeight = userWeight ?? _defaultBodyWeight;
    
    return baseMetValue * effectiveWeight * durationInHours;
  }
  
  static const double _defaultBodyWeight = 70.0; // kg
}
```

### 10. Basic Input Masking & UX Polish
**Category**: User Experience | **Priority**: Low | **Effort**: Low

**Problem**: Limited input formatting and basic user interaction feedback.

**Enhancement**:
```dart
class EnhancedDurationField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onChanged;
  
  @override
  State<EnhancedDurationField> createState() => _EnhancedDurationFieldState();
}

class _EnhancedDurationFieldState extends State<EnhancedDurationField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4), // Max 9999 minutes
          ],
          decoration: InputDecoration(
            labelText: 'Duration',
            hintText: 'Enter minutes (e.g., 30)',
            suffixText: 'min',
            prefixIcon: Icon(Icons.timer),
            border: OutlineInputBorder(),
            helperText: 'Recommended: 15-60 minutes',
          ),
          validator: (value) => ExerciseInputValidator.validateDuration(value).message,
          onChanged: (value) {
            widget.onChanged?.call();
            _showDurationFeedback(value);
          },
        ),
        if (_showQuickButtons)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                _buildQuickDurationButton('15'),
                _buildQuickDurationButton('30'),
                _buildQuickDurationButton('45'),
                _buildQuickDurationButton('60'),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildQuickDurationButton(String minutes) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text('${minutes}m'),
        onPressed: () {
          widget.controller.text = minutes;
          widget.onChanged?.call();
        },
      ),
    );
  }
}
```

### 11. Missing Exercise Recommendations & Tips
**Category**: Content Enhancement | **Priority**: Low | **Effort**: Low

**Problem**: No educational content or recommendations to guide users.

**Implementation**:
```dart
class ExerciseTipsService {
  static List<ExerciseTip> getTipsForActivity(String activityName) {
    final tips = _activityTips[activityName.toLowerCase()] ?? [];
    return tips;
  }
  
  static Map<String, List<ExerciseTip>> _activityTips = {
    'walking': [
      ExerciseTip(
        title: 'Maintain Good Posture',
        description: 'Keep your head up, shoulders back, and arms swinging naturally.',
        icon: Icons.accessibility_new,
      ),
      ExerciseTip(
        title: 'Gradual Progression',
        description: 'Start with 15-20 minutes and gradually increase duration.',
        icon: Icons.trending_up,
      ),
    ],
    'running': [
      ExerciseTip(
        title: 'Warm Up First',
        description: 'Start with 5-10 minutes of walking before running.',
        icon: Icons.sports,
      ),
    ],
  };
}

class ExerciseTipsWidget extends StatelessWidget {
  final String activityName;
  
  @override
  Widget build(BuildContext context) {
    final tips = ExerciseTipsService.getTipsForActivity(activityName);
    
    if (tips.isEmpty) return SizedBox.shrink();
    
    return Card(
      child: ExpansionTile(
        leading: Icon(Icons.lightbulb_outline),
        title: Text('Tips for $activityName'),
        children: tips.map((tip) => ListTile(
          leading: Icon(tip.icon, color: Colors.blue),
          title: Text(tip.title),
          subtitle: Text(tip.description),
        )).toList(),
      ),
    );
  }
}
```

### 12. Basic Performance Optimizations
**Category**: Performance | **Priority**: Low | **Effort**: Low

**Problem**: Minor performance issues with unnecessary rebuilds and resource usage.

**Optimizations**:
```dart
class OptimizedCaloriesController extends ChangeNotifier {
  // Use cached values to avoid recalculation
  Map<String, double> _calculationCache = {};
  
  double calculateCalories(String activity, int duration) {
    final cacheKey = '${activity}_$duration';
    
    if (_calculationCache.containsKey(cacheKey)) {
      return _calculationCache[cacheKey]!;
    }
    
    final result = _performCalculation(activity, duration);
    _calculationCache[cacheKey] = result;
    
    // Limit cache size
    if (_calculationCache.length > 100) {
      _calculationCache.clear();
    }
    
    return result;
  }
  
  @override
  void dispose() {
    _calculationCache.clear();
    super.dispose();
  }
}

// Use const constructors where possible
class CaloriesResultCard extends StatelessWidget {
  const CaloriesResultCard({
    super.key,
    required this.calories,
    required this.activity,
    required this.duration,
  });
  
  final double calories;
  final String activity;
  final int duration;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // const padding
        child: Column(
          children: [
            // Use const widgets where data doesn't change
            const Icon(Icons.local_fire_department, size: 32),
            Text('$calories kcal'),
            // ...
          ],
        ),
      ),
    );
  }
}
```

---

## Summary

**Total Issues: 12**
- **High Complexity: 3** (Architecture, data accuracy, personalization)
- **Medium Complexity: 5** (Validation, history, sharing, accessibility, tips)
- **Low Complexity: 4** (Localization, documentation, UX polish, performance)

**Priority Implementation Order:**
1. Enhanced calorie calculation with body weight consideration
2. Comprehensive activity database expansion
3. User profile integration and personalization
4. Exercise history and analytics features
5. Improved validation and error handling
6. Enhanced sharing and accessibility features

The calorias_por_exercicio module shows solid basic functionality but lacks the depth and personalization features that would make it truly valuable for users. The most critical improvements involve moving from simple multiplication to proper MET-based calculations and adding user context for accuracy.
