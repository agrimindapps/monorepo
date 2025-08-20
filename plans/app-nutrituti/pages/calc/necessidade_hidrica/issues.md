# Issues e Melhorias - Necessidade Hídrica Module

## 📋 Índice Geral

### 🔴 Complexidade ALTA (4 issues)
1. [SECURITY] - Parsing sem tratamento de exceção pode quebrar a aplicação
2. [BUG] - State management inconsistente causa perda de dados de formulário
3. [REFACTOR] - Lógica de cálculo hardcoded sem validação científica
4. [OPTIMIZE] - Widget rebuilds desnecessários degradam performance

### 🟡 Complexidade MÉDIA (5 issues)  
5. [TODO] - Falta persistência de histórico para tracking de hidratação
6. [STYLE] - Interface sem responsividade adequada para diferentes telas
7. [TODO] - Ausência de lembretes e notificações de hidratação
8. [REFACTOR] - Strings hardcoded impedem internacionalização
9. [STYLE] - Botões de ação com design inconsistente no formulário

### 🟢 Complexidade BAIXA (6 issues)
10. [DOC] - Ausência de documentação nos métodos principais
11. ✅ [STYLE] - Cores e ícones inconsistentes com design system
12. [TODO] - Falta validação de ranges realistas para peso corporal
13. ✅ [OPTIMIZE] - String concatenation ineficiente no compartilhamento
14. [STYLE] - Espaçamentos irregulares entre componentes
15. [TEST] - Ausência de validação de edge cases nos cálculos

---

## 🔴 Complexidade ALTA

### 1. [SECURITY] - Parsing sem tratamento de exceção pode quebrar a aplicação

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O método calcular no controller faz parsing direto de string para double 
sem tratamento de exceção, podendo causar crash da aplicação com entrada inválida.

**Prompt de Implementação:**
Adicione tratamento de exceção robusto ao método calcular na classe 
NecessidadeHidricaController. Implemente validação que capture FormatException e 
NumberFormatException, exibindo mensagens específicas para cada tipo de erro. 
Adicione validação de ranges realistas (peso entre 20-300kg) e teste com diferentes 
formatos de entrada incluindo valores negativos, muito grandes e caracteres inválidos.

**Dependências:** necessidade_hidrica_controller.dart, necessidade_hidrica_model.dart

**Validação:** Testar entrada de dados inválidos sem causar crash da aplicação

---

### 2. [BUG] - State management inconsistente causa perda de dados de formulário

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O modelo não notifica mudanças nos dropdowns fazendo com que mudanças 
de seleção não sejam refletidas na UI até próximo rebuild, causando inconsistência 
de estado.

**Prompt de Implementação:**
Refatore a arquitetura para que o NecessidadeHidricaModel estenda ChangeNotifier e 
notifique mudanças quando nivelAtividadeSelecionado e climaSelecionado forem alterados. 
Atualize os widgets input_form.dart para usar Consumer ou selector específicos que 
respondam apenas às mudanças relevantes. Garanta que todas as alterações de estado 
sejam propagadas corretamente através da árvore de widgets.

**Dependências:** necessidade_hidrica_model.dart, input_form.dart, 
necessidade_hidrica_controller.dart

**Validação:** Verificar se mudanças nos dropdowns são refletidas imediatamente na UI 
sem necessidade de rebuilds

---

### 3. [REFACTOR] - Lógica de cálculo hardcoded sem validação científica

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** A fórmula de 35ml por kg é hardcoded sem referência científica, e os 
fatores de ajuste por atividade e clima são arbitrários sem fundamentação médica.

**Prompt de Implementação:**
Crie uma classe CalculadoraHidratacao separada que implemente diferentes métodos 
científicos de cálculo (Instituto de Medicina dos EUA, European Food Safety Authority). 
Adicione constantes com referências científicas, implemente validação de resultados 
contra ranges seguros, e adicione método que retorne recomendações baseadas em idade, 
gênero e condições especiais. Inclua disclaimers apropriados sobre limitações do cálculo.

**Dependências:** Criar novo arquivo utils/calculadora_hidratacao.dart, atualizar 
necessidade_hidrica_controller.dart

**Validação:** Comparar resultados com calculadoras médicas estabelecidas e verificar 
se ranges de output são realistas

---

### 4. [OPTIMIZE] - Widget rebuilds desnecessários degradam performance

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Todo o formulário é reconstruído a cada mudança no controller, mesmo 
quando apenas campos específicos são alterados, causando performance ruim em 
dispositivos mais lentos.

**Prompt de Implementação:**
Implemente Consumer granular e Selector específicos para cada seção do formulário 
(peso, atividade, clima) que só rebuildem quando valores específicos mudarem. 
Adicione const constructors onde possível, extraia widgets estáticos como const, 
e use AnimatedBuilder apenas para animações específicas. Otimize especialmente o 
result_card que não precisa rebuild quando apenas dados de input mudam.

**Dependências:** input_form.dart, result_card.dart, necessidade_hidrica_view.dart

**Validação:** Usar Flutter Inspector para confirmar redução de rebuilds desnecessários

---

## 🟡 Complexidade MÉDIA

### 5. [TODO] - Falta persistência de histórico para tracking de hidratação

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Não há sistema de salvamento de cálculos anteriores nem tracking diário 
de consumo de água, limitando a utilidade da ferramenta para acompanhamento contínuo.

**Prompt de Implementação:**
Implemente sistema de persistência usando SharedPreferences para salvar histórico de 
cálculos com timestamp, peso, níveis de atividade e resultados. Crie tela de histórico 
que mostre evolução das necessidades hídricas, adicione funcionalidade de tracking 
diário onde usuário pode marcar quantidade consumida versus recomendada, e implemente 
gráficos simples mostrando tendências semanais e mensais.

**Dependências:** Criar history_service.dart, adicionar shared_preferences ao pubspec, 
criar widgets de histórico

**Validação:** Verificar persistência correta entre sessões da aplicação

---

### 6. [STYLE] - Interface sem responsividade adequada para diferentes telas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Layout fixo não se adapta bem a tablets ou celulares em landscape, com 
campos muito estreitos em telas grandes e muito apertados em telas pequenas.

**Prompt de Implementação:**
Implemente layout responsivo usando MediaQuery e LayoutBuilder para adaptar disposição 
dos elementos. Em tablets use layout de duas colunas com formulário à esquerda e 
informações à direita. Em telefones otimize espaçamento vertical e tamanho de fontes. 
Adicione breakpoints para diferentes tamanhos de tela e ajuste padding/margin 
proporcionalmente. Garanta que dropdowns tenham altura adequada em todos os dispositivos.

**Dependências:** necessidade_hidrica_view.dart, input_form.dart, result_card.dart

**Validação:** Testar em diferentes tamanhos de tela e orientações

---

### 7. [TODO] - Ausência de lembretes e notificações de hidratação

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** App não oferece funcionalidade de lembretes para beber água ao longo 
do dia, perdendo oportunidade de promover hidratação adequada.

**Prompt de Implementação:**
Adicione sistema de notificações locais usando flutter_local_notifications que permita 
configurar intervalos personalizados de lembrete. Implemente configurações para 
horário de início e fim dos lembretes, frequência personalizada, e mensagens 
motivacionais variadas. Adicione opção de pausar lembretes temporariamente e integre 
com o resultado do cálculo para sugerir quantidade por lembrete.

**Dependências:** Adicionar flutter_local_notifications, permission_handler, criar 
notification_service.dart

**Validação:** Testar recebimento de notificações em horários configurados

---

### 8. [REFACTOR] - Strings hardcoded impedem internacionalização

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Todos os textos estão hardcoded em português nos widgets, impossibilitando 
tradução para outros idiomas e dificultando manutenção de conteúdo.

**Prompt de Implementação:**
Extraia todas as strings para arquivo de constantes ou sistema de localização. 
Crie constants/necessidade_hidrica_strings.dart com todas as strings organizadas 
por contexto (títulos, labels, mensagens, dicas). Implemente suporte básico para 
internacionalização preparando estrutura para multiple idiomas. Substitua todas 
as strings hardcoded por referências às constantes em todos os widgets.

**Dependências:** Todos os arquivos de widget, criar arquivo de constantes

**Validação:** Verificar se mudanças em strings centralizadas refletem em toda a interface

---

### 9. [STYLE] - Botões de ação com design inconsistente no formulário

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Botões Limpar e Calcular têm mesmo estilo visual sem hierarquia clara, 
e não seguem padrões de design system estabelecidos na aplicação.

**Prompt de Implementação:**
Redesenhe botões seguindo hierarquia visual clara onde Calcular é primary button e 
Limpar é secondary. Use cores consistentes com ShadcnStyle, adicione ícones apropriados 
(calculate_outlined para calcular, refresh para limpar), implemente states visuais 
(hover, pressed, disabled), e garanta que spacing e sizing sigam especificações do 
design system da aplicação.

**Dependências:** input_form.dart, core/style/shadcn_style.dart

**Validação:** Comparar estilo com outros botões da aplicação para consistência

---

## 🟢 Complexidade BAIXA

### 10. [DOC] - Ausência de documentação nos métodos principais

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Métodos como calcular, getNivelAtividadeFator e getClimaFator não possuem 
documentação explicando lógica de negócio e parâmetros esperados.

**Prompt de Implementação:**
Adicione documentação Dart completa para todos os métodos públicos incluindo descrição 
da funcionalidade, parâmetros de entrada, valores de retorno e exemplos de uso quando 
aplicável. Documente especialmente a lógica de cálculo e fatores de ajuste com suas 
respectivas fundamentações. Use padrão dartdoc com comentários triple-slash para 
gerar documentação automática.

**Dependências:** necessidade_hidrica_controller.dart, necessidade_hidrica_model.dart

**Validação:** Executar dartdoc para verificar geração correta da documentação

---

### 11. ✅ [STYLE] - Cores e ícones inconsistentes com design system

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Ícones e cores usados não seguem padrão estabelecido pelo design system, 
com water_drop_outlined usado inconsistentemente e cores hardcoded.

**✅ Implementado:** Padronizados todos os ícones relacionados à água (water_drop, local_drink, 
analytics) de forma consistente através da interface. Substituídas cores hardcoded por 
referências ao ShadcnStyle e cores temáticas apropriadas para hidratação (azuis e cyan). 
Ícones agora têm semantic meaning apropriado para diferentes contextos (informação, ação, 
resultado). Melhorados botões com hierarquia visual clara e espaçamentos padronizados em 
múltiplos de 8px.

**Prompt de Implementação:**
Padronize uso de ícones relacionados à água (water_drop, local_drink) de forma 
consistente através da interface. Substitua cores hardcoded por referências ao 
ShadcnStyle, use cores temáticas apropriadas para hidratação (azuis e cyan), 
e garanta que ícones tenham semantic meaning apropriado para diferentes contextos 
(informação, ação, resultado).

**Dependências:** Todos os arquivos de widget, core/style/shadcn_style.dart

**Validação:** Verificar consistência visual com resto da aplicação

---

### 12. [TODO] - Falta validação de ranges realistas para peso corporal

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Validação atual permite peso até 300kg mas não valida contra ranges 
médicos realistas nem oferece feedback específico sobre valores extremos.

**Prompt de Implementação:**
Implemente validação mais específica com ranges médicos apropriados (ex: 20-200kg 
para adultos normais, com warnings para valores extremos mas válidos). Adicione 
mensagens de validação contextuais que informem sobre ranges esperados, implemente 
validação visual em tempo real no campo de entrada, e considere alertas especiais 
para valores que podem indicar erro de digitação.

**Dependências:** necessidade_hidrica_model.dart, input_form.dart

**Validação:** Testar com valores limite e verificar feedback apropriado

---

### 13. ✅ [OPTIMIZE] - String concatenation ineficiente no compartilhamento

**Status:** ✅ Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Método compartilhar usa StringBuffer mas ainda faz várias operações 
de string redundantes que podem ser otimizadas.

**✅ Implementado:** Otimizado completamente o método compartilhar eliminando operações 
desnecessárias de string. Pre-calculados textos que são reutilizados, usado formatação 
mais eficiente para números decimais com template de compartilhamento reutilizável. 
Substituído StringBuffer por interpolação direta de strings com const strings para 
textos fixos do template, resultando em melhor performance e código mais limpo.

**Prompt de Implementação:**
Otimize o método compartilhar eliminando operações desnecessárias de string, 
pre-calculando textos que são reutilizados, e usando formatação mais eficiente 
para números decimais. Considere criar template de compartilhamento reutilizável 
e adicione timestamp formatado adequadamente. Use const strings para textos fixos 
do template.

**Dependências:** necessidade_hidrica_controller.dart

**Validação:** Testar se compartilhamento continua funcionando com melhor performance

---

### 14. [STYLE] - Espaçamentos irregulares entre componentes

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Padding e margins não seguem sistema de espaçamento consistente, com 
valores arbitrários (10, 15, 16) ao invés de múltiplos padrão.

**Prompt de Implementação:**
Padronize todos os espaçamentos usando sistema baseado em múltiplos de 8 (8, 16, 24, 32) 
conforme Material Design guidelines. Substitua valores arbitrários por constantes 
de espaçamento definidas no design system, use EdgeInsets.symmetric e EdgeInsets.only 
de forma consistente, e garanta hierarquia visual clara entre diferentes níveis 
de componentes.

**Dependências:** Todos os arquivos de widget, possivelmente criar spacing_constants.dart

**Validação:** Verificar alinhamento visual consistente entre componentes

---

### 15. [TEST] - Ausência de validação de edge cases nos cálculos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Não há validação para cenários extremos como peso muito baixo/alto, 
combinações extremas de atividade+clima, ou resultados fora de ranges médicos seguros.

**Prompt de Implementação:**
Adicione validação para edge cases incluindo peso extremamente baixo (ex: <30kg) ou 
alto (>150kg), combinações que resultem em necessidade hídrica extrema (ex: peso alto + 
muito ativo + clima quente), e implemente caps de segurança para evitar recomendações 
perigosas. Adicione warnings quando resultado exceder guidelines médicos estabelecidos 
e sugira consulta profissional para casos extremos.

**Dependências:** necessidade_hidrica_controller.dart, possivelmente criar 
validation_utils.dart

**Validação:** Testar com combinações extremas e verificar se warnings aparecem 
apropriadamente

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

**Priorização sugerida:**
1. Issues #1, #2, #3 (críticas para estabilidade e qualidade)
2. Issues #4, #5, #6 (impacto na experiência do usuário)
3. Issues #7, #8, #9 (melhorias funcionais)
4. Issues #10-15 (polish e manutenção)

**Observações importantes:**
- Module apresenta boa estrutura MVC mas precisa refinamento na gestão de estado
- Fórmulas de cálculo necessitam validação científica para credibilidade médica
- Interface precisa melhorias de responsividade e acessibilidade
- Oportunidade excelente para adicionar features de tracking e gamificação
