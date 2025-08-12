# Issues e Melhorias - gestacao

## 📋 Índice Geral

### 🔴 Complexidade ALTA (3 issues)
1. [FIXME] - Base de dados de espécies muito limitada
2. [SECURITY] - Falta validação de datas impossíveis ou perigosas
3. [REFACTOR] - Dialog de informações hardcoded no index

### 🟡 Complexidade MÉDIA (4 issues)
4. [TODO] - Sistema de acompanhamento gestacional não implementado
5. [BUG] - Cálculo simplificado não considera variações individuais
6. [OPTIMIZE] - Falta diferenciação entre tipos de acasalamento
7. [STYLE] - Inconsistência no uso do sistema de design

### 🟢 Complexidade BAIXA (3 issues)
8. [DOC] - Ausência de referências veterinárias para períodos gestacionais
9. [TEST] - Validação de formulário inadequada
10. [UI] - Info card implementado mas não utilizado efetivamente

---

## 🔴 Complexidade ALTA

### 1. [FIXME] - Base de dados de espécies muito limitada

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O modelo tem apenas 7 espécies hardcoded (cadela, gata, vaca, égua, 
ovelha, cabra, porca) sem considerar raças específicas, animais exóticos, ou 
variações regionais. Períodos são fixos sem considerar variabilidade natural.

**Prompt de Implementação:**

Expanda significativamente a base de dados gestacionais veterinárias. Adicione 
raças específicas com variações (bulldogs têm gestações diferentes), animais 
exóticos comuns (chinchila, coelho, furão), aves ornamentais, répteis básicos, 
inclua ranges de variação (60-68 dias para cadelas), e organize por categorias 
(domésticos, rurais, exóticos).

**Dependências:** gestacao_model.dart, base de dados gestacionais veterinária

**Validação:** Comparar com literatura veterinária especializada, verificar 
precisão dos períodos por espécie, testar com casos clínicos diversos

---

### 2. [SECURITY] - Falta validação de datas impossíveis ou perigosas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O sistema permite datas de acasalamento no futuro ou muito antigas, 
pode gerar previsões de parto impossíveis, não valida se a data é biologicamente 
viável, e não alerta para situações de emergência obstétrica.

**Prompt de Implementação:**

Implemente validação robusta de datas gestacionais. Adicione verificação de 
data máxima no passado por espécie (não mais que período gestacional + margem), 
bloqueio de datas futuras, alertas para gestações próximas ao vencimento, 
alertas para possível gestação prolongada (risco obstétrico), e sistema de 
emergência para casos críticos.

**Dependências:** gestacao_controller.dart, sistema de validação de datas, 
alertas de emergência

**Validação:** Testar com datas extremas, verificar alertas de emergência 
adequados, confirmar bloqueio de datas impossíveis

---

### 3. [REFACTOR] - Dialog de informações hardcoded no index

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O método _showInfoDialog no index.dart tem mais de 70 linhas 
hardcoded tornando o arquivo extenso. Todo o conteúdo está inline dificultando 
manutenção, localização, e reutilização.

**Prompt de Implementação:**

Extraia o dialog para widget dedicado GestacaoInfoDialog na pasta widgets. 
Organize conteúdo por seções técnicas, torne localizável, adicione responsividade, 
considere conteúdo específico por espécie selecionada, e mantenha apenas chamada 
simples no index.

**Dependências:** index.dart, nova classe widgets/gestacao_info_dialog.dart

**Validação:** Verificar funcionalidade mantida, melhor organização do código, 
facilidade de manutenção

---

## 🟡 Complexidade MÉDIA

### 4. [TODO] - Sistema de acompanhamento gestacional não implementado

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** A calculadora apenas informa data de parto, mas não oferece 
acompanhamento do progresso gestacional, marcos importantes, preparativos 
necessários, ou alertas periódicos para cuidados específicos.

**Prompt de Implementação:**

Desenvolva sistema completo de acompanhamento gestacional veterinário. Implemente 
cronograma de marcos gestacionais por espécie, alertas para exames necessários 
(ultrassom, exames de sangue), preparativos pré-parto por semana, checklist 
de cuidados específicos, sistema de notificações para acompanhamento, e 
integração com agenda veterinária.

**Dependências:** gestacao_model.dart, sistema de notificações, base de 
conhecimento gestacional

**Validação:** Testar cronograma com diferentes espécies, verificar adequação 
dos marcos gestacionais, comparar com protocolos veterinários

---

### 5. [BUG] - Cálculo simplificado não considera variações individuais

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O cálculo usa períodos fixos sem considerar variações normais 
da gestação (±3-5 dias típico), idade da fêmea, número de filhotes, condições 
da mãe, ou fatores ambientais que afetam duração da gestação.

**Prompt de Implementação:**

Implemente cálculo com ranges de variação gestacional. Adicione cálculo de 
janela de parto (data provável ± variação), consideração da idade da fêmea 
(primíparas vs multíparas), ajuste por número estimado de filhotes, fatores 
de risco que alteram duração, e apresentação de range de datas possíveis 
ao invés de data única.

**Dependências:** gestacao_model.dart, gestacao_controller.dart

**Validação:** Comparar ranges com literatura veterinária, testar com diferentes 
cenários reprodutivos, verificar precisão das janelas calculadas

---

### 6. [OPTIMIZE] - Falta diferenciação entre tipos de acasalamento

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O sistema não diferencia entre data do cio, acasalamento natural, 
inseminação artificial, ou transferência de embriões. Cada método tem marcos 
diferentes para cálculo preciso da gestação.

**Prompt de Implementação:**

Adicione seleção do tipo de reprodução assistida. Implemente cálculos específicos 
para inseminação artificial (data da inseminação + 63 dias), transferência de 
embriões (data da transferência + período específico), acasalamento natural 
(múltiplas datas possíveis), e cio observado (estimativa com maior variação). 
Ajuste precisão conforme método usado.

**Dependências:** gestacao_model.dart, interface de seleção de método reprodutivo

**Validação:** Verificar precisão por método reprodutivo, testar com casos 
clínicos específicos, comparar com protocolos de reprodução assistida

---

### 7. [STYLE] - Inconsistência no uso do sistema de design

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O código mistura ShadcnStyle em alguns lugares com cores hardcoded 
(Colors.blue.shade300, Colors.amber.shade900, Colors.white). Não há consistência 
completa com o sistema de design existente.

**Prompt de Implementação:**

Padronize uso do sistema ShadcnStyle em todo o código. Substitua todas as cores 
hardcoded por tokens do design system, garanta suporte completo para modo 
escuro/claro, crie tokens específicos para alertas gestacionais se necessário, 
e mantenha consistência visual com outras calculadoras.

**Dependências:** index.dart, core/style/shadcn_style.dart

**Validação:** Verificar consistência visual completa, funcionamento em todos 
os temas, ausência de cores hardcoded

---

## 🟢 Complexidade BAIXA

### 8. [DOC] - Ausência de referências veterinárias para períodos gestacionais

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Os períodos gestacionais não possuem referências científicas 
veterinárias documentadas. Isso compromete a confiabilidade clínica da 
calculadora para profissionais veterinários e criadores.

**Prompt de Implementação:**

Adicione documentação completa com referências em reprodução veterinária. 
Inclua fontes como Canine and Feline Reproduction and Neonatology, Large Animal 
Theriogenology, guidelines de sociedades de teriogenologia, documente variações 
conhecidas por raça/linhagem, e crie bibliografia técnica para validação.

**Dependências:** Documentação, comentários no código

**Validação:** Verificar precisão das referências científicas, adequação das 
fontes especializadas, utilidade para reprodutores e veterinários

---

### 9. [TEST] - Validação de formulário inadequada

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O controller usa formKey.currentState!.validate() mas não há 
validadores específicos nos campos. Apenas verifica se espécie existe no mapa 
e se data foi selecionada, sem validações contextuais.

**Prompt de Implementação:**

Implemente validação robusta para formulário gestacional. Adicione validação 
de espécie selecionada válida, verificação de data de acasalamento realística, 
validação de data não futura, feedback específico para erros comuns, e 
sugestões de correção para entradas inválidas.

**Dependências:** gestacao_controller.dart, widgets de formulário

**Validação:** Testar com entradas inválidas diversas, verificar qualidade 
das mensagens de erro, confirmar prevenção de cálculos incorretos

---

### 10. [UI] - Info card implementado mas não utilizado efetivamente

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** O model tem showInfoCard e o controller tem toggleInfoCard(), 
mas a funcionalidade não está visível ou efetivamente implementada na interface, 
representando código parcialmente morto.

**Prompt de Implementação:**

Complete implementação do info card ou remova código desnecessário. Se manter: 
adicione info card visível na interface com informações contextuais sobre 
gestação da espécie selecionada, botão de toggle, e integração com controller. 
Se remover: limpe código relacionado do model e controller.

**Dependências:** gestacao_model.dart, gestacao_controller.dart, widgets de interface

**Validação:** Verificar funcionalidade completa integrada ou limpeza total 
do código relacionado

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação  
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída