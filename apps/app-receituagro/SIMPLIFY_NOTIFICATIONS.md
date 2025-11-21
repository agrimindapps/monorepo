# Relatório de Alteração: Simplificação da Seção de Notificações

## Alteração Realizada
A seção de notificações na página de configurações foi simplificada para conter apenas um switch geral de "Notificações Gerais", removendo as opções de "Som e Vibração" e "Notificações Promocionais".

## Arquivos Modificados
- `apps/app-receituagro/lib/features/settings/widgets/sections/new_notification_section.dart`

## Detalhes
- Removido o método `_buildSoundToggle`.
- Removido o método `_buildPromotionalToggle`.
- Removidas as chamadas para esses métodos no método `build`.
- A interface agora exibe apenas o switch principal para ativar/desativar notificações.
