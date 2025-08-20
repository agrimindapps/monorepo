# 📋 Issues Report - Gasto Energético Module

**Arquivo analisado**: `gasto_energetico/index.dart` e dependências  
**Data da análise**: 2024-12-19  
**Total de issues identificados**: 22 (9 HIGH, 8 MEDIUM, 5 LOW)

---

## 🔴 HIGH COMPLEXITY (9 issues)

### [HGE-001] Widget Input Form não implementado 
**Status**: 🔴 Pendente  
**Localização**: `widgets/gasto_energetico_input_form.dart`
**Descrição**: Widget principal de input está apenas com stub de implementação
**Problema**: `return Container(); // Implemente conforme o widget original`

**Implementação**:
1. Analisar referências dos widgets similares (`adiposidade_input_form.dart`, `calorias_diarias_form.dart`)
2. Implementar formulário completo com:
   - Seletor de gênero (Radio buttons)
   - Campos de peso, altura, idade com validação
   - Campos para horas de atividades (6 campos com valores padrão)
   - Botões de ação (Calcular, Limpar, Info)
3. Aplicar máscaras de input apropriadas
4. Configurar focus navigation

**Dependências**: HGE-005, HGE-007  
**Impacto**: CRÍTICO - Widget principal não funcional  
**Risco**: Alto - App não funciona para este módulo

---

### [HGE-002] Widget Result Card não implementado
**Status**: 🔴 Pendente  
**Localização**: `widgets/gasto_energetico_result_card.dart`  
**Descrição**: Widget de resultado está apenas com stub de implementação

**Implementação**:
1. Criar card animado para exibição de resultados
2. Mostrar TMB calculada
3. Mostrar gasto total energético
4. Detalhar gasto por atividade
5. Botão de compartilhamento funcional
6. Animação de aparecer/desaparecer baseada em `isVisible`

**Dependências**: HGE-001  
**Risco**: Alto - Usuário não vê resultados dos cálculos

---

### [HGE-003] Widget Info Dialog não implementado
**Status**: 🔴 Pendente  
**Localização**: `widgets/gasto_energetico_info_dialog.dart`  
**Descrição**: Dialog informativo está apenas com stub

**Implementação**:
1. Criar dialog com informações sobre:
   - Como funciona o cálculo de TMB
   - Explicação das atividades e valores MET
   - Orientações sobre distribuição de horas
   - Limitações do cálculo
2. Usar design consistente com outros dialogs do app
3. Scrollable content para dispositivos menores

**Risco**: Médio - Usuário sem contexto educativo

---

### [HGE-004] Falta de validação robusta de entrada
**Status**: 🔴 Pendente  
**Localização**: `controller/gasto_energetico_controller.dart` linha 65-87
**Descrição**: Validação básica mas sem formatação de dados e tratamento de erros

**Problemas identificados**:
- Não valida ranges apropriados (peso: 30-300kg, altura: 100-250cm, idade: 1-120 anos)
- Não trata entrada com vírgula/ponto inconsistente
- Parse de double pode crashar com entrada inválida
- Mensagens de erro não são user-friendly

**Implementação**:
1. Adicionar método `_validarRanges()` no controller
2. Implementar `_sanitizarInput()` para tratar vírgula/ponto
3. Usar `double.tryParse()` com fallback
4. Melhorar mensagens de erro contextuais
5. Adicionar validação de total de horas mais flexível (23-25h)

**Risco**: Alto - App pode crashar com inputs inválidos

---

### [HGE-005] Ausência de máscaras de input
**Status**: 🔴 Pendente  
**Localização**: `widgets/gasto_energetico_input_form.dart`
**Descrição**: Campos numéricos sem formatação adequada

**Implementação**:
1. Adicionar `MaskTextInputFormatter` para:
   - Peso: `###,##` (ex: 70,5 kg)
   - Altura: `###` (ex: 170 cm)  
   - Idade: `###` (ex: 30 anos)
   - Horas: `##,#` (ex: 8,5 horas)
2. Implementar conversão automática ponto->vírgula
3. Filtros para aceitar apenas números

**Referência**: Ver implementação em `adiposidade_input_form.dart` linhas 45-54

---

### [HGE-006] Falta de tratamento de dispose
**Status**: 🔴 Pendente  
**Localização**: `controller/gasto_energetico_controller.dart`
**Descrição**: Método `disposeAll()` existe mas não está sendo chamado

**Problemas**:
- Memory leak de controllers e focus nodes
- Método existe linha 37-43 mas não há chamada
- Widget principal é StatelessWidget, não gerencia lifecycle

**Implementação**:
1. Converter `GastoEnergeticoPage` para StatefulWidget
2. Implementar `dispose()` chamando `controller.disposeAll()`
3. Ou usar ProxyProvider com dispose automático

---

### [HGE-007] Implementação de compartilhamento incompleta
**Status**: 🔴 Pendente  
**Localização**: `index.dart` linha 64-67
**Descrição**: Feature de compartilhamento comentada como "pode ser implementado aqui"

**Implementação**:
1. Adicionar dependência `share_plus: ^7.2.2` no pubspec.yaml
2. Implementar método no controller:
```dart
Future<void> compartilharResultado() async {
  final texto = GastoEnergeticoUtils.gerarTextoCompartilhamento(modelo);
  await Share.share(texto, subject: 'Resultado Gasto Energético');
}
```
3. Chamar o método no onShare do ResultCard

---

### [HGE-008] Falta de persistência de dados
**Status**: 🔴 Pendente  
**Descrição**: Dados do usuário não são salvos entre sessões

**Implementação**:
1. Adicionar `SharedPreferences` para salvar:
   - Último gênero selecionado
   - Valores padrão de horas personalizados pelo usuário
   - Histórico de cálculos (últimos 5)
2. Implementar métodos `_salvarPreferencias()` e `_carregarPreferencias()`
3. Chamar no initState e nos métodos de cálculo

---

### [HGE-009] Ausência de tratamento de loading/error states
**Status**: 🔴 Pendente  
**Descrição**: Interface não mostra estados de carregamento ou erro

**Implementação**:
1. Adicionar propriedades no controller:
```dart
bool isLoading = false;
String? errorMessage;
```
2. Mostrar ProgressIndicator durante cálculos
3. Exibir mensagens de erro em diálogos
4. Desabilitar botões durante processamento

---

## 🟡 MEDIUM COMPLEXITY (8 issues)

### [MGE-001] Design não responsivo
**Status**: 🔴 Pendente  
**Localização**: Widget layouts
**Descrição**: Interface não adaptada para diferentes tamanhos de tela

**Implementação**:
1. Usar `LayoutBuilder` para detectar constraints
2. Aplicar grid responsivo nos campos de atividades
3. Ajustar padding/spacing baseado no tamanho da tela
4. Testar em dispositivos mobile e tablet

---

### [MGE-002] Valores padrão não customizáveis
**Status**: 🔴 Pendente  
**Localização**: `controller/gasto_energetico_controller.dart` linha 24-31
**Descrição**: Horas padrão fixas não refletem estilo de vida real

**Implementação**:
1. Adicionar botão "Personalizar Padrões"
2. Dialog para ajustar valores padrão por perfil:
   - Sedentário, Ativo, Muito Ativo
3. Salvar preferências customizadas

---

### [MGE-003] Falta de animações na interface
**Status**: 🔴 Pendente  
**Descrição**: Interface estática, sem feedback visual

**Implementação**:
1. Animação de slide-up no resultado
2. Shake animation em campos com erro
3. Loading animation durante cálculo
4. Transições suaves entre estados

---

### [MGE-004] Ausência de modo escuro/claro
**Status**: 🔴 Pendente  
**Descrição**: Interface não adapta a tema do sistema

**Implementação**:
1. Verificar se `ThemeManager().isDark.value` está sendo usado
2. Adaptar cores dos campos e ícones conforme tema
3. Usar `ShadcnStyle` consistentemente

**Referência**: Ver implementação em outros módulos

---

### [MGE-005] Falta de acessibilidade
**Status**: 🔴 Pendente  
**Descrição**: Interface não acessível para pessoas com deficiência

**Implementação**:
1. Adicionar `Semantics` widgets
2. Labels apropriados para screen readers
3. Contrast ratio adequado
4. Navegação por teclado/voice

---

### [MGE-006] Não há validação de consistência médica
**Status**: 🔴 Pendente  
**Descrição**: Valores calculados podem ser medicamente inconsistentes

**Implementação**:
1. Adicionar validações:
   - TMB muito baixa/alta para idade
   - Gasto energético extremo
   - Avisos para casos edge
2. Disclaimer médico no info dialog

---

### [MGE-007] Performance da renderização
**Status**: 🔴 Pendente  
**Descrição**: Rebuild desnecessário durante digitação

**Implementação**:
1. Usar `ValueListenableBuilder` para campos específicos
2. Debounce para validação durante digitação
3. `const` constructors onde possível

---

### [MGE-008] Falta de internacionalização
**Status**: 🔴 Pendente  
**Descrição**: Textos hardcoded em português

**Implementação**:
1. Extrair strings para arquivo de localização
2. Usar `context.l10n` pattern
3. Formatação de números baseada em locale

---

## 🟢 LOW COMPLEXITY (5 issues)

### [LGE-001] Nomenclatura inconsistente
**Status**: 🔴 Pendente  
**Localização**: Variáveis e métodos
**Descrição**: Mix de português/inglês nos nomes

**Implementação**:
1. Padronizar para português: `calcular()`, `limpar()`
2. Ou inglês: `calculate()`, `clear()`
3. Manter consistência em todo o módulo

---

### [LGE-002] Falta de documentação
**Status**: 🔴 Pendente  
**Descrição**: Métodos sem comentários explicativos

**Implementação**:
1. Adicionar dartdoc nos métodos públicos
2. Explicar fórmulas usadas (Harris-Benedict)
3. Documenter valores MET das atividades

---

### [LGE-003] Magic numbers não documentados
**Status**: 🔴 Pendente  
**Localização**: `gasto_energetico_utils.dart` linha 18-21
**Descrição**: Constantes da fórmula TMB sem explicação

**Implementação**:
1. Documentar origem das constantes (Harris-Benedict Equation)
2. Adicionar referências científicas
3. Considerar outras fórmulas (Mifflin-St Jeor)

---

### [LGE-004] Valores MET desatualizados
**Status**: 🔴 Pendente  
**Localização**: `gasto_energetico_utils.dart` linha 5-12
**Descrição**: Valores podem não refletir pesquisas atuais

**Implementação**:
1. Verificar com Compendium of Physical Activities 2024
2. Atualizar valores se necessário
3. Adicionar mais atividades específicas

---

### [LGE-005] Log de debug ausente
**Status**: 🔴 Pendente  
**Descrição**: Sem logs para debug em produção

**Implementação**:
1. Adicionar logs nos métodos de cálculo
2. Log de validações que falham
3. Analytics de uso de features

---

## 📊 Resumo de Prioridades

### Crítico (Implementar imediatamente)
- HGE-001: Widget Input Form 
- HGE-002: Widget Result Card
- HGE-004: Validação robusta
- HGE-005: Máscaras de input

### Alto (Próxima sprint)
- HGE-003: Info Dialog
- HGE-006: Dispose memory leaks
- HGE-007: Compartilhamento
- MGE-001: Design responsivo

### Médio (Backlog)
- HGE-008: Persistência
- HGE-009: Loading states
- MGE-002: Valores customizáveis
- MGE-003: Animações

### Baixo (Melhorias futuras)
- Todos os issues LOW
- Documentação
- Acessibilidade
- Internacionalização

---

## 🛠️ Comandos Úteis

```bash
# Análise de código
flutter analyze lib/app-nutrituti/pages/calc/gasto_energetico/

# Executar testes
flutter test test/gasto_energetico/

# Verificar dependências
flutter pub deps

# Hot reload para desenvolvimento
flutter hot-reload
```

---

**Análise gerada automaticamente**  
**Próxima revisão**: Após implementação dos issues HIGH
