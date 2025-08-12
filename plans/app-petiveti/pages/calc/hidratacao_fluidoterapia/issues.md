# Issues da Calculadora de Hidratação e Fluidoterapia

## Índice de Issues por Complexidade

### ALTA COMPLEXIDADE (3 issues)
1. [Implementação de Cálculos Críticos Incompletos](#issue-1-implementação-de-cálculos-críticos-incompletos)
2. [Sistema de Validações Médicas Inadequado](#issue-2-sistema-de-validações-médicas-inadequado)
3. [Arquitetura de Recomendações Não Implementada](#issue-3-arquitetura-de-recomendações-não-implementada)

### MÉDIA COMPLEXIDADE (4 issues)
4. [Gerenciamento de Estado Inconsistente](#issue-4-gerenciamento-de-estado-inconsistente)
5. [Interface de Resultados Limitada](#issue-5-interface-de-resultados-limitada)
6. [Validação de Temperatura Corporal Ausente](#issue-6-validação-de-temperatura-corporal-ausente)
7. [Sistema de Alertas por Condição Clínica](#issue-7-sistema-de-alertas-por-condição-clínica)

### BAIXA COMPLEXIDADE (3 issues)
8. [Formatação e Localização de Números](#issue-8-formatação-e-localização-de-números)
9. [Responsividade e Acessibilidade](#issue-9-responsividade-e-acessibilidade)
10. [Documentação de Códigos e Comentários](#issue-10-documentação-de-códigos-e-comentários)

---

## ISSUES DE ALTA COMPLEXIDADE

### Issue #1: Implementação de Cálculos Críticos Incompletos

**Status:** 🔴 Crítico  
**Execução:** 40 horas  
**Risco:** Alto - Cálculos médicos incorretos podem causar sérios danos aos animais  
**Benefício:** Essencial - Garantir precisão e segurança nos cálculos veterinários  

**Descrição Técnica:**
A calculadora possui duas funções críticas no controller que estão completamente vazias:
- `_calcularTaxaEDistribuicao()`: Linhas 87-100 do controller
- `_gerarRecomendacoes()`: Linhas 102-113 do controller

Estas funções são essenciais para:
1. Calcular a taxa de infusão baseada na via de administração e espécie
2. Distribuir o volume ao longo do tempo conforme protocolos veterinários
3. Gerar recomendações específicas baseadas na condição clínica e tipo de solução

**Problemas Identificados:**
```dart
void _calcularTaxaEDistribuicao() {
  if (_resultado == null) return;
  
  double? taxaInfusao;
  Map<String, double> distribuicaoHoraria = {};
  
  // Implementar lógica de cálculo de taxa e distribuição
  // ... CÓDIGO VAZIO
}
```

**Prompt de Implementação:**
"Implemente as funções `_calcularTaxaEDistribuicao()` e `_gerarRecomendacoes()` no controller de hidratação. Para a taxa de infusão, use os limites definidos no modelo (`limiteTaxaInfusao`) e a distribuição por via (`distribuicaoPorVia`). Para recomendações, use o mapa `recomendacoesSolucao` considerando a condição clínica selecionada. Inclua validações para evitar taxas perigosas e gere alertas específicos para condições críticas como choque ou insuficiência cardíaca."

**Dependências:**
- Model `HidratacaoFluidoterapiaModel` já possui as constantes necessárias
- Controller já possui a estrutura base

**Critérios de Validação:**
- [ ] Taxa de infusão respeitando limites por espécie e via
- [ ] Distribuição horária correta conforme protocolo veterinário
- [ ] Recomendações específicas para cada combinação solução/condição
- [ ] Alertas para situações de risco

---

### Issue #2: Sistema de Validações Médicas Inadequado

**Status:** 🔴 Crítico  
**Execução:** 32 horas  
**Risco:** Alto - Dados inválidos podem gerar prescrições perigosas  
**Benefício:** Essencial - Segurança dos cálculos médicos  

**Descrição Técnica:**
O sistema atual possui validações muito básicas que não consideram aspectos médicos críticos:

1. **Validação de Desidratação Inadequada:**
```dart
String? validateDesidratacao(String? value) {
  // ... código básico
  if (percent < 0 || percent > 15) {
    return 'O percentual deve estar entre 0 e 15';
  }
  return null;
}
```

2. **Falta Validações Cruzadas:**
- Peso vs espécie (gatos raramente > 10kg)
- Temperatura vs condição clínica
- Percentual de desidratação vs sinais clínicos
- Via de administração vs condição do paciente

3. **Ausência de Validações de Segurança:**
- Combinações perigosas de solução + condição clínica
- Volumes totais excessivos para o peso
- Taxa de infusão acima dos limites seguros

**Prompt de Implementação:**
"Crie um sistema robusto de validações médicas no controller. Inclua: 1) Validação cruzada peso-espécie, 2) Validação temperatura-condição clínica, 3) Alertas para combinações perigosas (ex: Insuficiência cardíaca + volumes altos), 4) Validação de limites seguros para taxa de infusão, 5) Método `validateMedicalSafety()` que analise todas as entradas em conjunto."

**Dependências:**
- Expandir validações no controller
- Adicionar constantes de limites no model
- Integrar com sistema de alertas

**Critérios de Validação:**
- [ ] Validações cruzadas entre campos implementadas
- [ ] Alertas para combinações perigosas funcionando
- [ ] Limites de segurança respeitados
- [ ] Interface mostrando avisos médicos específicos

---

### Issue #3: Arquitetura de Recomendações Não Implementada

**Status:** 🔴 Crítico  
**Execução:** 28 horas  
**Risco:** Alto - Falta de orientações pode levar a uso incorreto  
**Benefício:** Alto - Orientações clínicas essenciais para uso seguro  

**Descrição Técnica:**
O modelo possui estruturas para recomendações (`recomendacoesSolucao`) mas a lógica não está implementada. O sistema deveria:

1. **Gerar Recomendações Contextuais:**
```dart
// Model possui dados mas controller não os usa
static final Map<String, Map<String, String>> recomendacoesSolucao = {
  'Solução Fisiológica (NaCl 0,9%)': {
    'geral': 'Indicada para desidratações isotônicas...',
    'Insuficiência cardíaca': 'USAR COM CAUTELA...',
  },
  // ... outros casos
};
```

2. **Sistema de Monitoramento:**
- Parâmetros a monitorar por condição
- Frequência de avaliação
- Sinais de alerta

3. **Orientações de Administração:**
- Velocidade de infusão específica
- Pontos de avaliação durante a terapia
- Critérios para ajustes

**Prompt de Implementação:**
"Implemente o sistema completo de recomendações no método `_gerarRecomendacoes()`. Use o mapa `recomendacoesSolucao` para gerar orientações específicas baseadas na solução e condição clínica. Adicione recomendações de monitoramento (frequência cardíaca, pressão, diurese) e orientações de velocidade de infusão. Crie alertas especiais para condições críticas como choque ou insuficiência cardíaca."

**Dependências:**
- Estruturas no model já existem
- Interface de resultados precisa exibir recomendações
- Sistema de alertas integrado

**Critérios de Validação:**
- [ ] Recomendações específicas por solução/condição
- [ ] Orientações de monitoramento implementadas
- [ ] Alertas para condições críticas funcionando
- [ ] Interface exibindo todas as recomendações

---

## ISSUES DE MÉDIA COMPLEXIDADE

### Issue #4: Gerenciamento de Estado Inconsistente

**Status:** 🟡 Importante  
**Execução:** 16 horas  
**Risco:** Médio - Pode causar inconsistências na interface  
**Benefício:** Médio - Melhor experiência do usuário  

**Descrição Técnica:**
O controller possui estado para `showInfoCard` que não é utilizado e falta gerenciamento adequado dos estados de cálculo:

```dart
class HidratacaoFluidoterapiaController extends ChangeNotifier {
  bool _showInfoCard = true; // Não utilizado em lugar algum
  
  bool get showInfoCard => _showInfoCard; // Getter órfão
  
  void toggleInfoCard() { // Método não usado
    _showInfoCard = !_showInfoCard;
    notifyListeners();
  }
}
```

**Problemas:**
- Estado não utilizado ocupando memória
- Falta estados para loading durante cálculos
- Sem controle de erros específicos
- Ausência de histórico de cálculos

**Prompt de Implementação:**
"Refatore o gerenciamento de estado no controller. Remova estado não utilizado (`showInfoCard`), adicione estados para `isCalculating`, `hasError`, `errorMessage` e `calculationHistory`. Implemente loading state durante cálculos complexos e sistema de cache para os últimos 5 cálculos realizados."

**Dependências:**
- Refatoração do controller
- Atualização da interface para novos estados

**Critérios de Validação:**
- [ ] Estados desnecessários removidos
- [ ] Loading state implementado
- [ ] Sistema de erros funcionando
- [ ] Histórico de cálculos disponível

---

### Issue #5: Interface de Resultados Limitada

**Status:** 🟡 Importante  
**Execução:** 20 horas  
**Risco:** Médio - Informações importantes podem não ser visualizadas  
**Benefício:** Alto - Melhor compreensão dos resultados pelos usuários  

**Descrição Técnica:**
O `ResultCardWidget` exibe apenas informações básicas e não aproveita todos os dados calculados:

```dart
// Atual: Exibe apenas volumes básicos
_buildResultRow('Volume total em 24h:', '${modelo!.volumeTotalDia!.toStringAsFixed(0)} ml')

// Faltam:
// - Taxa de infusão por hora
// - Distribuição temporal detalhada
// - Recomendações de monitoramento
// - Alertas visuais por gravidade
```

**Problemas:**
- Não exibe taxa de infusão (campo existe no model)
- Falta distribuição horária visual
- Sem indicadores de gravidade
- Ausência de gráficos ou progressos
- Não mostra recomendações específicas

**Prompt de Implementação:**
"Expanda o `ResultCardWidget` para exibir informações completas. Adicione seções para: 1) Taxa de infusão com destaque visual, 2) Timeline de distribuição horária com gráfico de barras, 3) Card específico para recomendações com ícones, 4) Indicadores de gravidade com cores (verde/amarelo/vermelho), 5) Seção de monitoramento com checklist."

**Dependências:**
- Cálculos completos implementados (Issue #1)
- Recomendações funcionando (Issue #3)

**Critérios de Validação:**
- [ ] Taxa de infusão destacada visualmente
- [ ] Distribuição horária com gráfico
- [ ] Indicadores de gravidade coloridos
- [ ] Seção de recomendações organizada

---

### Issue #6: Validação de Temperatura Corporal Ausente

**Status:** 🟡 Importante  
**Execução:** 12 horas  
**Risco:** Médio - Temperaturas anômalas podem indicar emergência  
**Benefício:** Alto - Detectar situações críticas  

**Descrição Técnica:**
A temperatura corporal é usada nos cálculos mas não possui validação adequada:

```dart
// Controller usa temperatura mas sem validação específica
double fatorTemperatura = 1.0;
if (temperaturaCorporal > 39.0) {
  fatorTemperatura = 1.0 + ((temperaturaCorporal - 39.0) * 0.1);
}
```

**Problemas:**
- Sem validação de limites fisiológicos
- Não detecta situações de emergência (hipotermia/hipertermia grave)
- Falta alertas para temperaturas críticas
- Ausência de orientações específicas por temperatura

**Prompt de Implementação:**
"Crie validação completa para temperatura corporal no controller. Implemente: 1) Método `validateTemperature()` com limites por espécie (cães: 37.5-39.2°C, gatos: 38.0-39.5°C), 2) Alertas para hipotermia (<36°C) e hipertermia (>41°C), 3) Recomendações específicas para temperaturas anômalas, 4) Ajuste do fator de correção baseado em evidências veterinárias."

**Dependências:**
- Integração com sistema de validações (Issue #2)
- Atualização da interface para alertas de temperatura

**Critérios de Validação:**
- [ ] Limites fisiológicos por espécie implementados
- [ ] Alertas para temperaturas críticas funcionando
- [ ] Recomendações específicas por temperatura
- [ ] Interface destacando situações de risco

---

### Issue #7: Sistema de Alertas por Condição Clínica

**Status:** 🟡 Importante  
**Execução:** 18 horas  
**Risco:** Alto - Condições críticas requerem atenção especial  
**Benefício:** Alto - Segurança clínica aumentada  

**Descrição Técnica:**
Diferentes condições clínicas requerem alertas e cuidados específicos que não estão implementados:

```dart
// Model tem correções mas sem alertas específicos
static final Map<String, double> correcaoCondicaoClinica = {
  'Choque': 1.3,           // CRÍTICO - precisa alerta
  'Insuficiência cardíaca': 0.7,  // CUIDADO - monitoramento especial
  'Cetoacidose diabética': 1.2,   // URGENTE - protocolo específico
};
```

**Problemas:**
- Sem alertas visuais para condições críticas
- Falta protocolos específicos por condição
- Ausência de indicadores de urgência
- Sem orientações de monitoramento diferenciadas

**Prompt de Implementação:**
"Implemente sistema de alertas baseado em condições clínicas. Crie: 1) Enum `AlertLevel` (LOW, MEDIUM, HIGH, CRITICAL), 2) Mapa de alertas por condição no model, 3) Método `getAlertLevel()` no controller, 4) Widget `ConditionAlertCard` com cores e ícones específicos, 5) Protocolos de monitoramento diferenciados por gravidade."

**Dependências:**
- Sistema de recomendações (Issue #3)
- Interface de resultados expandida (Issue #5)

**Critérios de Validação:**
- [ ] Níveis de alerta definidos e funcionando
- [ ] Alertas visuais por condição implementados
- [ ] Protocolos específicos por gravidade
- [ ] Interface destacando condições críticas

---

## ISSUES DE BAIXA COMPLEXIDADE

### Issue #8: Formatação e Localização de Números

**Status:** 🟢 Melhoria  
**Execução:** 8 horas  
**Risco:** Baixo - Questão de usabilidade  
**Benefício:** Médio - Melhor experiência do usuário brasileiro  

**Descrição Técnica:**
O sistema usa formatação manual de números sem considerar localização adequada:

```dart
// Formatação inconsistente
'${modelo!.volumeTotalDia!.toStringAsFixed(0)} ml'

// Conversor manual básico
TextInputFormatter pontoPraVirgula() {
  return TextInputFormatter.withFunction((oldValue, newValue) {
    final text = newValue.text.replaceAll(".", ",");
    return TextEditingValue(/*...*/);
  });
}
```

**Problemas:**
- Falta uso de `NumberFormat` para localização
- Conversão manual de ponto/vírgula
- Sem formatação de milhares
- Ausência de formatação monetária para custos

**Prompt de Implementação:**
"Implemente formatação adequada usando `intl` package. Crie classe `NumberFormatter` com métodos para volumes (ml), temperaturas (°C), percentuais (%) e taxas (ml/h). Use `NumberFormat.decimalPattern('pt_BR')` para formatação brasileira. Substitua conversões manuais por formatadores apropriados."

**Dependências:**
- Adicionar dependency `intl` no pubspec.yaml
- Refatorar widgets que exibem números

**Critérios de Validação:**
- [ ] Formatação brasileira implementada
- [ ] Separadores de milhares funcionando
- [ ] Formatação consistente em toda interface
- [ ] Conversões automáticas ponto/vírgula

---

### Issue #9: Responsividade e Acessibilidade

**Status:** 🟢 Melhoria  
**Execução:** 14 horas  
**Risco:** Baixo - Não afeta funcionalidade médica  
**Benefício:** Médio - Melhor acessibilidade e usabilidade  

**Descrição Técnica:**
A interface possui largura fixa e falta recursos de acessibilidade:

```dart
// Largura fixa problemática
Center(
  child: SizedBox(
    width: 1120,  // Rígido - problemas em telas menores
    child: Padding(/*...*/),
  ),
)
```

**Problemas:**
- Layout com largura fixa (1120px)
- Falta `Semantics` para leitores de tela
- Sem suporte a temas de alto contraste
- Ausência de tooltips explicativos
- Navegação por teclado limitada

**Prompt de Implementação:**
"Torne a interface responsiva e acessível. Implemente: 1) Layout flexível usando `LayoutBuilder` e breakpoints, 2) `Semantics` widgets para campos críticos, 3) Tooltips explicativos em campos médicos, 4) Suporte a navegação por teclado, 5) Teste com `flutter inspector` para acessibilidade."

**Dependências:**
- Refatoração da estrutura de layout
- Testes em diferentes tamanhos de tela

**Critérios de Validação:**
- [ ] Layout responsivo em tablets e desktops
- [ ] Semantics implementado em campos críticos
- [ ] Tooltips explicativos funcionando
- [ ] Navegação por teclado fluida

---

### Issue #10: Documentação de Códigos e Comentários

**Status:** 🟢 Melhoria  
**Execução:** 10 horas  
**Risco:** Baixo - Questão de manutenibilidade  
**Benefício:** Médio - Facilita manutenção e evolução  

**Descrição Técnica:**
O código possui documentação muito limitada, especialmente em cálculos médicos críticos:

```dart
// Sem documentação adequada dos cálculos
final volumeDesidratacao = peso * (percentualDesidratacao / 100) * 1000;

// Fórmulas sem referências científicas
double fatorTemperatura = 1.0;
if (temperaturaCorporal > 39.0) {
  fatorTemperatura = 1.0 + ((temperaturaCorporal - 39.0) * 0.1);
}
```

**Problemas:**
- Falta documentação das fórmulas médicas
- Sem referências bibliográficas
- Comentários insuficientes em cálculos complexos
- Ausência de exemplos de uso

**Prompt de Implementação:**
"Adicione documentação completa ao código médico. Inclua: 1) Documentação dartdoc para todos os métodos de cálculo, 2) Referências bibliográficas veterinárias nos comentários, 3) Exemplos de cálculo passo-a-passo, 4) Explicação das constantes e fatores de correção, 5) Arquivo README específico da calculadora."

**Dependências:**
- Pesquisa de referências veterinárias
- Revisão de fórmulas por especialista

**Critérios de Validação:**
- [ ] Todos os cálculos documentados com fórmulas
- [ ] Referências bibliográficas incluídas
- [ ] Exemplos práticos documentados
- [ ] README específico criado

---

## Comandos Rápidos

### Análise de Complexidade
```bash
# Contar linhas de código por arquivo
find . -name "*.dart" -exec wc -l {} \; | sort -n

# Analisar dependências do pubspec
grep -A 20 "dependencies:" pubspec.yaml
```

### Testes e Validação
```bash
# Executar testes específicos da calculadora
flutter test test/calc/hidratacao_fluidoterapia_test.dart

# Análise estática
flutter analyze lib/app-petiveti/pages/calc/hidratacao_fluidoterapia/

# Verificar formatação
dart format lib/app-petiveti/pages/calc/hidratacao_fluidoterapia/
```

### Debug e Performance
```bash
# Profile da calculadora
flutter run --profile --trace-startup

# Analisar widget tree
flutter inspector
```

### Implementação Priorizada
```bash
# 1. Implementar cálculos críticos (Issue #1)
# 2. Adicionar validações médicas (Issue #2) 
# 3. Sistema de recomendações (Issue #3)
# 4. Melhorar interface de resultados (Issue #5)
```