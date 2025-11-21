# Relatório de Alteração: Remoção do Switch de Tema e Grupo Aparência

## Alteração Realizada
O switch de tema e o grupo "Aparência" foram removidos da página de configurações do aplicativo `app-receituagro`, conforme solicitado.

## Arquivos Modificados
- `apps/app-receituagro/lib/features/settings/settings_page.dart`

## Detalhes
- Removida a importação e o uso de `NewThemeSection`.
- Removida a importação e o uso de `ThemeSelectionDialog`.
- Removida a importação de `SettingsDesignTokens`.
- Removido o botão de configurações de tema do cabeçalho (`_buildThemeSettingsButton`).
- Removido o método `_openThemeDialog`.
- Removida a seção `NewThemeSection` da lista de configurações.

Com essas alterações, a página de configurações não exibe mais opções para alterar o tema ou a aparência do aplicativo.
