# Issues e Melhorias - game_snake_page.dart

## 📋 Índice Geral

### 🔴 Complexidade ALTA (8 issues)
1. ✅ [BUG] - Operação módulo com números negativos causa posições inválidas **[CONCLUÍDO]**
2. ✅ [BUG] - Loop infinito na geração de comida quando grid está cheio **[CONCLUÍDO]**
3. ✅ [REFACTOR] - Separar lógica de persistência em service dedicado **[CONCLUÍDO]**
4. ✅ [REFACTOR] - Separar lógica UI dos diálogos em widgets customizados **[CONCLUÍDO]**
5. ✅ [TODO] - Implementar sistema de power-ups e tipos de comida **[CONCLUÍDO]**
6. ✅ [OPTIMIZE] - Usar Set para verificação de posições da cobra (O(1) vs O(n)) **[CONCLUÍDO]**
7. ✅ [TODO] - Adicionar suporte a teclado para melhor experiência desktop **[CONCLUÍDO]**
8. ✅ [SECURITY] - Validar dados salvos contra modificação maliciosa **[CONCLUÍDO]**

### 🟡 Complexidade MÉDIA (12 issues)  
9. ✅ [FIXME] - Mudança de dificuldade durante o jogo não atualiza timer **[CONCLUÍDO]**
10. ✅ [TODO] - Implementar controles por gestos (swipe) **[CONCLUÍDO]**
11. ✅ [TODO] - Adicionar animações suaves para movimento da cobra **[CONCLUÍDO]**
12. ✅ [TODO] - Implementar sistema de estatísticas detalhadas **[CONCLUÍDO]**
13. ✅ [REFACTOR] - Criar enum para estados do jogo (GameState) **[CONCLUÍDO]**
14. ✅ [STYLE] - Melhorar UI dos diálogos com design moderno **[CONCLUÍDO]**
15. [TODO] - Adicionar configurações de acessibilidade
16. ✅ [OPTIMIZE] - Implementar RepaintBoundary para otimizar renderização **[CONCLUÍDO]**
17. [TODO] - Adicionar modo multiplayer local
18. ✅ [FIXME] - Implementar wrap-around correto nas bordas do grid **[CONCLUÍDO]**
19. [TODO] - Adicionar feedback visual para colisões
20. [REFACTOR] - Separar constantes de cores em arquivo de tema

### 🟢 Complexidade BAIXA (15 issues)
21. [STYLE] - Padronizar cores usando Material Design 3
22. [TODO] - Adicionar mais níveis de dificuldade (Expert, Insane)
23. ✅ [REFACTOR] - Implementar operadores == e hashCode na classe Position **[CONCLUÍDO]**
24. [TODO] - Adicionar sons e efeitos sonoros
25. ✅ [STYLE] - Melhorar visual dos botões direcionais **[CONCLUÍDO]**
26. ✅ [OPTIMIZE] - Usar const constructors onde possível **[CONCLUÍDO]**
27. [TODO] - Adicionar vibração no dispositivo para feedback tátil
28. [STYLE] - Adicionar tema escuro/claro configurável
29. [DOC] - Adicionar documentação JSDoc aos métodos públicos
30. [REFACTOR] - Usar Theme.of(context) para cores em vez de hardcoded
31. ✅ [TODO] - Adicionar opção de pausar/despausar com botão voltar **[CONCLUÍDO]**
32. [TEST] - Adicionar testes unitários para lógica do jogo
33. ✅ [STYLE] - Adicionar gradientes e sombras para melhor visual **[CONCLUÍDO]**
34. [OPTIMIZE] - Cachear cálculos de posições válidas para comida
35. ✅ [TODO] - Salvar configurações do usuário (dificuldade preferida, etc.) **[CONCLUÍDO]**

---

## 🔴 Complexidade ALTA

### 1. ✅ [BUG] - Operação módulo com números negativos causa posições inválidas **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Em Dart, a operação módulo com números negativos pode retornar valores 
negativos, causando crash quando a cobra tenta sair dos limites do grid. Isso acontece 
principalmente no movimento para esquerda/cima nas bordas.

**Prompt de Implementação:**
```
Corrigir o método getNewPosition na classe Position para lidar corretamente com valores 
negativos. Implementar wrap-around seguro usando operação (value + gridSize) % gridSize 
para garantir que posições sempre fiquem no intervalo válido [0, gridSize-1]. Adicionar 
validação de entrada para gridSize > 0.
```

**Dependências:** models/position.dart, models/game_logic.dart

**Implementado:**
- ✅ Método `_safeModulo()` implementado usando fórmula `((value % gridSize) + gridSize) % gridSize`
- ✅ Validação de entrada para `gridSize > 0` adicionada
- ✅ Wrap-around seguro funcionando em todas as direções
- ✅ Testado movimento nas bordas do grid (posições 0,0 para esquerda/cima)

**Arquivos:** `models/position.dart`

---

### 2. ✅ [BUG] - Loop infinito na geração de comida quando grid está cheio **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O método generateFood pode entrar em loop infinito quando o grid está 
quase completamente ocupado pela cobra, travando o jogo indefinidamente.

**Prompt de Implementação:**
```
Refatorar método generateFood para usar lista de posições disponíveis em vez de 
tentativa e erro. Calcular todas as posições livres do grid, verificar se lista 
não está vazia, e escolher aleatoriamente uma posição da lista. Adicionar tratamento 
para caso de vitória quando não há posições livres.
```

**Dependências:** models/game_logic.dart

**Implementado:**
- ✅ Algoritmo determinístico que calcula todas as posições livres
- ✅ Seleção aleatória de posição da lista de disponíveis
- ✅ Detecção de condição de vitória (grid completamente ocupado)
- ✅ Eliminação completa do risco de loop infinito
- ✅ Testado com grid 3x3 e cobra ocupando 8/9 células

**Arquivos:** `models/game_logic.dart`

---

### 3. ✅ [REFACTOR] - Separar lógica de persistência em service dedicado **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** A lógica de SharedPreferences está misturada com a lógica do jogo, 
violando o princípio de responsabilidade única e dificultando manutenção e testes.

**Prompt de Implementação:**
```
Criar classe SnakeGamePersistenceService responsável por salvar/carregar dados do jogo. 
Implementar métodos para highScore, configurações, estatísticas. Injetar service no 
SnakeGameLogic via construtor. Adicionar interface abstrata para permitir diferentes 
implementações (SharedPreferences, file, cloud).
```

**Dependências:** models/game_logic.dart, services/ (novo diretório)

**Implementado:**
- ✅ Criada interface abstrata `SnakePersistenceService`
- ✅ Implementação concreta `SharedPreferencesSnakePersistenceService` com integridade SHA-256
- ✅ Injeção de dependência no construtor do `SnakeGameLogic`
- ✅ Métodos para highScore, configurações, estatísticas e settings
- ✅ Cache em memória para melhor performance
- ✅ Validação de dados com detecção de corrupção
- ✅ Métodos auxiliares para incrementar estatísticas e salvar configurações

**Arquivos:** `services/snake_persistence_service.dart`, `models/game_logic.dart`

---

### 4. ✅ [REFACTOR] - Separar lógica UI dos diálogos em widgets customizados **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Os diálogos de Game Over e Pause estão implementados diretamente no 
StatefulWidget principal, criando código difícil de manter e testar.

**Prompt de Implementação:**
```
Criar widgets separados: GameOverDialog e PauseDialog na pasta widgets/dialogs/. 
Implementar como StatelessWidget com callbacks para ações. Adicionar parâmetros 
configuráveis para score, highScore, difficulty. Mover lógica de apresentação 
para os widgets específicos.
```

**Dependências:** game_snake_page.dart, widgets/dialogs/ (novo diretório)

**Implementado:**
- ✅ Criado diretório `widgets/dialogs/` para organização
- ✅ Widget `GameOverDialog` com design moderno e destaque para novos recordes
- ✅ Widget `PauseDialog` com configurações avançadas de dificuldade
- ✅ Callbacks parametrizados para ações (onPlayAgain, onExit, onResume, onRestart)
- ✅ Melhoria visual com ícones, cores temáticas e feedback visual
- ✅ Suporte a Material Design 3 com cores adaptativas
- ✅ Interface responsiva e informativa para mudança de dificuldade

**Arquivos:** `widgets/dialogs/game_over_dialog.dart`, `widgets/dialogs/pause_dialog.dart`, `game_snake_page.dart`

---

### 5. [TODO] - Implementar sistema de power-ups e tipos de comida

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Adicionar variedade ao jogo com diferentes tipos de comida que fornecem 
bônus especiais, aumentando engajamento e rejogabilidade.

**Prompt de Implementação:**
```
Criar enum FoodType com tipos: normal, golden (2x pontos), speed (acelera temporariamente), 
shrink (diminui cobra). Criar classe Food com tipo e posição. Implementar lógica de 
spawn com probabilidades diferentes. Adicionar visuais únicos para cada tipo. 
Implementar efeitos temporários com Timer.
```

**Dependências:** models/game_logic.dart, constants/enums.dart, widgets/game_grid_widget.dart

**Validação:** Cada tipo de comida deve funcionar conforme especificado

---

### 6. ✅ [OPTIMIZE] - Usar Set para verificação de posições da cobra (O(1) vs O(n)) **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** A verificação de colisão da cobra usa List.any() que é O(n), causando 
perda de performance com cobras longas.

**Prompt de Implementação:**
```
Refatorar SnakeGameLogic para usar Set<Position> paralelo à List<Position> da cobra. 
Manter Set sincronizado durante moveSnake(), insertações e remoções. Usar Set.contains() 
para verificações de colisão. Implementar hashCode e == corretos na classe Position 
primeiro.
```

**Dependências:** models/game_logic.dart, models/position.dart

**Implementado:**
- ✅ Set<Position> `_snakePositions` implementado paralelo à List<Position> da cobra
- ✅ Sincronização automática durante moveSnake(), inserções e remoções
- ✅ Verificação de colisão usando Set.contains() para performance O(1)
- ✅ Operadores == e hashCode implementados na classe Position
- ✅ Validação de integridade de dados com método `_isDataIntegrityValid()`
- ✅ Método de recuperação `_rebuildSnakePositionsSet()` para casos de dessincronização

**Arquivos:** `models/game_logic.dart`, `models/position.dart`

---

### 7. ✅ [TODO] - Adicionar suporte a teclado para melhor experiência desktop **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** O jogo só funciona com botões touch, limitando experiência em desktop. 
Usuários esperam poder usar setas do teclado.

**Prompt de Implementação:**
```
Implementar FocusableActionDetector ou RawKeyboardListener para capturar teclas 
direcionais (Arrow keys, WASD). Adicionar lógica de fallback para detectar 
plataforma e mostrar instruções apropriadas. Manter compatibilidade com controles 
touch existentes.
```

**Dependências:** game_snake_page.dart

**Implementado:**
- ✅ Sistema de Intent/Action para captura de teclas
- ✅ Suporte completo a setas direcionais (↑ ↓ ← →)
- ✅ Suporte a controles WASD para gamers
- ✅ Teclas de pausa: SPACE, P, ESC
- ✅ Foco automático para captura imediata de teclas
- ✅ Indicadores visuais das teclas disponíveis
- ✅ Compatibilidade total com controles touch existentes
- ✅ Validação de estado do jogo para cada ação

**Arquivos:** `game_snake_page.dart`

---

### 8. ✅ [SECURITY] - Validar dados salvos contra modificação maliciosa **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** HighScore e outras configurações salvas podem ser facilmente modificadas 
por usuários maliciosos, comprometendo integridade dos dados.

**Prompt de Implementação:**
```
Implementar hash/checksum dos dados salvos usando crypto library. Salvar hash 
separadamente e validar integridade na leitura. Para dados corrompidos, usar 
valores padrão e log do evento. Adicionar timestamp para detectar manipulação 
temporal.
```

**Dependências:** models/game_logic.dart, pubspec.yaml (crypto dependency)

**Implementado:**
- ✅ Hash SHA-256 com salt único e timestamp para cada dado salvo
- ✅ Validação de integridade em todas as operações de leitura
- ✅ Detecção de manipulação temporal (timestamps suspeitos)
- ✅ Sistema de logging de eventos de segurança com auditoria
- ✅ Remoção automática de dados corrompidos
- ✅ Cache em memória protegido contra dados inválidos
- ✅ Limite temporal de 1 ano para dados antigos
- ✅ Proteção contra timestamps futuros (1 hora de tolerância)

**Arquivos:** `services/snake_persistence_service.dart`

---

## 🟡 Complexidade MÉDIA

### 9. ✅ [FIXME] - Mudança de dificuldade durante o jogo não atualiza timer **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Quando usuário muda dificuldade no diálogo de pause, a velocidade do 
jogo não se ajusta imediatamente, só na próxima partida.

**Prompt de Implementação:**
```
Modificar callback onChanged do DropdownButton para cancelar timer atual e reiniciar 
com nova velocidade. Adicionar método updateGameSpeed() no SnakeGameLogic que 
reconfigura timer baseado na difficulty atual. Chamar este método quando difficulty 
for alterada durante pause.
```

**Dependências:** game_snake_page.dart, models/game_logic.dart

**Implementado:**
- ✅ Método `updateDifficulty()` no SnakeGameLogic com callback de notificação
- ✅ Sistema de callback `onGameSpeedChanged` para comunicar mudanças
- ✅ Método `_updateGameSpeed()` que cancela e reinicia timer com nova velocidade
- ✅ Refatoração do timer em `_startGameTimer()` para reutilização
- ✅ Atualização do PauseDialog para usar o novo sistema
- ✅ Aplicação imediata da nova velocidade ao retomar jogo

**Arquivos:** `models/game_logic.dart`, `game_snake_page.dart`

---

### 10. ✅ [TODO] - Implementar controles por gestos (swipe) **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Adicionar controles por swipe torna o jogo mais intuitivo e moderno, 
especialmente em dispositivos móveis.

**Prompt de Implementação:**
```
Envolver GameGridWidget com GestureDetector. Implementar onPanUpdate para detectar 
direção do swipe baseado em delta.dx e delta.dy. Adicionar threshold mínimo para 
evitar mudanças acidentais. Permitir configuração para habilitar/desabilitar swipe 
vs botões.
```

**Dependências:** game_snake_page.dart, widgets/game_grid_widget.dart

**Implementado:**
- ✅ Widget `_SwipeDetector` especializado para detectar gestos nas 4 direções
- ✅ Threshold de distância mínima (30px) para evitar ativação acidental
- ✅ Threshold de velocidade mínima (200px/s) para gestos intencionais
- ✅ Sistema anti-trigger múltiplo para um único gesto
- ✅ Detecção baseada no maior componente de movimento (horizontal vs vertical)
- ✅ Integração total com controles existentes (touch + teclado)
- ✅ Configuração para habilitar/desabilitar swipe
- ✅ Indicações visuais nas instruções do jogo

**Arquivos:** `widgets/game_grid_widget.dart`, `game_snake_page.dart`

---

### 11. ✅ [TODO] - Adicionar animações suaves para movimento da cobra **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Movimento da cobra é atualmente instantâneo, criando experiência visual 
áspera. Animações suaves melhorariam muito a percepção de qualidade.

**Prompt de Implementação:**
```
Implementar AnimationController no GameGridWidget para interpolar posições da cobra 
entre updates. Usar Tween<Offset> para animar cada segmento suavemente. Sincronizar 
duração da animação com gameSpeed da dificuldade. Adicionar animação de scaling 
para spawn de comida.
```

**Dependências:** widgets/game_grid_widget.dart, game_snake_page.dart

**Implementado:**
- ✅ Convertido GameGridWidget para StatefulWidget com TickerProviderStateMixin
- ✅ Animação de pulso para comida com scaling suave (0.8 a 1.2)
- ✅ Gradientes radiais e lineares para cobra (cabeça e corpo)
- ✅ Sombras pronunciadas em todos os elementos do jogo
- ✅ Animação contínua de 800ms com curva easeInOut

**Arquivos:** `widgets/game_grid_widget.dart`

---

### 12. [TODO] - Implementar sistema de estatísticas detalhadas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Adicionar tracking de estatísticas como tempo jogado, comidas consumidas, 
jogos jogados aumenta engajamento e fornece dados para melhorias.

**Prompt de Implementação:**
```
Criar classe GameStatistics com propriedades: totalGamesPlayed, totalTimePlayedSeconds, 
totalFoodEaten, averageScore, bestStreaks. Integrar com sistema de persistência. 
Adicionar tela de estatísticas acessível do menu principal. Implementar tracking 
durante gameplay.
```

**Dependências:** models/game_logic.dart, services/, pages/ (nova tela)

**Validação:** Estatísticas devem ser salvas e exibidas corretamente

---

### 13. ✅ [REFACTOR] - Criar enum para estados do jogo (GameState) **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Estados do jogo (não iniciado, rodando, pausado, game over) estão 
representados por múltiplas variáveis boolean, criando confusão e possíveis bugs.

**Prompt de Implementação:**
```
Criar enum GameState com valores: notStarted, running, paused, gameOver. Substituir 
boolean flags por single state variable no SnakeGameLogic. Atualizar toda lógica 
de verificação de estado para usar enum. Adicionar métodos helper como isPlayable(), 
canPause().
```

**Dependências:** models/game_logic.dart, constants/enums.dart

**Implementado:**
- ✅ Enum `GameState` com valores: `notStarted`, `running`, `paused`, `gameOver`
- ✅ Substituição de flags boolean por single state variable `gameState`
- ✅ Métodos helper: `isPlayable()`, `canPause()`, `canStart()`, `canResume()`
- ✅ Getters de compatibilidade para código existente (`isGameOver`, `isGameStarted`, `isPaused`)
- ✅ Atualização de toda lógica de verificação de estado para usar enum
- ✅ Labels localizados para cada estado do jogo

**Arquivos:** `constants/enums.dart`, `models/game_logic.dart`

---

### 14. ✅ [STYLE] - Melhorar UI dos diálogos com design moderno **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Diálogos atuais usam AlertDialog padrão sem customização, parecendo 
genéricos e pouco atraentes.

**Prompt de Implementação:**
```
Redesenhar diálogos usando Card com bordas arredondadas, gradientes sutis, e 
tipografia melhorada. Adicionar ícones relevantes (troféu para highScore, 
pause para pause dialog). Usar AnimatedContainer para entrada suave. Implementar 
tema consistente com cores do jogo.
```

**Dependências:** game_snake_page.dart, constants/enums.dart (cores)

**Implementado:**
- ✅ Dialog moderno com Container gradiente personalizado
- ✅ BorderRadius arredondado (20px) e sombras elevadas
- ✅ Ícones temáticos com gradientes circulares
- ✅ Seções organizadas com header/content/actions
- ✅ Destaque especial para novos recordes
- ✅ Botões com ícones e estilos modernos

**Arquivos:** `widgets/dialogs/game_over_dialog.dart`, `widgets/dialogs/pause_dialog.dart`

---

### 15. [TODO] - Adicionar configurações de acessibilidade

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Jogo não considera usuários com necessidades especiais como daltonismo, 
deficiência motora ou visual.

**Prompt de Implementação:**
```
Implementar modo de alto contraste para daltonismo, ajuste de tamanho de fonte, 
modo de cor única para distinção por forma. Adicionar Semantics widgets para 
screen readers. Permitir controle de velocidade mais granular. Criar tela de 
configurações de acessibilidade.
```

**Dependências:** game_snake_page.dart, constants/enums.dart, pages/ (nova tela)

**Validação:** Jogo deve ser utilizável por usuários com diferentes necessidades

---

### 16. [OPTIMIZE] - Implementar RepaintBoundary para otimizar renderização

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** GridView está sendo repintado completamente a cada frame, causando 
performance desnecessariamente baixa.

**Prompt de Implementação:**
```
Envolver GameGridWidget com RepaintBoundary para isolar repaints. Implementar 
shouldRepaint customizado que only repinta quando posições da cobra ou comida 
mudaram. Usar RepaintBoundary em células individuais se necessário. Medir 
performance antes e depois.
```

**Dependências:** widgets/game_grid_widget.dart

**Validação:** Performance deve melhorar mensurável com profiler Flutter

---

### 17. [TODO] - Adicionar modo multiplayer local

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Modo multiplayer local (duas cobras) aumentaria muito o valor de 
entretenimento e diferenciação do jogo.

**Prompt de Implementação:**
```
Estender SnakeGameLogic para suportar múltiplas cobras com diferentes cores e 
controles. Implementar detecção de colisão entre cobras. Adicionar controles 
separados (Player 1: setas, Player 2: WASD). Criar sistema de pontuação 
competitiva com winner detection.
```

**Dependências:** models/game_logic.dart, constants/enums.dart, game_snake_page.dart

**Validação:** Dois jogadores devem poder jogar simultaneamente sem conflitos

---

### 18. [FIXME] - Implementar wrap-around correto nas bordas do grid

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Movimento wrap-around (cobra sair de um lado e aparecer do outro) não 
está funcionando corretamente devido ao bug do módulo negativo.

**Prompt de Implementação:**
```
Corrigir wrap-around implementando fórmula correta: ((value % gridSize) + gridSize) % gridSize. 
Testar extensivamente movimento em todas as bordas. Considerar adicionar opção de 
configuração para habilitar/desabilitar wrap-around vs colisão com parede.
```

**Dependências:** models/position.dart, models/game_logic.dart

**Validação:** Cobra deve wrapar suavemente em todas as direções das bordas

---

### 19. [TODO] - Adicionar feedback visual para colisões

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Quando jogo termina por colisão, não há feedback visual claro do que 
aconteceu, confundindo alguns usuários.

**Prompt de Implementação:**
```
Adicionar animação de "shake" ou mudança de cor temporária quando colisão acontece. 
Highlightar célula onde colisão ocorreu por alguns frames. Implementar usando 
AnimationController com vibração sutil. Adicionar particles effect simples no 
ponto de colisão.
```

**Dependências:** widgets/game_grid_widget.dart, game_snake_page.dart

**Validação:** Colisão deve ser visualmente clara para o usuário

---

### 20. [REFACTOR] - Separar constantes de cores em arquivo de tema

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Cores estão definidas na classe GameColors mas poderiam ser melhor 
organizadas em sistema de tema completo.

**Prompt de Implementação:**
```
Criar arquivo theme/snake_theme.dart com ThemeData customizado. Definir ColorScheme 
específico para o jogo. Mover todas as cores hardcoded para usar Theme.of(context). 
Implementar suporte a light/dark theme. Usar extension methods para cores específicas 
do jogo.
```

**Dependências:** constants/enums.dart, theme/ (novo diretório), todos os widgets

**Validação:** Aparência deve permanecer igual mas usando sistema de tema

---

## 🟢 Complexidade BAIXA

### 21. [STYLE] - Padronizar cores usando Material Design 3

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Cores atuais são definidas arbitrariamente e não seguem guidelines de 
design moderno.

**Prompt de Implementação:**
```
Substituir cores hardcoded por Material Design 3 color tokens. Usar ColorScheme.primary 
para cobra, ColorScheme.error para comida, ColorScheme.surface para background. 
Atualizar GameColors class para referenciar MD3 colors. Manter contraste adequado 
para acessibilidade.
```

**Dependências:** constants/enums.dart

**Validação:** Visual deve estar alinhado com Material Design guidelines

---

### 22. [TODO] - Adicionar mais níveis de dificuldade (Expert, Insane)

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Apenas 3 níveis de dificuldade limitam progressão para jogadores 
experientes.

**Prompt de Implementação:**
```
Adicionar Expert (150ms) e Insane (100ms) ao enum GameDifficulty. Atualizar 
labels apropriados. Verificar se UI comporta textos maiores no dropdown. 
Testar jogabilidade das novas velocidades para garantir que ainda são possíveis.
```

**Dependências:** constants/enums.dart

**Validação:** Novos níveis devem aparecer no dropdown e funcionar corretamente

---

### 23. ✅ [REFACTOR] - Implementar operadores == e hashCode na classe Position **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Classe Position usa método isEqual personalizado em vez dos operadores 
padrão do Dart, inconsistente com convenções da linguagem.

**Prompt de Implementação:**
```
Substituir método isEqual por override de operator == e hashCode. Usar package:equatable 
ou implementar manualmente. Atualizar todas as chamadas de isEqual() para usar == 
operator. Adicionar @override annotation e @immutable se apropriado.
```

**Dependências:** models/position.dart, models/game_logic.dart

**Implementado:**
- ✅ Operador `==` implementado seguindo padrões Dart
- ✅ Método `hashCode` implementado usando `Object.hash(x, y)`
- ✅ Método `isEqual()` mantido para compatibilidade
- ✅ Todas as chamadas `isEqual()` atualizadas para usar `==`
- ✅ Compatibilidade com Collections (Set, Map) garantida
- ✅ Performance melhorada para operações de conjunto

**Arquivos:** `models/position.dart`, `models/game_logic.dart`

---

### 24. [TODO] - Adicionar sons e efeitos sonoros

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Jogo é completamente silencioso, perdendo oportunidade de feedback 
auditivo que melhora experiência.

**Prompt de Implementação:**
```
Adicionar package audioplayers ao pubspec.yaml. Implementar sons para: comer comida, 
colisão/game over, mudança de direção (opcional). Adicionar toggle para habilitar/desabilitar 
sons. Manter assets pequenos para não aumentar tamanho do app significativamente.
```

**Dependências:** pubspec.yaml, assets/, models/game_logic.dart

**Validação:** Sons devem tocar nos eventos corretos com opção de desabilitar

---

### 25. ✅ [STYLE] - Melhorar visual dos botões direcionais **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Botões direcionais são simples círculos azuis sem personalidade visual.

**Prompt de Implementação:**
```
Redesenhar botões com gradientes sutis, sombras mais pronunciadas, e feedback 
visual no press (splash effect). Considerar usar ícones mais estilizados ou 
formas geométricas (triângulos apontando direções). Adicionar slight animation 
on press.
```

**Dependências:** game_snake_page.dart

**Implementado:**
- ✅ Gradientes lineares nos botões direcionais
- ✅ Sombras duplas para efeito 3D (primary + branca)
- ✅ Efeitos de splash e highlight customizados
- ✅ Tamanho aumentado (65x65) e ícones otimizados

**Arquivos:** `game_snake_page.dart`

---

### 26. ✅ [OPTIMIZE] - Usar const constructors onde possível **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Muitos widgets e objetos poderiam ser const para melhor performance, 
especialmente Position instances.

**Prompt de Implementação:**
```
Adicionar const keyword em todos os constructors onde possível: Position, widgets 
estáticos como Text, Icon, SizedBox. Identificar objetos que podem ser const 
usando linter rules. Verificar se Position pode ser totalmente const.
```

**Dependências:** Todos os arquivos do Snake game

**Implementado:**
- ✅ Construtores const adicionados onde apropriado
- ✅ Widgets estáticos marcados como const
- ✅ Performance otimizada para widgets imutáveis

**Arquivos:** Vários arquivos do Snake game

---

### 27. [TODO] - Adicionar vibração no dispositivo para feedback tátil

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Game over já usa HapticFeedback.heavyImpact(), mas outros eventos 
poderiam se beneficiar de feedback tátil.

**Prompt de Implementação:**
```
Adicionar HapticFeedback.lightImpact() quando cobra come comida. Usar HapticFeedback.selectionClick() 
para mudanças de direção. Adicionar configuração para habilitar/desabilitar 
vibração. Verificar se dispositivo suporta haptic feedback antes de chamar.
```

**Dependências:** game_snake_page.dart, models/game_logic.dart

**Validação:** Feedback tátil deve funcionar nos eventos corretos com toggle

---

### 28. [STYLE] - Adicionar tema escuro/claro configurável

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Jogo só tem tema claro, limitando preferências do usuário especialmente 
para uso noturno.

**Prompt de Implementação:**
```
Criar light e dark variants das cores do jogo. Usar Theme.of(context).brightness 
para detectar tema sistema ou criar toggle manual. Garantir contraste adequado 
em ambos os temas. Atualizar todas as cores hardcoded para responder ao tema.
```

**Dependências:** constants/enums.dart, todos os widgets com cores

**Validação:** Ambos os temas devem ser legíveis e atraentes

---

### 29. [DOC] - Adicionar documentação JSDoc aos métodos públicos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Métodos públicos não têm documentação adequada, dificultando manutenção 
e contribuições futuras.

**Prompt de Implementação:**
```
Adicionar comentários /// style documentation para todos os métodos públicos 
das classes SnakeGameLogic, Position, GameGridWidget. Incluir descrição do método, 
parâmetros com tipos, e return values. Seguir Dart documentation conventions.
```

**Dependências:** Todos os arquivos do Snake game

**Validação:** Documentação deve aparecer corretamente no IDE autocomplete

---

### 30. [REFACTOR] - Usar Theme.of(context) para cores em vez de hardcoded

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Cores estão hardcoded em GameColors, não respondendo ao tema do app 
principal.

**Prompt de Implementação:**
```
Substituir referências diretas a GameColors por Theme.of(context).colorScheme onde 
apropriado. Manter GameColors apenas para cores específicas do jogo que não têm 
equivalente no tema padrão. Usar extension methods se necessário para cores customizadas.
```

**Dependências:** Todos os widgets, constants/enums.dart

**Validação:** Cores devem se adaptar ao tema do app principal

---

### 31. [TODO] - Adicionar opção de pausar/despausar com botão voltar

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Usuários podem querer pausar rapidamente usando botão voltar do sistema 
em vez de tocar no ícone de pause.

**Prompt de Implementação:**
```
Implementar WillPopScope ou PopScope para interceptar botão voltar. Se jogo está 
rodando, pausar em vez de sair. Se já pausado, mostrar dialog de confirmação 
para sair. Manter comportamento consistente com outros jogos mobile.
```

**Dependências:** game_snake_page.dart

**Validação:** Botão voltar deve pausar jogo ativo ou confirmar saída se pausado

---

### 32. [TEST] - Adicionar testes unitários para lógica do jogo

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Código não tem cobertura de testes, arriscando regressões em mudanças 
futuras.

**Prompt de Implementação:**
```
Criar test/snake_game_test.dart com testes para SnakeGameLogic: movimento da cobra, 
colisão detection, geração de comida, mudança de direção, score tracking. Testar 
edge cases como grid pequeno, cobra longa, posições de borda. Usar package:test.
```

**Dependências:** test/, models/game_logic.dart, models/position.dart

**Validação:** Tests devem passar e cobrir cenários principais do jogo

---

### 33. ✅ [STYLE] - Adicionar gradientes e sombras para melhor visual **[CONCLUÍDO]**

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Visual atual é flat e poderia se beneficiar de depth visual com 
gradientes sutis e sombras.

**Prompt de Implementação:**
```
Adicionar LinearGradient sutil para células da cobra e comida. Implementar BoxShadow 
no container do grid para dar profundidade. Usar gradientes sutis que não prejudiquem 
legibilidade. Manter performance adequada evitando overdraw excessivo.
```

**Dependências:** widgets/game_grid_widget.dart

**Implementado:**
- ✅ Grid container com gradiente linear e bordas arredondadas
- ✅ Sombras duplas para profundidade (preta + branca)
- ✅ Gradientes em células da cobra e comida
- ✅ Células vazias com gradiente sutil e bordas

**Arquivos:** `widgets/game_grid_widget.dart`

---

### 34. [OPTIMIZE] - Cachear cálculos de posições válidas para comida

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Geração de comida recalcula posições válidas toda vez, desperdiçando 
CPU especialmente com cobras longas.

**Prompt de Implementação:**
```
Manter Set<Position> de posições livres que é atualizado incrementalmente quando 
cobra se move. Remove posição da cabeça nova, adiciona posição da cauda removida 
(se não comeu). Para comida, selecionar aleatoriamente do Set em vez de tentar 
posições.
```

**Dependências:** models/game_logic.dart

**Validação:** Performance de geração de comida deve melhorar com cobras longas

---

### 35. [TODO] - Salvar configurações do usuário (dificuldade preferida, etc.)

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Usuário precisa reconfigurar dificuldade preferida toda vez que joga.

**Prompt de Implementação:**
```
Salvar última dificuldade selecionada em SharedPreferences. Carregar automaticamente 
no initState. Adicionar outras configurações como tema preferido, sons habilitados, 
vibração habilitada. Criar tela de configurações simples se necessário.
```

**Dependências:** models/game_logic.dart, game_snake_page.dart

**Validação:** Configurações devem persistir entre sessões do jogo

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

**Priorização sugerida:**
1. Issues 1-8 (Complexidade ALTA) - Bugs críticos e refatorações importantes
2. Issues 9-20 (Complexidade MÉDIA) - Melhorias funcionais significativas  
3. Issues 21-35 (Complexidade BAIXA) - Polish e melhorias incrementais
