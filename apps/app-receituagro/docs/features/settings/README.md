# ⚙️ Settings Feature

## Visão Geral

Feature responsável por todas as configurações do app, incluindo:
- Preferências do usuário (tema, idioma, notificações)
- Perfil do usuário
- Gerenciamento de dispositivos
- Text-to-Speech (TTS)
- Feature flags

## Arquitetura

```
settings/
├── data/
│   ├── datasources/
│   │   ├── device_local_datasource.dart
│   │   └── device_remote_datasource.dart
│   ├── repositories/
│   │   ├── profile_repository_impl.dart
│   │   ├── tts_settings_repository_impl.dart
│   │   └── user_settings_repository_impl.dart
│   └── services/
│       └── tts_service_impl.dart
├── domain/
│   ├── entities/
│   │   ├── device_settings_entity.dart
│   │   ├── premium_settings_entity.dart
│   │   ├── theme_settings_entity.dart
│   │   ├── tts_settings_entity.dart
│   │   └── user_settings_entity.dart
│   ├── repositories/
│   │   ├── i_settings_composite_repository.dart
│   │   ├── i_tts_settings_repository.dart
│   │   ├── i_user_settings_repository.dart
│   │   └── profile_repository.dart
│   ├── services/
│   │   └── i_tts_service.dart
│   └── usecases/
│       ├── get_user_settings_usecase.dart
│       └── update_user_settings_usecase.dart
├── presentation/
│   ├── providers/
│   │   ├── composite_settings_provider.dart
│   │   ├── device_notifier.dart
│   │   ├── notification_notifier.dart
│   │   ├── profile_notifier.dart
│   │   ├── settings_notifier.dart (deprecated wrapper)
│   │   ├── settings_providers.dart
│   │   ├── settings_state.dart (freezed)
│   │   ├── theme_notifier.dart
│   │   ├── tts_notifier.dart
│   │   └── user_settings_notifier.dart
│   └── widgets/
│       └── sections/
│           ├── auth_section.dart
│           ├── feature_flags_section.dart
│           ├── legal_section.dart
│           ├── new_notification_section.dart
│           ├── new_premium_section.dart
│           ├── support_section.dart
│           └── tts_settings_section.dart
└── pages/
    ├── profile_page.dart
    └── tts_settings_page.dart
```

## Providers (Riverpod)

| Provider | Tipo | Descrição |
|----------|------|-----------|
| `themeSettingsProvider` | AsyncNotifier | Controle de tema (dark/light) |
| `notificationSettingsProvider` | AsyncNotifier | Preferências de notificação |
| `userSettingsProvider` | AsyncNotifier | Settings gerais do usuário |
| `deviceProvider` | AsyncNotifier | Gerenciamento de dispositivos |
| `profileProvider` | AsyncNotifier | Dados do perfil |
| `ttsProvider` | AsyncNotifier | Text-to-Speech settings |

## Uso

```dart
// Watch theme state
final themeState = ref.watch(themeSettingsProvider);

// Toggle dark mode
ref.read(themeSettingsProvider.notifier).toggleDarkMode();

// Watch notification settings
final notifyState = ref.watch(notificationSettingsProvider);

// Enable notifications
ref.read(notificationSettingsProvider.notifier).setEnabled(true);
```

## Dependências

- **core**: DeviceIdentityService, AuthService
- **Riverpod**: State management
- **Freezed**: Immutable states
