# Relatório de Alteração: Remoção do Seletor de Idiomas

## Alteração Realizada
O seletor de idiomas foi removido da página de configurações do aplicativo `app-receituagro`, conforme solicitado, pois o aplicativo possui um único idioma.

## Arquivos Modificados
- `apps/app-receituagro/lib/features/settings/widgets/sections/new_theme_section.dart`

## Detalhes
- Removido o método `_buildLanguageSelector`.
- Removido o método `_buildLanguageItems`.
- Removida a chamada para `_buildLanguageSelector` no método `build`.
- Atualizada a documentação da classe `NewThemeSection`.
