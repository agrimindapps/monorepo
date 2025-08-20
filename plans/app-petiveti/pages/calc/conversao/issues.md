# Issues e Melhorias - conversao

## 📋 Índice Geral

### 🔴 Complexidade ALTA (3 issues)
1. [TODO] - Lógica de conversão não implementada
2. [REFACTOR] - ValueListenableBuilder excessivamente aninhados
3. [BUG] - Falta de validação para valores negativos/zeros

### 🟡 Complexidade MÉDIA (4 issues)
4. [REFACTOR] - Dialog de informações hardcoded no index
5. [OPTIMIZE] - Responsividade com cálculos repetitivos
6. [STYLE] - Inconsistência de cores e estilos hardcoded
7. [REFACTOR] - Model muito simples para conversões complexas

### 🟢 Complexidade BAIXA (2 issues)
8. [DOC] - Documentação ausente para tipos de conversão suportados
9. [TEST] - Falta de tratamento para formatação de números regionais

---

## 🔴 Complexidade ALTA

### 1. [TODO] - Lógica de conversão não implementada

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O controller possui apenas um exemplo de multiplicação por 2 como 
lógica de conversão. Não há implementação real de conversões entre unidades de 
medida (peso, volume, temperatura, etc.) que seriam úteis em medicina veterinária. 
A calculadora não fornece valor funcional aos usuários.

**Prompt de Implementação:**

Implemente sistema completo de conversões para medicina veterinária. Crie enum de 
tipos de conversão (peso, volume, temperatura, dosagem), mapeamento de fatores de 
conversão entre unidades, sistema de seleção de unidade origem/destino, validação 
de compatibilidade entre unidades, e formulas específicas para cada tipo. Mantenha 
precisão adequada para uso médico veterinário.

**Dependências:** conversao_model.dart, conversao_controller.dart, widgets de input

**Validação:** Testar conversões conhecidas, verificar precisão dos cálculos, 
confirmar unidades suportadas funcionam corretamente

---

### 2. [REFACTOR] - ValueListenableBuilder excessivamente aninhados

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** No index.dart há três ValueListenableBuilder aninhados escutando 
calculadoNotifier, resultadoNotifier e isLoadingNotifier separadamente. Isso causa 
performance ruim, códigocomplexo e rebuilds desnecessários. Cada mudança ativa 
toda a cadeia de listeners.

**Prompt de Implementação:**

Substitua os ValueListenableBuilders aninhados por uma solução otimizada. Use 
AnimatedBuilder com múltiplos Listenables, crie um ValueNotifier combinado que 
agregue todos os estados relevantes, ou implemente um estado consolidado. Mantenha 
a mesma reatividade mas reduza drasticamente os rebuilds da interface.

**Dependências:** index.dart, conversao_controller.dart

**Validação:** Verificar mesma reatividade visual, medir performance com flutter 
inspector, confirmar redução de rebuilds desnecessários

---

### 3. [BUG] - Falta de validação para valores negativos/zeros

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O método validarValor no controller apenas verifica se o valor é 
numérico, mas não valida se é apropriado para conversões (negativos podem ser 
inválidos para peso/volume, zero pode causar divisões problemáticas). Não há 
validação de range apropriado para uso veterinário.

**Prompt de Implementação:**

Adicione validação completa de valores considerando o contexto de conversões 
veterinárias. Implemente verificação de valores negativos conforme tipo de conversão, 
validação de ranges realísticos para cada unidade, tratamento de casos especiais 
como temperatura (que pode ser negativa), e feedback específico para cada tipo 
de erro de validação.

**Dependências:** conversao_controller.dart, conversao_model.dart

**Validação:** Testar com valores extremos, verificar feedback adequado para 
cada erro, confirmar aceitação apenas de valores válidos

---

## 🟡 Complexidade MÉDIA

### 4. [REFACTOR] - Dialog de informações hardcoded no index

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O método _showInfoDialog está implementado diretamente no index.dart 
com todo o UI hardcoded. Isso torna o arquivo muito longo, dificulta manutenção 
e reutilização do dialog. As informações são genéricas e pouco úteis.

**Prompt de Implementação:**

Extraia o dialog para um widget separado na pasta widgets. Crie ConversaoInfoDialog 
com informações específicas sobre os tipos de conversão suportados, exemplos 
práticos de uso veterinário, e design consistente com outros dialogs do app. 
Considere tornar o dialog dinâmico baseado no tipo de conversão selecionado.

**Dependências:** index.dart, nova pasta widgets/conversao_info_dialog.dart

**Validação:** Verificar dialog mantém funcionalidade, conteúdo é mais útil, 
código do index fica mais limpo

---

### 5. [OPTIMIZE] - Responsividade com cálculos repetitivos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** No build method do index.dart os cálculos de responsividade 
(screenWidth, isSmallScreen, isTablet, maxWidth, horizontalPadding) são executados 
a cada rebuild. Isso é ineficiente e pode impactar performance em devices mais 
lentos.

**Prompt de Implementação:**

Mova os cálculos de responsividade para um LayoutBuilder ou crie um widget 
responsivo reutilizável. Use computações cacheable ou extractors que evitem 
recálculos desnecessários. Considere criar um ResponsiveContainer widget que 
encapsule toda lógica de layout responsivo para reutilização em outras páginas.

**Dependências:** index.dart

**Validação:** Verificar que responsividade continua funcionando, medir performance 
durante rebuilds, confirmar redução de cálculos repetitivos

---

### 6. [STYLE] - Inconsistência de cores e estilos hardcoded

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Cores são hardcoded em vários lugares (Colors.blue, Colors.green, 
Colors.red) sem usar sistema de design. Estilos de texto, padding e bordas são 
definidos inline. Não há consistência com outras páginas do app nem suporte 
adequado para dark mode.

**Prompt de Implementação:**

Substitua todas as cores hardcoded pelo sistema de design ShadcnStyle. Extraia 
estilos repetitivos para constantes ou theme data. Garanta suporte adequado para 
dark/light mode usando Theme.of(context). Crie tokens de design específicos para 
esta calculadora se necessário.

**Dependências:** index.dart, core/style/shadcn_style.dart

**Validação:** Verificar consistência visual com outras páginas, testar em modo 
escuro, confirmar ausência de cores hardcoded

---

### 7. [REFACTOR] - Model muito simples para conversões complexas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** O ConversaoModel atual é muito básico com apenas controladores de 
texto e um resultado numérico. Para conversões reais seria necessário armazenar 
tipo de conversão, unidades selecionadas, histórico, configurações de precisão, 
e metadados sobre as conversões.

**Prompt de Implementação:**

Expanda o ConversaoModel para suportar conversões complexas. Adicione enums para 
tipos de conversão e unidades, propriedades para unidade origem/destino, sistema 
de histórico de conversões, configurações de precisão decimal, e metadados como 
timestamp e contexto da conversão. Mantenha backward compatibility.

**Dependências:** conversao_model.dart, conversao_controller.dart

**Validação:** Verificar que funcionalidade atual continua, novos recursos funcionam 
adequadamente, model suporta casos de uso complexos

---

## 🟢 Complexidade BAIXA

### 8. [DOC] - Documentação ausente para tipos de conversão suportados

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Não há documentação clara sobre quais tipos de conversão a calculadora 
deveria suportar, suas unidades, ou casos de uso específicos para medicina 
veterinária. O dialog de informações é muito genérico e pouco útil.

**Prompt de Implementação:**

Crie documentação completa dos tipos de conversão veterinária suportados. Inclua 
lista de unidades por categoria (peso, volume, temperatura, concentração), exemplos 
práticos de uso em clínicas veterinárias, tabelas de referência rápida, e casos 
especiais ou limitações das conversões.

**Dependências:** Documentação, dialog de informações

**Validação:** Verificar clareza da documentação, utilidade dos exemplos, 
cobertura de todos os tipos suportados

---

### 9. [TEST] - Falta de tratamento para formatação de números regionais

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O controller faz replaceAll(',', '.') de forma simplista para 
tratar decimais, mas não considera adequadamente formatação regional de números. 
Usuários podem ter problemas com separadores de milhares ou diferentes formatos 
de decimal conforme localização.

**Prompt de Implementação:**

Implemente tratamento robusto de formatação numérica regional. Use NumberFormat 
para parsing e formatação adequados à localização do usuário, trate separadores 
de milhares corretamente, valide entrada considerando formato local, e forneça 
feedback adequado para formatos inválidos.

**Dependências:** conversao_controller.dart, package intl

**Validação:** Testar com diferentes localizações, verificar parsing correto 
de números formatados, confirmar funcionamento internacional

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação  
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída