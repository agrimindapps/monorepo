# Issues e Melhorias - gestacao_parto

## 📋 Índice Geral

### 🔴 Complexidade ALTA (3 issues)
1. [REFACTOR] - Cálculo de idade fetal por ultrassom impreciso e limitado
2. [SECURITY] - Validação inadequada de dados de entrada críticos
3. [PERFORMANCE] - Código desnecessário executado a cada notifyListeners

### 🟡 Complexidade MÉDIA (4 issues)
4. [BUG] - Estado inconsistente na seleção de raça no formulário
5. [TODO] - Sistema de alertas gestacionais não implementado
6. [OPTIMIZE] - Cálculos veterinários simplificados demais
7. [STYLE] - Inconsistência no sistema de cores e design

### 🟢 Complexidade BAIXA (3 issues)
8. [UI] - Método de cálculo por ultrassom limitado a apenas cães e gatos
9. [DOC] - Falta documentação científica das fases gestacionais
10. [TEST] - Widget InfoCard não utilizado efetivamente

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Cálculo de idade fetal por ultrassom impreciso e limitado

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O método _estimarIdadeFetosCao() usa apenas 7 pontos de referência fixos (10mm-90mm) com diferença absoluta simples, enquanto _estimarIdadeRetosGato() tem apenas 4 faixas muito amplas (≤10mm=30dias). Isso é inadequado para uso veterinário real, onde precisão é crítica para diagnósticos gestacionais.

**Prompt de Implementação:**

Reimplemente o sistema de estimativa fetal por ultrassom com base científica veterinária. Adicione curvas de crescimento específicas por espécie baseadas em literatura, implemente interpolação logarítmica ou polinomial ao invés de diferença absoluta, adicione medidas múltiplas (diâmetro biparietal, comprimento vértice-sacro, diâmetro torácico), considere margens de erro e intervalos de confiança, e integre tabelas gestacionais de referência clínica veterinária.

**Dependências:** gestacao_parto_controller.dart, gestacao_parto_model.dart, base de dados ultrassonográfica veterinária

**Validação:** Comparar com tabelas de crescimento fetal veterinárias, testar precisão com casos clínicos reais, verificar adequação das margens de erro

---

### 2. [SECURITY] - Validação inadequada de dados de entrada críticos

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O sistema permite datas futuras para acasalamento/ultrassom, não valida tamanhos de fetos biologicamente impossíveis (valores negativos ou extremamente altos), não verifica consistência temporal entre datas, e pode gerar cálculos perigosos para tomada de decisão veterinária.

**Prompt de Implementação:**

Implemente validação robusta para segurança clínica veterinária. Adicione bloqueio de datas futuras para acasalamento/ultrassom, validação de ranges biológicos para tamanho fetal por espécie (mínimo 5mm, máximo 150mm para cães), verificação de consistência temporal (ultrassom posterior ao acasalamento estimado), alertas para gestações prolongadas (risco obstétrico), e sistema de avisos para valores limítrofes que requerem atenção veterinária.

**Dependências:** gestacao_parto_controller.dart, sistema de validação de entrada, alertas de segurança

**Validação:** Testar com valores extremos e datas impossíveis, verificar bloqueio adequado de entradas perigosas, confirmar alertas de segurança apropriados

---

### 3. [PERFORMANCE] - Código desnecessário executado a cada notifyListeners

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** O controller chama notifyListeners() em todos os métodos de atualização, mesmo quando não há mudança real de estado. Os métodos copyWith() criam novas instâncias desnecessariamente, e cálculos são refeitos mesmo quando dados base não mudaram, impactando performance em dispositivos mais lentos.

**Prompt de Implementação:**

Otimize o padrão de notificação e atualização de estado. Implemente verificação de mudança real antes do notifyListeners(), adicione cache para cálculos complexos, use lazy loading para cálculos pesados, implemente debounce para atualizações rápidas consecutivas, e otimize o método copyWith() para evitar criações desnecessárias de objetos.

**Dependências:** gestacao_parto_controller.dart, gestacao_parto_model.dart

**Validação:** Medir performance antes/depois, verificar redução de rebuilds desnecessários, confirmar manutenção da funcionalidade

---

## 🟡 Complexidade MÉDIA

### 4. [BUG] - Estado inconsistente na seleção de raça no formulário

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Médio | **Benefício:** Alto

**Descrição:** No InputFormWidget linha 57, a seleção de raça atualiza diretamente model.racaSelecionada sem usar o controller e sem notifyListeners(), causando inconsistência de estado. O controller reseta racaSelecionada ao mudar espécie, mas a UI pode não refletir imediatamente.

**Prompt de Implementação:**

Corrija o fluxo de atualização de estado para raça. Crie método atualizarRaca() no controller similar aos outros, remova atualização direta do model na UI, implemente reset adequado da raça quando espécie muda, garanta sincronização entre controller e UI, e adicione validação de raça válida para espécie selecionada.

**Dependências:** gestacao_parto_controller.dart, input_form_widget.dart

**Validação:** Testar mudanças de espécie e verificar reset de raça, confirmar sincronização UI-controller, verificar ausência de estados inconsistentes

---

### 5. [TODO] - Sistema de alertas gestacionais não implementado

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** A calculadora determina fases gestacionais mas não oferece alertas proativos, marcos veterinários importantes, recomendações de exames periódicos, ou preparativos específicos para cada fase da gestação.

**Prompt de Implementação:**

Desenvolva sistema completo de alertas gestacionais veterinários. Implemente notificações para marcos críticos (implantação, organogênese, crescimento fetal), alertas para exames recomendados (ultrassom confirmatório, hemograma, radiografia pré-parto), lembretes de cuidados nutricionais e ambientais, sistema de contagem regressiva para parto, e integração com calendário para acompanhamento veterinário.

**Dependências:** Sistema de notificações, base de conhecimento gestacional veterinária, interface de calendário

**Validação:** Verificar adequação dos marcos por espécie, testar funcionalidade de alertas, comparar com protocolos gestacionais veterinários

---

### 6. [OPTIMIZE] - Cálculos veterinários simplificados demais

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O sistema usa períodos fixos por espécie sem considerar variações raciais significativas (Bulldogs vs Galgos têm gestações diferentes), idade da fêmea, número de filhotes, condições ambientais, e histórico reprodutivo que afetam duração gestacional.

**Prompt de Implementação:**

Implemente cálculos gestacionais veterinários mais precisos. Adicione ajustes raciais mais específicos baseados em literatura, considere idade da fêmea (primíparas vs pluríparas), estimativa de número de filhotes (gestações múltiplas são mais curtas), fatores de risco (diabetes, obesidade), condições ambientais (temperatura, estresse), e apresente ranges de variação ao invés de datas fixas.

**Dependências:** gestacao_parto_model.dart, base de dados reprodutiva veterinária avançada

**Validação:** Comparar precisão com casos clínicos reais, verificar adequação dos ajustes raciais, validar ranges com literatura especializada

---

### 7. [STYLE] - Inconsistência no sistema de cores e design

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O código mistura ShadcnStyle com colors hardcoded (Colors.blue.shade50, Colors.yellow.shade50, Colors.red), não há padronização completa do design system, e algumas cores não consideram adequadamente o modo escuro.

**Prompt de Implementação:**

Padronize uso do ShadcnStyle em toda a interface. Substitua todas as colors hardcoded por tokens do design system, crie tokens específicos para alertas gestacionais (sucesso, atenção, emergência), garanta suporte completo para modo escuro/claro, mantenha consistência com outras calculadoras veterinárias, e documente padrões de cor para contextos específicos.

**Dependências:** result_card_widget.dart, core/style/shadcn_style.dart, index.dart

**Validação:** Verificar consistência visual completa, funcionamento adequado em todos os temas, ausência de cores hardcoded

---

## 🟢 Complexidade BAIXA

### 8. [UI] - Método de cálculo por ultrassom limitado a apenas cães e gatos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** A calculadora restringe ultrassom apenas para cães e gatos, mas outras espécies (coelhos, hamsters) também podem ter ultrassom gestacional em clínicas especializadas. Isso limita utilidade da ferramenta para veterinários de animais exóticos.

**Prompt de Implementação:**

Expanda opção de ultrassom para outras espécies quando disponível. Adicione dados ultrassonográficos para coelhos (gestação curta mas ultrassom viável), implemente avisos sobre limitações por espécie, adicione referências específicas para ultrassom em animais pequenos, e mantenha opção desabilitada apenas quando tecnicamente inviável.

**Dependências:** gestacao_parto_model.dart, input_form_widget.dart

**Validação:** Verificar adequação da expansão por espécie, confirmar avisos apropriados sobre limitações, validar com literatura de ultrassom em animais exóticos

---

### 9. [DOC] - Falta documentação científica das fases gestacionais

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** As descrições das fases gestacionais no model não possuem referências científicas veterinárias. Informações como "Fetos visíveis em ultrassom por volta do dia 25-30" precisam de fundamentação técnica para uso profissional.

**Prompt de Implementação:**

Adicione documentação científica completa para todas as fases gestacionais. Inclua referências como "Canine and Feline Reproduction and Neonatology", "Large Animal Theriogenology", guidelines de sociedades reprodutivas veterinárias, documente variações conhecidas por raça/espécie, adicione comentários com fontes no código, e crie glossário técnico para termos especializados.

**Dependências:** gestacao_parto_model.dart, documentação técnica

**Validação:** Verificar precisão das referências científicas, adequação para uso veterinário profissional, completude da documentação técnica

---

### 10. [TEST] - Widget InfoCard não utilizado efetivamente

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** O InfoCardWidget existe e é importado no index.dart, mas não é usado na interface. O model tem showInfoCard e controller tem toggleInfoCard(), mas a funcionalidade não está implementada, representando código parcialmente morto.

**Prompt de Implementação:**

Complete implementação do InfoCard ou remova funcionalidade desnecessária. Se manter: integre widget na interface com informações contextuais sobre gestação da espécie selecionada, implemente toggle funcional, adicione conteúdo educativo relevante. Se remover: limpe código relacionado do model, controller e imports desnecessários.

**Dependências:** info_card_widget.dart, gestacao_parto_controller.dart, gestacao_parto_model.dart, index.dart

**Validação:** Verificar implementação completa integrada ou limpeza total do código relacionado, confirmar ausência de funcionalidades parciais

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação  
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída