# Issues e Melhorias - game_sudoku_page.dart

# Índice Geral - Issues e Melhorias Sudoku

## 🔴 Complexidade ALTA
1. **[REFACTOR]** Implementar Arquitetura MVC Completa - Separação de responsabilidades e estado
2. **[REFACTOR]** Separar Lógica de Geração de Puzzle - Classes especializadas para geração, resolução e validação

## 🟡 Complexidade MÉDIA  
3. **[OPTIMIZE]** Melhorar Performance de Verificação de Conflitos - Otimização incremental
4. **[TODO]** Implementar Sistema de Desfazer/Refazer Jogadas - Histórico de movimentos
5. **[TODO]** Adicionar Modos de Jogo e Temas Visuais - Múltiplos modos e personalização

## 🟢 Complexidade BAIXA
6. **[BUG]** Corrigir Reset de Anotações ao Mudar de Célula - Comportamento consistente
7. **[ACCESSIBILITY]** Melhorar Acessibilidade do Jogo - Suporte a leitores de tela e escalabilidade
8. **[OPTIMIZE]** Melhorar Gerenciamento de Recursos - Timers e SharedPreferences 
9. **[STYLE]** Melhorar a Estética e Feedback Visual - Animações e transições

### 🔧 Comandos Rápidos
- `Executar #[número]` - Implementar issue específica
- `Detalhar #[número]` - Prompt detalhado  
- `Focar [complexidade]` - Trabalhar por complexidade
- `Agrupar [tipo]` - Executar por tipo
- `Validar #[número]` - Revisar implementação

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Implementar Arquitetura MVC Completa para Gerenciamento de Estado

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O atual `GameSudokuPage` tem muita lógica de UI misturada com lógica de controle. A
classe `SudokuGameLogic` contém tanto a lógica de negócio quanto o estado do jogo. Implementar uma
arquitetura MVC completa separaria responsabilidades, facilitaria testes e melhoraria a
manutenibilidade.

**Prompt de Implementação:**
```
Refatore o sistema de gerenciamento de estado do jogo Sudoku implementando uma arquitetura MVC 
mais clara:

1. Crie uma pasta `controllers` com um arquivo `sudoku_controller.dart` que será responsável por:
   - Intermediar a comunicação entre o modelo e a view
   - Gerenciar callbacks e eventos de UI
   - Atualizar o estado e notificar a view

2. Mova a lógica de estado atual da classe SudokuGameLogic para este controller:
   - O controller deve ter um método para cada ação do usuário
   - Implemente notificações de mudança de estado usando ChangeNotifier ou ValueNotifier

3. Reorganize a classe SudokuGameLogic para ser um modelo puro:
   - Remova lógica de UI e timers
   - Mantenha apenas os algoritmos de jogo e validação
   
4. Atualize o GameSudokuPage para observar as mudanças de estado:
   - Use ValueListenable/Consumer ou outro padrão de observação
   - Remova a lógica de controle direta, delegando para o controller

Use o seguinte padrão para o controller:
```dart
class SudokuController extends ChangeNotifier {
  final SudokuGameLogic model = SudokuGameLogic();
  
  // Métodos públicos para ações do usuário
  void selectCell(int row, int col) {
    model.selectCell(row, col);
    notifyListeners();
  }
  
  // Outros métodos...
}
```

Atualize a UI para consumir o controller em vez de manipular o modelo diretamente.
```

**Dependências:** 
- `/lib/app-minigames/pages/game_sudoku/models/game_logic.dart`
- `/lib/app-minigames/pages/game_sudoku/game_sudoku_page.dart`
- Criar: `/lib/app-minigames/pages/game_sudoku/controllers/sudoku_controller.dart`

**Validação:** O código deve compilar e executar sem erros. A funcionalidade do jogo deve permanecer
intacta, mas com uma estrutura de código mais organizada e testável. Verificar se mudanças em um
componente não afetam outros indevidamente.

---

### 2. [REFACTOR] - Separar Lógica de Geração de Puzzle em Classes Especializadas

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** A geração do puzzle, validação e resolução estão todos na classe `SudokuGameLogic`.
Estas são responsabilidades distintas e poderiam ser separadas em classes especializadas, seguindo
o princípio de responsabilidade única.

**Prompt de Implementação:**
```
Refatore a lógica de geração de puzzles do Sudoku, separando-a em classes especializadas:

1. Crie uma pasta `services` com os seguintes arquivos:
   - `puzzle_generator.dart`: Responsável pela geração de novos puzzles
   - `puzzle_solver.dart`: Implementa algoritmos de resolução 
   - `puzzle_validator.dart`: Verifica a validade de jogadas e do tabuleiro

2. Mova os métodos relacionados de SudokuGameLogic para essas classes:
   - PuzzleGenerator: generateSolvedBoard(), _fillBox(), _removeRandomCells()
   - PuzzleSolver: _solveBoard(), isValidNumber()
   - PuzzleValidator: updateConflicts(), checkCompletion(), isValidNumber()

3. Crie uma classe SudokuBoard para representar o estado do tabuleiro:
   - Encapsule as matrizes board, solution, isEditable, hasConflict e notes
   - Implemente métodos para acessar e modificar o estado

4. Atualize SudokuGameLogic para usar essas classes:
   - Mantenha a API pública inalterada
   - Internamente, delegue as operações para as novas classes

Exemplo de uso:
```dart
class SudokuGameLogic {
  final SudokuBoard board = SudokuBoard();
  final PuzzleGenerator generator = PuzzleGenerator();
  final PuzzleSolver solver = PuzzleSolver();
  final PuzzleValidator validator = PuzzleValidator();
  
  void generatePuzzle() {
    // Gerar tabuleiro completo
    generator.generateSolvedBoard(board);
    
    // Salvar solução
    board.saveSolution();
    
    // Remover células
    generator.removeRandomCells(board, difficulty.cellsToRemove);
    
    isGameStarted = true;
  }
  
  // Outros métodos...
}
```

Certifique-se de manter a API pública inalterada para não quebrar o jogo existente.
```

**Dependências:** 
- `/lib/app-minigames/pages/game_sudoku/models/game_logic.dart`
- Criar: `/lib/app-minigames/pages/game_sudoku/services/puzzle_generator.dart`
- Criar: `/lib/app-minigames/pages/game_sudoku/services/puzzle_solver.dart`
- Criar: `/lib/app-minigames/pages/game_sudoku/services/puzzle_validator.dart`
- Criar: `/lib/app-minigames/pages/game_sudoku/models/sudoku_board.dart`

**Validação:** O jogo deve manter o mesmo comportamento após a refatoração. Os puzzles devem ser
gerados corretamente e a jogabilidade deve ser idêntica. Validar com testes unitários para cada
classe.

---

## 🟡 Complexidade MÉDIA

### 3. [OPTIMIZE] - Melhorar Performance de Verificação de Conflitos

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** O método `updateConflicts()` atual recria a matriz completa e verifica cada célula 
individualmente, o que é ineficiente, especialmente após cada jogada. Podemos otimizar verificando 
apenas as células afetadas pela última jogada.

**Prompt de Implementação:**
```
Otimize o método updateConflicts() na classe SudokuGameLogic para melhorar a performance:

1. Modifique o método para aceitar parâmetros opcionais de linha e coluna:
```dart
void updateConflicts([int? affectedRow, int? affectedCol]) {
  // Se ambos os parâmetros forem fornecidos, atualize apenas as células afetadas
  if (affectedRow != null && affectedCol != null) {
    _updateConflictsForCell(affectedRow, affectedCol);
    return;
  }
  
  // Caso contrário, atualize o tabuleiro inteiro (comportamento atual)
  hasConflict = List.generate(boardSize, (_) => List.filled(boardSize, false));
  
  for (int i = 0; i < boardSize; i++) {
    for (int j = 0; j < boardSize; j++) {
      if (board[i][j] != 0) {
        _updateConflictsForCell(i, j);
      }
    }
  }
}

// Método auxiliar para atualizar conflitos de uma célula específica
void _updateConflictsForCell(int row, int col) {
  if (board[row][col] == 0) return;
  
  int num = board[row][col];
  board[row][col] = 0;
  hasConflict[row][col] = !isValidNumber(row, col, num);
  board[row][col] = num;
  
  // Verifica conflitos na mesma linha, coluna e bloco 3x3
  _checkRowConflicts(row, num);
  _checkColConflicts(col, num);
  _checkBoxConflicts(row, col, num);
}

// Métodos auxiliares para verificar conflitos por região
void _checkRowConflicts(int row, int placedNum) {
  for (int j = 0; j < boardSize; j++) {
    if (board[row][j] == placedNum) {
      // Verifica se há mais de uma ocorrência deste número na linha
      int count = 0;
      for (int k = 0; k < boardSize; k++) {
        if (board[row][k] == placedNum) count++;
      }
      if (count > 1) {
        for (int k = 0; k < boardSize; k++) {
          if (board[row][k] == placedNum) {
            hasConflict[row][k] = true;
          }
        }
      }
      break;
    }
  }
}

// Implementar _checkColConflicts e _checkBoxConflicts de forma similar
```

2. Atualize as chamadas existentes para o método:
```dart
// Na função insertNumber()
board[selectedRow][selectedCol] = number;
updateConflicts(selectedRow, selectedCol);
```

3. Faça o mesmo para outros métodos que modificam o tabuleiro.
```

**Dependências:** 
- `/lib/app-minigames/pages/game_sudoku/models/game_logic.dart`

**Validação:** Execute o jogo e verifique se as verificações de conflito continuam funcionando 
corretamente. Não deve haver diferença visual, mas a interface deve responder mais rapidamente, 
especialmente em dispositivos mais lentos.

---

### 4. [TODO] - Implementar Sistema de Desfazer/Refazer Jogadas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Adicionar um sistema de desfazer e refazer jogadas melhoraria significativamente a 
experiência do usuário, permitindo experimentar diferentes estratégias sem penalidades.

**Prompt de Implementação:**
```
Implemente um sistema de desfazer/refazer jogadas no jogo de Sudoku:

1. Adicione as seguintes estruturas de dados em SudokuGameLogic:
```dart
// Para armazenar histórico de jogadas
List<GameMove> moveHistory = [];
int currentMoveIndex = -1;

// Classe para representar uma jogada
class GameMove {
  final int row;
  final int col;
  final int oldValue;
  final int newValue;
  final Set<int> oldNotes;
  
  GameMove({
    required this.row, 
    required this.col, 
    required this.oldValue, 
    required this.newValue,
    required this.oldNotes
  });
}
```

2. Modifique os métodos que alteram o tabuleiro para registrar as jogadas:
```dart
void insertNumber(int number) {
  if (selectedRow == -1 || selectedCol == -1 || !isEditable[selectedRow][selectedCol]) {
    return;
  }
  
  if (isNoteMode) {
    toggleNote(number);
  } else {
    // Registrar jogada atual
    final oldValue = board[selectedRow][selectedCol];
    final oldNotes = Set<int>.from(notes[selectedRow][selectedCol]);
    
    // Limpar anotações
    notes[selectedRow][selectedCol].clear();
    
    // Inserir número
    board[selectedRow][selectedCol] = number;
    
    // Registrar no histórico (removendo jogadas "futuras" se estiver desfazendo)
    if (currentMoveIndex < moveHistory.length - 1) {
      moveHistory = moveHistory.sublist(0, currentMoveIndex + 1);
    }
    
    moveHistory.add(GameMove(
      row: selectedRow, 
      col: selectedCol, 
      oldValue: oldValue, 
      newValue: number,
      oldNotes: oldNotes
    ));
    currentMoveIndex++;
    
    // Verificar conflitos e completude (como antes)
    updateConflicts(selectedRow, selectedCol);
    if (checkCompletion()) {
      endGame();
    }
  }
}
```

3. Adicione métodos para desfazer e refazer:
```dart
bool canUndo() => currentMoveIndex >= 0;
bool canRedo() => currentMoveIndex < moveHistory.length - 1;

void undo() {
  if (!canUndo()) return;
  
  final move = moveHistory[currentMoveIndex];
  board[move.row][move.col] = move.oldValue;
  notes[move.row][move.col] = Set<int>.from(move.oldNotes);
  
  currentMoveIndex--;
  updateConflicts();
}

void redo() {
  if (!canRedo()) return;
  
  currentMoveIndex++;
  final move = moveHistory[currentMoveIndex];
  
  board[move.row][move.col] = move.newValue;
  notes[move.row][move.col].clear();
  
  updateConflicts();
}
```

4. Adicione botões de desfazer/refazer na interface:
```dart
// Em game_sudoku_page.dart, adicione no AppBar:
actions: [
  IconButton(
    icon: const Icon(Icons.undo),
    onPressed: gameLogic.canUndo() ? () {
      setState(() {
        gameLogic.undo();
      });
    } : null,
  ),
  IconButton(
    icon: const Icon(Icons.redo),
    onPressed: gameLogic.canRedo() ? () {
      setState(() {
        gameLogic.redo();
      });
    } : null,
  ),
  // Botões existentes...
],
```

5. Limpe o histórico quando um novo jogo começar:
```dart
void initializeGame() {
  resetBoard();
  moveHistory = [];
  currentMoveIndex = -1;
  generatePuzzle();
  startTimer();
}
```
```

**Dependências:** 
- `/lib/app-minigames/pages/game_sudoku/models/game_logic.dart`
- `/lib/app-minigames/pages/game_sudoku/game_sudoku_page.dart`

**Validação:** Teste o jogo fazendo algumas jogadas e verificando se os botões de desfazer/refazer
funcionam corretamente. Os números e anotações devem ser restaurados corretamente ao desfazer/
refazer.

---

### 5. [TODO] - Adicionar Modos de Jogo e Temas Visuais

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Implementar diferentes modos de jogo (temporizador, desafio diário, personalizado)
e temas visuais (claro, escuro, colorido) para aumentar o engajamento e personalização.

**Prompt de Implementação:**
```
Implemente modos de jogo adicionais e temas visuais para o Sudoku:

1. Crie uma classe de temas em um novo arquivo `theme_provider.dart`:
```dart
import 'package:flutter/material.dart';

enum SudokuTheme { classic, dark, colorful }

class SudokuThemeProvider {
  static ThemeData getThemeData(SudokuTheme theme) {
    switch (theme) {
      case SudokuTheme.classic:
        return ThemeData(
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black87),
          ),
          // Outras configurações de tema
        );
      case SudokuTheme.dark:
        return ThemeData.dark().copyWith(
          primaryColor: Colors.blueGrey,
          // Outras configurações
        );
      case SudokuTheme.colorful:
        return ThemeData(
          primaryColor: Colors.purple,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.purple,
            accentColor: Colors.amber,
          ),
          // Outras configurações
        );
    }
  }
  
  static Color getCellBackgroundColor(SudokuTheme theme, bool isSelected, bool isEditable, bool hasConflict) {
    switch (theme) {
      case SudokuTheme.classic:
        if (hasConflict) return Colors.red.withAlpha(80);
        if (isSelected) return Colors.blue.withAlpha(80);
        return isEditable ? Colors.white : Colors.grey[200]!;
      case SudokuTheme.dark:
        if (hasConflict) return Colors.red.withAlpha(80);
        if (isSelected) return Colors.blueGrey.withAlpha(120);
        return isEditable ? Colors.grey[800]! : Colors.grey[900]!;
      case SudokuTheme.colorful:
        if (hasConflict) return Colors.red.withAlpha(80);
        if (isSelected) return Colors.purple.withAlpha(80);
        return isEditable ? Colors.white : Colors.purple[50]!;
    }
  }
  
  // Outros métodos de estilo
}
```

2. Adicione enum para modos de jogo em `constants/enums.dart`:
```dart
enum GameMode {
  classic(label: 'Clássico'),
  timed(label: 'Contra o Tempo'),
  challenge(label: 'Desafio Diário'),
  zen(label: 'Zen (Sem Timer)');
  
  final String label;
  const GameMode({required this.label});
}
```

3. Atualize `SudokuGameLogic` para suportar diferentes modos:
```dart
GameMode gameMode = GameMode.classic;
SudokuTheme currentTheme = SudokuTheme.classic;

// Modifique a inicialização do jogo
void initializeGame({GameMode? mode, SudokuTheme? theme}) {
  if (mode != null) gameMode = mode;
  if (theme != null) currentTheme = theme;
  
  resetBoard();
  generatePuzzle();
  
  // Ajustes específicos do modo
  if (gameMode == GameMode.timed) {
    // Configurar timer limitado
    elapsedSeconds = 300; // 5 minutos inicial
    startCountdownTimer();
  } else if (gameMode == GameMode.zen) {
    // Sem timer
  } else {
    // Timer padrão
    startTimer();
  }
}

// Método para timer regressivo
void startCountdownTimer() {
  _cancelTimerSafely();
  
  gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (isGameOver || isPaused) {
      timer.cancel();
      return;
    }
    
    if (elapsedSeconds > 0) {
      elapsedSeconds--;
    } else {
      // Tempo acabou
      endGame();
      // Adicionar lógica para game over por tempo
    }
  });
}
```

4. Atualize a UI para incluir seleção de tema e modo de jogo em `game_sudoku_page.dart`:
```dart
// Adicione um menu dropdown no AppBar ou em um drawer
PopupMenuButton<SudokuTheme>(
  icon: const Icon(Icons.palette),
  onSelected: (SudokuTheme theme) {
    setState(() {
      gameLogic.currentTheme = theme;
      // Você pode precisar reconstruir elementos de UI
    });
  },
  itemBuilder: (context) => SudokuTheme.values.map((theme) => 
    PopupMenuItem(
      value: theme,
      child: Text(theme.toString().split('.').last),
    )
  ).toList(),
),

// Adicione um menu para selecionar o modo de jogo
// Pode ser adicionado antes de iniciar um novo jogo
```

5. Atualize os widgets para usar o tema selecionado:
```dart
// Em SudokuCellWidget, atualize o método _getCellColor():
Color _getCellColor() {
  return SudokuThemeProvider.getCellBackgroundColor(
    gameLogic.currentTheme,
    isSelected,
    isEditable,
    hasConflict
  );
}
```
```

**Dependências:** 
- `/lib/app-minigames/pages/game_sudoku/models/game_logic.dart`
- `/lib/app-minigames/pages/game_sudoku/game_sudoku_page.dart`
- `/lib/app-minigames/pages/game_sudoku/constants/enums.dart`
- `/lib/app-minigames/pages/game_sudoku/widgets/sudoku_cell.dart`
- Criar: `/lib/app-minigames/pages/game_sudoku/theme/theme_provider.dart`

**Validação:** Teste o jogo em diferentes temas e modos para garantir que todas as funcionalidades
estejam corretas. Verifique se os estilos visuais são aplicados corretamente e se os modos de jogo
funcionam como esperado.

---

## 🟢 Complexidade BAIXA

### 6. [BUG] - Corrigir Reset de Anotações ao Mudar de Célula

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Conforme mencionado nos TODOs do código, há um bug em que as anotações podem não ser
corretamente resetadas ao mudar de célula em certos casos.

**Prompt de Implementação:**
```
Corrija o bug de reset de anotações no SudokuGameLogic:

1. Identifique o problema no método selectCell():
```dart
void selectCell(int row, int col) {
  if (isEditable[row][col]) {
    selectedRow = row;
    selectedCol = col;
  }
}
```

2. Atualize o método para garantir que o estado das anotações seja preservado corretamente:
```dart
void selectCell(int row, int col) {
  // Guarde a seleção anterior
  final int previousRow = selectedRow;
  final int previousCol = selectedCol;
  
  if (isEditable[row][col]) {
    // Se a célula selecionada for diferente, atualize a seleção
    if (selectedRow != row || selectedCol != col) {
      selectedRow = row;
      selectedCol = col;
      
      // Verifica se havia uma célula selecionada anteriormente
      if (previousRow >= 0 && previousCol >= 0) {
        // Se a célula anterior tinha um número colocado, mas ainda tinha anotações,
        // limpe as anotações para evitar estados inconsistentes
        if (board[previousRow][previousCol] != 0 && notes[previousRow][previousCol].isNotEmpty) {
          notes[previousRow][previousCol].clear();
        }
      }
    }
  }
}
```

3. Atualize também o método insertNumber() para garantir comportamento consistente:
```dart
void insertNumber(int number) {
  if (selectedRow == -1 || selectedCol == -1 || !isEditable[selectedRow][selectedCol]) {
    return;
  }

  if (isNoteMode) {
    toggleNote(number);
  } else {
    // Se já existir um número e não for o mesmo, limpe as anotações
    if (board[selectedRow][selectedCol] != 0 && board[selectedRow][selectedCol] != number) {
      notes[selectedRow][selectedCol].clear();
    }
    
    // Inserir número (limpa anotações se for diferente de 0)
    if (number != 0) {
      notes[selectedRow][selectedCol].clear();
    }
    board[selectedRow][selectedCol] = number;

    // Verificar conflitos e completude (como antes)
    updateConflicts();
    if (checkCompletion()) {
      endGame();
    }
  }
}
```
```

**Dependências:** 
- `/lib/app-minigames/pages/game_sudoku/models/game_logic.dart`

**Validação:** Teste o jogo criando anotações em uma célula, depois mudando para outra célula e 
verificando se as anotações permanecem. Em seguida, coloque um número em uma célula com anotações e
verifique se as anotações são corretamente limpas.

---

### 7. [ACCESSIBILITY] - Melhorar Acessibilidade do Jogo

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** O jogo atual carece de recursos de acessibilidade como suporte a leitor de tela,
modos de alto contraste e opções de redimensionamento.

**Prompt de Implementação:**
```
Melhore a acessibilidade do jogo Sudoku com as seguintes alterações:

1. Adicione semantics aos widgets principais em `sudoku_cell.dart`:
```dart
@override
Widget build(BuildContext context) {
  return Semantics(
    label: value != 0 
      ? 'Célula com número $value'
      : 'Célula vazia',
    enabled: isEditable,
    selected: isSelected,
    onTap: onTap,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        // Implementação existente...
      ),
    ),
  );
}
```

2. Adicione opções de tamanho de fonte e elementos de UI em `game_info_widget.dart`:
```dart
class GameInfoWidget extends StatelessWidget {
  // Propriedades existentes...
  final double uiScale;
  
  // Construtor atualizado
  const GameInfoWidget({
    super.key,
    required this.gameLogic,
    required this.onDifficultyChanged,
    this.uiScale = 1.0,
  });
  
  // Atualize os métodos build para usar o scale
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0 * uiScale),
      child: Row(
        // Implementação existente...
      ),
    );
  }
  
  // Atualize os estilos de texto
  Widget _buildTimer() {
    return Text(
      gameLogic.getFormattedTime(),
      style: TextStyle(
        fontSize: 18 * uiScale,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  // Similarmente para outros widgets
}
```

3. Adicione um controle de escala na UI principal em `game_sudoku_page.dart`:
```dart
class _GameSudokuPageState extends State<GameSudokuPage> {
  late SudokuGameLogic gameLogic;
  double uiScale = 1.0; // Valor padrão
  
  // Métodos existentes...
  
  void _changeUIScale(double newScale) {
    setState(() {
      uiScale = newScale;
    });
  }
  
  // Adicione um slider no menu ou drawer:
  Widget _buildAccessibilityControls() {
    return ExpansionTile(
      title: const Text('Acessibilidade'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Text('Tamanho da UI:'),
              Expanded(
                child: Slider(
                  value: uiScale,
                  min: 0.8,
                  max: 1.5,
                  divisions: 7,
                  label: '${(uiScale * 100).round()}%',
                  onChanged: _changeUIScale,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Atualize o build para usar o scale
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Adicione um drawer ou menu com as opções de acessibilidade
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Configurações'),
            ),
            _buildAccessibilityControls(),
            // Outras opções...
          ],
        ),
      ),
      // No corpo principal, passe o scale para os widgets
      body: Column(
        children: [
          GameInfoWidget(
            gameLogic: gameLogic,
            onDifficultyChanged: _updateDifficulty,
            uiScale: uiScale,
          ),
          // Atualize os outros widgets similarmente
        ],
      ),
    );
  }
}
```

4. Adicione descrições TalkBack/VoiceOver em `number_pad_widget.dart`:
```dart
InkWell(
  onTap: () => onNumberSelected(number),
  child: Semantics(
    label: 'Botão número $number',
    hint: isNoteMode 
      ? 'Toque para adicionar ou remover anotação $number'
      : 'Toque para inserir número $number',
    button: true,
    enabled: true,
    child: Container(
      // Implementação existente...
    ),
  ),
),
```

5. Adicione uma opção de modo de alto contraste em ThemeProvider:
```dart
// Em theme_provider.dart
enum AccessibilityMode { standard, highContrast }

// Métodos adicionais para suportar alto contraste
static Color getCellBackgroundColorWithAccessibility(
    SudokuTheme theme, 
    AccessibilityMode accessMode,
    bool isSelected, 
    bool isEditable, 
    bool hasConflict) {
  
  if (accessMode == AccessibilityMode.highContrast) {
    if (hasConflict) return Colors.red;
    if (isSelected) return Colors.yellow;
    return isEditable ? Colors.white : Colors.black;
  } else {
    return getCellBackgroundColor(theme, isSelected, isEditable, hasConflict);
  }
}
```
```

**Dependências:** 
- `/lib/app-minigames/pages/game_sudoku/widgets/sudoku_cell.dart`
- `/lib/app-minigames/pages/game_sudoku/widgets/number_pad_widget.dart`
- `/lib/app-minigames/pages/game_sudoku/widgets/game_info_widget.dart`
- `/lib/app-minigames/pages/game_sudoku/game_sudoku_page.dart`
- Criar: `/lib/app-minigames/pages/game_sudoku/theme/theme_provider.dart` (se ainda não existir)

**Validação:** Teste o jogo com diferentes configurações de acessibilidade. Verifique se o
redimensionamento da UI funciona corretamente. Teste com um leitor de tela para verificar se as
descrições estão claras e úteis.

---

### 8. [OPTIMIZE] - Melhorar Gerenciamento de Recursos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Há melhorias a serem feitas no gerenciamento de recursos, particularmente na
manipulação de timers e acesso ao SharedPreferences, que atualmente é feito de forma síncrona.

**Prompt de Implementação:**
```
Melhore o gerenciamento de recursos na classe SudokuGameLogic:

1. Otimize o acesso ao SharedPreferences com gerenciamento de concorrência:
```dart
// Propriedades adicionais
bool _isLoadingSaveData = false;
bool _isSavingData = false;

// Método melhorado para carregar high score
Future<int> loadHighScore() async {
  if (_isLoadingSaveData) {
    // Evita chamadas concorrentes
    return 0; // Valor temporário
  }
  
  _isLoadingSaveData = true;
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('sudoku_high_score') ?? 0;
  } catch (e) {
    debugPrint('Erro ao carregar high score: $e');
    return 0;
  } finally {
    _isLoadingSaveData = false;
  }
}

// Método melhorado para salvar high score
Future<void> saveHighScore() async {
  if (_isSavingData) {
    return; // Evita chamadas concorrentes
  }
  
  _isSavingData = true;
  try {
    final prefs = await SharedPreferences.getInstance();
    final highScore = await loadHighScore();

    if (score > highScore) {
      await prefs.setInt('sudoku_high_score', score);
    }
  } catch (e) {
    debugPrint('Erro ao salvar high score: $e');
  } finally {
    _isSavingData = false;
  }
}
```

2. Melhore o gerenciamento de timers:
```dart
// Adicione um método para desativar todos os timers
void _cleanupTimers() {
  _cancelTimerSafely();
}

// Atualize o método dispose
@override
void dispose() {
  _cleanupTimers();
}

// Atualize initializeGame para garantir que timers antigos sejam cancelados
void initializeGame() {
  _cleanupTimers();
  resetBoard();
  generatePuzzle();
  startTimer();
}
```

3. Adicione monitoramento de uso de memória para elementos grandes:
```dart
// Adicione este método para depuração
void logMemoryUsage() {
  final boardSize = this.board.length * this.board[0].length * 4; // 4 bytes por int
  final solutionSize = this.solution.length * this.solution[0].length * 4;
  final notesSize = this.notes.length * this.notes[0].length * 8; // Estimativa para Set
  
  debugPrint('Uso de memória estimado:');
  debugPrint('- Tabuleiro: $boardSize bytes');
  debugPrint('- Solução: $solutionSize bytes');
  debugPrint('- Anotações: $notesSize bytes');
  debugPrint('- Total: ${boardSize + solutionSize + notesSize} bytes');
}
```

4. Melhore o gerenciamento da solução do tabuleiro para reduzir uso de memória:
```dart
// Versão atual (mantém a solução completa em memória)
solution = List.generate(boardSize, (i) => List.from(board[i]));

// Versão melhorada (opcionalmente compacta a solução ou guarda apenas células-chave)
List<List<int>> _compactSolution() {
  // Opção 1: Manter a solução como está para simplicidade
  return List.generate(boardSize, (i) => List.from(board[i]));
  
  // Opção 2 (mais avançada): Compactar usando run-length encoding ou outra técnica
  // Implementar se a memória for uma preocupação real
}
```
```

**Dependências:** 
- `/lib/app-minigames/pages/game_sudoku/models/game_logic.dart`

**Validação:** Execute o jogo e verifique se todas as funcionalidades continuam funcionando
corretamente. Verifique os logs para garantir que não há erros relacionados ao SharedPreferences
ou timers. Use ferramentas de profiling para verificar o uso de memória.

---

### 9. [STYLE] - Melhorar a Estética e Feedback Visual do Jogo

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** A interface atual do jogo é funcional, mas pode ser melhorada com animações,
transições e feedback visual para proporcionar uma experiência mais agradável e intuitiva.

**Prompt de Implementação:**
```
Melhore a estética e o feedback visual do jogo Sudoku:

1. Adicione animações para seleção de células em `sudoku_cell.dart`:
```dart
@override
Widget build(BuildContext context) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    decoration: BoxDecoration(
      color: _getCellColor(),
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
    ),
    child: Stack(
      // Conteúdo existente...
    ),
  );
}
```

2. Adicione efeito de destaque para números iguais ao selecionado:
```dart
// Adicione esta propriedade em SudokuCellWidget
final bool isHighlighted;

// No construtor:
const SudokuCellWidget({
  // Outros parâmetros...
  this.isHighlighted = false,
});

// Atualize o método _getCellColor():
Color _getCellColor() {
  if (hasConflict) {
    return Colors.red.withValues(alpha: 0.3);
  } else if (isSelected) {
    return Colors.blue.withValues(alpha: 0.3);
  } else if (isHighlighted) {
    return Colors.blue.withValues(alpha: 0.1);
  } else if (isEditable) {
    return Colors.white;
  } else {
    return Colors.grey[200]!;
  }
}

// Em SudokuBoardWidget, atualize a criação de células:
SudokuCellWidget(
  value: gameLogic.board[row][col],
  isSelected: row == gameLogic.selectedRow && col == gameLogic.selectedCol,
  isEditable: gameLogic.isEditable[row][col],
  hasConflict: gameLogic.hasConflict[row][col],
  notes: gameLogic.notes[row][col],
  onTap: () => onCellTap(row, col),
  borderColor: _getBorderColor(row, col),
  borderWidth: _getBorderWidth(row, col),
  isHighlighted: gameLogic.board[row][col] != 0 && 
                 gameLogic.selectedRow >= 0 && 
                 gameLogic.selectedCol >= 0 && 
                 gameLogic.board[row][col] == gameLogic.board[gameLogic.selectedRow][gameLogic.selectedCol],
),
```

3. Adicione efeitos de transição entre estados de jogo:
```dart
// Em game_sudoku_page.dart, use AnimatedSwitcher para transições
@override
Widget build(BuildContext context) {
  return Scaffold(
    // AppBar existente...
    body: AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: gameLogic.isPaused
        ? const Center(
            key: ValueKey('paused'),
            child: Text('JOGO PAUSADO', style: TextStyle(fontSize: 24)),
          )
        : Column(
            key: const ValueKey('playing'),
            children: [
              // Conteúdo existente...
            ],
          ),
    ),
  );
}
```

4. Adicione efeito de celebração na vitória:
```dart
// Em game_sudoku_page.dart, método _showVictoryDialog
void _showVictoryDialog() {
  // Opcional: Adicionar confetes ou outro efeito visual antes do diálogo
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('Parabéns!', 
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 48, color: Colors.amber),
            const Text('Você completou o puzzle!',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text('Tempo: ${gameLogic.getFormattedTime()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Pontuação: ${gameLogic.score}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        // Ações existentes...
      );
    },
  );
}
```

5. Melhore o feedback táctil ao pressionar células e botões:
```dart
// Em number_pad_widget.dart
InkWell(
  onTap: () {
    // Opcional: Adicionar HapticFeedback.lightImpact(); para feedback tátil
    onNumberSelected(number);
  },
  splashColor: Colors.blue.withValues(alpha: 0.3),
  highlightColor: Colors.blue.withValues(alpha: 0.1),
  child: Container(
    // Conteúdo existente...
  ),
),
```
```

**Dependências:** 
- `/lib/app-minigames/pages/game_sudoku/widgets/sudoku_cell.dart`
- `/lib/app-minigames/pages/game_sudoku/widgets/sudoku_board_widget.dart`
- `/lib/app-minigames/pages/game_sudoku/game_sudoku_page.dart`
- `/lib/app-minigames/pages/game_sudoku/widgets/number_pad_widget.dart`

**Validação:** Execute o jogo e verifique se as animações e transições funcionam corretamente. A
interface deve parecer mais dinâmica e responsiva, com feedback visual claro para as ações do
usuário.

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída
