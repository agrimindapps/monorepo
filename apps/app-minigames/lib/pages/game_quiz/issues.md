# Issues e Melhorias - game_quiz_page.dart

## 📋 Índice Geral

### 🔴 Complexidade ALTA (2 issues)
1. [REFACTOR] - Implementar gerenciamento de estado mais robusto
2. [TODO] - Adicionar sistema de ranking e persistência de pontuações

### 🟡 Complexidade MÉDIA (5 issues)  
3. [REFACTOR] - Extrair lógica de negócios para service/controller
4. [TODO] - Implementar sistema de dificuldade progressiva
5. [OPTIMIZE] - Melhorar carregamento e gestão de questões
6. [TODO] - Adicionar animações e feedback visual
7. [TODO] - Implementar modo de jogo com categorias

### 🟢 Complexidade BAIXA (5 issues)
8. [STYLE] - Melhorar responsividade da interface
9. [FIXME] - Corrigir problema de verificação de resposta
10. [REFACTOR] - Implementar constantes para valores fixos
11. [DOC] - Adicionar documentação e comentários ao código
12. [TODO] - Adicionar opção de ajuda e dicas durante o quiz

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Implementar gerenciamento de estado mais robusto

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O atual gerenciamento de estado usando StatefulWidget e setState pode se 
tornar difícil de manter conforme o jogo cresce em complexidade. Implementar um sistema
de gerenciamento de estado mais robusto como Provider, Bloc, Riverpod ou GetX facilitaria
o desenvolvimento futuro e a manutenção do código.

**Prompt de Implementação:**
```
Analise o arquivo game_quiz_page.dart e seus componentes. Refatore o código para 
implementar um sistema de gerenciamento de estado usando Provider. Crie um QuizProvider 
que encapsule toda a lógica atual do QuizModel, separando a lógica de negócios da 
interface. Atualize todos os widgets para consumir o estado do Provider ao invés de 
depender diretamente do estado do StatefulWidget. Mantenha todas as funcionalidades 
existentes, garantindo que o jogo continua funcionando como antes.
```

**Dependências:** 
- game_quiz_page.dart
- models/quiz_model.dart
- Novo arquivo: providers/quiz_provider.dart

**Validação:** Todas as funcionalidades do jogo devem continuar funcionando como antes, 
com a diferença que o estado agora é gerenciado pelo Provider ao invés de setState.

---

### 2. [TODO] - Adicionar sistema de ranking e persistência de pontuações

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Atualmente o jogo não salva as pontuações entre sessões. Implementar um 
sistema de ranking que persista as pontuações usando um banco de dados local (SharedPreferences 
ou Hive) ou remoto aumentaria o engajamento dos usuários e adicionaria um elemento 
competitivo ao jogo.

**Prompt de Implementação:**
```
Implemente um sistema de ranking e persistência de pontuações para o quiz. Crie uma 
classe ScoreService que gerencia o armazenamento e recuperação de pontuações usando 
SharedPreferences. Adicione uma tela de ranking acessível a partir da tela de game over, 
mostrando as melhores pontuações. Atualize a lógica de game over para salvar a pontuação 
atual no ranking se ela for alta o suficiente. A implementação deve permitir visualizar 
o histórico de pontuações e uma classificação dos melhores resultados.
```

**Dependências:** 
- game_quiz_page.dart
- Novos arquivos: 
  - services/score_service.dart
  - pages/ranking_page.dart
  - models/score_model.dart

**Validação:** Ao finalizar um jogo, a pontuação deve ser salva e persistida entre sessões 
do aplicativo. O usuário deve conseguir visualizar um ranking com as melhores pontuações.

---

## 🟡 Complexidade MÉDIA

### 3. [REFACTOR] - Extrair lógica de negócios para service/controller

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** A lógica de negócios está espalhada entre o QuizModel e o QuizPageState. 
Seguindo os princípios de Clean Architecture, seria melhor extrair essa lógica para um 
service/controller dedicado, deixando a view (QuizPage) responsável apenas pela exibição.

**Prompt de Implementação:**
```
Refatore o código atual extraindo a lógica de negócios da classe QuizPageState para uma 
nova classe QuizController. Esta classe deve encapsular as funcionalidades como 
inicialização do jogo, processamento de feedback, exibição de diálogos e gerenciamento 
do estado do jogo. O QuizPageState deve apenas delegar ações para o controller e 
refletir o estado atual na interface. Mantenha a compatibilidade com o QuizModel 
existente, mas prepare a estrutura para futuras melhorias.
```

**Dependências:** 
- game_quiz_page.dart
- models/quiz_model.dart
- Novo arquivo: controllers/quiz_controller.dart

**Validação:** A funcionalidade do jogo deve permanecer inalterada, mas com uma separação 
clara entre a lógica de negócios (controller) e a interface (QuizPage).

---

### 4. [TODO] - Implementar sistema de dificuldade progressiva

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Atualmente o jogo tem apenas um nível de dificuldade. Implementar um sistema 
de dificuldade progressiva tornaria o jogo mais desafiador e envolvente para os usuários, 
aumentando gradualmente a dificuldade conforme o jogador progride.

**Prompt de Implementação:**
```
Implemente um sistema de dificuldade progressiva no quiz. Modifique o QuizModel para 
suportar diferentes níveis de dificuldade nas questões (fácil, médio, difícil). 
Atualize o método loadQuestions para carregar questões com dificuldade variada. 
Implemente uma lógica que aumente progressivamente a dificuldade conforme o jogador 
acerta mais questões consecutivamente. Adicione indicadores visuais da dificuldade 
atual e ajuste o tempo disponível e pontuação com base na dificuldade.
```

**Dependências:** 
- models/quiz_model.dart
- game_quiz_page.dart
- constants/enums.dart (adicionar enum para níveis de dificuldade)

**Validação:** O jogo deve começar com questões fáceis e aumentar gradualmente a 
dificuldade. O tempo para responder deve ser ajustado conforme a dificuldade, e a 
pontuação recebida por respostas corretas deve refletir o nível de dificuldade.

---

### 5. [OPTIMIZE] - Melhorar carregamento e gestão de questões

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Atualmente as questões são definidas diretamente no código como uma string JSON. 
Isso limita a escalabilidade e dificulta a manutenção. A otimização deve focar em carregar 
questões de um arquivo JSON externo ou banco de dados, permitindo atualizações sem alterar 
o código.

**Prompt de Implementação:**
```
Refatore o sistema de carregamento de questões para usar um arquivo JSON externo ou um 
serviço de dados. Crie um QuizDataService que será responsável por carregar e fornecer 
as questões para o QuizModel. Implemente um método para carregar questões a partir de um 
arquivo JSON na pasta assets, permitindo fácil atualização das questões sem modificar o 
código. O serviço deve suportar filtragem de questões por categoria e dificuldade.
```

**Dependências:** 
- models/quiz_model.dart
- Novo arquivo: services/quiz_data_service.dart
- Novo arquivo: assets/data/quiz_questions.json

**Validação:** O jogo deve carregar questões a partir do arquivo JSON externo em vez de 
usar a string JSON embutida no código. Deve ser possível adicionar novas questões apenas 
editando o arquivo JSON sem modificar o código fonte.

---

### 6. [TODO] - Adicionar animações e feedback visual

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O jogo atual carece de animações e feedback visual que tornariam a experiência 
mais envolvente. Adicionar animações para transições entre questões, feedback para respostas 
corretas/incorretas e efeitos visuais melhoraria significativamente a experiência do usuário.

**Prompt de Implementação:**
```
Adicione animações e feedback visual ao quiz para melhorar a experiência do usuário. 
Implemente transições animadas entre questões usando AnimatedSwitcher. Adicione animações 
de comemoração para respostas corretas e feedback visual para respostas incorretas. 
Implemente uma animação para o cronômetro que mude de cor conforme o tempo diminui. 
Adicione efeitos de partículas ou confetes quando o jogador completar o quiz com sucesso.
```

**Dependências:** 
- game_quiz_page.dart
- widgets/question_card.dart
- widgets/options_grid.dart
- widgets/status_card.dart

**Validação:** A interface do jogo deve apresentar animações fluidas durante a transição 
entre questões e feedback visual claro para ações do usuário como acertos e erros.

---

### 7. [TODO] - Implementar modo de jogo com categorias

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Atualmente o jogo oferece apenas um conjunto geral de questões. Implementar 
categorias (como Tecnologia, Ciência, Esportes, etc.) permitiria uma experiência mais 
personalizada e aumentaria a rejogabilidade.

**Prompt de Implementação:**
```
Implemente um sistema de categorias para o quiz. Modifique o QuizModel e o carregamento 
de questões para suportar diferentes categorias. Crie uma tela de seleção de categoria 
antes de iniciar o jogo, permitindo que o usuário escolha em qual categoria deseja jogar. 
Adicione metadados às questões para indicar a qual categoria pertencem e atualize a 
interface para mostrar visualmente a categoria atual durante o jogo.
```

**Dependências:** 
- models/quiz_model.dart
- game_quiz_page.dart
- Novo arquivo: pages/category_selection_page.dart
- constants/enums.dart (adicionar enum para categorias)

**Validação:** O usuário deve poder selecionar uma categoria específica antes de iniciar 
o jogo, e apenas questões dessa categoria devem ser exibidas durante a partida.

---

## 🟢 Complexidade BAIXA

### 8. [STYLE] - Melhorar responsividade da interface

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** A interface atual tem largura fixa (1020) e não se adapta bem a diferentes 
tamanhos de tela. Melhorar a responsividade garantiria uma experiência consistente em 
dispositivos de diferentes tamanhos.

