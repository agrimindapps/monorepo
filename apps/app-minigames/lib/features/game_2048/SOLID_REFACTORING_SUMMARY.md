# Refatorações SOLID Aplicadas - Game 2048

## Feature: Game 2048 (Puzzle Clássico)

### Análise da Arquitetura Existente:

A feature **Game 2048** já estava bem organizada com Clean Architecture:

✅ **Pontos Positivos Originais:**
- Clean Architecture (data/domain/presentation)
- 6 Use Cases bem definidos
- Repository pattern implementado
- Riverpod providers
- Entities imutáveis (Grid, Tile, Position)

❌ **Problemas Identificados:**
- **Algoritmo complexo de movimento** (237 linhas) em MoveTilesUseCase
- **Random() inline** em SpawnTileUseCase
- **Probabilidade hardcoded** (90% = 2, 10% = 4) sem constantes
- **Lógica de game over** com varredura em CheckGameOverUseCase
- **Processamento de linha** misturado com lógica de merge

### Arquivos Criados:

1. **tile_spawner_service.dart**
   - **Princípio**: SRP
   - **Responsabilidade**: Geração de novos tiles no grid
   - **Benefícios**:
     - Remove Random() inline do UseCase
     - Centraliza probabilidades (90% tile-2, 10% tile-4)
     - Seleção aleatória de posição isolada
     - Spawn múltiplo para inicialização
   - **Métodos** (11 métodos):
     - `spawnTile()` - Spawna novo tile em posição aleatória
     - `spawnMultipleTiles()` - Spawna múltiplos tiles (init)
     - `determineValue()` - Determina valor (2 ou 4)
     - `selectRandomPosition()` - Seleciona posição aleatória
     - `canSpawnTile()` - Verifica se há espaço
     - `getAvailableSpaceCount()` - Conta posições disponíveis
     - `getSpawnProbability()` - Calcula probabilidade (0.9 ou 0.1)
     - `validateSpawnConfig()` - Valida configuração
     - `getStatistics()` - Estatísticas de spawn
     - `createTestConfig()` - Config para testes
     - `spawnWithConfig()` - Spawn determinístico (testes)
   - **Constantes**: value2Threshold (9), commonValue (2), rareValue (4), probabilityRange (10)
   - **Modelos**: SpawnValidation, SpawnStatistics, SpawnTestConfig

2. **line_mover_service.dart**
   - **Princípio**: SRP + Algorithm Extraction
   - **Responsabilidade**: Processamento de movimento e merge em linhas/colunas
   - **Benefícios**:
     - Extrai algoritmo complexo (237 linhas → serviço isolado)
     - Lógica de merge separada de lógica de movimento
     - Cálculo de score centralizado
     - Processa grid completo para qualquer direção
   - **Métodos** (11 métodos):
     - `processLine()` - Processa linha individual (merge + move)
     - `canMergeWithNext()` - Verifica possibilidade de merge
     - `mergeTiles()` - Merge de dois tiles
     - `moveTile()` - Move tile sem merge
     - `calculatePosition()` - Calcula nova posição
     - `processGrid()` - Processa grid inteiro (todas direções)
     - `getLineStatistics()` - Estatísticas de linha
   - **Modelos**: LineProcessResult, MergeResult, MoveResult, GridProcessResult, LineStatistics

3. **game_over_checker_service.dart**
   - **Princípio**: SRP + Query Methods
   - **Responsabilidade**: Detecção de game over e movimentos possíveis
   - **Benefícios**:
     - Varredura horizontal/vertical isolada
     - Detecção de merge possível centralizada
     - Informações detalhadas sobre estado do jogo
     - Estatísticas de densidade do grid
   - **Métodos** (14 métodos):
     - `isGameOver()` - Verifica se jogo acabou
     - `hasEmptyPositions()` - Verifica posições vazias
     - `hasPossibleMerges()` - Verifica merges possíveis
     - `hasHorizontalMerges()` - Verifica merges horizontais
     - `hasHorizontalMergeInRow()` - Merge em linha específica
     - `hasVerticalMerges()` - Verifica merges verticais
     - `hasVerticalMergeInColumn()` - Merge em coluna específica
     - `canMergeTiles()` - Verifica se dois valores podem mergear
     - `getGameStateInfo()` - Informações detalhadas do estado
     - `countPossibleMerges()` - Conta total de merges possíveis
     - `getMergeOpportunities()` - Lista posições com merge
     - `getDensityStats()` - Estatísticas de densidade
     - `isValidGridState()` - Valida estado do grid
     - `isWithinBounds()` - Verifica bounds
   - **Modelos**: GameStateInfo, MergeOpportunities, GridDensityStats

### Melhorias Aplicadas:

**Antes (UseCases com algoritmos complexos)**:
```dart
// move_tiles_usecase.dart (237 linhas!)
class MoveTilesUseCase {
  Future<Either<Failure, GameStateEntity>> call(...) {
    // 100+ linhas de lógica de linha/coluna
    switch (direction) {
      case Direction.left: ...
      case Direction.right: ...
    }
    // Processamento inline de merge
    _LineProcessResult _processLine(...) { ... }
  }
}

// spawn_tile_usecase.dart
class SpawnTileUseCase {
  final Random _random = Random();  // ❌ Random inline
  
  Future<Either<Failure, GridEntity>> call(...) {
    final value = _random.nextInt(10) < 9 ? 2 : 4;  // ❌ Magic numbers
  }
}

// check_game_over_usecase.dart
class CheckGameOverUseCase {
  Future<Either<Failure, bool>> call(...) {
    // Varredura horizontal inline
    for (int row = 0; row < size; row++) { ... }
    // Varredura vertical inline
    for (int col = 0; col < size; col++) { ... }
  }
}
```

**Depois (UseCases usando Services)**:
```dart
// UseCases simplificados orquestrando serviços
final tile = _spawnerService.spawnTile(grid);
final result = _lineMoverService.processGrid(grid: grid, direction: direction);
final isOver = _gameOverChecker.isGameOver(grid);
```

### Impacto:

**Separação de Responsabilidades**:
- ✅ Spawn de tiles isolado em TileSpawnerService
- ✅ Algoritmo de movimento em LineMoverService
- ✅ Detecção de game over em GameOverCheckerService
- ✅ UseCases como orquestradores

**Constantes Centralizadas**:
- ✅ Probabilidades de spawn documentadas (90%/10%)
- ✅ Lógica de merge em um único lugar
- ✅ Fácil ajustar dificuldade do jogo

**Testabilidade**:
- ✅ Cada serviço testável isoladamente
- ✅ Spawn determinístico com configs de teste
- ✅ Mocks mais simples (sem Random inline)
- ✅ Testes de merge sem dependências de grid

**Algoritmos Complexos Isolados**:
- ✅ 237 linhas de movimento → serviço dedicado
- ✅ Merge logic separada de move logic
- ✅ Detecção de game over em queries especializadas

### Princípios SOLID Aplicados:

- ✅ **S**RP: Cada serviço com responsabilidade específica (spawn, move, game over)
- ✅ **O**CP: Fácil adicionar novos tamanhos de grid ou regras de merge
- ✅ **L**SP: Serviços mantêm contratos esperados
- ✅ **I**SP: Interfaces focadas (spawn ≠ move ≠ game over)
- ✅ **D**IP: Todos serviços injetáveis via @lazySingleton

### Arquitetura Final:

```
lib/features/game_2048/
├── data/
│   ├── datasources/
│   │   └── game_2048_local_datasource.dart
│   ├── models/
│   │   └── high_score_model.dart
│   └── repositories/
│       └── game_2048_repository_impl.dart
├── di/
│   └── game_2048_injection.dart
├── domain/
│   ├── entities/
│   │   ├── enums.dart
│   │   ├── game_state_entity.dart
│   │   ├── grid_entity.dart
│   │   ├── high_score_entity.dart
│   │   ├── position_entity.dart
│   │   └── tile_entity.dart
│   ├── repositories/
│   │   └── game_2048_repository.dart
│   ├── services/ 🆕
│   │   ├── tile_spawner_service.dart 🆕 (248 linhas)
│   │   ├── line_mover_service.dart 🆕 (384 linhas)
│   │   └── game_over_checker_service.dart 🆕 (328 linhas)
│   └── usecases/
│       ├── check_game_over_usecase.dart (simplificado)
│       ├── load_high_score_usecase.dart
│       ├── move_tiles_usecase.dart (simplificado, era 237 linhas!)
│       ├── restart_game_usecase.dart
│       ├── save_high_score_usecase.dart
│       └── spawn_tile_usecase.dart (simplificado)
└── presentation/
    ├── pages/
    │   └── game_2048_page.dart
    ├── providers/
    │   ├── game_2048_notifier.dart
    │   └── game_2048_notifier.g.dart
    └── widgets/
        ├── game_controls_widget.dart
        ├── game_over_dialog.dart
        ├── grid_widget.dart
        └── tile_widget.dart
```

### Destaque - Algoritmo Complexo Extraído:

O **LineMoverService** (384 linhas) implementa o algoritmo core do 2048:

1. **Processamento de Linha**:
   - Extrai tiles não-vazios
   - Detecta possibilidade de merge
   - Calcula novas posições
   - Determina tipo de animação

2. **Lógica de Merge**:
   - Merge de tiles adjacentes com mesmo valor
   - Score gained = valor do tile resultante
   - Tracking de IDs mergeados para animações
   - Position calculation baseado em direção

3. **Processamento de Grid**:
   - Suporta 4 direções (left, right, up, down)
   - Processa cada linha/coluna independentemente
   - Acumula resultados (tiles, score, movement)
   - Reversão de arrays para direções opostas

### Comparação com outras features:

| Feature | Complexidade | Serviços | Linhas | Tipo |
|---------|-------------|----------|--------|------|
| **Caça-Palavra** | Grid placement | 3 | 608 | Puzzle |
| **Campo Minado** | Flood-fill, Neighbors | 3 | 642 | Logic |
| **FlappBird** | Physics, Collision | 3 | 644 | Action |
| **Game 2048** | Line processing, Merge | 3 | 960 | Strategy |

**Game 2048** é o mais complexo algoritmicamente:
- **960 linhas** de serviços (vs ~640 das outras features)
- Algoritmo de linha com 384 linhas (maior serviço até agora)
- Lógica de merge bidirecional (horizontal + vertical)
- Sistema de animações baseado em tipo de movimento

---

**Status**: ✅ Refatoração concluída com algoritmos complexos isolados

## Total de Arquivos Criados: 3

- **Game 2048**: 3 serviços especializados (spawner, line mover, game over checker)

**Destaque**: Maior refatoração até agora - UseCase de 237 linhas → serviço de 384 linhas com responsabilidade única
