# Snake Game - Improvement Opportunities

## 📋 Overview

O jogo Snake está bem arquiteturado com Clean Architecture, mas há várias oportunidades de melhorias em performance, gameplay e user experience.

---

## 🎯 Oportunidades de Melhoria Identificadas

### **HIGH PRIORITY - Impacto Alto / Complexidade Média**

#### 1. **Performance: Cache de Posições Livres** 🔴
**Problema:**
- `getFreePositions()` é `O(gridSize²)` = `O(400)` operações a cada frame
- Executado toda vez que precisa gerar comida
- Em hard difficulty (50ms por frame), pode causar drops

**Solução:**
- Manter Set<Position> de `freePositions` ao invés de recalcular
- Atualizar incrementalmente ao mover serpente
- Cache invalidado apenas quando preciso

**Impacto:** -60% CPU em getFreePositions
**Complexidade:** Média
**Tempo Estimado:** 2-3h

---

#### 2. **Dynamic Difficulty Progression** 🟠
**Problema:**
- Dificuldade é fixa (easy/medium/hard)
- Jogo não fica progressivamente mais duro ao ganhar pontos
- Sem sistema de "waves" ou "levels"

**Solução:**
- Aumentar gameSpeed a cada 10 pontos (ex: medium começa em 100ms, cai para 90ms)
- Aumentar frequência de comida ao crescer (ex: 2 comidas em grid)
- Aumentar randomness de comida (strategic → random → nearby)

**Exemplos:**
```
Score 0-10: Normal speed, 1 comida, comida estratégica
Score 11-20: -10% speed, 1 comida, comida aleatória
Score 21-30: -20% speed, 2 comidas, comida aleatória
Score 31+: -30% speed, 2 comidas, comida próxima (fácil)
```

**Impacto:** Replayability +200%, Engaging +300%
**Complexidade:** Média
**Tempo Estimado:** 2-3h

---

#### 3. **Input Buffering** 🟡
**Problema:**
- Apenas 1 input por frame é processado
- Em movimento rápido, inputs podem ser ignorados
- Player não consegue fazer mudanças rápidas de direção

**Solução:**
- Queue de inputs (máx 2 na fila)
- Processar fila ANTES do movimento
- Descartar inputs inválidos (direção oposta)

**Impacto:** Gameplay responsivo, reduz frustration
**Complexidade:** Baixa
**Tempo Estimado:** 1h

---

### **MEDIUM PRIORITY - Impacto Médio / Complexidade Baixa**

#### 4. **Grid Occupancy Win Condition** 🟠
**Problema:**
- Sem vitória ao preencher grid (no snake classic também não tem, mas é uma feature legal)
- Player não tem objetivo final

**Solução:**
- Detector: se `occupancyPercentage > 95%` → WIN
- Bônus de pontos: `gridSize² - snakeLength`
- Status: "You Won!" + mensagem especial

**Impacto:** Objetivo claro, meta alcançável
**Complexidade:** Baixa
**Tempo Estimado:** 1h

---

#### 5. **Comida Powerup System** 🟡
**Problema:**
- Comida é homogênea (sempre +1 ponto)
- Sem variação de tipos

**Solução:**
- Tipos de comida:
  - `normal`: +1 ponto
  - `bonus`: +5 pontos (mais raro, 20% chance)
  - `speed_boost`: +2 movimento (temporário)
  - `slow_down`: +1 ponto mas reduz speed por 3 segundos

**Impacto:** Variação, estratégia, diversão
**Complexidade:** Média
**Tempo Estimado:** 2h

---

#### 6. **Danger Visualization** 🟡
**Problema:**
- Cálculo de danger level existe em `CollisionDetectionService` mas não é usado
- Player não tem feedback visual

**Solução:**
- Mostrar "danger indicator" na cabeça:
  - Verde: low/medium danger
  - Amarelo: high danger
  - Vermelho: critical danger
- Cor muda dinâmicamente a cada frame

**Impacto:** Better decision making, visual feedback
**Complexidade:** Baixa
**Tempo Estimado:** 1h

---

### **LOW PRIORITY - Nice to Have**

#### 7. **Replay System** 🟡
**Problema:**
- Sem forma de revisar jogo anterior
- Apenas estatísticas finais

**Solução:**
- Gravar todas as posições: `List<SnakeGameState>`
- Salvar ao game over
- Modo "playback" que reconstrói jogo movimento a movimento

**Impacto:** Analytics, learning tool
**Complexidade:** Média
**Tempo Estimado:** 3h

---

#### 8. **Leaderboard Local** 🟡
**Problema:**
- Apenas high score único é salvo
- Sem histórico de scores anteriores

**Solução:**
- Salvar top 10 scores com:
  - score
  - snakeLength
  - difficulty
  - timestamp
  - foodEaten
- Mostrar ranking na home

**Impacto:** Motivation, competitive
**Complexidade:** Baixa
**Tempo Estimado:** 2h

---

#### 9. **Wall Mode (Optional Difficulty)** 🟡
**Problema:**
- Apenas wraparound existe
- Sem mode com paredes sólidas

**Solução:**
- Novo enum: `WallMode.wraparound | WallMode.solid`
- Se solid: colisão com parede = game over
- Mais desafiador, menos espaço

**Impacto:** Variação, novo challenge
**Complexidade:** Média
**Tempo Estimado:** 2h

---

## 📊 Summary Table

| Melhoria | Prioridade | Impacto | Complexidade | Tempo (h) |
|----------|-----------|--------|--------------|-----------|
| Cache Posições | 🔴 Alta | ⭐⭐⭐ | Média | 2-3 |
| Dynamic Difficulty | 🔴 Alta | ⭐⭐⭐ | Média | 2-3 |
| Input Buffering | 🔴 Alta | ⭐⭐⭐ | Baixa | 1 |
| Grid Occupancy Win | 🟠 Média | ⭐⭐ | Baixa | 1 |
| Powerup System | 🟠 Média | ⭐⭐ | Média | 2 |
| Danger Visualization | 🟠 Média | ⭐⭐ | Baixa | 1 |
| Replay System | 🟡 Baixa | ⭐ | Média | 3 |
| Leaderboard Local | 🟡 Baixa | ⭐ | Baixa | 2 |
| Wall Mode | 🟡 Baixa | ⭐ | Média | 2 |

---

## 🚀 Recommended Order

### **Phase 1: Core Performance & Feel** (5-7 horas)
1. ✅ Input Buffering (1h)
2. ✅ Cache Posições Livres (2-3h)
3. ✅ Dynamic Difficulty (2-3h)

**Result:** Game feels more responsive and engaging

### **Phase 2: Game Polish** (3-4 horas)
4. ✅ Grid Occupancy Win (1h)
5. ✅ Danger Visualization (1h)
6. ✅ Powerup System (2h)

**Result:** More depth and better visual feedback

### **Phase 3: Advanced Features** (7 horas)
7. ✅ Replay System (3h)
8. ✅ Leaderboard (2h)
9. ✅ Wall Mode (2h)

---

## 💡 Implementation Notes

### Cache de Posições
```dart
// Antes: O(gridSize²) toda vez
List<Position> freePositions = _collisionService.getFreePositions(...);

// Depois: O(1) lookup + O(1) updates
Set<Position> _freePositions = {...};

void moveSnake(newHead, removeOldTail) {
  _freePositions.remove(newHead); // O(1)
  if (removeOldTail) {
    _freePositions.add(oldTail); // O(1)
  }
}
```

### Dynamic Difficulty
```dart
int _calculateGameSpeed(int score, SnakeDifficulty baseDifficulty) {
  final speedMultiplier = 1 - (score ~/ 10) * 0.05; // 5% per 10 points
  return (baseDifficulty.gameSpeed.inMilliseconds * speedMultiplier).toInt();
}
```

### Input Buffering
```dart
class DirectionQueue {
  final List<Direction> _queue = [];
  static const maxSize = 2;

  void enqueue(Direction dir) {
    if (_queue.length < maxSize && isValidDirection(dir)) {
      _queue.add(dir);
    }
  }

  Direction? dequeue() => _queue.isNotEmpty ? _queue.removeAt(0) : null;
}
```

---

## 📝 Files to Modify

- `domain/services/collision_detection_service.dart` - Add caching interface
- `domain/services/snake_movement_service.dart` - Input queue + dynamic speed
- `domain/services/food_generator_service.dart` - Powerup system
- `domain/services/game_state_manager_service.dart` - Dynamic difficulty + win condition
- `domain/entities/game_state.dart` - Add freePositionsCache
- `presentation/providers/snake_game_notifier.dart` - Input queue handling
- `presentation/pages/snake_page.dart` - Danger visualization

---

**Last Updated:** 2025-10-31
**Status:** Ready for Implementation
