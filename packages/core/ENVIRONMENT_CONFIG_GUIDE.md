# Environment Configuration Guide

## Overview

The `EnvironmentConfig` system provides secure, type-safe access to environment variables and secrets across all apps in the monorepo.

## Quick Start

### 1. Create .env file

```bash
# From monorepo root
cp .env.example .env
# Edit .env with your actual values
```

### 2. Initialize in main.dart

```dart
import 'package:core/core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment config FIRST
  await EnvironmentConfig.initialize(
    requiredKeys: [
      'FIREBASE_API_KEY',
      'FIREBASE_PROJECT_ID',
      'REVENUE_CAT_API_KEY_IOS',
    ],
  );

  // Then initialize core services
  await InjectionContainer.init();

  runApp(MyApp());
}
```

### 3. Access values

```dart
// Get required value (throws if missing)
final apiKey = EnvironmentConfig.get('FIREBASE_API_KEY');

// Get optional value
final debugUrl = EnvironmentConfig.getOptional('DEBUG_API_URL');

// Get with fallback
final timeout = EnvironmentConfig.get('API_TIMEOUT', fallback: '30');

// Get typed values
final enableOffline = EnvironmentConfig.getBool('ENABLE_OFFLINE_MODE');
final maxRetries = EnvironmentConfig.getInt('MAX_RETRIES', fallback: 3);

// Check existence
if (EnvironmentConfig.has('SUPABASE_URL')) {
  // Use Supabase
}
```

## File Structure

```
monorepo/
├── .env                    # ❌ NEVER commit (gitignored)
├── .env.example            # ✅ Commit this (documentation)
└── packages/core/
    └── lib/src/shared/config/
        └── environment_config.dart
```

## .env File Format

```bash
# Comments start with #
# Format: KEY=VALUE

# Simple values
FIREBASE_API_KEY=abc123

# Values with spaces (use quotes)
APP_NAME="My Awesome App"

# Multi-line not supported (use separate keys)
```

## Security Best Practices

### ✅ DO:
- Keep .env file in root directory (gitignored)
- Use .env.example to document required keys
- Validate required keys on startup
- Use different .env files per environment

### ❌ DON'T:
- Commit .env files to git
- Hardcode secrets in code
- Use dummy/placeholder values in production
- Share .env files via email/chat

## Environment-Specific Configuration

### Development
```bash
# .env.development
ENV=development
FIREBASE_PROJECT_ID=myapp-dev
API_BASE_URL=https://dev-api.myapp.com
```

### Production
```bash
# .env.production
ENV=production
FIREBASE_PROJECT_ID=myapp-prod
API_BASE_URL=https://api.myapp.com
```

### Load specific env file
```dart
await EnvironmentConfig.initialize(
  envFilePath: '.env.production',
);
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/build.yml
- name: Create .env
  run: |
    echo "FIREBASE_API_KEY=${{ secrets.FIREBASE_API_KEY }}" >> .env
    echo "REVENUE_CAT_API_KEY=${{ secrets.REVENUE_CAT_KEY }}" >> .env

- name: Build
  run: flutter build apk --release
```

### GitLab CI

```yaml
# .gitlab-ci.yml
before_script:
  - echo "FIREBASE_API_KEY=$FIREBASE_API_KEY" >> .env
  - echo "REVENUE_CAT_API_KEY=$REVENUE_CAT_KEY" >> .env
```

## Web Platform

⚠️ Note: File I/O is not available on Web. For web builds:

1. Use compile-time environment variables:
```bash
flutter build web --dart-define=FIREBASE_API_KEY=abc123
```

2. Or inject at runtime via JavaScript:
```html
<script>
  window.env = {
    FIREBASE_API_KEY: 'abc123'
  };
</script>
```

## Migration from Old System

### Before (❌ Insecure)
```dart
class Config {
  static const apiKey = 'hardcoded_key_123';  // ❌ Committed to git
}
```

### After (✅ Secure)
```dart
// In .env (not committed)
FIREBASE_API_KEY=real_key_abc123

// In code
final apiKey = EnvironmentConfig.get('FIREBASE_API_KEY');
```

## Troubleshooting

### Error: "Environment variable X not found"
**Solution**: Add the key to your .env file or provide a fallback:
```dart
EnvironmentConfig.get('MY_KEY', fallback: 'default_value');
```

### Error: "No .env file found"
**Solution**:
1. Check that .env exists in project root
2. Or provide custom path:
```dart
await EnvironmentConfig.initialize(
  envFilePath: '../.env',
);
```

### Warning: "EnvironmentConfig.get called before initialize"
**Solution**: Call `initialize()` in main() before using `get()`:
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvironmentConfig.initialize();  // ← Add this
  runApp(MyApp());
}
```

## API Reference

### Methods

| Method | Description | Throws |
|--------|-------------|--------|
| `initialize()` | Load .env file | Yes (if required keys missing) |
| `get(key)` | Get value (required) | Yes (if not found) |
| `getOptional(key)` | Get value (optional) | No (returns null) |
| `getBool(key)` | Get as boolean | No (returns fallback) |
| `getInt(key)` | Get as integer | Yes (if invalid) |
| `has(key)` | Check if key exists | No |

### Example: Required Keys Validation

```dart
await EnvironmentConfig.initialize(
  requiredKeys: [
    'FIREBASE_API_KEY',
    'FIREBASE_PROJECT_ID',
    'REVENUE_CAT_API_KEY_IOS',
    'REVENUE_CAT_API_KEY_ANDROID',
  ],
);
// Throws ConfigurationException if any key is missing
```

## Questions?

Contact the core team or check CLAUDE.md for architecture details.
