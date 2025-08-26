# Claude Code Configuration - Flutter Monorepo

## 🏢 Monorepo Structure
- **app-gasometer**: Vehicle control (Provider + Hive + Analytics)
- **app-plantis**: Plant care (Provider + Notifications + Scheduling)
- **app_taskolist**: Task management (Riverpod + Clean Architecture)
- **app-receituagro**: Agricultural diagnostics (Provider + Static Data + Hive)
- **app-petiveti**: Pet care management
- **app_agrihurbi**: Agricultural management
- **packages/core**: Shared services (Firebase, RevenueCat, Hive)

## 🤖 Agent Usage Patterns
- **Direct specialist calls** for specific, clear tasks
- **project-orchestrator** for complex/multi-step workflows
- **code-intelligence** auto-selects Sonnet/Haiku based on complexity
- **task-intelligence** auto-selects based on issue criticality

## 📋 Active Context (Updated by agents)
<!-- Agents can update this section with current work context -->

## 🔧 Development Commands
- `flutter analyze` - Run analysis across all apps
- `melos run build:all:apk:debug` - Build all apps for testing
- Follow Clean Architecture + Repository patterns established

## 🎯 Quality Standards
- Maintain consistency between Provider (3 apps) vs Riverpod (1 app)
- Maximize core package reuse
- Follow established security and performance patterns