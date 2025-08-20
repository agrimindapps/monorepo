# Issues e Melhorias - dosagem_medicamento

## 📋 Índice Geral

### 🔴 Complexidade ALTA (4 issues)
1. [SECURITY] - Cálculos de dosagem sem validação de segurança médica
2. [FIXME] - Dados de medicamentos muito limitados e sem diferenciação por espécie
3. [BUG] - Parsing de dosagem com tratamento inadequado de intervalos
4. [REFACTOR] - Dialog de alerta hardcoded no index

### 🟡 Complexidade MÉDIA (4 issues)
5. [TODO] - Sistema de contraindicações não implementado
6. [REFACTOR] - Controller com responsabilidades misturadas
7. [OPTIMIZE] - Cálculo sempre usa média sem considerar casos clínicos
8. [STYLE] - Inconsistência no uso do sistema de design

### 🟢 Complexidade BAIXA (2 issues)
9. [DOC] - Falta de referências farmacológicas para medicamentos
10. [TEST] - Validação inadequada para valores extremos

---

## 🔴 Complexidade ALTA

### 1. [SECURITY] - Cálculos de dosagem sem validação de segurança médica

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** A calculadora realiza cálculos de dosagem farmacológica sem validações 
de segurança adequadas. Não verifica doses máximas absolutas, não considera 
toxicidade, não alerta para overdoses potenciais, e não valida se o resultado 
está dentro de ranges terapêuticos seguros.

**Prompt de Implementação:**

Implemente sistema robusto de validação farmacológica. Adicione verificação de 
doses máximas diárias por medicamento, alertas para potencial toxicidade, 
validação de ranges terapêuticos vs tóxicos, sistema de confirmação dupla para 
doses próximas aos limites de segurança, e bloqueio automático para cálculos 
claramente perigosos com redirect para consulta veterinária.

**Dependências:** dosagem_medicamentos_controller.dart, dosagem_medicamentos_model.dart, 
sistema de validação farmacológica

**Validação:** Testar com doses extremas, verificar alertas de segurança adequados, 
confirmar bloqueio de doses perigosas, validar com referências farmacológicas

---

### 2. [FIXME] - Dados de medicamentos muito limitados e sem diferenciação por espécie

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O modelo tem apenas 10 medicamentos hardcoded sem diferenciação 
entre cães e gatos. Muitos medicamentos têm dosagens diferentes entre espécies, 
alguns são contraindicados para certas espécies. Faltam medicamentos veterinários 
comuns e especializados.

**Prompt de Implementação:**

Expanda significativamente o banco de dados farmacológico veterinário. Organize 
medicamentos por espécie com dosagens específicas, adicione medicamentos 
especializados por área (cardiologia, dermatologia, etc.), implemente sistema 
de contraindicações por espécie, adicione medicamentos de uso exclusivamente 
veterinário, e use referências atualizadas como Plumb's Veterinary Drug Handbook.

**Dependências:** dosagem_medicamentos_model.dart, base de dados farmacológica 
veterinária

**Validação:** Comparar com manuais veterinários, verificar adequação das dosagens 
por espécie, testar contraindicações

---

### 3. [BUG] - Parsing de dosagem com tratamento inadequado de intervalos

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O controller faz split simples por "-" para intervalos sem validar 
espaços, formatos diferentes, ou casos extremos. O utils valida intervalo mas 
não verifica se min < max. Pode gerar cálculos incorretos com entradas malformadas.

**Prompt de Implementação:**

Implemente parser robusto para dosagens e intervalos. Adicione tratamento de 
diferentes formatos (10-20, 10 - 20, 10 a 20), validação de min < max, suporte 
a diferentes separadores decimais, normalização de entrada, e feedback claro 
para formatos inválidos. Considere usar regex para parsing mais confiável.

**Dependências:** dosagem_medicamentos_controller.dart, dosagem_medicamentos_utils.dart

**Validação:** Testar com diversos formatos de entrada, verificar handling de 
casos extremos, confirmar cálculos sempre corretos

---

### 4. [REFACTOR] - Dialog de alerta hardcoded no index

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O método _showAlertDialog no index.dart tem mais de 100 linhas 
hardcoded, tornando o arquivo muito longo. Todo o conteúdo está inline, 
dificultando manutenção, localização, e reutilização em outras calculadoras 
médicas.

**Prompt de Implementação:**

Extraia o dialog para widget dedicado MedicamentoAlertDialog na pasta widgets. 
Organize conteúdo por seções, torne localizável, adicione responsividade adequada, 
considere tornar o conteúdo configurável por tipo de medicamento ou contexto, 
e mantenha apenas chamada simples no index.

**Dependências:** index.dart, nova classe widgets/medicamento_alert_dialog.dart

**Validação:** Verificar funcionalidade mantida, melhor organização do código, 
facilidade de manutenção

---

## 🟡 Complexidade MÉDIA

### 5. [TODO] - Sistema de contraindicações não implementado

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Não há sistema para alertar sobre contraindicações dos medicamentos 
por espécie, idade, condições médicas, ou interações com outros medicamentos. 
Isso é crítico em farmacologia veterinária onde erros podem ser fatais.

**Prompt de Implementação:**

Desenvolva sistema abrangente de contraindicações farmacológicas. Crie base de 
dados de contraindicações por medicamento/espécie, sistema de alerta para 
condições médicas incompatíveis, verificação de interações medicamentosas, 
questionário sobre condições do paciente, e alertas específicos para situações 
de risco como gestação, lactação, idade avançada.

**Dependências:** dosagem_medicamentos_model.dart, sistema de perfil do paciente

**Validação:** Verificar alertas para contraindicações conhecidas, testar com 
casos clínicos complexos, comparar com literatura farmacológica

---

### 6. [REFACTOR] - Controller com responsabilidades misturadas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O controller mistura cálculo farmacológico, validação, parsing 
de entrada, e gerenciamento de estado da UI. Isso dificulta testes unitários, 
reutilização de lógica, e manutenção do código.

**Prompt de Implementação:**

Separe responsabilidades criando services especializados. Implemente 
PharmacologicalCalculationService para cálculos, DosageParsingService para 
parsing de entradas, MedicationValidationService para validações, e mantenha 
controller apenas como orquestrador. Use injeção de dependência para facilitar testes.

**Dependências:** dosagem_medicamentos_controller.dart, novos services especializados

**Validação:** Verificar separação clara de responsabilidades, facilidade de 
testes unitários, manutenibilidade melhorada

---

### 7. [OPTIMIZE] - Cálculo sempre usa média sem considerar casos clínicos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Para intervalos de dosagem, o sistema sempre usa a média sem 
considerar severidade da condição, resposta ao tratamento, ou outros fatores 
clínicos que influenciariam se usar dose mínima, máxima, ou intermediária.

**Prompt de Implementação:**

Implemente sistema inteligente de seleção de dosagem dentro do intervalo. 
Adicione opções para severidade da condição (leve, moderada, severa), consideração 
da resposta a tratamentos anteriores, ajuste por idade e condição do paciente, 
e sugestões contextuais para quando usar doses baixas vs altas dentro do range.

**Dependências:** dosagem_medicamentos_controller.dart, sistema de avaliação clínica

**Validação:** Testar com diferentes cenários clínicos, verificar adequação das 
sugestões, comparar com protocolos veterinários

---

### 8. [STYLE] - Inconsistência no uso do sistema de design

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O dialog usa ShadcnStyle em alguns lugares mas Colors hardcoded 
em outros (Colors.red.shade300, Colors.red.shade900). Não há consistência 
completa com o sistema de design existente.

**Prompt de Implementação:**

Padronize uso do sistema ShadcnStyle em todo o código. Substitua todas as cores 
hardcoded por tokens do design system, garanta suporte completo para modo 
escuro/claro, crie tokens específicos para alertas médicos se necessário, e 
mantenha consistência visual com outras calculadoras do app.

**Dependências:** index.dart, core/style/shadcn_style.dart

**Validação:** Verificar consistência visual completa, funcionamento em todos 
os temas, ausência de cores hardcoded

---

## 🟢 Complexidade BAIXA

### 9. [DOC] - Falta de referências farmacológicas para medicamentos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Dosagens dos medicamentos não possuem referências científicas 
documentadas. Isso dificulta validação por veterinários e pode gerar desconfiança 
na precisão dos dados fornecidos pela calculadora.

**Prompt de Implementação:**

Adicione documentação completa com referências farmacológicas veterinárias. 
Inclua fontes como Plumb's Veterinary Drug Handbook, Papich Handbook of Veterinary 
Drugs, guidelines de sociedades veterinárias, documente limitações conhecidas 
de cada medicamento, e crie bibliografia técnica para validação profissional.

**Dependências:** Documentação, comentários no código

**Validação:** Verificar precisão das referências, adequação das fontes científicas, 
utilidade para veterinários

---

### 10. [TEST] - Validação inadequada para valores extremos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** DosagemMedicamentosUtils.validateNumber apenas verifica se é 
positivo, mas não considera ranges realísticos para peso de animais, concentrações 
de medicamentos, ou dosagens biologicamente possíveis.

**Prompt de Implementação:**

Implemente validação contextual para cada tipo de campo. Para peso: ranges 
realísticos por espécie, para concentrações: valores típicos de medicamentos 
veterinários, para dosagens: limites farmacológicos seguros, e feedback específico 
para valores questionáveis vs impossíveis com sugestões de verificação.

**Dependências:** dosagem_medicamentos_utils.dart

**Validação:** Testar com valores extremos, verificar ranges apropriados para 
contexto veterinário, confirmar feedback útil

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação  
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída