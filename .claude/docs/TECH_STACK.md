# 🛠️ Tech Stack & Versões

Este documento define as tecnologias aprovadas para uso no monorepo.

## Core
*   **Flutter**: `>=3.24.0`
*   **Dart**: `>=3.5.0`

## Bibliotecas Principais (Padrão)

| Categoria | Pacote | Versão Mínima | Observação |
|-----------|--------|---------------|------------|
| **State Management** | `flutter_riverpod` | `^2.6.1` | Padrão obrigatório. Use com `riverpod_annotation`. |
| **Code Gen** | `riverpod_generator` | `^2.6.1` | |
| **DI** | `get_it` + `injectable` | `^8.0` / `^2.5` | Padrão para services e repositories. |
| **Navigation** | `go_router` | `^14.0` | Navegação declarativa. |
| **Functional** | `dartz` | `^0.10.1` | Para `Either` e programação funcional. |
| **Immutability** | `freezed` | `^2.5.0` | Para States, Events e Entities. |

## Persistência de Dados (Local)

### ✅ Aprovado: Drift (SQLite)
*   **Pacote**: `drift`
*   **Uso**: Preferencial para novos apps e dados relacionais complexos.
*   **Web**: Suporte via WASM (`sqlite3.wasm`).

### ⚠️ Legado/Manutenção: Hive (NoSQL)
*   **Pacote**: `hive`
*   **Uso**: Mantido em apps existentes (`app-plantis`, `app-receituagro`). Evitar em novos projetos se relacionamentos forem necessários.

## Backend & Remote
*   **Firebase**: Auth, Firestore, Analytics, Crashlytics.
*   **Supabase**: Alternativa aprovada (usada em `app-nutrituti`).

## UI Components
*   `flutter_staggered_grid_view`: Para grids complexos.
*   `skeletonizer`: Para loading states.
*   `google_fonts`: Tipografia.
*   `icons_plus`: Ícones variados.

## 🚫 Proibido / Depreciado
*   ❌ **GetX**: Removido/Em remoção. Não utilizar.
*   ❌ **Provider (puro)**: Em migração para Riverpod. Não adicionar novos.
*   ❌ **Singleton Pattern manual**: Use `GetIt`.
