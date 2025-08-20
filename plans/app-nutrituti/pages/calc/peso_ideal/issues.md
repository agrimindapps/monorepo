# Issues e Melhorias - Peso Ideal Module

## 📋 Índice Geral

### 🔴 Complexidade ALTA (3 issues)
~~1. [REFACTOR] - Arquitetura inconsistente com outros módulos~~ ✅
2. [SECURITY] - Parsing inseguro sem tratamento de exceções
3. [BUG] - Lógica de cálculo científicamente questionável
4. [TODO] - Falta de validação de entrada abrangente
~~5. [OPTIMIZE] - Performance ruim com rebuilds desnecessários~~ ✅

### 🟡 Complexidade MÉDIA (5 issues)  
6. [REFACTOR] - Separação de responsabilidades inadequada
7. [STYLE] - Inconsistência visual entre telas
8. [TODO] - Sistema de persistência de dados ausente
9. [ACCESSIBILITY] - Recursos de acessibilidade insuficientes
10. [TODO] - Funcionalidade de comparação de métodos ausente

### 🟢 Complexidade BAIXA (5 issues)
11. [DOC] - Documentação técnica insuficiente
12. [STYLE] - Hardcoding de strings sem internacionalização
13. [OPTIMIZE] - Operações de string ineficientes
14. [TEST] - Falta de testes unitários
15. [TODO] - Recursos de compartilhamento limitados

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Arquitetura inconsistente com outros módulos

**Status:** ✅ Concluído | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O módulo usa ListenableBuilder diretamente no index.dart em vez do 
padrão Provider utilizado pelos outros módulos da aplicação, criando inconsistência 
arquitetural e dificultando manutenção.

**Prompt de Implementação:**
```
Refatore o arquivo index.dart do módulo peso_ideal para utilizar o padrão Provider 
consistente com outros módulos. Substitua a implementação atual que usa 
ListenableBuilder por ChangeNotifierProvider, mantendo a funcionalidade existente. 
Assegure-se de que o controller seja corretamente fornecido e disposado através 
do Provider. Adapte a view para consumir o controller via Consumer ou 
context.watch/read conforme apropriado.
```

**Dependências:** index.dart, peso_ideal_page.dart, provider package

**Validação:** Verificar se a funcionalidade permanece inalterada e se o padrão 
Provider funciona corretamente com disposal automático

**✅ IMPLEMENTAÇÃO CONCLUÍDA:**
- Migrado de ListenableBuilder para ChangeNotifierProvider no index.dart
- Removidas dependências diretas do controller nos widgets
- Implementado Consumer nos widgets que precisam acessar o estado
- Disposal automático do controller através do Provider
- Arquitetura agora consistente com outros módulos da aplicação
- Funcionalidade mantida inalterada com melhor separação de responsabilidades

---

### 2. [SECURITY] - Parsing inseguro sem tratamento de exceções

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O código usa double.parse diretamente sem try-catch, podendo causar 
crashes da aplicação quando o usuário insere dados inválidos. Presente tanto no 
modelo quanto nos utils.

**Prompt de Implementação:**
```
Implemente tratamento seguro de parsing nos arquivos peso_ideal_model.dart e 
peso_ideal_utils.dart. Substitua todas as chamadas double.parse por implementação 
com try-catch que retorne valores padrão ou exiba mensagens de erro apropriadas. 
Adicione validação para verificar se o texto de entrada é um número válido antes 
do parsing. Inclua validação de ranges apropriados para altura (50-300 cm).
```

**Dependências:** peso_ideal_model.dart, peso_ideal_utils.dart

**Validação:** Testar com entradas inválidas como letras, símbolos e valores 
extremos para garantir que não ocorram crashes

---

### 3. [BUG] - Lógica de cálculo científicamente questionável

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** As fórmulas utilizadas são hardcoded sem referência científica e 
podem não ser medicamente precisas. O limite mínimo de 130cm é muito restritivo 
e exclui pessoas de baixa estatura legitimamente.

**Prompt de Implementação:**
```
Revisar e validar as fórmulas de cálculo de peso ideal implementadas no modelo. 
Pesquisar e implementar fórmulas cientificamente validadas como Devine, Robinson, 
Miller ou Hamwi. Permitir seleção entre diferentes métodos de cálculo. Ajustar 
os limites mínimos de altura para valores mais inclusivos (ex: 100cm). Adicionar 
disclaimers apropriados sobre limitações do cálculo e necessidade de consulta 
médica.
```

**Dependências:** peso_ideal_model.dart, peso_ideal_utils.dart, peso_ideal_result.dart

**Validação:** Comparar resultados com calculadoras médicas estabelecidas e 
verificar se os ranges de altura são apropriados

---

### 4. [TODO] - Falta de validação de entrada abrangente

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** A validação atual é limitada apenas ao campo vazio e altura mínima. 
Faltam validações para altura máxima, formato de entrada inadequado e feedback 
visual em tempo real.

**Prompt de Implementação:**
```
Implementar sistema abrangente de validação de entrada no peso_ideal_utils.dart 
e peso_ideal_form.dart. Adicionar validação para altura máxima (ex: 300cm), 
verificação de formato numérico, feedback visual em tempo real nos campos de 
entrada. Implementar indicadores visuais de erro nos campos (bordas vermelhas, 
ícones de erro). Criar mensagens de erro específicas para cada tipo de problema 
de validação.
```

**Dependências:** peso_ideal_utils.dart, peso_ideal_form.dart, core/widgets

**Validação:** Testar todas as combinações de entrada inválida e verificar se 
o feedback visual e textual é apropriado

---

### 5. [OPTIMIZE] - Performance ruim com rebuilds desnecessários

**Status:** ✅ Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O uso de ListenableBuilder no index.dart e falta de Consumer 
específico nas views causam rebuilds desnecessários de toda a árvore de widgets 
quando apenas partes específicas precisam ser atualizadas.

**Prompt de Implementação:**
```
Otimizar a arquitetura de rebuilds substituindo ListenableBuilder por Consumer 
granular nos widgets específicos que precisam reagir a mudanças de estado. 
Implementar Consumer apenas nos widgets que realmente precisam ser reconstruídos 
(formulário para validação, resultado para exibição). Usar const constructors 
onde possível para widgets estáticos. Separar partes estáticas das dinâmicas 
nos widgets de resultado.
```

**Dependências:** index.dart, peso_ideal_form.dart, peso_ideal_result.dart

**Validação:** Usar Flutter Inspector para verificar redução no número de 
rebuilds e melhorar performance geral

**✅ IMPLEMENTAÇÃO CONCLUÍDA:**
- Migrado de ListenableBuilder para ChangeNotifierProvider
- Implementado Consumer granular nos widgets específicos
- Removido controller das props dos widgets filhos
- Otimizada arquitetura de rebuilds com Consumer apenas nos componentes que mudam
- Mantidos widgets estáticos com const constructors
- Performance melhorada com rebuilds mais específicos e menos desnecessários

---

## 🟡 Complexidade MÉDIA

### 6. [REFACTOR] - Separação de responsabilidades inadequada

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O modelo contém lógica de cálculo que deveria estar em um service 
separado, e o controller delega funções para utils quando poderia manter a lógica 
internamente ou usar services apropriados.

**Prompt de Implementação:**
```
Criar um service dedicado para cálculos de peso ideal em 
services/peso_ideal_service.dart. Mover toda lógica de cálculo do modelo e utils 
para este service. Refatorar o controller para usar o service em vez de delegar 
para utils. Manter no modelo apenas dados e getters/setters. Implementar 
diferentes métodos de cálculo no service (Devine, Robinson, etc.).
```

**Dependências:** Criar services/peso_ideal_service.dart, refatorar controller, 
model e utils

**Validação:** Verificar se a separação de responsabilidades está clara e se 
os testes unitários são mais fáceis de implementar

---

