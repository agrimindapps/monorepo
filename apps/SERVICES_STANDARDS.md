# Monorepo Services Standards

## Service Selection Guidelines

### When to Create App-Level Service
- Domain-specific business logic (fuel calculations, plant care logic, etc.)
- App-specific integrations or wrappers
- Feature unique to one app

### When to Use Core Package Service
- Generic functionality (storage, auth, analytics, etc.)
- Cross-app features (backup, sync, notifications)
- Infrastructure concerns (security, performance, logging)

## Canonical Services by App

### app-gasometer
**Keep in App:**
- Financial domain services (conflict_resolver, validator, sync)
- Receipt image handling
- Audit trail
- Gasometer analytics wrapper

**Use from Core:**
- Firebase services
- Storage services
- Image processing (base functionality)
- Navigation
- Security

### app-plantis
**Keep in App:**
- Plant care calculator
- Plant data management
- Task generation
- Plantis-specific notifications
- Backup subsystem (for now)

**Use from Core:**
- Secure storage (migrate to EnhancedSecureStorageService)
- Form validation (migrate)
- Image management (migrate)
- Firebase services

### app-petiveti
**Model app** - uses core services extensively, minimal app-level code.

## Service Naming Conventions
- App-specific: `{app_name}_{feature}_service.dart`
- Generic: `{feature}_service.dart` (should be in core)
- Wrappers: `{app_name}_{core_feature}_wrapper.dart`
