# Issues e Melhorias - fluidoterapia

## 📋 Índice Geral

### 🔴 Complexidade ALTA (3 issues)
1. [SECURITY] - Fórmula de fluidoterapia inadequada para uso veterinário
2. [FIXME] - Cálculo simplificado não considera fatores clínicos
3. [REFACTOR] - Dialog de informações hardcoded no index

### 🟡 Complexidade MÉDIA (4 issues)
4. [TODO] - Sistema de monitoramento e alertas não implementado
5. [BUG] - Cálculo fixo não considera tipos de equipo
6. [OPTIMIZE] - Falta diferenciação entre espécies e condições
7. [STYLE] - Uso inconsistente do sistema de design

### 🟢 Complexidade BAIXA (3 issues)
8. [DOC] - Ausência de referências veterinárias para fluidoterapia
9. [TEST] - Validação inadequada para valores extremos
10. [UI] - Info card não utilizado no resultado

---

## 🔴 Complexidade ALTA

### 1. [SECURITY] - Fórmula de fluidoterapia inadequada para uso veterinário

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** A fórmula atual `volumeTotal = peso * percentualHidratacao` está 
incorreta para fluidoterapia veterinária. Não considera necessidades de manutenção, 
déficit de hidratação, perdas anômalas, e diferenças fisiológicas entre espécies. 
Isso pode levar a subhidratação ou sobrecarga hídrica.

**Prompt de Implementação:**

Implemente fórmula completa de fluidoterapia veterinária. Calcule necessidades 
de manutenção (50-60ml/kg/dia para cães, 40-50ml/kg/dia para gatos), déficit 
de hidratação (peso × % desidratação × 10), perdas anômalas (vômito, diarreia), 
e volume total = manutenção + déficit + perdas. Adicione validação de limites 
seguros e alertas para volumes excessivos.

**Dependências:** fluidoterapia_model.dart, fluidoterapia_controller.dart, 
sistema de validação veterinária

**Validação:** Comparar com protocolos de fluidoterapia veterinária, testar 
com casos clínicos reais, verificar limites de segurança

---

### 2. [FIXME] - Cálculo simplificado não considera fatores clínicos

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O sistema não considera fatores críticos como grau de desidratação 
clínica, função renal, cardíaca, condições que alteram distribuição hídrica, 
temperatura corporal, e necessidades específicas por patologia.

**Prompt de Implementação:**

Desenvolva sistema abrangente de avaliação clínica. Implemente questionário 
sobre grau de desidratação (leve 5%, moderada 7-9%, severa >10%), avaliação 
de função renal/cardíaca, consideração de perdas patológicas específicas, 
ajustes por temperatura e ambiente, e modificações por condições como diabetes, 
insuficiência renal, ou cardíaca.

**Dependências:** fluidoterapia_model.dart, sistema de avaliação clínica, 
base de conhecimento veterinário

**Validação:** Testar com protocolos clínicos estabelecidos, verificar adequação 
para diferentes patologias, comparar com guidelines veterinários

---

### 3. [REFACTOR] - Dialog de informações hardcoded no index

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O método _showInfoDialog no index.dart tem mais de 60 linhas 
hardcoded tornando o arquivo extenso. O conteúdo está inline dificultando 
manutenção, localização, e reutilização.

**Prompt de Implementação:**

Extraia o dialog para widget dedicado FluidoterapiaInfoDialog na pasta widgets. 
Organize conteúdo por seções técnicas, torne localizável, adicione responsividade, 
considere conteúdo configurável por contexto de uso, e mantenha apenas chamada 
simples no index.

**Dependências:** index.dart, nova classe widgets/fluidoterapia_info_dialog.dart

**Validação:** Verificar funcionalidade mantida, melhor organização do código, 
facilidade de manutenção

---

## 🟡 Complexidade MÉDIA

### 4. [TODO] - Sistema de monitoramento e alertas não implementado

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Não há sistema para alertar sobre necessidade de monitoramento 
durante fluidoterapia, sinais de sobrecarga hídrica, ajustes de taxa conforme 
resposta do paciente, ou protocolos de segurança.

**Prompt de Implementação:**

Crie sistema inteligente de monitoramento de fluidoterapia. Implemente alertas 
para sinais de sobrecarga (frequência respiratória, edema), cronômetro para 
reavaliação periódica, checklist de monitoramento por espécie, sistema de 
ajuste de taxa baseado em resposta clínica, e protocolos de emergência.

**Dependências:** fluidoterapia_model.dart, sistema de alertas e notificações

**Validação:** Testar alertas com cenários clínicos, verificar protocolos de 
monitoramento adequados, comparar com práticas veterinárias

---

### 5. [BUG] - Cálculo fixo não considera tipos de equipo

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O cálculo assume fixamente macrogotas (20 gotas/ml) no código, 
mas apenas menciona microgotas no resultado. Não permite seleção do tipo de 
equipo usado, podendo causar erros de administração.

**Prompt de Implementação:**

Adicione seleção de tipo de equipo na interface. Implemente opções para 
macrogotas (20 gotas/ml), microgotas (60 gotas/ml), equipos específicos por 
fabricante, cálculo automático baseado na seleção, e alertas sobre diferenças 
críticas entre tipos de equipo.

**Dependências:** fluidoterapia_model.dart, input_card_widget.dart, 
result_card_widget.dart

**Validação:** Testar cálculos com diferentes tipos de equipo, verificar 
precisão das taxas calculadas, confirmar alertas adequados

---

### 6. [OPTIMIZE] - Falta diferenciação entre espécies e condições

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** O sistema não diferencia necessidades hídricas entre cães, gatos, 
animais exóticos, nem considera idade (filhotes vs adultos vs idosos), condições 
especiais como gestação, lactação, ou patologias específicas.

**Prompt de Implementação:**

Implemente sistema de diferenciação por espécie e condição. Adicione cálculos 
específicos para cães vs gatos, ajustes para filhotes (necessidades maiores), 
considerações para animais idosos (função renal reduzida), modificações para 
gestação/lactação, e protocolos específicos por condição médica.

**Dependências:** fluidoterapia_model.dart, sistema de seleção de espécie e condição

**Validação:** Comparar com protocolos específicos por espécie, testar com 
diferentes faixas etárias, verificar adequação para condições especiais

---

### 7. [STYLE] - Uso inconsistente do sistema de design

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O código mistura ShadcnStyle em alguns lugares com cores hardcoded 
(Colors.blue.shade50, Colors.green, Colors.white). Não há consistência completa 
com o sistema de design existente.

**Prompt de Implementação:**

Padronize uso do sistema ShadcnStyle em todo o código. Substitua todas as cores 
hardcoded por tokens do design system, garanta suporte completo para modo 
escuro/claro, crie tokens específicos para alertas médicos se necessário, e 
mantenha consistência visual com outras calculadoras.

**Dependências:** index.dart, input_card_widget.dart, result_card_widget.dart, 
core/style/shadcn_style.dart

**Validação:** Verificar consistência visual completa, funcionamento em todos 
os temas, ausência de cores hardcoded

---

## 🟢 Complexidade BAIXA

### 8. [DOC] - Ausência de referências veterinárias para fluidoterapia

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Os cálculos e recomendações não possuem referências científicas 
veterinárias documentadas. Isso compromete a confiabilidade clínica da 
calculadora para profissionais veterinários.

**Prompt de Implementação:**

Adicione documentação completa com referências em fluidoterapia veterinária. 
Inclua fontes como Fluid, Electrolyte, and Acid-Base Disorders in Small Animal 
Practice (DiBartolo), guidelines AAHA/AAFP, protocolos de emergência veterinária, 
documente limitações da calculadora, e crie bibliografia técnica para validação.

**Dependências:** Documentação, comentários no código

**Validação:** Verificar precisão das referências científicas, adequação das 
fontes veterinárias, utilidade para profissionais

---

### 9. [TEST] - Validação inadequada para valores extremos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** FluidoterapiaController.validateNumber apenas verifica se é 
positivo, mas não considera ranges realísticos para peso de animais, percentuais 
de hidratação biologicamente possíveis, ou períodos de administração seguros.

**Prompt de Implementação:**

Implemente validação contextual específica para fluidoterapia. Para peso: ranges 
por espécie (0.1-100kg), para percentual: valores fisiológicos (3-15%), para 
período: tempos seguros de administração (6-24h típico), e feedback específico 
para valores questionáveis vs perigosos.

**Dependências:** fluidoterapia_controller.dart

**Validação:** Testar com valores extremos, verificar ranges adequados para 
contexto veterinário, confirmar feedback clínico útil

---

### 10. [UI] - Info card não utilizado no resultado

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Existe info_card_widget.dart na pasta widgets mas não é utilizado 
em lugar algum. O controller tem showInfoCard = true mas não é implementado na UI, 
representando código morto.

**Prompt de Implementação:**

Remova código morto ou implemente funcionalidade do info card. Se for manter: 
integre info_card_widget.dart no result_card_widget.dart para mostrar informações 
contextuais, adicione toggle para mostrar/ocultar, e conecte com controller.showInfoCard. 
Se não for usar: remova arquivo e propriedade do controller.

**Dependências:** info_card_widget.dart, fluidoterapia_controller.dart, 
result_card_widget.dart

**Validação:** Verificar funcionalidade integrada ou limpeza completa do código morto

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação  
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída