# Legacy Pages

These pages are from the old architecture and need to be migrated or removed:

- `sobre.dart` - About page (references deleted ThemeManager)
- `tts_settings_page.dart` - TTS settings (OLD version, new version in features/settings)
- `atualizacao.dart` - Update page (references deleted ThemeManager)

## Migration Status

New versions exist in:
- `/features/settings/presentation/pages/settings_page.dart` (replaces config_page)
- `/features/settings/presentation/pages/tts_settings_page.dart` (NEW version)

The old pages can be kept for reference but should not be used in production.
