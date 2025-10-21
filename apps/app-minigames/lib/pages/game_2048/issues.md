# Issues e Melhorias - game_2048_page.dart

## 📋 Índice Geral

### 🔴 Complexidade ALTA (6 issues)
1. ✅ [TODO] - Implementar detecção de animação de merge para tiles
2. ✅ [TODO] - Implementar sistema de undo/redo de movimentos
3. ✅ [TODO] - Implementar contagem de movimentos e duração do jogo
4. ✅ [REFACTOR] - Separar diálogos em widgets dedicados
5. [OPTIMIZE] - Implementar lazy loading para estatísticas e histórico
6. ✅ [TODO] - Adicionar sistema de pausa/resume do jogo
7. [SECURITY] - Validar e sanitizar dados do SharedPreferences

### 🟡 Complexidade MÉDIA (11 issues)  
8. ✅ [TODO] - Adicionar confirmação antes de perder progresso
9. [TODO] - Implementar diferentes modos de jogo e dificuldades
10. [FIXME] - Melhorar tratamento de erros e feedback visual
11. [TODO] - Adicionar suporte a múltiplos idiomas
12. [OPTIMIZE] - Otimizar performance da renderização do grid
13. ✅ [TODO] - Implementar autosave inteligente
14. [STYLE] - Melhorar acessibilidade e navegação por teclado
15. [TODO] - Adicionar tutorial interativo para novos usuários
16. [TODO] - Implementar conquistas e sistema de recompensas
17. [REFACTOR] - Melhorar arquitetura de eventos entre controller e view
18. [TODO] - Adicionar modo escuro e temas customizáveis

### 🟢 Complexidade BAIXA (12 issues)
19. [STYLE] - Melhorar feedback visual para swipes inválidos
20. [TODO] - Adicionar sons e efeitos sonoros
21. [OPTIMIZE] - Usar const constructors onde possível
22. [STYLE] - Melhorar animações de entrada e saída dos diálogos
23. [TODO] - Adicionar mais esquemas de cores
24. [FIXME] - Corrigir responsividade em telas muito pequenas
25. [DOC] - Adicionar documentação JSDoc aos métodos públicos
26. [STYLE] - Padronizar espaçamentos usando Design System
27. [TODO] - Adicionar indicador de progresso para operações assíncronas
28. [REFACTOR] - Extrair strings hardcoded para arquivo de constantes
29. [TEST] - Adicionar testes unitários para controller e models
30. [TODO] - Implementar compartilhamento de conquistas

---

## 🔴 Complexidade ALTA

### 1. ✅ [DONE] - Implementar detecção de animação de merge para tiles

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** O código possui um TODO comentado sobre implementar detecção de merge, 
mas atualmente isMerging sempre retorna false. Isso impede que animações de combinação 
de tiles funcionem corretamente, prejudicando a experiência visual.

**Implementação Realizada:**
- Adicionada lista `mergedTiles` no GameBoard para rastrear tiles que sofreram merge
- Modificado método `moveLeft()` para detectar e registrar merges durante movimento
- Implementado método `getAllTilePositions()` que retorna tiles com flags corretos de isMerging
- Atualizada a UI em `game_2048_page.dart` para usar detecção real ao invés de hardcoded false
- Adicionado sistema de limpeza de flags de animação com timer de 300ms
- Sincronizado timing de animação com MergeEffect widget existente (escala 1.0 → 1.2)
- Integrado com sistema de notificação de listeners no controller

**Dependências:** models/game_board.dart, models/tile.dart, widgets/tile_widget.dart, controllers/game_controller.dart

**Validação:** Tiles que se combinam agora mostram animação de merge visualmente distinta com escala animada

---

### 2. ✅ [DONE] - Implementar sistema de undo/redo de movimentos

**Status:** ✅ Concluído | **Execução:** Muito Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Controller possui método undoLastMove não implementado. Sistema de undo 
é feature essencial para melhorar experiência do usuário, especialmente para iniciantes 
ou movimentos acidentais.

**Implementação Realizada:**
- Criada classe `GameState` para representar snapshot completo do estado do jogo
- Implementado sistema de histórico com `stateHistory` e `redoHistory` stacks (limite: 10 estados)
- Adicionados métodos `undoLastMove()` e `redoLastMove()` no GameBoard com validação
- Implementado método `_saveCurrentState()` para capturar estado antes de cada movimento
- Criados getters `canUndo()`, `canRedo()`, `getUndoCount()`, `getRedoCount()` para UI
- Implementados métodos `undoLastMove()` e `redoLastMove()` no Game2048Controller
- Adicionados botões de Undo/Redo na UI com estados visuais (habilitado/desabilitado)
- Sistema limpa histórico de redo quando novo movimento é feito
- Integrado com feedback háptico (selectionClick) para ações de undo/redo
- Estado restaurado inclui: board, score, moveCount, hasWon, flags de jogo

**Dependências:** controllers/game_controller.dart, models/game_board.dart, widgets/game_controls_widget.dart

**Validação:** Undo/Redo restaura estado anterior exato incluindo score, posições e flags de jogo

---

### 3. ✅ [DONE] - Implementar contagem de movimentos e duração do jogo

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Controller possui TODOs sobre contagem de movimentos e duração, mas 
atualmente usa valores hardcoded (0 movimentos, 5 minutos). Estatísticas precisas 
são importantes para análise de performance.

**Implementação Realizada:**
- Adicionadas propriedades `moveCount`, `startTime` e `endTime` no GameBoard
- Implementado rastreamento automático de movimentos durante makeMove()
- Adicionado cálculo de duração baseado em timestamps reais
- Criada classe utilitária para formatação de duração
- Atualizada UI para exibir informações em tempo real
- Integrado com sistema de estatísticas e histórico

**Dependências:** models/game_board.dart, controllers/game_controller.dart, services/game_service.dart, utils/format_utils.dart

**Validação:** Movimentos e tempo são contados e exibidos corretamente na interface e salvos no histórico

---

### 4. ✅ [REFACTOR] - Separar diálogos em widgets dedicados

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Métodos _showWinDialog e _showGameOverDialog estão implementados 
diretamente na página principal, violando princípio de responsabilidade única e 
dificultando reutilização e testes.

**Prompt de Implementação:**
```
Criar pasta widgets/dialogs/ com GameWinDialog e GameOverDialog como StatelessWidget. 
Implementar callbacks para ações (novo jogo, continuar, sair). Adicionar parâmetros 
configuráveis para score, highScore. Mover lógica de apresentação para widgets específicos. 
Simplificar métodos na página principal.
```

**Dependências:** game_2048_page.dart, widgets/dialogs/ (novo diretório)

**Validação:** Diálogos devem manter funcionalidade idêntica mas serem reutilizáveis

---

### 5. [OPTIMIZE] - Implementar lazy loading para estatísticas e histórico

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Getter statistics do controller cria novo objeto GameStatistics a cada 
chamada, incluindo carregamento completo do histórico. Isso pode causar performance 
ruim com histórico extenso.

**Prompt de Implementação:**
```
Implementar cache de estatísticas no controller com invalidação inteligente. Carregar 
histórico apenas quando necessário. Adicionar paginação para histórico extenso. 
Implementar debounce para atualizações frequentes. Usar FutureBuilder para carregamento 
assíncrono na UI.
```

**Dependências:** controllers/game_controller.dart, services/game_service.dart

**Validação:** Performance deve melhorar significativamente com histórico de 50+ jogos

---

### 6. ✅ [TODO] - Adicionar sistema de pausa/resume do jogo

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Método togglePause() no controller não está implementado. Sistema de 
pausa é importante para jogos que podem durar vários minutos, especialmente em 
dispositivos móveis.

**Implementação Realizada:**
- Adicionadas propriedades `isPaused` e `pausedDuration` no GameBoard
- Implementados métodos `pauseGame()` e `resumeGame()` no GameBoard
- Implementado método `togglePause()` no controller com rastreamento de tempo de pausa
- Adicionado botão pausa/continuar no GameControlsWidget
- Criado overlay visual indicando jogo pausado na interface
- Desabilitado input durante pausa (teclado e gestos)
- Ajustado cálculo de duração do jogo para descontar tempo pausado

**Dependências:** controllers/game_controller.dart, models/game_board.dart, game_2048_page.dart, widgets/game_controls_widget.dart

**Validação:** Jogo pausa/despausa corretamente mantendo estado e tempo de jogo é calculado sem incluir pausas

---

### 7. [SECURITY] - Validar e sanitizar dados do SharedPreferences

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Médio

**Descrição:** GameService carrega dados do SharedPreferences sem validação adequada. 
Dados corrompidos ou modificados maliciosamente podem causar crashes ou comportamento 
inesperado.

**Prompt de Implementação:**
```
Implementar validação de schema para todos os dados salvos. Adicionar checksums 
para detectar modificações. Implementar fallback gracioso para dados corrompidos. 
Validar ranges de valores (scores, contadores). Adicionar logging de tentativas 
de tampering.
```

**Dependências:** services/game_service.dart

**Validação:** Dados inválidos devem ser rejeitados e resetados para valores padrão

---

## 🟡 Complexidade MÉDIA

### 8. ✅ [DONE] - Adicionar confirmação antes de perder progresso

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Controller possui TODO sobre mostrar dialog de confirmação ao mudar 
tamanho do tabuleiro, mas atualmente salva automaticamente. Usuário pode perder 
progresso inadvertidamente.

**Implementação Realizada:**
- Criado widget `ConfirmationDialog` com diferentes tipos de confirmação (novo jogo, mudança de tamanho, sair)
- Implementada exibição de progresso atual (pontuação, movimentos, tempo de jogo)
- Adicionada confirmação inteligente baseada em progresso significativo (moveCount > 0 ou score > 0)
- Implementada confirmação para ações destrutivas: novo jogo, mudança de tamanho do tabuleiro
- Adicionada confirmação para sair da página com progresso não salvo (PopScope)
- Criados métodos auxiliares `_hasSignificantProgress()` e `_getCurrentProgressInfo()`
- Integrado com sistema de salvamento automático antes de sair

**Dependências:** game_2048_page.dart, widgets/dialogs/confirmation_dialog.dart

**Validação:** Confirmação aparece apenas quando há progresso significativo e exibe detalhes do progresso atual

---

### 9. [TODO] - Implementar diferentes modos de jogo e dificuldades

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Jogo atualmente só tem modo clássico. Adicionar variações aumentaria 
significativamente a rejogabilidade e apelo para diferentes tipos de jogadores.

**Prompt de Implementação:**
```
Criar enum GameMode com variações: clássico, tempo limitado, sem novas peças após X 
movimentos, target personalizado (1024, 4096). Implementar no GameBoard e controller. 
Adicionar seleção de modo na UI. Adaptar sistema de estatísticas para diferentes modos.
```

**Dependências:** constants/enums.dart, models/game_board.dart, controllers/game_controller.dart

**Validação:** Cada modo deve ter mecânicas distintas e estatísticas separadas

---

### 10. [FIXME] - Melhorar tratamento de erros e feedback visual

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Erros são mostrados apenas em card simples na parte inferior. Alguns 
erros podem passar despercebidos e não há classificação por severidade ou ações 
sugeridas.

**Prompt de Implementação:**
```
Criar sistema de notificações com diferentes tipos (erro, aviso, sucesso). Implementar 
SnackBar para erros temporários e AlertDialog para erros críticos. Adicionar códigos 
de erro específicos e mensagens amigáveis. Incluir ações sugeridas quando aplicável.
```

**Dependências:** game_2048_page.dart, controllers/game_controller.dart

**Validação:** Diferentes tipos de erro devem ter apresentação e tratamento apropriados

---

### 11. [TODO] - Adicionar suporte a múltiplos idiomas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Todas as strings estão hardcoded em português. Suporte a i18n aumentaria 
significativamente o alcance do jogo para usuários internacionais.

**Prompt de Implementação:**
```
Implementar package flutter_localizations. Criar arquivo de strings para português 
e inglês. Extrair todas as strings hardcoded para arquivos .arb. Adaptar UI para 
diferentes comprimentos de texto. Considerar direção de texto RTL para futura expansão.
```

**Dependências:** pubspec.yaml, todos os arquivos com strings, l10n/ (novo diretório)

**Validação:** Interface deve funcionar corretamente em português e inglês

---

### 12. [OPTIMIZE] - Otimizar performance da renderização do grid

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** GridView.builder reconstrói todos os tiles a cada movimento, mesmo 
tiles que não mudaram. Em grids 6x6 isso pode impactar performance em dispositivos 
mais lentos.

**Prompt de Implementação:**
```
Implementar system de dirty tiles que rastreia quais posições mudaram. Usar 
RepaintBoundary para isolar tiles individuais. Implementar shouldRebuild inteligente 
baseado em mudanças reais. Considerar usar CustomScrollView com slivers para melhor 
performance.
```

**Dependências:** game_2048_page.dart, widgets/tile_widget.dart

**Validação:** Performance deve melhorar em grids grandes com profiler Flutter

---

### 13. ✅ [DONE] - Implementar autosave inteligente

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Jogo só salva ao finalizar ou explicitamente. Autosave inteligente 
previniria perda de progresso em crashes ou fechamento inesperado do app.

**Implementação Realizada:**
- Criado serviço `GameStatePersistenceService` para persistência inteligente do estado do jogo
- Implementada classe `GameStateData` para serialização completa do estado (board, score, movimentos, tempo, configurações)
- Sistema de **timer-based autosave** configurável (15s, 30s, 1min, 2min)
- Sistema de **movement-based autosave** (a cada 3, 5 ou 10 movimentos)
- **App lifecycle detection** com `WidgetsBindingObserver` para save automático ao pausar/sair do app
- **Session recovery system** com dialog de restauração ao abrir o app
- **Settings configuráveis** via `AutoSaveSettings` (ativar/desativar, frequências, comportamentos)
- Interface de usuário completa para configuração via `SettingsDialog`
- Integração com `GameController` para gerenciamento automático de autosave
- Sistema de limpeza automática de saves antigos (7+ dias)
- Validação e recovery gracioso de dados corrompidos

**Dependências:** controllers/game_controller.dart, services/game_state_persistence_service.dart, widgets/dialogs/settings_dialog.dart

**Validação:** Progresso é preservado em crashes, fechamento inesperado e oferece recuperação inteligente na abertura do app

---

### 14. [STYLE] - Melhorar acessibilidade e navegação por teclado

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Jogo suporta teclas direcionais mas não possui Semantics adequados 
para screen readers ou navegação completa por teclado nos controles.

**Prompt de Implementação:**
```
Adicionar Semantics widgets para descrever estado do jogo. Implementar navegação 
por Tab nos controles. Adicionar hints de teclado e tooltips. Suportar teclas 
adicionais (Space para novo jogo, Esc para pausa). Testar com TalkBack/VoiceOver.
```

**Dependências:** game_2048_page.dart, widgets/

**Validação:** Jogo deve ser completamente utilizável apenas com teclado e screen reader

---

### 15. [TODO] - Adicionar tutorial interativo para novos usuários

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Jogo só possui instruções estáticas. Tutorial interativo melhoraria 
significativamente a curva de aprendizado para usuários que nunca jogaram 2048.

**Prompt de Implementação:**
```
Criar sistema de overlay com dicas contextuais. Implementar tutorial passo-a-passo 
mostrando como fazer primeiro movimento, como combinar tiles, como atingir objetivo. 
Adicionar animações explicativas. Permitir pular ou replay do tutorial.
```

**Dependências:** game_2048_page.dart, widgets/tutorial/ (novo diretório)

**Validação:** Usuários novatos devem conseguir entender o jogo após tutorial

---

### 16. [TODO] - Implementar conquistas e sistema de recompensas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Jogo não possui sistema de conquistas, perdendo oportunidade de 
aumentar engajamento e motivação para continuar jogando.

**Prompt de Implementação:**
```
Criar enum para tipos de conquistas (primeira vitória, pontuações altas, sequências). 
Implementar tracking no controller. Criar UI para mostrar progresso e conquistas 
desbloqueadas. Adicionar notificações quando conquista for obtida. Considerar 
recompensas como novos temas.
```

**Dependências:** constants/enums.dart, controllers/game_controller.dart, services/game_service.dart

**Validação:** Conquistas devem ser desbloqueadas corretamente e persistir entre sessões

---

### 17. [REFACTOR] - Melhorar arquitetura de eventos entre controller e view

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Comunicação entre controller e view depende apenas de notifyListeners 
genérico. Eventos específicos permitiriam tratamento mais granular e performance 
melhor.

**Prompt de Implementação:**
```
Implementar sistema de eventos tipados (GameWon, GameOver, ScoreChanged, etc). 
Usar Stream ou EventBus para comunicação específica. Permitir que view se inscreva 
apenas em eventos relevantes. Reduzir rebuilds desnecessários da UI.
```

**Dependências:** controllers/game_controller.dart, game_2048_page.dart

**Validação:** UI deve reagir apenas a mudanças relevantes, melhorando performance

---

### 18. [TODO] - Adicionar modo escuro e temas customizáveis

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Interface só possui tema claro. Modo escuro é expectativa padrão em 
apps modernos e temas customizáveis aumentam personalização.

**Prompt de Implementação:**
```
Implementar detecção de tema do sistema. Criar esquemas de cores para modo escuro. 
Permitir override manual da preferência do usuário. Adicionar mais opções de 
personalização (gradientes, animações). Salvar preferências no settings.
```

**Dependências:** constants/game_config.dart, todos os widgets

**Validação:** Modo escuro deve ser visualmente consistente e acessível

---

## 🟢 Complexidade BAIXA

### 19. [STYLE] - Melhorar feedback visual para swipes inválidos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Quando usuário faz swipe que não resulta em movimento, não há feedback 
visual indicando que o gesto foi reconhecido mas é inválido.

**Prompt de Implementação:**
```
Adicionar animação sutil de "shake" ou mudança de cor temporária quando movimento 
inválido for tentado. Implementar usando AnimationController com vibração curta. 
Adicionar feedback háptico leve para indicar movimento inválido.
```

**Dependências:** game_2048_page.dart, widgets/game_gesture_detector.dart

**Validação:** Feedback deve ser claro mas não intrusivo para movimentos inválidos

---

### 20. [TODO] - Adicionar sons e efeitos sonoros

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Jogo é completamente silencioso, perdendo oportunidade de melhorar 
experiência com feedback auditivo adequado.

**Prompt de Implementação:**
```
Adicionar package audioplayers. Implementar sons para: movimento de tiles, merge 
de tiles, vitória, game over. Criar configuração para habilitar/desabilitar sons. 
Usar sons sutis que não se tornem irritantes com uso prolongado.
```

**Dependências:** pubspec.yaml, controllers/game_controller.dart, services/game_service.dart

**Validação:** Sons devem tocar nos eventos corretos com opção de desabilitar

---

### 21. [OPTIMIZE] - Usar const constructors onde possível

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Muitos widgets poderiam ser const para melhor performance, especialmente 
widgets estáticos e de layout.

**Prompt de Implementação:**
```
Identificar todos os widgets que podem ser const: Text, Icon, SizedBox, Padding, etc. 
Adicionar const keyword onde aplicável. Usar linter rules para detectar oportunidades. 
Verificar se não quebra funcionalidade de hot reload.
```

**Dependências:** Todos os arquivos de widgets

**Validação:** Performance deve melhorar ligeiramente sem mudança de comportamento

---

### 22. [STYLE] - Melhorar animações de entrada e saída dos diálogos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Diálogos usam animação padrão do AlertDialog. Animações customizadas 
dariam mais polimento e profissionalismo à interface.

**Prompt de Implementação:**
```
Implementar PageRouteBuilder personalizado para diálogos com animações de slide 
ou fade mais elaboradas. Adicionar animação de bounce sutil para conquistas. 
Sincronizar timing com outras animações do jogo para consistência visual.
```

**Dependências:** game_2048_page.dart, widgets/dialogs/

**Validação:** Animações devem ser suaves e contribuir para experiência premium

---

### 23. [TODO] - Adicionar mais esquemas de cores

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Apenas 4 esquemas de cores disponíveis. Mais opções aumentariam 
personalização e satisfação do usuário.

**Prompt de Implementação:**
```
Adicionar pelo menos 4 novos esquemas: vermelho, rosa, dourado, monocromático. 
Garantir contraste adequado para acessibilidade. Considerar esquemas temáticos 
(neon, pastel, terra). Organizar em categorias se necessário.
```

**Dependências:** constants/enums.dart, widgets/tile_widget.dart

**Validação:** Novos esquemas devem ser visualmente distintos e acessíveis

---

### 24. [FIXME] - Corrigir responsividade em telas muito pequenas

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Em telas muito pequenas (abaixo de 300px), layout pode ficar 
comprimido ou elementos podem transbordar.

**Prompt de Implementação:**
```
Ajustar constantes responsivas para telas extremamente pequenas. Implementar 
scroll vertical quando necessário. Reduzir tamanhos de fonte e padding 
proporcionalmente. Testar em diferentes tamanhos de tela e densidades.
```

**Dependências:** constants/game_config.dart, game_2048_page.dart

**Validação:** Jogo deve ser utilizável em telas de 320x568px ou menores

---

### 25. [DOC] - Adicionar documentação JSDoc aos métodos públicos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Métodos públicos não possuem documentação adequada, dificultando 
manutenção e contribuições futuras.

**Prompt de Implementação:**
```
Adicionar comentários /// style para todos os métodos públicos das classes principais. 
Incluir descrição, parâmetros, retorno e exemplos quando relevante. Seguir 
conventions do Dart para documentação. Gerar documentação com dart doc.
```

**Dependências:** Todos os arquivos principais

**Validação:** Documentação deve aparecer no IDE e ser gerada corretamente

---

### 26. [STYLE] - Padronizar espaçamentos usando Design System

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Espaçamentos estão definidos inline em vários lugares. Centralizar 
em design system melhoraria consistência visual.

**Prompt de Implementação:**
```
Criar classe DesignSystem com espaçamentos padronizados (4, 8, 16, 24, 32px). 
Substituir todos os EdgeInsets e SizedBox hardcoded. Definir typescale consistente. 
Padronizar border radius e elevations.
```

**Dependências:** constants/, todos os widgets

**Validação:** Visual deve permanecer consistente mas usando sistema centralizado

---

### 27. [TODO] - Adicionar indicador de progresso para operações assíncronas

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Operações como carregamento inicial e salvamento não possuem feedback 
visual adequado além do CircularProgressIndicator na AppBar.

**Prompt de Implementação:**
```
Adicionar LinearProgressIndicator para operações de duração conhecida. Implementar 
shimmer loading para carregamento de estatísticas. Mostrar percentage quando 
aplicável. Usar diferentes estilos para diferentes tipos de operação.
```

**Dependências:** game_2048_page.dart, controllers/game_controller.dart

**Validação:** Usuário deve ter feedback claro sobre operações em andamento

---

### 28. [REFACTOR] - Extrair strings hardcoded para arquivo de constantes

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Strings como "2048", "Parabéns!", "Game Over!" estão espalhadas 
pelo código. Centralizar facilitaria manutenção e i18n futuro.

**Prompt de Implementação:**
```
Criar classe GameStrings com todas as strings do jogo organizadas por categoria. 
Substituir strings hardcoded por referências às constantes. Preparar estrutura 
para futuro suporte a i18n.
```

**Dependências:** constants/, todos os arquivos com strings

**Validação:** Funcionalidade deve permanecer idêntica usando strings centralizadas

---

### 29. [TEST] - Adicionar testes unitários para controller e models

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Código não possui cobertura de testes, arriscando regressões em 
mudanças futuras especialmente na lógica complexa do controller.

**Prompt de Implementação:**
```
Criar testes para Game2048Controller (movimento, score, estados). Testar GameBoard 
com diferentes cenários (movimento válido/inválido, vitória, game over). Usar 
mockito para mockar GameService. Adicionar testes de integração básicos.
```

**Dependências:** test/, todos os models e controllers

**Validação:** Testes devem passar e cobrir cenários principais do jogo

---

### 30. [TODO] - Implementar compartilhamento de conquistas

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Usuários podem querer compartilhar scores altos ou conquistas em 
redes sociais para aumentar engajamento e atrair novos jogadores.

**Prompt de Implementação:**
```
Adicionar package share_plus. Implementar sharing de score final com imagem 
personalizada. Criar templates visuais para diferentes conquistas. Adicionar 
botões de share nos diálogos de vitória e game over. Incluir link do app se 
aplicável.
```

**Dependências:** pubspec.yaml, game_2048_page.dart, widgets/dialogs/

**Validação:** Compartilhamento deve funcionar nas principais plataformas sociais

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

**Priorização sugerida:**
1. Issues 1-7 (Complexidade ALTA) - TODOs críticos e melhorias arquiteturais
2. Issues 8-18 (Complexidade MÉDIA) - Features importantes e otimizações  
3. Issues 19-30 (Complexidade BAIXA) - Polish e melhorias incrementais