**Prompt de Implementação:**
```
Melhore a responsividade da interface do quiz. Substitua o SizedBox de largura fixa por 
um layout que se adapte automaticamente ao tamanho da tela. Use LayoutBuilder para 
ajustar o tamanho dos elementos baseado no espaço disponível. Implemente diferentes 
layouts para orientação retrato e paisagem. Ajuste o tamanho dos textos e botões para 
garantir legibilidade em qualquer tamanho de tela.
```

**Dependências:** 
- game_quiz_page.dart
- widgets/options_grid.dart
- widgets/question_card.dart
- widgets/status_card.dart

**Validação:** A interface do jogo deve se adaptar corretamente a diferentes tamanhos de 
tela, desde smartphones pequenos até tablets, mantendo a usabilidade e legibilidade.

---

### 9. [FIXME] - Corrigir problema de verificação de resposta

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O método processAnswer em QuizModel compara o selectedAnswer com a propriedade 
'termo' da questão, mas a interface mostra o botão com base na propriedade 'options'. Isso 
pode causar inconsistências na verificação de respostas.

**Prompt de Implementação:**
```
Corrija o problema de verificação de respostas no quiz. Analise o método processAnswer 
no QuizModel e a forma como as opções são apresentadas na interface. Garanta que a 
comparação entre a resposta selecionada e a resposta correta seja consistente. 
Adicione uma propriedade 'correctAnswer' explícita nas questões ou modifique a lógica 
para garantir que a verificação funcione corretamente em todos os casos.
```

**Dependências:** 
- models/quiz_model.dart
- game_quiz_page.dart
- widgets/options_grid.dart

**Validação:** O jogo deve corretamente identificar quando uma resposta está certa ou 
errada, sem inconsistências entre o que é mostrado na interface e o que é verificado 
no modelo.

---

### 10. [REFACTOR] - Implementar constantes para valores fixos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O código contém diversos valores fixos (hardcoded) como cores, durações, 
tamanhos de fonte e números (3 vidas, 20 segundos). Estes deveriam ser extraídos para 
constantes para facilitar manutenção e consistência.

**Prompt de Implementação:**
```
Refatore o código para extrair todos os valores fixos para constantes. Crie um arquivo 
de constantes para armazenar valores como cores, durações, tamanhos de fonte e valores 
numéricos do jogo (número de vidas, tempo para responder, etc). Substitua todos os 
valores hardcoded por referências a estas constantes em todo o código do quiz.
```

**Dependências:** 
- game_quiz_page.dart
- models/quiz_model.dart
- Novo arquivo: constants/quiz_constants.dart

**Validação:** Todos os valores fixos devem ser referenciados a partir do arquivo de 
constantes, facilitando modificações futuras e mantendo consistência visual e funcional.

---

### 11. [DOC] - Adicionar documentação e comentários ao código

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O código atual tem poucos comentários explicativos. Adicionar documentação 
adequada facilitaria a manutenção e o entendimento do código por novos desenvolvedores.

**Prompt de Implementação:**
```
Adicione documentação e comentários ao código do quiz. Para cada classe, adicione uma 
descrição geral do seu propósito. Para métodos importantes, adicione comentários 
explicando sua funcionalidade, parâmetros e valores de retorno. Use o formato de 
documentação padrão do Dart com /// para que a documentação seja reconhecida por 
ferramentas como o dartdoc. Priorize explicar a lógica de negócios complexa e decisões 
de design importantes.
```

**Dependências:** 
- game_quiz_page.dart
- models/quiz_model.dart
- widgets/options_grid.dart
- widgets/question_card.dart
- widgets/status_card.dart
- constants/enums.dart

**Validação:** O código deve estar bem documentado, com comentários explicativos para 
classes e métodos importantes, facilitando o entendimento e manutenção por qualquer 
desenvolvedor.

---

### 12. [TODO] - Adicionar opção de ajuda e dicas durante o quiz

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Implementar um sistema de ajuda que permita ao jogador obter dicas sobre 
a resposta correta, talvez ao custo de pontos ou tempo, aumentaria a jogabilidade e 
diminuiria a frustração em questões difíceis.

**Prompt de Implementação:**
```
Adicione um sistema de ajuda e dicas ao quiz. Implemente um botão de dica na interface 
que, quando pressionado, fornece uma pista sobre a resposta correta. A utilização da 
dica deve ter um custo (redução de pontos potenciais ou tempo). Atualize o QuizModel 
para suportar essa funcionalidade e adicione um campo 'hint' às questões. O sistema 
deve limitar o número de dicas disponíveis por jogo.
```

**Dependências:** 
- game_quiz_page.dart
- models/quiz_model.dart
- widgets/options_grid.dart
- Novo componente: widgets/hint_button.dart

**Validação:** O jogador deve poder solicitar uma dica durante o jogo, que fornecerá 
informações úteis sobre a resposta correta, com um custo apropriado para balancear a 
jogabilidade.

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída
