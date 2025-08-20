# Issues e Melhorias - dosagem_anestesico

## 📋 Índice Geral

### 🔴 Complexidade ALTA (5 issues)
1. [SECURITY] - Dados anestésicos incompletos e potencialmente perigosos
2. [BUG] - Inconsistência entre anestésicos disponíveis e concentrações
3. [FIXME] - Cálculos simplificados ignoram fatores críticos de segurança
4. [REFACTOR] - Dois dialogs hardcoded muito longos no index
5. [SECURITY] - Ausência de validação de ranges seguros de dosagem

### 🟡 Complexidade MÉDIA (3 issues)
6. [TODO] - Sistema de interações medicamentosas não implementado
7. [REFACTOR] - Controller mistura lógica de negócio com formatação
8. [OPTIMIZE] - Compartilhamento gera texto longo desnecessariamente

### 🟢 Complexidade BAIXA (2 issues)
9. [DOC] - Falta de referências farmacológicas para dosagens
10. [TEST] - Validação inadequada de peso para contexto anestésico

---

## 🔴 Complexidade ALTA

### 1. [SECURITY] - Dados anestésicos incompletos e potencialmente perigosos

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O model possui dados anestésicos muito limitados e incompletos. Para 
cães há apenas 3 opções, para gatos apenas 1. Concentrações incluem medicamentos 
não listados nas dosagens. Faltam anestésicos comuns como isoflurano, sevoflurano. 
Isso pode levar a uso inadequado ou doses perigosas.

**Prompt de Implementação:**

Expanda significativamente o banco de dados de anestésicos veterinários. Inclua 
anestésicos inalatórios, intravenosos, e locais comumente usados, adicione dosagens 
específicas por idade, peso, estado físico (ASA), implemente sistema de protocolos 
anestésicos combinados, adicione contraindicações detalhadas por condição médica, 
e use referências farmacológicas veterinárias atualizadas.

**Dependências:** dosagem_anestesicos_model.dart, literatura farmacológica veterinária

**Validação:** Comparar com manuais de anestesia veterinária, verificar completude 
dos dados, validar dosagens com especialistas

---

### 2. [BUG] - Inconsistência entre anestésicos disponíveis e concentrações

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O map de concentrações inclui 10 medicamentos mas o map de anestésicos 
por espécie tem apenas alguns deles. Isso pode causar crashes ou cálculos incorretos 
quando usuário seleciona anestésico que não tem dosagem definida para a espécie, 
mas tem concentração cadastrada.

**Prompt de Implementação:**

Sincronize completamente os dados de anestésicos, dosagens e concentrações. 
Implemente validação que garanta consistência entre todos os maps, adicione 
verificação de integridade dos dados na inicialização, crie sistema de 
disponibilidade por espécie que previna seleções inválidas, e adicione logs 
de auditoria para identificar inconsistências.

**Dependências:** dosagem_anestesicos_model.dart, dosagem_anestesicos_controller.dart

**Validação:** Testar todas as combinações espécie/anestésico, verificar ausência 
de crashes, confirmar dados sempre consistentes

---

### 3. [FIXME] - Cálculos simplificados ignoram fatores críticos de segurança

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O cálculo usa apenas peso e dosagem média, ignorando fatores críticos 
como estado físico (ASA), idade, condições pré-existentes, jejum, medicações 
concomitantes. Usa sempre a média da faixa de dosagem sem considerar fatores 
individuais que podem requerer ajustes.

**Prompt de Implementação:**

Implemente sistema de cálculo anestésico mais seguro considerando classificação 
ASA, ajustes por idade (pediátrico, geriátrico), fatores de risco cardiovascular 
e respiratório, interações medicamentosas conhecidas, ajustes para condições 
especiais (insuficiência hepática, renal), e sistema de alertas para combinações 
de alto risco.

**Dependências:** dosagem_anestesicos_controller.dart, novo sistema de avaliação 
de riscos

**Validação:** Testar com casos clínicos conhecidos, verificar alertas de segurança, 
comparar com protocolos anestésicos estabelecidos

---

### 4. [REFACTOR] - Dois dialogs hardcoded muito longos no index

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Os métodos _showInfoDialog e _showAlertDialog no index.dart somam 
mais de 200 linhas hardcoded, tornando o arquivo muito longo e difícil de manter. 
Todo conteúdo está inline, dificultando manutenção, localização, e reutilização.

**Prompt de Implementação:**

Extraia ambos os dialogs para widgets dedicados na pasta widgets. Crie 
AnestesicoInfoDialog e AnestesicoAlertDialog com conteúdo estruturado, 
responsividade adequada, possibilidade de localização, e organização clara 
por seções. Mantenha apenas chamadas simples no index.

**Dependências:** index.dart, novos widgets de dialog

**Validação:** Verificar funcionalidade mantida, melhor organização do código, 
facilidade de manutenção

---

### 5. [SECURITY] - Ausência de validação de ranges seguros de dosagem

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Não há validação se o peso inserido resulta em dosagens seguras. 
Para animais muito pequenos ou muito grandes, os cálculos podem gerar volumes 
perigosos. Não há alertas para dosagens que excedem limites seguros estabelecidos.

**Prompt de Implementação:**

Implemente sistema robusto de validação de segurança anestésica. Adicione 
verificação de dosagens máximas absolutas por medicamento, alertas para volumes 
muito pequenos (< 0.1ml) ou muito grandes, validação de peso vs dosagem para 
detectar erros potenciais, sistema de confirmação dupla para dosagens próximas 
aos limites, e bloqueio para cálculos claramente perigosos.

**Dependências:** dosagem_anestesicos_controller.dart, sistema de validação de 
segurança

**Validação:** Testar com pesos extremos, verificar alertas adequados, confirmar 
bloqueio de dosagens perigosas

---

## 🟡 Complexidade MÉDIA

### 6. [TODO] - Sistema de interações medicamentosas não implementado

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Não há sistema para alertar sobre interações entre anestésicos 
ou com outros medicamentos que o animal possa estar usando. Isso é crítico em 
anestesia veterinária onde combinações inadequadas podem ser fatais.

**Prompt de Implementação:**

Desenvolva sistema de verificação de interações medicamentosas. Crie banco de 
dados de interações conhecidas entre anestésicos, sistema de alerta para 
combinações perigosas, questionário sobre medicações atuais do paciente, 
verificação de compatibilidade entre medicamentos selecionados, e recomendações 
de ajuste de dose quando necessário.

**Dependências:** dosagem_anestesicos_model.dart, banco de dados de interações

**Validação:** Verificar alertas para interações conhecidas, testar com protocolos 
anestésicos comuns, comparar com literatura farmacológica

---

### 7. [REFACTOR] - Controller mistura lógica de negócio com formatação

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O método calcular no controller gera string formatada para resultado 
e o método compartilhar constrói texto completo. Isso mistura cálculo com 
apresentação, dificultando testes, localização, e diferentes formatos de saída.

**Prompt de Implementação:**

Separe cálculos de formatação criando AnesthesiaCalculationService para cálculos 
puros e AnesthesiaFormatterService para formatação de resultados. Crie estruturas 
de dados para resultados que permitam diferentes apresentações, implemente 
suporte a localização, e facilite geração de relatórios em diferentes formatos.

**Dependências:** dosagem_anestesicos_controller.dart, novos services especializados

**Validação:** Verificar separação clara de responsabilidades, facilidade de 
testes, flexibilidade de formatação

---

### 8. [OPTIMIZE] - Compartilhamento gera texto longo desnecessariamente

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O método compartilhar gera texto muito longo incluindo todas as 
descrições e advertências. Para compartilhamento rápido entre profissionais, 
seria mais útil ter versões resumidas ou opções de formato diferentes.

**Prompt de Implementação:**

Crie sistema de compartilhamento flexível com múltiplas opções. Implemente 
formato resumido (apenas dosagem calculada), formato completo (atual), formato 
para prescrição (estruturado), formato de emergência (dados críticos), e 
possibilidade de personalizar campos incluídos no compartilhamento.

**Dependências:** dosagem_anestesicos_controller.dart

**Validação:** Testar diferentes formatos de compartilhamento, verificar utilidade 
prática, confirmar legibilidade

---

## 🟢 Complexidade BAIXA

### 9. [DOC] - Falta de referências farmacológicas para dosagens

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Dosagens e concentrações não possuem referências científicas 
documentadas. Isso dificulta validação por veterinários e pode gerar desconfiança 
na precisão dos cálculos fornecidos pela calculadora.

**Prompt de Implementação:**

Adicione documentação completa com referências farmacológicas veterinárias. 
Inclua fontes como Plumb's Veterinary Drug Handbook, literatura de anestesia 
veterinária, guidelines de sociedades veterinárias, documente limitações e 
contraindicações, e crie bibliografia técnica para validação profissional.

**Dependências:** Documentação, comentários no código

**Validação:** Verificar precisão das referências, adequação das fontes, utilidade 
para veterinários

---

### 10. [TEST] - Validação inadequada de peso para contexto anestésico

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Validação de peso apenas verifica se é número positivo, mas não 
considera ranges realísticos para anestesia veterinária. Pesos muito baixos 
(< 0.5kg) ou muito altos requerem considerações especiais que não são alertadas.

**Prompt de Implementação:**

Implemente validação específica para peso em contexto anestésico. Adicione 
alertas para animais muito pequenos (< 1kg) que requerem cuidados especiais, 
verificação de peso vs espécie para detectar inconsistências, warnings para 
animais grandes que podem precisar ajustes de protocolo, e sugestões de 
cuidados especiais baseados no peso.

**Dependências:** dosagem_anestesicos_controller.dart

**Validação:** Testar com ranges extremos de peso, verificar alertas apropriados, 
confirmar sugestões úteis

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação  
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída