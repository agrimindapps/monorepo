# Issues e Melhorias - Macronutrientes Module

**Data de Análise:** 13 de junho de 2025  
**Arquivos Analisados:** 7 arquivos do módulo macronutrientes  
**Status:** 📋 Análise Completa | ✅ 4 Issues Resolvidas (1, 3, 4, 5)

---

## 📋 Índice Geral

### 🔴 Complexidade ALTA (5 issues)
1. ✅ [BUG] - Interface de entrada incompleta: campos de porcentagem ausentes
2. [REFACTOR] - Arquitetura inconsistente com padrões do codebase
3. ✅ [SECURITY] - Parsing sem tratamento de exceções pode causar crashes
4. ✅ [BUG] - setState manual desnecessário e propenso a erros
5. ✅ [REFACTOR] - Responsabilidades mal distribuídas entre componentes

### 🟡 Complexidade MÉDIA (4 issues)
6. [FEATURE] - Distribuições predefinidas não implementadas na UI
7. [UX] - Feedback visual limitado e estados de carregamento ausentes
8. [OPTIMIZATION] - Recálculos desnecessários de resultados
9. [ACCESSIBILITY] - Suporte inadequado à acessibilidade

### 🟢 Complexidade BAIXA (6 issues)
10. [STYLE] - Design básico que pode ser mais moderno e atrativo
11. [DOC] - Documentação insuficiente de métodos e classes
12. [TEST] - Ausência completa de testes unitários e de integração
13. [FEATURE] - Histórico de cálculos e persistência de dados ausente
14. [VALIDATION] - Validação de entrada limitada para valores realistas
15. [CODE_QUALITY] - Strings hardcoded sem externalização

---

## 🔴 Complexidade ALTA

### 1. ✅ [BUG] - Interface de entrada incompleta: campos de porcentagem ausentes

**Status:** ✅ Resolvido | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O formulário de entrada só exibe o campo de calorias diárias, mas está 
faltando os campos essenciais para porcentagens de carboidratos, proteínas e gorduras. 
O controller e model já possuem toda a lógica necessária, mas a interface não permite 
ao usuário inserir esses valores, tornando o calculador não funcional.

**Prompt de Implementação:**
```
Complete a interface de entrada do MacronutrientesFormWidget adicionando os campos 
de porcentagem que estão ausentes:

1. Adicione três campos de entrada para porcentagens:
   - Carboidratos (controller: carboidratosController, padrão: 50%)
   - Proteínas (controller: proteinasController, padrão: 25%)  
   - Gorduras (controller: gordurasController, padrão: 25%)

2. Use VTextField para consistência com o resto do app
3. Adicione máscaras de porcentagem (model.porcentagemmask)
4. Implemente validação em tempo real que a soma seja 100%
5. Adicione ícones apropriados para cada macronutriente
6. Use cores diferenciadas: carboidratos (amber), proteínas (red), gorduras (blue)
7. Adicione indicador visual quando soma não for 100%

Mantenha o layout responsivo e a aparência consistente com outros formulários do app.
```

**Dependências:**
- view/widgets/macronutrientes_form_widget.dart
- model/macronutrientes_model.dart (já possui os controllers)
- controller/macronutrientes_controller.dart (já possui validação)

**Validação:** Confirmar que todos os campos são exibidos, validação funciona e 
cálculo é executado corretamente com os valores inseridos.

---

### 2. [REFACTOR] - Arquitetura inconsistente com padrões do codebase

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O módulo não segue o padrão Provider usado em outros calculadores do 
codebase. Utiliza setState manual e passa callbacks excessivos entre widgets, violando 
princípios de arquitetura limpa e dificultando manutenção.

**Prompt de Implementação:**
```
Refatore a arquitetura para usar o padrão Provider/ChangeNotifier consistente com 
outros módulos:

1. Converta MacronutrientesController para extends ChangeNotifier
2. Substitua MacronutrientesPage para StatelessWidget com ChangeNotifierProvider
3. Remova todos os callbacks (onCalcular, onLimpar, setState) do MacronutrientesFormWidget
4. Use Consumer<MacronutrientesController> nos widgets que precisam reagir a mudanças
5. Implemente notifyListeners() nos métodos calcular() e limpar()
6. Remova _MainContent wrapper desnecessário
7. Simplifique a estrutura de widgets seguindo o padrão de outros calculadores

Use como referência a estrutura de:
- app-nutrituti/pages/calc/massa_corporea/index.dart
- app-petiveti/pages/calc/hidratacao_fluidoterapia/index.dart
```

**Dependências:**
- view/macronutrientes_page.dart
- controller/macronutrientes_controller.dart  
- view/widgets/macronutrientes_form_widget.dart
- view/widgets/macronutrientes_result_widget.dart

**Validação:** Arquitetura deve ser consistente com outros módulos e funcionalidade 
deve permanecer inalterada.

---

### 3. ✅ [SECURITY] - Parsing sem tratamento de exceções pode causar crashes

**Status:** ✅ Resolvido | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O método calcular() realiza parsing direto de strings para números sem 
try-catch, podendo causar crashes se o usuário inserir valores inválidos ou deixar 
campos vazios após as validações iniciais.

**Prompt de Implementação:**
```
Adicione tratamento robusto de exceções no método calcular() do controller:

1. Envolva cada operação de parsing em blocos try-catch separados
2. Implemente função helper parseDouble() e parseInt() que retornam valores seguros
3. Adicione validações de faixa para valores realistas:
   - Calorias diárias: 800-5000 kcal
   - Porcentagens: 0-100% individualmente, soma exata de 100%
4. Exiba mensagens de erro específicas para cada tipo de problema
5. Restaure foco no campo problemático quando houver erro
6. Implemente logging de erros para debugging

Estrutura sugerida:
```dart
try {
  final calorias = _parseDoubleWithValidation(
    model.caloriasDiariasController.text, 
    800, 5000, 
    'Calorias devem estar entre 800 e 5000'
  );
  model.caloriasDiarias = calorias;
} catch (e) {
  _exibirMensagem(context, 'Calorias inválidas: ${e.toString()}');
  model.focusCalorias.requestFocus();
  return;
}
```

**Dependências:**
- controller/macronutrientes_controller.dart

**Validação:** Testar com valores inválidos e extremos para confirmar que não há 
crashes e mensagens de erro são apropriadas.

---

### 4. [BUG] - setState manual desnecessário e propenso a erros

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** A página principal usa setState manual nos métodos _calcular() e 
_limpar(), o que é desnecessário e pode causar inconsistências de estado. Além disso, 
passa uma função setState como parâmetro para widgets filhos.

**Prompt de Implementação:**
```
Elimine o uso de setState manual e simplifique o gerenciamento de estado:

1. Remova os métodos _calcular() e _limpar() da página principal
2. Faça widgets filhos chamarem diretamente os métodos do controller
3. Remova o parâmetro setState de MacronutrientesFormWidget
4. Use notifyListeners() no controller para atualizar a UI automaticamente
5. Substitua AnimatedOpacity por Consumer para reatividade adequada
6. Garanta que dispose() do model seja chamado corretamente

Estrutura simplificada:
```dart
class MacronutrientesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MacronutrientesController(MacronutrientesModel()),
      child: Scaffold(
        // ... resto da implementação sem setState
      ),
    );
  }
}
```

**Dependências:**
- view/macronutrientes_page.dart
- view/widgets/macronutrientes_form_widget.dart
- view/widgets/macronutrientes_result_widget.dart

**Validação:** UI deve atualizar automaticamente sem setState manual e não deve 
haver memory leaks.

---

### 5. [REFACTOR] - Responsabilidades mal distribuídas entre componentes

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O controller possui lógica de UI (exibição de mensagens), o model 
contém dados que deveriam estar em constants, e widgets possuem lógica de negócio. 
Isso viola o princípio de separação de responsabilidades.

**Prompt de Implementação:**
```
Reorganize as responsabilidades seguindo princípios de arquitetura limpa:

1. CONTROLLER: Mantenha apenas lógica de negócio e coordenação
   - Remova _exibirMensagem() e use callbacks ou streams para UI
   - Mova getSomaPorcentagens() para um service/helper

2. MODEL: Mantenha apenas dados e estado
   - Mova distribuicoesPredefinidas para constants/macronutrientes_constants.dart
   - Mova caloriasPorGrama para constants
   - Mantenha apenas controllers, focus nodes e variáveis de estado

3. WIDGETS: Mantenha apenas lógica de apresentação
   - Implementem validação visual própria
   - Gerenciem suas próprias mensagens de erro

4. SERVICES: Crie services separados para:
   - MacronutrientesCalculationService (cálculos)
   - MacronutrientesValidationService (validações)
   - MacronutrientesConstants (constantes)

5. UTILS: Crie helpers para:
   - Formatação de números
   - Geração de texto para compartilhamento
   - Parsing seguro de valores
```

**Dependências:**
- Todos os arquivos do módulo
- Novos arquivos: services/, utils/, constants/

**Validação:** Cada componente deve ter responsabilidade única e bem definida, 
mantendo funcionalidade inalterada.

---

## 🟡 Complexidade MÉDIA

### 6. [FEATURE] - Distribuições predefinidas não implementadas na UI

**Status:** 🟡 Pendente | **Execução:** Média | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** O model possui distribuições predefinidas completas (Baixo Carboidrato, 
Cetogênico, Equilibrado, etc.) e o controller tem método para aplicá-las, mas a 
interface não oferece essa funcionalidade ao usuário.

**Prompt de Implementação:**
```
Implemente interface para seleção de distribuições predefinidas:

1. Adicione seção "Distribuições Predefinidas" no formulário
2. Use DropdownButtonFormField ou chips horizontais para seleção
3. Exiba cada opção com nome e porcentagens (ex: "Equilibrado (50/25/25)")
4. Implemente preview das porcentagens antes de aplicar
5. Adicione botão "Aplicar" que chama controller.aplicarDistribuicaoPredefinida()
6. Use cores diferenciadas para cada tipo de distribuição
7. Inclua tooltips explicativos para cada distribuição
8. Mantenha opção "Personalizado" para entrada manual

Layout sugerido:
- Dropdown com distribuições predefinidas
- Preview visual das porcentagens
- Campos de entrada manual (habilitados só em "Personalizado")
- Botão para aplicar distribuição selecionada
```

**Dependências:**
- view/widgets/macronutrientes_form_widget.dart
- model/macronutrientes_model.dart (distribuicoesPredefinidas)
- controller/macronutrientes_controller.dart (aplicarDistribuicaoPredefinida)

**Validação:** Usuário deve conseguir selecionar distribuições predefinidas e 
ver os campos preenchidos automaticamente.

---

### 7. [UX] - Feedback visual limitado e estados de carregamento ausentes

**Status:** 🟡 Pendente | **Execução:** Média | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Interface não fornece feedback adequado durante operações como cálculo 
e compartilhamento. Ausência de estados de loading, validação em tempo real e 
animações de transição.

**Prompt de Implementação:**
```
Melhore o feedback visual e estados da interface:

1. LOADING STATES:
   - Adicione isCalculating no controller
   - Implemente loading no botão "Calcular"
   - Adicione spinner durante compartilhamento

2. VALIDAÇÃO EM TEMPO REAL:
   - Mostre indicador quando soma de porcentagens ≠ 100%
   - Use cores: verde (=100%), vermelho (≠100%)
   - Exiba soma atual das porcentagens

3. ANIMAÇÕES:
   - Animação de entrada para card de resultado
   - Transição suave entre estados
   - Feedback tátil em botões

4. MENSAGENS CONTEXTUAIS:
   - Toast messages para sucesso/erro
   - Dicas inline para campos
   - Avisos preventivos

5. PROGRESS INDICATORS:
   - Barra de progresso para preenchimento do formulário
   - Indicadores visuais para campos obrigatórios

Estrutura sugerida:
```dart
// No controller
bool _isCalculating = false;
bool get isCalculating => _isCalculating;

// Na UI
if (controller.isCalculating)
  CircularProgressIndicator()
else
  Text('Calcular')
```

**Dependências:**
- controller/macronutrientes_controller.dart
- view/widgets/macronutrientes_form_widget.dart
- view/widgets/macronutrientes_result_widget.dart

**Validação:** Interface deve ser mais responsiva e fornecer feedback claro para 
todas as ações do usuário.

---

### 8. [OPTIMIZATION] - Recálculos desnecessários de resultados

**Status:** 🟡 Pendente | **Execução:** Média | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** ResultWidget reconstrói completamente a cada mudança, mesmo quando 
dados não mudaram. Cálculos de formatação são refeitos desnecessariamente.

**Prompt de Implementação:**
```
Otimize performance e reduza recálculos desnecessários:

1. MEMOIZAÇÃO:
   - Cache resultados formatados no model
   - Só recalcule quando dados de entrada mudarem
   - Use late variables para cálculos pesados

2. WIDGET OPTIMIZATION:
   - Use const constructors onde possível
   - Implemente shouldRebuild logic
   - Separe widgets que mudam frequentemente

3. LAZY LOADING:
   - Adie formatação até exibição dos resultados
   - Use getters lazy para valores formatados
   - Cache strings de compartilhamento

4. GRANULAR UPDATES:
   - Use ValueListenableBuilder para propriedades específicas
   - Evite notifyListeners() desnecessários
   - Implemente dirty flags para controlar updates

Estrutura otimizada:
```dart
class MacronutrientesModel {
  String? _formattedCarbsCalorias;
  String get formattedCarbsCalorias {
    _formattedCarbsCalorias ??= carboidratosCalorias.toStringAsFixed(0);
    return _formattedCarbsCalorias!;
  }
  
  void _clearCache() {
    _formattedCarbsCalorias = null;
    // ... clear other cached values
  }
}
```

**Dependências:**
- model/macronutrientes_model.dart
- view/widgets/macronutrientes_result_widget.dart
- controller/macronutrientes_controller.dart

**Validação:** Performance deve melhorar sem impactar funcionalidade. Use 
Flutter Inspector para verificar rebuilds desnecessários.

---

### 9. [ACCESSIBILITY] - Suporte inadequado à acessibilidade

**Status:** 🟡 Pendente | **Execução:** Média | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Módulo não implementa recursos de acessibilidade como labels 
semânticos, navegação por teclado, suporte a screen readers e feedback adequado.

**Prompt de Implementação:**
```
Implemente suporte completo à acessibilidade:

1. SEMANTIC LABELS:
   - Adicione Semantics widgets com labels descritivos
   - Implemente hints para todos os campos de entrada
   - Configure announcements para mudanças de estado

2. NAVEGAÇÃO:
   - Configure order de navegação por Tab
   - Implemente atalhos de teclado úteis
   - Adicione skip links para seções principais

3. SCREEN READER SUPPORT:
   - Configure liveRegion para resultados
   - Adicione descriptions contextuais
   - Implemente feedback auditivo para ações

4. VISUAL ACCESSIBILITY:
   - Garanta contraste adequado de cores
   - Adicione indicadores visuais além de cores
   - Implemente zoom/responsividade para texto grande

5. MOTOR ACCESSIBILITY:
   - Áreas de toque adequadas (min 44x44)
   - Suporte a input assistivo
   - Tempo adequado para interações

Exemplo de implementação:
```dart
Semantics(
  label: 'Campo de calorias diárias',
  hint: 'Digite sua meta calórica entre 800 e 5000 calorias',
  textField: true,
  child: VTextField(...),
)
```

**Dependências:**
- Todos os arquivos de widget
- view/widgets/macronutrientes_form_widget.dart
- view/widgets/macronutrientes_result_widget.dart

**Validação:** Testar com TalkBack/VoiceOver e navegação por teclado em 
dispositivos iOS e Android.

---

## 🟢 Complexidade BAIXA

### 10. [STYLE] - Design básico que pode ser mais moderno e atrativo

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Interface atual é funcional mas visualmente básica. Pode ser melhorada 
com design mais moderno, melhores cores, ícones e animações sutis.

**Prompt de Implementação:**
```
Modernize o design visual do módulo:

1. CARDS DE RESULTADO:
   - Use gradientes sutis nas cores dos macronutrientes
   - Adicione sombras e bordas mais elegantes
   - Implemente layout de gráfico circular visual

2. FORMULÁRIO:
   - Melhore espaçamento e hierarquia visual
   - Use ícones mais expressivos para cada macronutriente
   - Adicione separadores visuais entre seções

3. CORES E TIPOGRAFIA:
   - Use paleta de cores mais harmoniosa
   - Implemente hierarquia tipográfica clara
   - Adicione emphasis em números importantes

4. MICRO-INTERAÇÕES:
   - Animações sutis nos botões
   - Feedback hover/tap visual
   - Transições suaves entre estados

5. RESPONSIVIDADE:
   - Layout adaptativo para tablets
   - Componentes que escalam bem
   - Uso eficiente do espaço disponível

Mantenha consistência com o design system do app (ShadcnStyle).
```

**Dependências:**
- view/widgets/macronutrientes_result_widget.dart
- view/widgets/macronutrientes_form_widget.dart

**Validação:** Design deve ser mais atrativo mantendo usabilidade e performance.

---

### 11. [DOC] - Documentação insuficiente de métodos e classes

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Classes e métodos carecem de documentação adequada, dificultando 
manutenção e compreensão do código.

**Prompt de Implementação:**
```
Adicione documentação completa seguindo padrões Dart:

1. CLASSES:
   - Documente propósito e responsabilidade
   - Inclua exemplos de uso quando relevante
   - Descreva relacionamentos com outras classes

2. MÉTODOS PÚBLICOS:
   - Documente parâmetros e retornos
   - Inclua throws documentation para exceções
   - Adicione exemplos para métodos complexos

3. CONSTANTES E PROPRIEDADES:
   - Documente unidades de medida
   - Explique faixas válidas de valores
   - Inclua referências científicas quando aplicável

4. FÓRMULAS E CÁLCULOS:
   - Documente bases científicas dos cálculos
   - Inclua referências a estudos ou guidelines
   - Explique conversões e fatores usados

Exemplo:
```dart
/// Calcula a distribuição de macronutrientes em gramas e calorias.
/// 
/// Utiliza as seguintes conversões calóricas:
/// - Carboidratos e Proteínas: 4 kcal/g
/// - Gorduras: 9 kcal/g
/// 
/// Throws [ArgumentError] se porcentagens não somarem 100%.
/// Throws [RangeError] se calorias estiverem fora da faixa 800-5000.
void calcular(BuildContext context) {
  // implementação
}
```

**Dependências:**
- Todos os arquivos do módulo

**Validação:** Gerar documentação com dartdoc e verificar completude.

---

### 12. [TEST] - Ausência completa de testes unitários e de integração

**Status:** 🟢 Pendente | **Execução:** Média | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Módulo não possui nenhum teste, dificultando detecção de regressões 
e garantia de qualidade.

**Prompt de Implementação:**
```
Implemente suíte completa de testes:

1. TESTES UNITÁRIOS:
   - Controller: calcular(), limpar(), aplicarDistribuicaoPredefinida()
   - Model: dispose(), validações básicas
   - Utils: se criados, teste todas as funções helper

2. TESTES DE WIDGET:
   - MacronutrientesFormWidget: renderização e interação
   - MacronutrientesResultWidget: exibição de dados
   - MacronutrientesInfoWidget: abertura e conteúdo

3. TESTES DE INTEGRAÇÃO:
   - Fluxo completo: entrada -> cálculo -> resultado
   - Aplicação de distribuições predefinidas
   - Funcionalidade de compartilhamento

4. TESTES DE EDGE CASES:
   - Valores extremos e inválidos
   - Campos vazios e incompletos
   - Soma de porcentagens diferente de 100%

Estrutura de testes:
```
test/
├── unit/
│   ├── macronutrientes_controller_test.dart
│   └── macronutrientes_model_test.dart
├── widget/
│   ├── macronutrientes_form_widget_test.dart
│   └── macronutrientes_result_widget_test.dart
└── integration/
    └── macronutrientes_flow_test.dart
```

Exemplo de teste crítico:
```dart
void main() {
  group('MacronutrientesController', () {
    test('calcular deve processar valores válidos corretamente', () {
      final model = MacronutrientesModel();
      final controller = MacronutrientesController(model);
      
      model.caloriasDiariasController.text = '2000';
      model.carboidratosController.text = '50';
      model.proteinasController.text = '25';
      model.gordurasController.text = '25';
      
      controller.calcular(mockContext);
      
      expect(model.calculado, isTrue);
      expect(model.carboidratosGramas, equals(250.0));
      expect(model.proteinasGramas, equals(125.0));
      expect(model.gordurasGramas, closeTo(55.6, 0.1));
    });
  });
}
```

**Dependências:**
- Todos os arquivos do módulo
- Novos arquivos de teste
- Mock dependencies

**Validação:** Atingir pelo menos 80% de cobertura de testes e garantir que 
todos os casos críticos sejam cobertos.

---

### 13. [FEATURE] - Histórico de cálculos e persistência de dados ausente

**Status:** 🟢 Pendente | **Execução:** Média | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Dados são perdidos ao sair da tela. Não há histórico de cálculos 
nem possibilidade de salvar configurações preferidas do usuário.

**Prompt de Implementação:**
```
Implemente persistência de dados e histórico:

1. MODELO DE HISTÓRICO:
   - Crie MacronutrientesHistoryItem com timestamp, valores e resultados
   - Implemente serialização JSON para storage local
   - Limite histórico a últimos 50 cálculos

2. STORAGE LOCAL:
   - Use SharedPreferences para dados simples
   - Implemente auto-save das preferências do usuário
   - Salve última distribuição usada

3. FUNCIONALIDADES:
   - Tela de histórico com lista de cálculos anteriores
   - Opção de restaurar cálculo do histórico
   - Exportar histórico para CSV/PDF
   - Limpar histórico com confirmação

4. PREFERÊNCIAS:
   - Salvar distribuição predefinida favorita
   - Lembrar último valor de calorias inserido
   - Configurações de unidades (se houver variações)

5. INTERFACE:
   - Botão "Histórico" no AppBar
   - Indicador de auto-save
   - Opções de backup/restore

Estrutura do modelo:
```dart
class MacronutrientesHistoryItem {
  final DateTime timestamp;
  final double calorias;
  final int carbsPorcentagem;
  final int proteinPorcentagem;
  final int fatPorcentagem;
  final Map<String, double> resultados;
  
  Map<String, dynamic> toJson();
  factory MacronutrientesHistoryItem.fromJson(Map<String, dynamic> json);
}
```

**Dependências:**
- Novo arquivo: models/macronutrientes_history.dart
- Novo arquivo: services/macronutrientes_storage_service.dart
- controller/macronutrientes_controller.dart
- Nova tela: views/macronutrientes_history_page.dart

**Validação:** Dados devem persistir entre sessões e histórico deve funcionar 
corretamente.

---

### 14. [VALIDATION] - Validação de entrada limitada para valores realistas

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Validação atual só verifica campos vazios. Não há verificação de 
valores realistas ou ranges apropriados para uso nutricional.

**Prompt de Implementação:**
```
Implemente validação robusta para valores nutricionalmente realistas:

1. RANGES RECOMENDADOS:
   - Calorias diárias: 800-5000 kcal (com avisos especiais fora de 1200-3500)
   - Carboidratos: 10-70% (aviso se <20% ou >65%)
   - Proteínas: 10-50% (aviso se <15% ou >35%)
   - Gorduras: 10-50% (aviso se <20% ou >40%)

2. VALIDAÇÃO EM TEMPO REAL:
   - Cores de campo: verde (válido), amarelo (questionável), vermelho (inválido)
   - Mensagens contextuais abaixo dos campos
   - Soma automática das porcentagens com indicador visual

3. AVISOS NUTRICIONAIS:
   - Alertas para distribuições extremas
   - Recomendações baseadas em guidelines científicos
   - Links para informações educacionais

4. PREVENÇÃO DE ERROS:
   - Auto-correção quando possível
   - Sugestões de valores próximos válidos
   - Validação de entrada durante digitação

5. ACCESSIBILITY:
   - Announce validation errors to screen readers
   - Clear error states with proper contrast
   - Keyboard navigation friendly

Exemplo de validação:
```dart
String? validateCarboidratos(String? value) {
  if (value == null || value.isEmpty) return 'Campo obrigatório';
  final num = int.tryParse(value);
  if (num == null) return 'Valor inválido';
  if (num < 10) return 'Muito baixo (mín. 10%)';
  if (num > 70) return 'Muito alto (máx. 70%)';
  if (num < 20) return 'Atenção: abaixo do recomendado';
  return null;
}
```

**Dependências:**
- view/widgets/macronutrientes_form_widget.dart
- controller/macronutrientes_controller.dart
- Novo arquivo: utils/macronutrientes_validation.dart

**Validação:** Testar com valores extremos e verificar que validação é 
apropriada e educativa.

---

### 15. [CODE_QUALITY] - Strings hardcoded sem externalização

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Todas as strings estão hardcoded no código, dificultando manutenção 
e impossibilitando internacionalização futura.

**Prompt de Implementação:**
```
Externalize todas as strings para arquivo de constantes:

1. CATEGORIZAÇÃO:
   - Títulos e labels de UI
   - Mensagens de erro e validação
   - Textos informativos e tooltips
   - Conteúdo do dialog de informações

2. ESTRUTURA ORGANIZADA:
   - Agrupe por contexto (form, results, validation, etc.)
   - Use naming convention clara e consistente
   - Prepare estrutura para i18n futuro

3. IMPLEMENTAÇÃO:
   - Crie constants/macronutrientes_strings.dart
   - Substitua todas as strings hardcoded
   - Mantenha keys semânticos e descritivos

Estrutura do arquivo de strings:
```dart
class MacronutrientesStrings {
  // Page titles
  static const String pageTitle = 'Distribuição de Macronutrientes';
  static const String resultsTitle = 'Resultados do Cálculo';
  
  // Form labels
  static const String caloriesLabel = 'Calorias Diárias (kcal)';
  static const String carbsLabel = 'Carboidratos (%)';
  static const String proteinLabel = 'Proteínas (%)';
  static const String fatLabel = 'Gorduras (%)';
  
  // Buttons
  static const String calculateButton = 'Calcular';
  static const String clearButton = 'Limpar';
  static const String shareButton = 'Compartilhar';
  
  // Validation messages
  static const String caloriesRequired = 'Necessário informar as calorias diárias';
  static const String percentagesRequired = 'Necessário informar as porcentagens de todos os macronutrientes';
  static const String percentagesSumError = 'A soma das porcentagens deve ser igual a 100%';
  
  // Predefined distributions
  static const String lowCarb = 'Baixo Carboidrato';
  static const String ketogenic = 'Cetogênico';
  static const String balanced = 'Equilibrado';
  static const String highProtein = 'Alta Proteína';
  static const String highCarb = 'Alto Carboidrato';
  static const String custom = 'Personalizado';
}
```

**Dependências:**
- Todos os arquivos do módulo com texto
- Novo arquivo: constants/macronutrientes_strings.dart

**Validação:** Confirmar que todas as strings foram externalizadas e 
funcionalidade permanece inalterada.

---

## 📊 Resumo da Análise

**Total de Issues Identificados:** 15
- 🔴 **Alta Complexidade:** 5 issues críticos
- 🟡 **Média Complexidade:** 4 issues importantes  
- 🟢 **Baixa Complexidade:** 6 issues de melhoria

**Issues Críticos Prioritários:**
1. **Issue #1:** Interface incompleta (BUG crítico)
2. **Issue #3:** Parsing sem exceções (SECURITY)
3. **Issue #2:** Arquitetura inconsistente (REFACTOR)

**Estimativa de Esforço:**
- **Críticos:** ~16-24 horas
- **Importantes:** ~12-16 horas  
- **Melhorias:** ~12-18 horas
- **Total:** ~40-58 horas

**Funcionalidade Atual:** O módulo está parcialmente funcional mas com interface 
incompleta que impede uso real pelos usuários.

**Recomendação:** Priorizar Issue #1 (interface incompleta) imediatamente, seguido 
pelos issues de segurança e arquitetura antes de implementar melhorias de UX.

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída
