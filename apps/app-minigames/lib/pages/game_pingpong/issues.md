# Issues e Melhorias - pingpong_page.dart

## 📋 Índice Geral

### 🔴 Complexidade ALTA (3 issues)
1. [REFACTOR] - Separação de responsabilidades e arquitetura MVC
2. [OPTIMIZE] - Otimização de performance com isolate para física do jogo
3. [TODO] - Implementação de níveis de dificuldade adaptativos

### 🟡 Complexidade MÉDIA (6 issues)  
4. [FIXME] - Melhoria na detecção de colisões para maior precisão
5. [TODO] - Implementação de efeitos sonoros e feedback tátil
6. [REFACTOR] - Separação da lógica do jogo em componentes menores
7. [STYLE] - Melhoria na interface visual e responsividade
8. [TODO] - Implementação de modo multijogador local
9. [TEST] - Adição de testes unitários e de widget

### 🟢 Complexidade BAIXA (6 issues)
10. [TODO] - Adição de contador de tempo e estatísticas de jogo
11. [REFACTOR] - Centralização de constantes e configurações
12. [STYLE] - Melhoria na acessibilidade do jogo
13. [DOC] - Documentação do código e comentários
14. [BUG] - Correção do sistema de pausa em situações específicas
15. [TODO] - Implementação de sistema de power-ups

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Separação de responsabilidades e arquitetura MVC

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O arquivo `ping_pong_game.dart` mistura lógica de jogo, renderização e 
interface do usuário, violando o princípio de responsabilidade única. Isso dificulta a 
manutenção, testabilidade e extensibilidade do código. É necessário refatorar para uma 
arquitetura MVC (Model-View-Controller) ou similar para separar adequadamente as 
responsabilidades.

**Prompt de Implementação:**
```
Refatore o jogo de Ping Pong para uma arquitetura MVC (Model-View-Controller):

1. Crie uma pasta 'models' contendo:
   - game_state.dart: Para armazenar o estado do jogo (posições, pontuações, etc.)
   - ball.dart: Classe para a bola com sua física e comportamento
   - paddle.dart: Classe para as raquetes do jogador e da IA

2. Crie uma pasta 'controllers' contendo:
   - game_controller.dart: Para gerenciar a lógica do jogo, colisões e regras
   - ai_controller.dart: Para controlar o comportamento da IA
   - input_controller.dart: Para gerenciar entradas do usuário

3. Refatore o arquivo atual para focar apenas na visualização, movendo a lógica para 
   os controladores apropriados e o estado para os modelos.

Mantenha a funcionalidade existente, apenas reorganizando o código para seguir 
a arquitetura MVC.
```

**Dependências:** 
- ping_pong_game.dart (refatorar completamente)
- Novos arquivos em models/, controllers/ e widgets/

**Validação:** O jogo deve funcionar exatamente como antes, mas com código mais organizado,
testável e manutenível. Cada componente deve ter responsabilidades claras e bem definidas.

---

### 2. [OPTIMIZE] - Otimização de performance com isolate para física do jogo

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** A lógica de física do jogo está sendo executada na thread principal da UI,
o que pode causar queda de quadros e travamentos, especialmente em dispositivos mais 
antigos ou quando a complexidade do jogo aumentar. Mover os cálculos de física para um 
isolate melhoraria significativamente a performance.

**Prompt de Implementação:**
```
Otimize a performance do jogo de Ping Pong implementando um sistema de física em 
isolate:

1. Crie uma classe PhysicsEngine em um arquivo separado que encapsule todos os 
   cálculos de física do jogo (movimento da bola, colisões, etc.).

2. Implemente um sistema que execute esses cálculos em um isolate:
   - Use compute() para cálculos mais simples
   - Ou crie um isolate persistente para comunicação contínua

3. Estabeleça um sistema de comunicação entre o isolate e a UI:
   - Envie o estado atual para o isolate
   - Receba o estado atualizado de volta
   - Atualize a UI com base no estado recebido

4. Adicione um mecanismo de throttling para garantir que a UI seja atualizada a uma 
   taxa consistente (60 FPS idealmente)

5. Implemente um sistema de fallback para dispositivos que não suportam isolates
```

**Dependências:**
- Criação de physics_engine.dart
- Modificação de ping_pong_game.dart
- Potencial criação de um service para gerenciar o isolate

**Validação:** A UI deve permanecer suave mesmo com cálculos de física complexos.
Use ferramentas de profiling para comparar a performance antes e depois da otimização,
verificando uso de CPU e estabilidade de FPS.

---

### 3. [TODO] - Implementação de níveis de dificuldade adaptativos

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Atualmente, o jogo tem apenas um nível de dificuldade fixo determinado pela
variável `_aiReactionSpeed`. Implementar um sistema de dificuldade adaptativa que se 
ajuste ao desempenho do jogador tornaria o jogo mais engajante e desafiador para 
jogadores de diferentes níveis de habilidade.

**Prompt de Implementação:**
```
Implemente um sistema de dificuldade adaptativa para o jogo de Ping Pong:

1. Crie uma classe DifficultyManager para gerenciar a dificuldade do jogo:
   - Rastreie métricas de desempenho do jogador (taxa de vitória, tempo de reação, etc.)
   - Ajuste dinamicamente parâmetros como velocidade da IA, velocidade da bola, etc.
   - Implemente diferentes perfis de dificuldade (fácil, médio, difícil, adaptativo)

2. Adicione um sistema de adaptação que:
   - Aumente gradualmente a dificuldade quando o jogador está vencendo facilmente
   - Diminua a dificuldade quando o jogador está perdendo consecutivamente
   - Encontre o "ponto ideal" de desafio para manter o engajamento
   
3. Adicione um menu de configurações que permita ao jogador escolher:
   - Nível de dificuldade fixo (fácil, médio, difícil)
   - Modo adaptativo (ajusta automaticamente)
   - Configurações personalizadas (velocidade da bola, tamanho das raquetes, etc.)
   
4. Implemente um sistema de feedback visual que indique sutilmente mudanças na dificuldade
```

**Dependências:**
- Criação de difficulty_manager.dart
- Modificação de ping_pong_game.dart
- Adição de um menu de configurações
- Potencial criação de modelos de perfil de dificuldade

**Validação:** Teste o jogo com jogadores de diferentes níveis de habilidade e verifique 
se a dificuldade se ajusta apropriadamente. O jogo deve ser desafiador mas não frustrante
para novatos, e desafiador mas não impossível para jogadores experientes.

---

## 🟡 Complexidade MÉDIA

### 4. [FIXME] - Melhoria na detecção de colisões para maior precisão

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** O sistema atual de detecção de colisões é simplificado e pode resultar em 
comportamentos inesperados ou imprecisos, especialmente em velocidades mais altas. 
Implementar um sistema de colisão mais preciso melhoraria a experiência de jogo e 
reduziria frustrações.

**Prompt de Implementação:**
```
Melhore o sistema de detecção de colisões do jogo de Ping Pong:

1. Implemente uma detecção de colisão contínua (não apenas baseada em posição):
   - Use ray casting para detectar quando a bola atravessa uma raquete
   - Leve em consideração a trajetória da bola entre frames
   - Calcule o ponto exato de colisão para reflexão mais precisa

2. Melhore o cálculo de rebatimento da bola:
   - Considere o ângulo de incidência
   - Adicione um componente de velocidade baseado no movimento da raquete
   - Adicione uma pequena aleatoriedade para evitar loops previsíveis

3. Implemente zonas de impacto nas raquetes:
   - Centro: rebatimento normal
   - Bordas: ângulos mais extremos
   - Cantos: efeitos especiais ou velocidade aumentada

4. Adicione feedback visual para colisões (efeitos de partículas, flashes, etc.)
```

**Dependências:**
- Modificação da lógica de colisão em ping_pong_game.dart
- Potencial criação de uma classe específica para colisões

**Validação:** Teste o jogo em diferentes velocidades e ângulos, verificando se as 
colisões são detectadas corretamente. A bola não deve atravessar as raquetes e o 
comportamento de rebatimento deve ser natural e intuitivo.

---

### 5. [TODO] - Implementação de efeitos sonoros e feedback tátil

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** O jogo atual não possui feedback sonoro ou tátil, o que diminui a 
imersão e a satisfação do jogador. Adicionar efeitos sonoros para eventos como 
colisões, pontuação e fim de jogo, além de feedback tátil (vibração) em dispositivos 
móveis, melhoraria significativamente a experiência do usuário.

**Prompt de Implementação:**
```
Implemente um sistema completo de feedback sonoro e tátil para o jogo de Ping Pong:

1. Crie uma classe SoundManager para gerenciar efeitos sonoros:
   - Adicione sons para: colisão com raquetes, colisão com paredes, pontuação, 
     vitória, derrota, início do jogo, pausa
   - Implemente um sistema de carregamento preguiçoso para os sons
   - Adicione controle de volume e opção para silenciar

2. Implemente feedback tátil (vibração) para dispositivos móveis:
   - Use HapticFeedback do Flutter para eventos importantes
   - Varie a intensidade de acordo com o evento (colisão leve, pontuação, etc.)
   - Torne o feedback tátil opcional nas configurações

3. Adicione música de fundo com as seguintes características:
   - Tema principal durante o jogo
   - Variações para situações de tensão (pontuação alta, jogo empatado)
   - Fade out durante pausas e transições

4. Adicione configurações para personalizar o feedback:
   - Volumes separados para efeitos sonoros e música
   - Ativar/desativar vibração
   - Opções de áudio acessíveis
```

**Dependências:**
- Criação de sound_manager.dart
- Adição de recursos de áudio ao projeto
- Modificação de ping_pong_game.dart para integrar o feedback
- Adição de permissões de vibração no AndroidManifest e Info.plist

**Validação:** Teste o jogo com som e vibração habilitados, verificando se o feedback 
é apropriado, imersivo e não irritante. Verifique também se as opções para 
desabilitar funcionam corretamente para usuários que preferem jogar em silêncio.

---

### 6. [REFACTOR] - Separação da lógica do jogo em componentes menores

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** A classe `_PingPongGameState` é muito grande e contém múltiplas 
responsabilidades, o que dificulta a manutenção e extensão do código. Refatorar a 
lógica em componentes menores e mais especializados melhoraria a organização e 
facilitaria futuras modificações.

**Prompt de Implementação:**
```
Refatore a lógica do jogo de Ping Pong em componentes menores e mais especializados:

1. Extraia a lógica de física para uma classe separada:
   - Movimento da bola
   - Detecção de colisões
   - Cálculos de rebatimento

2. Crie uma classe dedicada para a IA do oponente:
   - Diferentes estratégias de jogo
   - Ajuste de dificuldade
   - Comportamentos especiais

3. Extraia a renderização para componentes separados:
   - Uma classe para renderizar a bola
   - Uma classe para renderizar as raquetes
   - Uma classe para efeitos visuais

4. Crie uma classe para gerenciamento de estado do jogo:
   - Pontuação
   - Estado atual (jogando, pausado, game over)
   - Transições entre estados

5. Implemente um sistema de eventos para comunicação entre componentes
```

**Dependências:**
- Refatoração significativa de ping_pong_game.dart
- Criação de vários arquivos menores para cada componente

**Validação:** O jogo deve funcionar exatamente como antes, mas com código mais organizado,
testável e manutenível. Cada componente deve ter responsabilidades claras e bem definidas.

---

### 7. [STYLE] - Melhoria na interface visual e responsividade

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** A interface atual do jogo é funcional, mas bastante simples e não se 
adapta bem a diferentes tamanhos de tela. Melhorar o design visual e a responsividade 
tornaria o jogo mais atraente e utilizável em uma variedade maior de dispositivos.

**Prompt de Implementação:**
```
Melhore a interface visual e a responsividade do jogo de Ping Pong:

1. Crie um tema visual consistente e atraente:
   - Esquema de cores personalizado
   - Tipografia adequada e legível
   - Elementos de UI com design consistente

2. Implemente um layout responsivo que se adapte a diferentes tamanhos de tela:
   - Calcule automaticamente o tamanho ideal para a área de jogo
   - Ajuste o tamanho dos elementos (bola, raquetes) proporcionalmente
   - Suporte tanto orientação retrato quanto paisagem

3. Adicione elementos visuais para melhorar a imersão:
   - Fundo com efeito de grade ou linhas
   - Partículas ou rastros seguindo a bola
   - Animações para eventos importantes (pontuação, vitória)

4. Melhore os menus e diálogos:
   - Menu inicial com opções de jogo
   - Tela de pausa com mais opções
   - Tela de fim de jogo com estatísticas e opções

5. Adicione transições suaves entre telas e estados do jogo
```

**Dependências:**
- Modificação de ping_pong_game.dart
- Criação de arquivos de tema e estilo
- Potencial adição de recursos gráficos (imagens, animações)

**Validação:** Teste o jogo em dispositivos com diferentes tamanhos de tela e orientações,
verificando se a interface se adapta corretamente e mantém boa jogabilidade. A experiência
visual deve ser agradável e profissional.

---

### 8. [TODO] - Implementação de modo multijogador local

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Atualmente, o jogo só permite jogar contra a IA. Adicionar um modo 
multijogador local, onde dois jogadores podem competir no mesmo dispositivo, 
aumentaria significativamente o valor de entretenimento e as opções de jogo.

**Prompt de Implementação:**
```
Implemente um modo multijogador local para o jogo de Ping Pong:

1. Crie um sistema de seleção de modo de jogo:
   - Modo único contra IA (existente)
   - Modo multijogador local (novo)

2. Para o modo multijogador local:
   - Divida a tela em duas áreas de controle para cada jogador
   - Substitua a IA por controles para o segundo jogador
   - Adapte a UI para mostrar claramente qual lado pertence a qual jogador

3. Implemente controles para o segundo jogador:
   - Em dispositivos touchscreen: área de toque na direita da tela
   - Em dispositivos com teclado: teclas adicionais (W/S ou setas)
   - Suporte a controladores externos, se possível

4. Adicione elementos específicos para multijogador:
   - Contagem regressiva antes do início
   - Indicadores visuais para cada jogador
   - Estatísticas e histórico de partidas

5. Implemente um sistema de rounds e melhor de X partidas
```

**Dependências:**
- Modificação significativa de ping_pong_game.dart
- Criação de novos componentes de UI para o modo multijogador
- Potencial criação de um gerenciador de modos de jogo

**Validação:** Teste o modo multijogador com dois jogadores reais, verificando se 
os controles são responsivos e justos para ambos. O jogo deve ser divertido e competitivo,
com clara indicação de qual jogador está controlando qual raquete.

---

### 9. [TEST] - Adição de testes unitários e de widget

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O código atual não possui testes automatizados, o que dificulta refatorações 
seguras e pode permitir a introdução de bugs. Implementar testes unitários para a lógica 
do jogo e testes de widget para a interface melhoraria a qualidade e manutenibilidade 
do código.

**Prompt de Implementação:**
```
Implemente uma suíte de testes automatizados para o jogo de Ping Pong:

1. Crie testes unitários para a lógica do jogo:
   - Física da bola (movimento, colisões, rebatimentos)
   - Lógica da IA (movimento, tomada de decisões)
   - Sistema de pontuação e regras do jogo
   - Gerenciamento de estado (início, pausa, fim de jogo)

2. Implemente testes de widget para a interface:
   - Renderização correta dos elementos visuais
   - Interação do usuário (toques, gestos)
   - Atualizações de UI baseadas em mudanças de estado
   - Diálogos e menus

3. Adicione testes de integração para fluxos completos:
   - Ciclo completo de jogo (início ao fim)
   - Interações entre componentes
   - Persistência de configurações e pontuações

4. Configure CI/CD para executar os testes automaticamente

5. Utilize mocks e stubs para isolar componentes durante os testes
```

**Dependências:**
- Criação de arquivos de teste em uma pasta test/
- Potencial refatoração do código para melhorar a testabilidade
- Adição de pacotes de teste ao pubspec.yaml

**Validação:** Execute a suíte de testes e verifique se todos passam. Faça alterações 
intencionais que quebrariam a funcionalidade e confirme que os testes falham 
apropriadamente, demonstrando sua eficácia.

---

## 🟢 Complexidade BAIXA

### 10. [TODO] - Adição de contador de tempo e estatísticas de jogo

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O jogo atual não possui contador de tempo nem estatísticas detalhadas 
sobre a partida. Adicionar essas funcionalidades proporcionaria ao jogador mais 
informações sobre seu desempenho e tornaria o jogo mais engajante.

**Prompt de Implementação:**
```
Adicione um sistema de contador de tempo e estatísticas detalhadas ao jogo de Ping Pong:

1. Implemente um contador de tempo:
   - Tempo total de jogo
   - Tempo por rodada
   - Contador regressivo opcional para modo de tempo limitado

2. Adicione rastreamento de estatísticas em tempo real:
   - Velocidade máxima da bola
   - Tempo médio de reação do jogador
   - Quantidade de rebatidas em sequência (rally)
   - Taxa de acerto/erro

3. Exiba as estatísticas de forma não intrusiva durante o jogo:
   - Pequeno painel com informações básicas
   - Opção para expandir para ver mais detalhes
   - Atualizações visuais para recordes pessoais

4. Ao final do jogo, mostre um resumo completo:
   - Todas as estatísticas coletadas
   - Comparação com partidas anteriores
   - Destaque para recordes pessoais batidos

5. Adicione opção para compartilhar resultados
```

**Dependências:**
- Modificação de ping_pong_game.dart
- Criação de uma classe para gerenciar estatísticas
- Adição de elementos de UI para exibir as informações

**Validação:** Jogue uma partida completa e verifique se todas as estatísticas são 
registradas e exibidas corretamente. Teste cenários específicos (como rally longo ou 
velocidade alta) para garantir que as estatísticas são precisas.

---

### 11. [REFACTOR] - Centralização de constantes e configurações

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O código atual tem várias constantes e configurações espalhadas pela 
classe `_PingPongGameState`. Centralizar essas constantes em um arquivo separado 
melhoraria a manutenibilidade e facilitaria ajustes no comportamento do jogo.

**Prompt de Implementação:**
```
Centralize todas as constantes e configurações do jogo de Ping Pong:

1. Crie um arquivo constants.dart com classes para diferentes categorias:
   - GameConfig: dimensões, velocidades, limites
   - UIConfig: cores, tamanhos, espaçamentos
   - PhysicsConfig: parâmetros físicos, colisões
   - AIConfig: comportamento da IA, dificuldades

2. Substitua todos os valores hardcoded no código por referências a estas constantes

3. Adicione documentação para cada constante explicando seu propósito e impacto

4. Organize as constantes de forma lógica e hierárquica

5. Para valores que podem variar com base em preferências do usuário, crie um sistema 
   que permita carregá-los de configurações salvas
```

**Dependências:**
- Criação de constants.dart
- Modificação de ping_pong_game.dart para usar as constantes centralizadas

**Validação:** Verifique se o jogo funciona exatamente como antes após a refatoração.
Teste alterando algumas constantes para confirmar que afetam o comportamento do jogo
conforme esperado.

---

### 12. [STYLE] - Melhoria na acessibilidade do jogo

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O jogo atual não possui recursos de acessibilidade, o que pode 
dificultar ou impossibilitar seu uso por pessoas com deficiências. Implementar 
recursos de acessibilidade tornaria o jogo mais inclusivo e utilizável por um 
público mais amplo.

**Prompt de Implementação:**
```
Melhore a acessibilidade do jogo de Ping Pong:

1. Adicione suporte a leitores de tela:
   - Rótulos semânticos para todos os elementos interativos
   - Anúncios de eventos importantes (pontuação, início/fim de jogo)
   - Descrições claras para menus e configurações

2. Implemente opções de contraste e visibilidade:
   - Modo de alto contraste para elementos do jogo
   - Opção para aumentar o tamanho da bola e raquetes
   - Opções de cores alternativas para daltônicos

3. Adicione controles alternativos:
   - Suporte a switches de acessibilidade
   - Opção para controlar com botões em vez de gestos
   - Ajuste de sensibilidade para movimentos

4. Implemente opções de jogabilidade acessível:
   - Modo de velocidade reduzida
   - Assistência automática opcional
   - Feedback sonoro aprimorado para orientação espacial

5. Adicione documentação sobre os recursos de acessibilidade disponíveis
```

**Dependências:**
- Modificação de ping_pong_game.dart
- Adição de recursos visuais alternativos
- Potencial criação de um menu de acessibilidade

**Validação:** Teste o jogo com ferramentas de acessibilidade (como leitores de tela)
e verifique se todas as funcionalidades são acessíveis. Teste também as opções visuais
alternativas para garantir que são eficazes.

---

### 13. [DOC] - Documentação do código e comentários

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O código atual tem comentários limitados e falta documentação estruturada.
Adicionar documentação abrangente e comentários explicativos melhoraria a compreensão 
do código e facilitaria futuras manutenções e colaborações.

**Prompt de Implementação:**
```
Melhore a documentação e comentários do código do jogo de Ping Pong:

1. Adicione comentários de documentação (///) para todas as classes e métodos públicos:
   - Descrição clara da função
   - Parâmetros e valores de retorno
   - Exemplos de uso quando relevante
   - Notas sobre comportamentos especiais ou casos de borda

2. Documente a lógica de negócio complexa:
   - Sistema de física e colisões
   - Algoritmo da IA
   - Sistema de pontuação e regras

3. Adicione comentários explicativos para trechos de código não óbvios:
   - Cálculos matemáticos complexos
   - Otimizações específicas
   - Soluções para bugs ou limitações

4. Crie um arquivo README.md explicando:
   - Visão geral do jogo
   - Arquitetura e componentes principais
   - Como executar e testar
   - Como estender ou modificar

5. Siga as convenções de documentação do Dart/Flutter
```

**Dependências:**
- Modificação de todos os arquivos do jogo para adicionar documentação
- Criação de README.md

**Validação:** A documentação deve ser clara, precisa e útil para alguém não familiarizado
com o código. Verifique se ela explica adequadamente todos os aspectos importantes do jogo
e se segue as convenções de documentação do Dart/Flutter.

---

### 14. [BUG] - Correção do sistema de pausa em situações específicas

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O sistema atual de pausa pode apresentar comportamentos inconsistentes em 
certas situações, como quando o jogo é pausado durante uma colisão ou quando a bola está
se movendo muito rapidamente. Corrigir essas inconsistências melhoraria a experiência 
do usuário e a confiabilidade do jogo.

**Prompt de Implementação:**
```
Corrija o sistema de pausa do jogo de Ping Pong para lidar com situações específicas:

1. Implemente um sistema robusto de pausa:
   - Salve o estado completo do jogo ao pausar (posições, velocidades, etc.)
   - Garanta que nenhuma atualização de física ocorra durante a pausa
   - Adicione transição suave ao pausar/despausar

2. Corrija casos específicos:
   - Pausar durante uma colisão
   - Pausar quando a bola está em alta velocidade
   - Pausar exatamente quando um ponto é marcado

3. Melhore a interface de pausa:
   - Indique claramente que o jogo está pausado
   - Adicione opções durante a pausa (reiniciar, configurações, sair)
   - Implemente um contador regressivo ao despausar (3, 2, 1, Continuar!)

4. Adicione salvamento automático do estado do jogo ao pausar ou sair
```

**Dependências:**
- Modificação do método _pauseGame em ping_pong_game.dart
- Melhorias na interface de pausa

**Validação:** Teste pausar o jogo em diferentes momentos, especialmente durante eventos
críticos como colisões ou pontuação. Verifique se o jogo retoma corretamente do estado
pausado sem comportamentos estranhos ou bugs.

---

### 15. [TODO] - Implementação de sistema de power-ups

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** O jogo atual segue estritamente as regras tradicionais do Ping Pong. 
Adicionar um sistema de power-ups opcional tornaria o jogo mais variado, divertido 
e imprevisível, aumentando o engajamento e a replayability.

**Prompt de Implementação:**
```
Implemente um sistema de power-ups para o jogo de Ping Pong:

1. Crie uma classe PowerUp com diferentes tipos:
   - Raquete maior/menor
   - Bola mais rápida/mais lenta
   - Bola que muda de direção aleatoriamente
   - Campo com obstáculos temporários
   - Inversão de controles do oponente

2. Implemente o sistema de spawn de power-ups:
   - Aparecem aleatoriamente no campo em intervalos regulares
   - Podem ser coletados ao atingi-los com a bola
   - Têm duração limitada após ativação

3. Adicione feedback visual e sonoro:
   - Ícone distinto para cada power-up
   - Efeito visual quando um power-up é coletado ou ativado
   - Indicador de tempo restante para power-ups ativos

4. Implemente um modo de jogo específico para power-ups:
   - Modo clássico (sem power-ups)
   - Modo caótico (com power-ups frequentes)
   - Modo personalizado (configurar quais power-ups aparecem)

5. Balanceie os power-ups para manter o jogo justo e divertido
```

**Dependências:**
- Criação de power_up.dart
- Modificação de ping_pong_game.dart
- Adição de recursos visuais para os power-ups

**Validação:** Teste o jogo com diferentes power-ups e verifique se eles funcionam 
conforme esperado, tornando o jogo mais divertido sem desequilibrá-lo excessivamente.
Confirme que o feedback visual e sonoro é claro e que os power-ups têm impacto 
significativo na jogabilidade.

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída
