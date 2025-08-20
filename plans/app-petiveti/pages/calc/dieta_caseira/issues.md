# Issues e Melhorias - dieta_caseira

## 📋 Índice Geral

### 🔴 Complexidade ALTA (4 issues)
1. [FIXME] - Cálculos nutricionais simplificados demais
2. [SECURITY] - Valores nutricionais hardcoded podem estar desatualizados
3. [BUG] - Lógica de distribuição de alimentos inadequada
4. [REFACTOR] - Dialog de informações excessivamente longo no index

### 🟡 Complexidade MÉDIA (4 issues)
5. [TODO] - Sistema de suplementação não implementado
6. [REFACTOR] - Controller com múltiplas responsabilidades
7. [OPTIMIZE] - Cálculos desnecessários a cada notifyListeners
8. [STYLE] - Inconsistência no uso do sistema de design

### 🟢 Complexidade BAIXA (2 issues)
9. [DOC] - Falta de referências científicas para fatores nutricionais
10. [TEST] - Validação inadequada de ranges de peso e idade

---

## 🔴 Complexidade ALTA

### 1. [FIXME] - Cálculos nutricionais simplificados demais

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Os cálculos de necessidade calórica usam apenas RER * fator, ignorando 
fatores importantes como BCS (Body Condition Score), metabolismo individual, 
condições médicas específicas, e necessidades de micronutrientes. A distribuição 
de alimentos é simplista e não considera biodisponibilidade de nutrientes.

**Prompt de Implementação:**

Implemente sistema de cálculo nutricional veterinário mais robusto. Adicione 
cálculo de BCS, ajustes para condições médicas específicas, consideração de 
biodisponibilidade de nutrientes, validação de adequação nutricional AAFCO, 
sistema de micronutrientes essenciais, e alertas para deficiências potenciais. 
Use referências científicas atualizadas.

**Dependências:** dieta_caseira_controller.dart, dieta_caseira_model.dart, nova 
classe de cálculos nutricionais

**Validação:** Comparar com tabelas AAFCO, testar com casos clínicos conhecidos, 
verificar adequação nutricional dos resultados

---

### 2. [SECURITY] - Valores nutricionais hardcoded podem estar desatualizados

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Valores nutricionais dos alimentos estão hardcoded no model sem 
fonte ou data. Podem estar desatualizados, incorretos, ou não representar 
variações regionais. Não há sistema de atualização nem verificação de precisão 
dos dados nutricionais utilizados.

**Prompt de Implementação:**

Crie sistema de dados nutricionais baseado em fontes confiáveis como USDA Food Data. 
Implemente versionamento de dados nutricionais, sistema de atualização via API, 
validação cruzada com múltiplas fontes, consideração de variações por preparo 
e origem, e rastreabilidade das fontes dos dados utilizados nos cálculos.

**Dependências:** dieta_caseira_model.dart, sistema de dados externos, API de 
nutrição

**Validação:** Verificar fontes dos dados, testar precisão com análises laboratoriais, 
confirmar atualização adequada

---

### 3. [BUG] - Lógica de distribuição de alimentos inadequada

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O método _calcularQuantidadesAlimentos usa proporções fixas 
(0.5, 0.3, 0.2) para distribuir macronutrientes entre alimentos sem considerar 
palatabilidade, digestibilidade, ou restrições alimentares. Pode gerar dietas 
nutricionalmente inadequadas ou não palatáveis.

**Prompt de Implementação:**

Desenvolva algoritmo inteligente de distribuição de alimentos. Considere 
palatabilidade por espécie, digestibilidade dos ingredientes, restrições 
alimentares por condição médica, variação na composição dos alimentos, 
balanceamento de aminoácidos essenciais, e preferências alimentares típicas. 
Implemente múltiplas opções de formulação.

**Dependências:** dieta_caseira_controller.dart, sistema de restrições alimentares

**Validação:** Testar palatabilidade das dietas geradas, verificar adequação 
nutricional, confirmar viabilidade prática

---

### 4. [REFACTOR] - Dialog de informações excessivamente longo no index

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O método _showInfoDialog no index.dart tem mais de 160 linhas 
hardcoded, tornando o arquivo muito longo e difícil de manter. Todo o conteúdo 
está inline, dificultando localização, atualização, e reutilização em outros 
contextos.

**Prompt de Implementação:**

Extraia o dialog para widget dedicado DietaCaseiraInfoDialog na pasta widgets. 
Organize conteúdo em seções estruturadas, implemente navegação por abas ou 
expansible sections, adicione responsividade adequada, torne o conteúdo 
localizável, e mantenha apenas chamada simples no index. Considere conteúdo 
dinâmico baseado no contexto.

**Dependências:** index.dart, nova classe widgets/dieta_caseira_info_dialog.dart

**Validação:** Verificar funcionalidade mantida, organização melhorada do 
conteúdo, facilidade de manutenção

---

## 🟡 Complexidade MÉDIA

### 5. [TODO] - Sistema de suplementação não implementado

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Dietas caseiras requerem suplementação adequada de vitaminas, 
minerais, e outros nutrientes essenciais. Não há sistema para calcular e 
recomendar suplementos necessários, o que pode resultar em deficiências 
nutricionais graves.

**Prompt de Implementação:**

Desenvolva sistema de recomendação de suplementação para dietas caseiras. 
Calcule necessidades de vitaminas e minerais por espécie/idade/condição, 
identifique deficiências potenciais na dieta calculada, recomende suplementos 
específicos com dosagens, considere interações entre nutrientes, e forneça 
alternativas comerciais validadas.

**Dependências:** dieta_caseira_controller.dart, banco de dados de suplementos

**Validação:** Comparar com diretrizes AAFCO, verificar adequação das dosagens, 
testar identificação de deficiências

---

### 6. [REFACTOR] - Controller com múltiplas responsabilidades

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** O DietaCaseiraController gerencia validação, cálculos nutricionais, 
geração de recomendações, e estado da UI. Isso viola o princípio de responsabilidade 
única e dificulta testes unitários e manutenção do código.

**Prompt de Implementação:**

Divida o controller em services especializados. Crie NutritionalCalculationService 
para cálculos, DietValidationService para validações, RecommendationService 
para geração de recomendações, e mantenha controller apenas como orquestrador. 
Use injeção de dependência para facilitar testes e manutenção.

**Dependências:** dieta_caseira_controller.dart, novos services especializados

**Validação:** Verificar separação clara de responsabilidades, facilidade de 
testes unitários, manutenibilidade melhorada

---

### 7. [OPTIMIZE] - Cálculos desnecessários a cada notifyListeners

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Métodos como setEspecie, setEstadoFisiologico chamam notifyListeners 
imediatamente, potencialmente causando rebuilds desnecessários antes de todos 
os campos estarem preenchidos. Isso pode impactar performance especialmente 
em devices mais lentos.

**Prompt de Implementação:**

Implemente sistema de notificação inteligente que evita rebuilds desnecessários. 
Use debouncing para agrupar mudanças rápidas, notifique apenas quando cálculo 
é realmente necessário, considere usar ValueNotifier específicos para diferentes 
seções da UI, e implemente dirty flag para identificar quando recálculo é necessário.

**Dependências:** dieta_caseira_controller.dart

**Validação:** Medir performance antes/depois, verificar reduçã o de rebuilds, 
confirmar responsividade mantida

---

### 8. [STYLE] - Inconsistência no uso do sistema de design

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O dialog usa ShadcnStyle em alguns lugares mas Colors hardcoded 
em outros (Colors.amber.shade900, Colors.blue). Não há consistência completa 
com o sistema de design nem suporte adequado para todas as variações de tema.

**Prompt de Implementação:**

Padronize uso do sistema ShadcnStyle em todo o código. Substitua todas as cores 
hardcoded por tokens do design system, garanta suporte completo para modo 
escuro/claro, crie tokens específicos para estados nutricionais se necessário, 
e mantenha consistência visual com outras calculadoras do app.

**Dependências:** index.dart, core/style/shadcn_style.dart

**Validação:** Verificar consistência visual completa, funcionamento em todos 
os temas, ausência de cores hardcoded

---

## 🟢 Complexidade BAIXA

### 9. [DOC] - Falta de referências científicas para fatores nutricionais

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Fatores energéticos, proporções de macronutrientes, e outros 
valores utilizados nos cálculos não possuem referências científicas documentadas. 
Isso dificulta validação médica e confiança dos veterinários na ferramenta.

**Prompt de Implementação:**

Adicione documentação completa com referências científicas para todos os fatores 
utilizados. Inclua fontes AAFCO, NRC, e literatura veterinária relevante, 
documente limitações conhecidas dos cálculos, adicione disclaimers apropriados, 
e crie documento técnico separado com justificativa científica para cada valor utilizado.

**Dependências:** Documentação, comentários no código

**Validação:** Verificar precisão das referências, adequação das fontes, 
utilidade para veterinários

---

### 10. [TEST] - Validação inadequada de ranges de peso e idade

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Validação apenas verifica se valores são numéricos, mas não 
considera ranges biologicamente realísticos para peso e idade de animais. 
Aceita valores absurdos que podem gerar cálculos nutricionais incorretos.

**Prompt de Implementação:**

Implemente validação específica para ranges realísticos. Para peso: limites 
por espécie (0.5-80kg cães, 0.5-15kg gatos), para idade: limites biologicamente 
possíveis por espécie, validação cruzada peso/idade para detectar inconsistências, 
e feedback específico para valores fora do normal vs impossíveis.

**Dependências:** dieta_caseira_controller.dart

**Validação:** Testar com valores extremos, verificar ranges apropriados por 
espécie, confirmar feedback adequado

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação  
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída