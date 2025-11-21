# Relatório de Análise - App Petiveti

## Visão Geral
O aplicativo `app-petiveti` está em um estado híbrido de migração para Riverpod.
- **State Management**: Utiliza `flutter_riverpod` (StateNotifierProvider, FutureProvider, StreamProvider).
- **Dependency Injection**: A maioria das features ainda utiliza `GetIt` (`di.getIt`) para injetar UseCases e Repositories dentro dos Providers.
- **Arquitetura**: Clean Architecture bem definida (Data, Domain, Presentation).

## Status por Feature

| Feature | Status | Observações |
|---------|--------|-------------|
| **Animals** | ✅ Migrado | Usa `@riverpod` e `ref.watch/read`. Sem `GetIt` nos providers. |
| **Appointments** | ⚠️ Híbrido | Usa Riverpod mas provavelmente com `GetIt` (precisa verificar detalhadamente). |
| **Medications** | ⚠️ Híbrido | Usa `StateNotifierProvider` mas injeta dependências via `di.getIt`. |
| **Vaccines** | ⚠️ Híbrido | Usa `StateNotifierProvider` mas injeta dependências via `di.getIt`. |
| **Calculators** | ⚠️ Híbrido | Usa `di.getIt` diretamente nos providers e pages. |
| **Reminders** | ⚠️ Híbrido | Usa `di.getIt` nos providers. |
| **Weight** | ⚠️ Híbrido | Provavelmente usa `di.getIt` (padrão observado). |
| **Expenses** | ⚠️ Híbrido | Provavelmente usa `di.getIt` (padrão observado). |
| **Promo** | ⚠️ Híbrido | Provavelmente usa `di.getIt` (padrão observado). |
| **Subscription** | ⚠️ Híbrido | Provavelmente usa `di.getIt` (padrão observado). |
| **Sync** | ⚠️ Híbrido | Provavelmente usa `di.getIt` (padrão observado). |
| **Home** | ⚠️ Híbrido | Provavelmente usa `di.getIt` (padrão observado). |
| **Settings** | ⚠️ Híbrido | Provavelmente usa `di.getIt` (padrão observado). |

## Plano de Ação

1.  **Criar Bridge Providers**: Para cada feature, criar um arquivo `_providers.dart` (se não existir ou atualizar o existente) que exponha os UseCases, Repositories e DataSources usando Riverpod (`@riverpod` ou `Provider`).
2.  **Refatorar Notifiers**: Atualizar os Notifiers para receberem `Ref` ou usar `ref.read` diretamente, removendo a dependência de `di.getIt`.
3.  **Atualizar Providers**: Atualizar a definição dos providers para usar os novos Bridge Providers.
4.  **Remover GetIt**: Remover o registro no `GetIt` (Modules) após a migração completa da feature.

## Prioridade
1.  Medications
2.  Vaccines
3.  Reminders
4.  Calculators
5.  Outras features (Weight, Expenses, etc.)
