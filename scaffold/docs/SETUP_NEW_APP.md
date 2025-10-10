# Setup New App - Step by Step Guide

This guide walks you through creating a new Flutter app from the scaffold template.

## Prerequisites

- Flutter 3.29 or higher
- Dart 3.7.2 or higher
- Firebase CLI installed
- Firebase project created

## Quick Setup (Automated)

The fastest way to create a new app:

```bash
cd /path/to/monorepo/scaffold

./scripts/setup_new_app.sh my_app com.company.myapp "My App"
```

That's it! Your app is ready.

## Manual Setup (Detailed)

If you prefer manual setup or need customization:

### Step 1: Create Flutter App

```bash
cd /path/to/monorepo/apps
flutter create --org com.company --project-name my_app my_app
cd my_app
```

### Step 2: Copy Scaffold Structure

```bash
# From scaffold directory
cp -r scaffold/lib my_app/
cp -r scaffold/test my_app/
cp scaffold/analysis_options.yaml my_app/
cp scaffold/.gitignore my_app/
```

### Step 3: Configure pubspec.yaml

Replace contents with scaffold/pubspec.yaml.template and replace:
- `{{APP_NAME}}` → your_app_name
- `{{BUNDLE_ID}}` → com.company.yourapp
- `{{APP_DESCRIPTION}}` → Your app description

### Step 4: Process Template Files

Find all `.template` files and:
1. Replace placeholders
2. Remove `.template` extension

```bash
# Example
find lib -name "*.template" | while read file; do
  # Replace placeholders
  sed -i '' 's/{{APP_NAME}}/my_app/g' "$file"
  # Rename file
  mv "$file" "${file%.template}"
done
```

### Step 5: Setup Firebase

1. Create Firebase project at https://console.firebase.google.com
2. Add Android app with bundle ID
3. Download `google-services.json` to `android/app/`
4. Add iOS app
5. Download `GoogleService-Info.plist` to `ios/Runner/`

### Step 6: Configure Firebase

Edit `lib/core/config/app_config.dart`:

```dart
static const String firebaseProjectId = 'your-project-id';
static const String firebaseStorageBucket = 'your-bucket.appspot.com';
```

### Step 7: Install Dependencies

```bash
flutter pub get
```

### Step 8: Generate Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates:
- Hive type adapters (*.g.dart)
- Injectable DI code (injection.config.dart)
- Riverpod providers (*.g.dart)

### Step 9: Initialize Hive Boxes

The scaffold includes Hive setup in `lib/core/storage/boxes_setup.dart`.
Make sure your models are registered:

```dart
if (!Hive.isAdapterRegistered(0)) {
  Hive.registerAdapter(ExampleModelAdapter());
}
```

### Step 10: Setup Routes

Edit `lib/core/router/app_router.dart` and add your routes:

```dart
GoRoute(
  path: '/your-route',
  name: 'your-route',
  builder: (context, state) => YourPage(),
),
```

### Step 11: Run the App

```bash
flutter run
```

## Post-Setup Configuration

### 1. Analytics Setup

If using Firebase Analytics:

```dart
// lib/main.dart
await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
```

### 2. Environment Configuration

Update `lib/core/config/environment_config.dart` with your API endpoints:

```dart
static String get apiBaseUrl {
  switch (_current) {
    case Environment.development:
      return 'https://dev-api.yourapp.com';
    // ...
  }
}
```

### 3. Theme Customization

Customize colors in `lib/core/theme/color_schemes.dart`:

```dart
static const ColorScheme lightColorScheme = ColorScheme(
  primary: Color(0xYOUR_COLOR),
  // ...
);
```

### 4. App Constants

Update `lib/core/config/app_constants.dart` with your strings and routes.

## Next Steps

1. **Remove Example Feature** (if not needed):
   ```bash
   rm -rf lib/features/example
   rm -rf test/features/example
   ```

2. **Create Your First Feature**:
   ```bash
   ./scripts/generate_feature.sh users
   ```

3. **Implement Your Feature**:
   - Follow the example feature structure
   - Domain layer: entities, repositories, services, use cases
   - Data layer: models, datasources, repository impl
   - Presentation layer: notifiers, providers, pages, widgets
   - Tests: use cases tests with Mocktail

4. **Run Quality Checks**:
   ```bash
   ./scripts/run_checks.sh
   ```

## Troubleshooting

### Build Runner Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Hive Issues

Make sure:
- Type IDs are unique
- Adapters are registered before opening boxes
- Boxes are opened in main()

### Firebase Issues

- Check `google-services.json` is in `android/app/`
- Check `GoogleService-Info.plist` is in `ios/Runner/`
- Run `flutterfire configure` if using FlutterFire CLI

### Import Issues

If imports are not resolving:
1. Run `flutter pub get`
2. Restart IDE
3. Check `analysis_options.yaml` excludes generated files

## Support

- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Check [ARCHITECTURE.md](ARCHITECTURE.md) for architecture details
- Review [PATTERNS.md](PATTERNS.md) for code patterns

---

**You're all set! Start building amazing features!** 🚀
