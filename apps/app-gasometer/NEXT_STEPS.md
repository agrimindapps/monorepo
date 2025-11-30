# Next Steps - Analyzer Warnings Remediation

After applying automatic fixes, 270 remaining warnings require manual review and architectural decisions.

## Priority Actions

### 1. HIGH PRIORITY: only_throw_errors (87 warnings)

**Issue**: The codebase throws instances of classes that don't extend Exception or Error.

**Pattern**:
```dart
// ❌ Current (causes warning)
throw SyncException('message');
throw SyncError('message');
throw ValidationException('message');
```

**Solution**: Create custom exception hierarchy extending Exception:

```dart
// ✅ Recommended
abstract class GasometerException implements Exception {
  final String message;
  GasometerException(this.message);

  @override
  String toString() => message;
}

class SyncException extends GasometerException {
  SyncException(super.message);
}

class ValidationException extends GasometerException {
  ValidationException(super.message);
}

// Usage
throw SyncException('message');
throw ValidationException('message');
```

**Affected Files** (sample):
- `lib/features/vehicles/data/repositories/vehicle_repository_drift_impl.dart`
- `lib/features/vehicles/data/sync/vehicle_drift_sync_adapter.dart`
- Multiple service implementations

**Effort**: 4-6 hours (create base, update all throwing locations)

---

### 2. HIGH PRIORITY: deprecated_member_use (9 warnings)

**Issue**: Radio widget API changed in Flutter Material 3.

**Pattern**:
```dart
// ❌ Deprecated (Flutter 3.32+)
Radio(
  groupValue: selectedValue,
  onChanged: (value) { ... },
)
```

**Solution**: Use RadioGroup (Flutter 3.32+):

```dart
// ✅ New API
RadioGroup<String>(
  value: selectedValue,
  onChanged: (value) { ... },
  children: [
    RadioMenuButton(value: 'a', child: Text('Option A')),
    RadioMenuButton(value: 'b', child: Text('Option B')),
  ],
)
```

**Affected File**:
- `lib/shared/widgets/financial_conflict_dialog.dart` (2 occurrences)

**Effort**: 1-2 hours

---

### 3. HIGH PRIORITY: dead_null_aware_expression (16 warnings)

**Issue**: Using nullable operator (?.) on non-nullable types.

**Pattern**:
```dart
// ❌ Warning (syncState is non-nullable)
syncState?.maybeWhen(...);  // ? is redundant
```

**Solution**: Remove the nullable operator:

```dart
// ✅ Correct
syncState.maybeWhen(...);
```

**Affected Files**:
- `lib/features/sync/domain/services/gasometer_sync_orchestrator.dart` (12)
- `lib/features/sync/domain/services/gasometer_sync_service.dart` (5)

**Effort**: 1-2 hours (requires null safety review)

---

## MEDIUM PRIORITY ACTIONS

### 4. avoid_classes_with_only_static_members (48 warnings)

**Issue**: Utility classes should be extensions or sealed classes.

**Pattern**:
```dart
// ❌ Current
class DateUtils {
  static String format(DateTime date) => ...;
  static DateTime parse(String date) => ...;
}
```

**Solution Options**:

**Option A - Extension on type**:
```dart
extension DateUtils on DateTime {
  String format() => ...;
}

extension DateParsing on String {
  DateTime parseAsDate() => ...;
}
```

**Option B - Top-level functions** (simpler):
```dart
String formatDate(DateTime date) => ...;
DateTime parseDate(String date) => ...;
```

**Option C - Sealed class** (if state needed):
```dart
sealed class DateUtils {
  static String format(DateTime date) => ...;
}
```

**Affected Files** (sample):
- `lib/core/constants/responsive_constants.dart` (3)
- `lib/core/theme/design_tokens.dart`
- `lib/features/fuel/presentation/services/fuel_statistics_service.dart`
- `test/helpers/fake_data.dart`

**Recommendation**: Use top-level functions for simple utilities, extensions for type-specific operations.

**Effort**: 6-8 hours

---

### 5. unintended_html_in_doc_comment (12 warnings)

**Issue**: Angle brackets in doc comments are interpreted as HTML tags.

**Pattern**:
```dart
/// This method accepts <T> type parameter
/// Returns a result <T>
class MyClass { ... }
```

**Solution**: Escape angle brackets:

```dart
/// This method accepts `<T>` type parameter
/// Returns a result `<T>`
class MyClass { ... }
```

**Affected Files**:
- `lib/features/sync/domain/services/gasometer_sync_orchestrator.dart`
- `lib/features/vehicles/domain/services/vehicle_id_reconciliation_service.dart`
- Other service documentation

**Effort**: 1-2 hours (quick search & replace)

---

## LOW PRIORITY ACTIONS

### 6. avoid_slow_async_io (12 warnings)

**Issue**: Async I/O operations that could block the UI thread.

**Pattern**:
```dart
// ⚠️ May block
final bytes = await File('path/file').readAsBytes();
await File('path/file').writeAsBytes(data);
```

**Recommendation**:
- Evaluate if operations are on main thread
- Consider isolates for large files
- Can often be ignored in test/utility contexts

**Affected Files**: Service and storage classes

**Effort**: 2-4 hours (performance review)

---

### 7. depend_on_referenced_packages (48 warnings)

**Issue**: Dependencies used but not declared in pubspec.yaml.

**Analysis**: These are **FALSE POSITIVES** - all dependencies are available through the `core` package.

**Status**: SAFE TO IGNORE

**Why**: The app imports through `core` package which handles dependency management.

---

### 8. avoid_types_as_parameter_names (9 warnings)

**Issue**: Parameter names matching built-in type names.

**Pattern**:
```dart
void calculate(int sum) { ... }  // 'sum' is not a type, but pattern suggests avoiding
```

**Solution**: Rename to avoid confusion:

```dart
void calculate(int total) { ... }
```

**Affected Files**:
- `lib/features/sync/domain/services/sync_pull_service.dart`
- Test files

**Effort**: 1 hour

---

## IMPLEMENTATION ROADMAP

```
Week 1 (Priority 1-3):
├─ Fix only_throw_errors (4-6h)
├─ Fix deprecated_member_use (1-2h)
└─ Fix dead_null_aware_expression (1-2h)

Week 2 (Priority 4-5):
├─ Refactor utility classes (6-8h)
└─ Fix doc comments (1-2h)

Week 3+ (Nice to have):
├─ Optimize I/O operations (2-4h)
└─ Parameter naming cleanup (1h)
```

---

## Verification Checklist

After each category of fixes:

```bash
# Run analyzer
flutter analyze

# Run tests
flutter test

# Build for verification
flutter build apk --debug

# Check specific warnings
flutter analyze | grep "only_throw_errors"
```

---

## Resources

- Flutter Material 3 Radio Migration: https://flutter.dev/docs/release/breaking-changes/radio-theme
- Dart Exception Best Practices: https://dart.dev/guides/language/effective-dart/usage
- Custom Lints: https://pub.dev/packages/custom_lint

---

**Status**: Ready for implementation
**Last Updated**: 2025-11-30
