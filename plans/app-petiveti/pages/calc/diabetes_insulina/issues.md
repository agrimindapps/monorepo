# Issues e Melhorias - diabetes_insulina

## 📋 Índice Geral

### 🔴 Complexidade ALTA (5 issues)
1. [SECURITY] - Cálculos médicos sem validação rigorosa
2. [BUG] - Lógica de cálculo inconsistente entre modos
3. [FIXME] - Valores hardcoded de fatores de insulina
4. [REFACTOR] - Dialog de informações hardcoded excessivamente longo
5. [BUG] - Tratamento inadequado de valores extremos de glicemia

### 🟡 Complexidade MÉDIA (3 issues)
6. [REFACTOR] - Lógica de negócio misturada com apresentação
7. [OPTIMIZE] - Controller com responsabilidade excessiva
8. [STYLE] - Inconsistência de cores e estilos hardcoded

### 🟢 Complexidade BAIXA (2 issues)
9. [DOC] - Falta documentação médica das fórmulas utilizadas
10. [TEST] - Validação insuficiente para valores de peso/glicemia

---

## 🔴 Complexidade ALTA

### 1. [SECURITY] - Cálculos médicos sem validação rigorosa

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** A calculadora realiza cálculos de dosagem de insulina sem validações 
médicas adequadas. Não há verificação de ranges seguros, validação cruzada de 
parâmetros, ou avisos para situações perigosas. Dosagens incorretas podem ser 
fatais para animais diabéticos.

**Prompt de Implementação:**

Implemente sistema robusto de validação médica para cálculos de insulina. Adicione 
verificação de ranges seguros por espécie/peso, validação cruzada entre glicemia 
e dosagem proposta, alertas obrigatórios para situações de risco, sistema de 
double-check para valores extremos, e logs de auditoria para cálculos realizados. 
Inclua disclaimers médicos obrigatórios antes de mostrar resultados.

**Dependências:** diabetes_insulina_controller.dart, diabetes_insulina_utils.dart, 
widgets de resultado

**Validação:** Testar com valores extremos, verificar alertas de segurança, 
confirmar ranges médicos adequados, validar disclaimers obrigatórios

---

### 2. [BUG] - Lógica de cálculo inconsistente entre modos

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O controller tem dois modos de cálculo (usarRegra e dose baseada 
em peso) mas a lógica se contradiz. Quando usarRegra=true ignora peso/espécie, 
mas depois pode usar temDoseAnterior que sobrescreve tudo. A precedência entre 
os diferentes métodos de cálculo não está clara.

**Prompt de Implementação:**

Refatore a lógica de cálculo para ter precedência clara e consistente. Defina 
hierarquia: dose anterior > regra específica > cálculo por peso. Separe cada 
modo em métodos específicos, valide incompatibilidades entre modos, adicione 
logs de qual método foi usado, e forneça feedback claro ao usuário sobre qual 
cálculo está sendo aplicado.

**Dependências:** diabetes_insulina_controller.dart, diabetes_insulina_model.dart

**Validação:** Testar todas as combinações de modos, verificar consistência 
dos resultados, confirmar feedback adequado ao usuário

---

### 3. [FIXME] - Valores hardcoded de fatores de insulina

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Fatores de insulina (0.5 U/kg cães, 0.25 U/kg gatos) estão 
hardcoded no model. Não há fonte médica documentada, variação por idade/condição, 
ou possibilidade de ajuste. Fatores podem estar desatualizados ou inadequados 
para diferentes protocolos veterinários.

**Prompt de Implementação:**

Crie sistema configurável de fatores de insulina baseado em literatura veterinária. 
Implemente fatores variáveis por idade, peso, condição do animal, protocolo 
utilizado. Adicione referências médicas para cada fator, sistema de versionamento 
de protocolos, e possibilidade de customização por veterinário. Documente fontes 
científicas utilizadas.

**Dependências:** diabetes_insulina_model.dart, nova classe de protocolos médicos

**Validação:** Verificar fontes científicas, testar com diferentes protocolos, 
confirmar flexibilidade do sistema

---

### 4. [REFACTOR] - Dialog de informações hardcoded excessivamente longo

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O método _showInfoDialog no index.dart tem mais de 180 linhas 
hardcoded, tornando o arquivo ilegível. Todo o conteúdo está inline, dificultando 
manutenção, tradução, e reutilização. O dialog também não é responsivo adequadamente.

**Prompt de Implementação:**

Extraia o dialog para widget dedicado na pasta widgets. Crie DiabetesInsulinaInfoDialog 
com conteúdo estruturado em seções separadas, sistema de navegação por abas ou 
expansible panels, responsividade adequada para diferentes tamanhos de tela, e 
possibilidade de localização. Mantenha apenas a chamada simples no index.

**Dependências:** index.dart, nova classe widgets/diabetes_insulina_info_dialog.dart

**Validação:** Verificar funcionalidade mantida, melhor organização do conteúdo, 
responsividade adequada

---

### 5. [BUG] - Tratamento inadequado de valores extremos de glicemia

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O sistema trata glicemia < 70 como emergência mas ainda calcula 
e recomenda dosagem de insulina, o que pode ser perigoso. Não há bloqueio de 
cálculo para hipoglicemia severa nem redirecionamento para atendimento veterinário 
imediato.

**Prompt de Implementação:**

Implemente sistema de bloqueio para valores críticos de glicemia. Para hipoglicemia 
severa (< 70), interrompa cálculos e mostre apenas protocolo de emergência. Para 
hiperglicemia extrema (> 400), adicione warnings obrigatórios e recomendação de 
hospitalização. Crie fluxos específicos para cada faixa crítica com protocolos 
veterinários adequados.

**Dependências:** diabetes_insulina_controller.dart, diabetes_insulina_utils.dart

**Validação:** Testar com valores extremos, verificar bloqueios adequados, 
confirmar protocolos de emergência corretos

---

## 🟡 Complexidade MÉDIA

### 6. [REFACTOR] - Lógica de negócio misturada com apresentação

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** O controller contém lógica de geração de recomendações textuais 
(_gerarRecomendacoes) que deveria estar em um service separado. Isso dificulta 
testes, reutilização, e internacionalização das recomendações médicas.

**Prompt de Implementação:**

Extraia lógica de recomendações para DiabetesRecommendationService. Separe 
cálculo matemático de geração de texto, crie sistema estruturado de recomendações 
por categoria (monitoramento, emergência, geral), implemente suporte a 
internacionalização, e torne as recomendações configuráveis por protocolo médico.

**Dependências:** diabetes_insulina_controller.dart, novo service de recomendações

**Validação:** Verificar separação adequada de responsabilidades, facilidade 
de testes, manutenção simplificada

---

### 7. [OPTIMIZE] - Controller com responsabilidade excessiva

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O DiabetesInsulinaController gerencia estado da UI, validação, 
cálculos médicos, e geração de recomendações. Isso viola o princípio de 
responsabilidade única e dificulta testes unitários e manutenção.

**Prompt de Implementação:**

Divida o controller em múltiplas classes especializadas. Crie DiabetesCalculationService 
para cálculos, DiabetesValidationService para validações médicas, 
DiabetesStateManager para gerenciamento de estado. Mantenha controller apenas 
como orquestrador entre UI e services. Use injeção de dependência para facilitar testes.

**Dependências:** diabetes_insulina_controller.dart, novos services especializados

**Validação:** Verificar separação clara de responsabilidades, facilidade de 
testes unitários, manutenibilidade melhorada

---

### 8. [STYLE] - Inconsistência de cores e estilos hardcoded

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Colors hardcoded em index.dart e utils (Colors.red, Colors.green, 
Colors.orange) sem usar sistema de design. Não há consistência com outras páginas 
nem suporte adequado para modo escuro. Estilos são definidos inline repetitivamente.

**Prompt de Implementação:**

Substitua cores hardcoded pelo sistema ShadcnStyle existente. Crie tokens de 
design específicos para status médicos (normal, alerta, emergência), garanta 
suporte adequado para modo escuro, extraia estilos repetitivos para constantes, 
e mantenha consistência visual com outras calculadoras do app.

**Dependências:** index.dart, diabetes_insulina_utils.dart, core/style/shadcn_style.dart

**Validação:** Verificar consistência visual, funcionamento em modo escuro, 
ausência de cores hardcoded

---

## 🟢 Complexidade BAIXA

### 9. [DOC] - Falta documentação médica das fórmulas utilizadas

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Não há documentação das fórmulas médicas utilizadas, referências 
científicas, ou justificativa para os fatores de correção aplicados. Isso 
dificulta validação médica e confiança dos veterinários na ferramenta.

**Prompt de Implementação:**

Adicione documentação completa das fórmulas médicas utilizadas. Inclua referências 
científicas para cada fator, explicação dos algoritmos de ajuste, limitações 
conhecidas da calculadora, e casos onde não deve ser utilizada. Crie documento 
técnico separado com validação veterinária dos cálculos.

**Dependências:** Documentação, comentários no código

**Validação:** Verificar clareza da documentação, precisão das referências, 
utilidade para veterinários

---

### 10. [TEST] - Validação insuficiente para valores de peso/glicemia

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** DiabetesInsulinaUtils.validateNumber apenas verifica se é número 
positivo, mas não valida ranges realísticos para peso de animais ou valores 
de glicemia biologicamente possíveis. Aceita valores absurdos que podem causar 
cálculos incorretos.

**Prompt de Implementação:**

Implemente validação específica para cada tipo de valor. Para peso: ranges 
realísticos por espécie (0.5-100kg cães, 0.5-15kg gatos). Para glicemia: valores 
biologicamente possíveis (10-800 mg/dL). Adicione feedback específico para 
valores fora do range normal vs impossíveis, e sugestões de verificação da medição.

**Dependências:** diabetes_insulina_utils.dart

**Validação:** Testar com valores extremos, verificar ranges apropriados, 
confirmar feedback adequado

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação  
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída