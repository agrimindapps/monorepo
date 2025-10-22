# Caça-Palavras (Word Search) - Clean Architecture + Riverpod

Implementação completa do jogo Caça-Palavras seguindo Clean Architecture e padrões do monorepo.

## ✅ Implementação

### **Arquitetura**
- ✅ Clean Architecture (Domain/Data/Presentation)
- ✅ Repository Pattern
- ✅ Use Cases com validação centralizada
- ✅ Either<Failure, T> para error handling
- ✅ Immutable entities (Equatable)

### **State Management**
- ✅ Riverpod com code generation (@riverpod)
- ✅ AsyncValue<T> para states assíncronos
- ✅ Auto-dispose lifecycle management
- ✅ ProviderContainer para testes (sem widgets)

### **Features Implementadas**
- ✅ Grid 2D dinâmico (8x8, 10x10, 12x12)
- ✅ Seleção de células com debounce (100ms)
- ✅ Detecção de palavras em 4 direções (horizontal, vertical, diagonais)
- ✅ Highlight de palavras na lista
- ✅ Progress tracking
- ✅ High score persistence (SharedPreferences)
- ✅ Victory dialog com estatísticas
- ✅ Difficulty selection com confirmação
- ✅ Haptic feedback (selection + found word)
- ✅ Responsive layout (portrait + landscape)
- ✅ Instruções do jogo

### **Testing**
- ✅ 20 testes unitários (100% pass rate)
- ✅ Cobertura dos use cases principais:
  - SelectCellUseCase (8 testes)
  - CheckWordMatchUseCase (6 testes)
  - ToggleWordHighlightUseCase (6 testes)
- ✅ Mocktail para mocking
- ✅ Testes sem widgets (ProviderContainer)

### **Code Quality**
- ✅ 0 analyzer errors
- ✅ 0 warnings
- ✅ Código gerado (Riverpod) via build_runner
- ✅ Injectable DI configurado

## 📁 Estrutura

```
lib/features/caca_palavra/
├── domain/
│   ├── entities/
│   │   ├── enums.dart              # GameDifficulty, WordDirection, GameStatus
│   │   ├── position.dart           # Posição no grid (row, col)
│   │   ├── word_entity.dart        # Palavra com posições e estado
│   │   ├── game_state.dart         # Estado completo do jogo
│   │   └── high_score.dart         # Recordes por dificuldade
│   ├── repositories/
│   │   └── caca_palavra_repository.dart
│   └── usecases/
│       ├── generate_grid_usecase.dart      # Gera grid com palavras
│       ├── select_cell_usecase.dart        # Lógica de seleção (adjacency)
│       ├── check_word_match_usecase.dart   # Verifica match de palavras
│       ├── toggle_word_highlight_usecase.dart
│       ├── restart_game_usecase.dart
│       ├── load_high_score_usecase.dart
│       └── save_high_score_usecase.dart
├── data/
│   ├── models/
│   │   └── high_score_model.dart          # Model com JSON serialization
│   ├── datasources/
│   │   └── caca_palavra_local_data_source.dart  # SharedPreferences
│   └── repositories/
│       └── caca_palavra_repository_impl.dart
├── presentation/
│   ├── providers/
│   │   ├── caca_palavra_game_notifier.dart        # Game state notifier
│   │   └── caca_palavra_game_notifier.g.dart     # Generated
│   ├── pages/
│   │   └── caca_palavra_page.dart                 # Main page
│   └── widgets/
│       ├── grid_cell_widget.dart
│       ├── word_grid_widget.dart
│       ├── word_list_widget.dart
│       └── victory_dialog.dart
└── di/
    └── caca_palavra_injection.dart        # Injectable module

test/features/caca_palavra/
└── domain/usecases/
    ├── select_cell_usecase_test.dart       # 8 testes
    ├── check_word_match_usecase_test.dart  # 6 testes
    └── toggle_word_highlight_usecase_test.dart  # 6 testes
```

## 🎮 Como Usar

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/caca_palavra/presentation/pages/caca_palavra_page.dart';

// Na navegação
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const CacaPalavraPage(),
  ),
);

// Ou via rotas nomeadas
'/caca-palavras': (context) => const CacaPalavraPage(),
```

## 🧪 Executar Testes

```bash
# Testes unitários
flutter test test/features/caca_palavra/

# Build runner (gerar código Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Análise estática
flutter analyze lib/features/caca_palavra
```

## 📊 Métricas

- **Linhas de código**: ~2500
- **Testes unitários**: 20
- **Cobertura**: Use cases principais 100%
- **Analyzer**: 0 errors, 0 warnings
- **Build runner**: Succeeded

## 🎯 Funcionalidades Técnicas

### **Debounce na Seleção**
- Timer de 100ms para evitar múltiplas execuções
- Cancela timer anterior ao novo toque
- Cleanup automático no dispose

### **Adjacency e Alignment Validation**
- Verifica se célula é adjacente (max 1 passo)
- Mantém direção consistente
- Clear automático ao mudar direção

### **Grid Generation**
- Algoritmo de posicionamento de palavras com múltiplas tentativas
- 4 direções suportadas
- Preenchimento com letras aleatórias
- Validação de conflitos

### **High Score Management**
- Persiste melhor tempo por dificuldade
- Compara e atualiza automaticamente
- Exibe no victory dialog

## 🔄 Migrações Futuras

- [ ] Adicionar analytics (estrutura já preparada)
- [ ] Suporte a temas customizados
- [ ] Palavras customizáveis
- [ ] Modo multiplayer
- [ ] Leaderboard online

## 📚 Referências

- Template base: `features/tictactoe` (grid 2D)
- Padrões: CLAUDE.md + Migration Guide
- State: Riverpod code generation
- Testing: Mocktail + ProviderContainer