### 7. [STYLE] - Inconsistência visual entre telas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O layout e estilos visuais não seguem exatamente os mesmos padrões 
dos outros módulos, especialmente no resultado e na formatação de dados.

**Prompt de Implementação:**
```
Padronizar os estilos visuais do módulo peso_ideal para seguir exatamente os 
mesmos padrões dos outros módulos calculadora. Ajustar espaçamentos, cores, 
tipografia e layout dos cards de resultado. Implementar o mesmo padrão de 
exibição de informações usado nos outros módulos. Garantir que a responsividade 
siga os mesmos breakpoints e comportamentos.
```

**Dependências:** peso_ideal_form.dart, peso_ideal_result.dart, core/style

**Validação:** Comparar visualmente com outros módulos e verificar consistência 
em diferentes tamanhos de tela

---

### 8. [TODO] - Sistema de persistência de dados ausente

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Não há persistência de histórico de cálculos realizados, 
dificultando o acompanhamento de progresso do usuário ao longo do tempo.

**Prompt de Implementação:**
```
Implementar sistema de persistência para histórico de cálculos de peso ideal. 
Criar modelo de dados para histórico incluindo data, altura, gênero, resultado 
e método de cálculo usado. Usar SharedPreferences para armazenamento local. 
Adicionar tela de histórico acessível via app bar. Limitar histórico a últimos 
50 cálculos. Implementar funcionalidade de exportação do histórico.
```

**Dependências:** shared_preferences, criar models/peso_ideal_history.dart, 
services/storage_service.dart

**Validação:** Verificar se dados persistem entre sessões e se a tela de 
histórico exibe informações corretamente

---

### 9. [ACCESSIBILITY] - Recursos de acessibilidade insuficientes

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Faltam labels semânticos, navegação por teclado, e suporte adequado 
para leitores de tela, limitando o uso por pessoas com deficiência.

**Prompt de Implementação:**
```
Implementar recursos de acessibilidade abrangentes em todos os widgets do módulo. 
Adicionar Semantics widgets com labels descritivos, hints e propriedades 
apropriadas. Implementar navegação por teclado com atalhos (Enter para calcular, 
Tab para navegar). Adicionar tooltips informativos. Garantir contraste adequado 
de cores. Testar compatibilidade com leitores de tela usando labels claros 
em português.
```

**Dependências:** Todos widgets do módulo, core/widgets

**Validação:** Testar com simulador de leitor de tela e navegação apenas por 
teclado para verificar usabilidade

---

### 10. [TODO] - Funcionalidade de comparação de métodos ausente

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O aplicativo não permite comparar diferentes métodos de cálculo 
de peso ideal simultaneamente, limitando a utilidade educacional e prática.

**Prompt de Implementação:**
```
Implementar funcionalidade de comparação entre diferentes métodos de cálculo 
de peso ideal. Criar widget de resultado expandido que mostre resultados de 
múltiplos métodos (Devine, Robinson, Miller, Hamwi) simultaneamente. Adicionar 
explicação sobre diferenças entre métodos. Incluir visualização gráfica 
comparativa. Permitir seleção de métodos preferenciais para comparação.
```

**Dependências:** peso_ideal_result.dart, services/peso_ideal_service.dart

**Validação:** Verificar se todos métodos produzem resultados corretos e se 
a interface de comparação é intuitiva

---

## 🟢 Complexidade BAIXA

### 11. [DOC] - Documentação técnica insuficiente

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Classes e métodos carecem de documentação adequada, dificultando 
manutenção e compreensão do código por outros desenvolvedores.

**Prompt de Implementação:**
```
Adicionar documentação completa em formato dartdoc para todas as classes, 
métodos e propriedades públicas do módulo peso_ideal. Incluir descrições claras 
dos parâmetros, valores de retorno, exceções possíveis e exemplos de uso quando 
apropriado. Documentar as fórmulas utilizadas com referências científicas. 
Criar README específico do módulo explicando arquitetura e uso.
```

**Dependências:** Todos arquivos do módulo

**Validação:** Executar dart doc e verificar se documentação é gerada corretamente 
e se é compreensível

---

### 12. [STYLE] - Hardcoding de strings sem internacionalização

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Todas as strings da interface estão hardcoded em português, 
impedindo localização para outros idiomas no futuro.

**Prompt de Implementação:**
```
Extrair todas as strings hardcoded do módulo peso_ideal para arquivos de 
constantes ou sistema de localização. Criar peso_ideal_strings.dart com todas 
as constantes de texto. Substituir strings literais por referências às constantes. 
Organizar strings por categoria (labels, mensagens, tooltips, etc.). Preparar 
estrutura para futura implementação de internacionalização.
```

**Dependências:** Criar utils/peso_ideal_strings.dart, todos widgets

**Validação:** Verificar se todas strings foram extraídas e interface funciona 
normalmente com as constantes

---

### 13. [OPTIMIZE] - Operações de string ineficientes

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** O método de compartilhamento usa concatenação de strings simples 
em vez de StringBuffer, e formatação de números é feita repetidamente.

**Prompt de Implementação:**
```
Otimizar operações de string no peso_ideal_utils.dart substituindo concatenação 
simples por StringBuffer no método compartilhar. Criar formatters estáticos 
para reutilização em vez de criar novos NumberFormat a cada uso. Implementar 
cache para strings formatadas frequentemente usadas. Otimizar replacement de 
vírgulas por pontos usando métodos mais eficientes.
```

**Dependências:** peso_ideal_utils.dart, peso_ideal_model.dart

**Validação:** Medir performance de operações de string antes e depois das 
otimizações

---

### 14. [TEST] - Falta de testes unitários

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O módulo não possui testes unitários, dificultando validação de 
mudanças e detecção de regressões durante refatorações.

**Prompt de Implementação:**
```
Criar suite completa de testes unitários para o módulo peso_ideal. Implementar 
testes para todas as funções de cálculo, validação de entrada, formatação de 
dados e comportamento do controller. Incluir testes de edge cases como valores 
extremos, entradas inválidas e diferentes combinações de gênero/altura. Criar 
mocks apropriados para dependências externas. Atingir cobertura mínima de 90%.
```

**Dependências:** Criar test/peso_ideal_test.dart, flutter_test, mockito

**Validação:** Executar testes e verificar cobertura usando ferramentas de 
análise de cobertura

---

### 15. [TODO] - Recursos de compartilhamento limitados

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** A funcionalidade de compartilhamento atual é básica, apenas texto 
simples, sem opções de formato ou inclusão de gráficos/imagens.

**Prompt de Implementação:**
```
Expandir funcionalidades de compartilhamento do módulo peso_ideal. Implementar 
opções de compartilhamento em diferentes formatos (texto simples, texto formatado, 
imagem). Criar gerador de imagem com resultado visual incluindo gráfico simples. 
Adicionar opção de compartilhamento via diferentes apps (WhatsApp, email, redes 
sociais). Incluir branding do app na imagem compartilhada.
```

**Dependências:** peso_ideal_utils.dart, packages para geração de imagem

**Validação:** Testar compartilhamento em diferentes plataformas e verificar 
se formatos são exibidos corretamente

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

## 📊 Resumo Executivo

**Total de Issues:** 13 (3 Alta + 5 Média + 5 Baixa complexidade) | **Concluídas:** 2
**Prioridade Crítica:** Issues #2, #3, #4 (Segurança, Cálculos científicos, Validação)
**Esforço Estimado:** 15-25 horas de desenvolvimento
**Risco Geral:** Médio (principalmente relacionado à validação científica)
**Benefício:** Alto (melhoria significativa em qualidade, segurança e usabilidade)

**Recomendação de Sequência:**
1. **Fase Crítica:** Issues #2, #4 (Segurança e validação)
2. **Fase Arquitetural:** Issue #6 (Separação de responsabilidades) 
3. **Fase Funcional:** Issues #3, #8, #10 (Cálculos científicos e recursos)
4. **Fase Polish:** Issues #7, #9, #11-15 (UI e qualidade de código)
