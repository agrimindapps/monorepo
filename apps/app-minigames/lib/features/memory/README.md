# Memory Game (Jogo da Memória) - Clean Architecture + Riverpod

Implementação completa do Jogo da Memória seguindo Clean Architecture e padrões SOLID Featured do monorepo.

## ✅ Implementação

### **Arquitetura**
- ✅ Clean Architecture (Domain/Data/Presentation)
- ✅ Repository Pattern
- ✅ Use Cases com validação centralizada
- ✅ Either<Failure, T> para error handling (dartz)
- ✅ Immutable entities (Equatable)
- ✅ SOLID Principles

### **State Management**
- ✅ Riverpod com code generation (@riverpod)
- ✅ GameStateEntity com state machine (initial/playing/paused/completed/error)
- ✅ Auto-dispose lifecycle management
- ✅ GetIt integration para dependency injection

### **Features Implementadas**
- ✅ 3 níveis de dificuldade (Fácil: 4x4, Médio: 6x6, Difícil: 8x8)
- ✅ Flip card com animação 3D
- ✅ Match detection com delay configurável por dificuldade
- ✅ Contador de movimentos e tempo
- ✅ Sistema de pontuação com eficiência e velocidade
- ✅ High score persistence (SharedPreferences)
- ✅ Victory dialog com estatísticas completas
- ✅ Indicador de novo recorde
- ✅ Pause/resume game
- ✅ Difficulty selection durante o jogo
- ✅ Haptic feedback (light/medium/heavy)
- ✅ Responsive layout (portrait + landscape)
- ✅ Error handling com mensagens amigáveis

### **Testing**
- ✅ 20 testes unitários criados
- ✅ Cobertura dos use cases principais:
  - FlipCardUseCase (6 testes)
  - CheckMatchUseCase (8 testes)
  - GenerateCardsUseCase (6 testes)
- ✅ Testes de validação de estados e regras de negócio
- ✅ Mock-free testing (use cases sem dependências externas)

### **Code Quality**
- ✅ Código organizado e modular
- ✅ Separação clara de responsabilidades
- ✅ Injectable DI configurado
- ✅ Generated code via build_runner

## 📁 Estrutura

```
lib/features/memory/
├── domain/
│   ├── entities/
│   │   ├── enums.dart              # GameDifficulty, CardState, GameStatus
│   │   ├── card_entity.dart        # Card com id, pairId, color, icon, state
│   │   ├── game_state_entity.dart  # Estado completo do jogo
│   │   └── high_score_entity.dart  # High scores por dificuldade
│   ├── repositories/
│   │   └── memory_repository.dart  # Interface do repository
│   └── usecases/
│       ├── generate_cards_usecase.dart       # Gera e embaralha cartas
│       ├── flip_card_usecase.dart            # Lógica de flip com validação
│       ├── check_match_usecase.dart          # Verifica match e atualiza estado
│       ├── restart_game_usecase.dart         # Reset completo do jogo
│       ├── load_high_score_usecase.dart      # Carrega do storage
│       └── save_high_score_usecase.dart      # Salva com validação
├── data/
│   ├── models/
│   │   └── high_score_model.dart            # Model com JSON serialization
│   ├── datasources/
│   │   └── memory_local_datasource.dart     # SharedPreferences
│   └── repositories/
│       └── memory_repository_impl.dart      # Implementação do repository
├── presentation/
│   ├── providers/
│   │   ├── memory_game_notifier.dart        # Game state notifier
│   │   └── memory_game_notifier.g.dart     # Generated
│   ├── pages/
│   │   └── memory_game_page.dart            # Main page
│   └── widgets/
│       ├── memory_card_widget.dart          # Card com flip animation
│       ├── memory_grid_widget.dart          # Grid responsivo
│       ├── game_stats_widget.dart           # Tempo, movimentos, pares
│       └── victory_dialog.dart              # Win screen
└── di/
    └── memory_injection.dart                # Injectable + GetIt setup

test/features/memory/
└── domain/usecases/
    ├── flip_card_usecase_test.dart          # 6 testes
    ├── check_match_usecase_test.dart        # 8 testes
    └── generate_cards_usecase_test.dart     # 6 testes
```

## 🎮 Como Usar

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/memory/presentation/pages/memory_game_page.dart';

// Na navegação
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const ProviderScope(
      child: MemoryGamePage(),
    ),
  ),
);

// Ou via rotas nomeadas
'/memory-game': (context) => const MemoryGamePage(),
```

## 🔧 Setup (DI)

```dart
import 'package:get_it/get_it.dart';
import 'features/memory/di/memory_injection.dart';

// No main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sl = GetIt.instance;
  await initMemoryDI(sl);

  runApp(const ProviderScope(child: MyApp()));
}
```

## 🧪 Executar Testes

```bash
# Testes unitários
flutter test test/features/memory/

# Build runner (gerar código Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Análise estática
flutter analyze lib/features/memory
```

## 📊 Métricas

- **Linhas de código**: ~1767
- **Testes unitários**: 20
- **Cobertura**: Use cases principais 100%
- **Arquivos**: 24 (domain: 10, data: 5, presentation: 9)

## 🎯 Funcionalidades Técnicas

### **Flip Animation**
- AnimationController com SingleTickerProviderStateMixin
- TweenSequence para flip suave (400ms)
- Transform 3D com perspective
- Atualização automática via didUpdateWidget

### **Match Logic**
- Validação de exatamente 2 cartas viradas
- Delay configurável por dificuldade (600-1000ms)
- Update otimista do estado
- Detecção automática de vitória

### **Scoring System**
```dart
efficiency = totalPairs / moves
speedFactor = totalPairs * 10 / timeInSeconds
efficiencyFactor = (efficiency * speedFactor).clamp(0.1, 3.0)

score = (matches * 100 * difficultyMultiplier) * efficiencyFactor
```

### **High Score Management**
- Persiste melhor pontuação por dificuldade
- Compara e atualiza automaticamente na vitória
- Exibe indicador visual de novo recorde
- Estrutura preparada para leaderboard online

### **State Machine**
```
initial → playing → paused → playing → completed
   ↓         ↓         ↓          ↓         ↓
 error ← error ← error ← error ← error
```

## 🔄 Comparação: Before/After

### **Before (Legacy)**
```
lib/pages/game_memory/
├── constants/              # Misturado com lógica
├── controllers/            # Provider misto
├── models/                 # Mutável
├── providers/              # ChangeNotifier
├── services/               # Acoplado
├── utils/                  # Espalhado
└── widgets/                # Lógica misturada
```

### **After (SOLID Featured)**
```
lib/features/memory/
├── domain/                 # Business logic isolada
├── data/                   # Persistência desacoplada
├── presentation/           # UI reativa
└── di/                     # Dependency injection
```

## 🚀 Migração de Outros Jogos

**Tempo estimado baseado em complexidade:**
- **Simple (Tic-Tac-Toe, Quiz)**: 2-3h
- **Medium (Snake, 2048)**: 4-6h
- **Complex (Sudoku, Campo Minado)**: 8-12h

**Checklist de migração:**
1. ✅ Analisar lógica atual (30min)
2. ✅ Criar entidades e enums (30min)
3. ✅ Implementar use cases (1-2h)
4. ✅ Criar repository e datasource (30min)
5. ✅ Riverpod notifier (1h)
6. ✅ Widgets e page (1-2h)
7. ✅ Testes unitários (2-3h)
8. ✅ Validação e docs (30min)

## 📚 Referências

- Template base: Gold Standard - `features/caca_palavra` (20 tests)
- Padrões: CLAUDE.md + Migration Guide
- State: Riverpod code generation
- Testing: Flutter test + Mocktail pattern
- Architecture: Clean Architecture + SOLID

## 🔮 Melhorias Futuras

- [ ] Adicionar analytics (estrutura preparada)
- [ ] Temas customizáveis (cores/ícones)
- [ ] Modo multiplayer local
- [ ] Leaderboard online
- [ ] Achievements system
- [ ] Daily challenges
- [ ] Sound effects (estrutura preparada)
