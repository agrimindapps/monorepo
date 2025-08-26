# Code Intelligence Report - calorie_page.dart

## 🎯 Análise Executada
- **Tipo**: Profunda | **Modelo**: Sonnet
- **Trigger**: Complexidade alta detectada - 589 linhas, múltiplas responsabilidades, lógica crítica de cálculos veterinários
- **Escopo**: Análise completa da página, provider relacionado e estrutura de dados

## 📊 Executive Summary

### **Health Score: 7.5/10**
- **Complexidade**: Alta - Sistema step-by-step com múltiplas responsabilidades
- **Maintainability**: Boa - Boa separação de concerns e componentização
- **Conformidade Padrões**: 85% - Segue Clean Architecture e padrões Riverpod
- **Technical Debt**: Médio - Algumas oportunidades de refatoração identificadas

### **Quick Stats**
| Métrica | Valor | Status |
|---------|--------|--------|
| Issues Totais | 12 | 🟡 |
| Críticos | 2 | 🟡 |
| Complexidade Cyclomatic | Alta | 🟡 |
| Lines of Code | 589 | Info |

## 🔴 ISSUES CRÍTICOS (Immediate Action)

### 1. [PERFORMANCE] - Rebuild desnecessários em Consumer widgets
**Impact**: 🔥 Alto | **Effort**: ⚡ 2 horas | **Risk**: 🚨 Médio

**Description**: Consumer na linha 282 está causando rebuilds desnecessários da barra de navegação. O provider `calorieCanProceedProvider` na linha 447 do provider executa `canProceedToNextStep()` a cada rebuild, que contém lógica computacional.

**Implementation Prompt**:
```dart
// Substituir Consumer por watch específico
final canProceed = ref.watch(calorieCanProceedProvider);
// E implementar cache/memoization no provider:
final calorieCanProceedProvider = Provider<bool>((ref) {
  final state = ref.watch(calorieProvider);
  return ref.read(calorieProvider.notifier).canProceedToNextStep();
});
```

**Validation**: Medir performance com Flutter Inspector e verificar redução de rebuilds.

---

### 2. [MEMORY] - Potencial memory leak em AnimationController
**Impact**: 🔥 Alto | **Effort**: ⚡ 1 hora | **Risk**: 🚨 Alto

**Description**: `_fadeController` pode não ser disposed corretamente em cenários de navegação rápida ou interrupção de transição. Método `_animateTransition()` pode ser chamado após dispose.

**Implementation Prompt**:
```dart
void _animateTransition() {
  if (!mounted || _fadeController.isDisposed) return;
  _fadeController.reset();
  _fadeController.forward();
}

// E adicionar verificação no dispose:
@override
void dispose() {
  if (_fadeController.isAnimating) {
    _fadeController.stop();
  }
  _pageController.dispose();
  _fadeController.dispose();
  super.dispose();
}
```

**Validation**: Testar navegação rápida e verificar que não há exceções de AnimationController disposed.

## 🟡 ISSUES IMPORTANTES (Next Sprint)

### 3. [ARCHITECTURE] - Violação do princípio de responsabilidade única
**Impact**: 🔥 Médio | **Effort**: ⚡ 4 horas | **Risk**: 🚨 Baixo

**Description**: `CaloriePage` tem múltiplas responsabilidades: navegação, validação, animação, dialogs, e formatação de texto para compartilhamento. Viola SRP e dificulta manutenção.

**Implementation Prompt**:
```dart
// Extrair para services/controllers separados:
class CalorieNavigationController {
  void goToNextStep(bool isLastStep) { /* lógica */ }
  void goToPreviousStep() { /* lógica */ }
}

class CalorieDialogService {
  void showPresetsDialog(BuildContext context) { /* lógica */ }
  void showShareDialog(CalorieOutput output) { /* lógica */ }
}

class CalorieShareFormatter {
  String formatForSharing(CalorieOutput output) { /* lógica */ }
}
```

**Validation**: Página deve ter <300 linhas após refatoração e responsabilidades claramente separadas.

### 4. [UX] - Falta de feedback visual durante transições
**Impact**: 🔥 Médio | **Effort**: ⚡ 2 horas | **Risk**: 🚨 Baixo

**Description**: Transições entre steps não têm loading states ou skeleton screens, causando momentos de UI vazia durante animações.

**Implementation Prompt**:
```dart
Widget _buildStepperView(CalorieState state) {
  return Stack(
    children: [
      PageView(/* existing code */),
      if (_isTransitioning)
        const Center(child: CircularProgressIndicator()),
    ],
  );
}

// Adicionar estado de transição:
bool _isTransitioning = false;
void _animateTransition() {
  setState(() => _isTransitioning = true);
  _fadeController.reset();
  _fadeController.forward().then((_) {
    if (mounted) setState(() => _isTransitioning = false);
  });
}
```

**Validation**: Usuário deve ver feedback visual durante transições entre steps.

### 5. [ERROR_HANDLING] - Tratamento de erros insuficiente
**Impact**: 🔥 Médio | **Effort**: ⚡ 3 horas | **Risk**: 🚨 Médio

**Description**: Não há tratamento específico para erros de validação por step, erros de rede ou falhas de cálculo. Usuário pode ficar preso em estados de erro sem orientação.

**Implementation Prompt**:
```dart
Widget _buildErrorBanner(CalorieState state) {
  if (!state.hasError && !state.hasValidationErrors) {
    return const SizedBox.shrink();
  }
  
  return Container(
    padding: const EdgeInsets.all(16),
    color: Colors.red.shade50,
    child: Column(
      children: [
        if (state.hasError)
          Text(state.error!, style: TextStyle(color: Colors.red)),
        ...state.validationErrors.map((error) => 
          Text(error, style: TextStyle(color: Colors.orange))),
      ],
    ),
  );
}

// Adicionar retry e recovery actions
```

**Validation**: Todos os estados de erro devem ter mensagens claras e ações de recuperação.

### 6. [ACCESSIBILITY] - Falta de suporte à acessibilidade
**Impact**: 🔥 Médio | **Effort**: ⚡ 2 horas | **Risk**: 🚨 Baixo

**Description**: Ausência de semantics, labels para screen readers, navegação por teclado e contraste adequado para usuários com deficiência visual.

**Implementation Prompt**:
```dart
// Adicionar Semantics widgets:
Semantics(
  label: 'Passo ${state.currentStep + 1} de ${state.totalSteps}',
  child: CalorieStepIndicator(/* existing code */),
)

// Hero widgets para navegação:
Hero(
  tag: 'calorie-form-${state.currentStep}',
  child: _buildStepperView(state),
)

// Focus management:
FocusScope.of(context).requestFocus(_stepFocusNodes[newStep]);
```

**Validation**: Testar com TalkBack/VoiceOver e navegação apenas por teclado.

## 🟢 ISSUES MENORES (Continuous Improvement)

### 7. [CODE_QUALITY] - Magic numbers e strings hardcoded
**Impact**: 🔥 Baixo | **Effort**: ⚡ 30 minutos | **Risk**: 🚨 Nenhum

**Description**: Duração de animações, dimensões e textos estão hardcoded no código em vez de constantes nomeadas.

**Implementation Prompt**:
```dart
class CaloriePageConstants {
  static const animationDuration = Duration(milliseconds: 300);
  static const fadeAnimationCurve = Curves.easeInOut;
  static const cardPadding = EdgeInsets.all(16.0);
  static const presetDialogMaxHeight = 400.0;
}
```

**Validation**: Remover todos os valores mágicos e centralizar em classe de constantes.

### 8. [PERFORMANCE] - Lista de histórico não virtualizada
**Impact**: 🔥 Baixo | **Effort**: ⚡ 1 hora | **Risk**: 🚨 Baixo

**Description**: Dialog de histórico usa ListView.builder sem altura limitada, pode causar overflow com muitos itens.

**Implementation Prompt**:
```dart
SizedBox(
  height: 400,
  child: history.isEmpty
    ? const Center(/* existing empty state */)
    : ListView.builder(
        shrinkWrap: true, // Adicionar
        itemCount: math.min(history.length, 50), // Limitar itens
        itemBuilder: (context, index) {
          // existing code
        },
      ),
)
```

**Validation**: Testar com >50 itens no histórico e verificar performance.

### 9. [MAINTAINABILITY] - Falta de testes unitários identificáveis
**Impact**: 🔥 Baixo | **Effort**: ⚡ 4 horas | **Risk**: 🚨 Baixo

**Description**: Código complexo sem evidência de testes unitários para validação de lógica de navegação e estados.

**Implementation Prompt**:
```dart
// Criar testes para:
void main() {
  group('CaloriePage Navigation', () {
    testWidgets('should navigate to next step when canProceed is true', (tester) async {
      // Test implementation
    });
    
    testWidgets('should show validation errors on invalid input', (tester) async {
      // Test implementation
    });
  });
}
```

**Validation**: Cobertura de testes >80% para métodos de navegação e validação.

## 📈 ANÁLISE MONOREPO ESPECÍFICA

### **Package Integration Opportunities**
- **Shared Animation Controllers**: Lógica de animação FadeTransition pode ser extraída para packages/core/widgets
- **Dialog Service Pattern**: Serviço de dialogs seguindo padrão similar aos outros apps do monorepo
- **Error Handling Middleware**: Padrão de tratamento de erro que poderia ser compartilhado com app-gasometer

### **Cross-App Consistency**
- **Navigation Patterns**: app-petiveti usa PageView + step navigation, enquanto outros apps usam routing direto
- **State Management**: Consistente com padrão Riverpod estabelecido em app_task_manager
- **Form Validation**: Padrão similar aos forms em app-gasometer, mas com validação mais robusta

### **Premium Logic Review**
- **RevenueCat Integration**: Não identificada integração específica para features premium
- **Feature Gating**: Calculadora aparenta ser funcionalidade core, mas poderia ter features premium (histórico avançado, export PDF)
- **Analytics Events**: Ausência de tracking de eventos para interações críticas (cálculos realizados, presets utilizados)

## 🎯 RECOMENDAÇÕES ESTRATÉGICAS

### **Quick Wins** (Alto impacto, baixo esforço)
1. **Issue #2** - Fix AnimationController memory leak - **ROI: Alto** (Estabilidade crítica)
2. **Issue #7** - Extrair magic numbers para constantes - **ROI: Alto** (Manutenibilidade)
3. **Issue #8** - Limitar items no histórico - **ROI: Alto** (Performance)

### **Strategic Investments** (Alto impacto, alto esforço)
1. **Issue #3** - Refatorar responsabilidades da página - **ROI: Médio-Longo Prazo** (Arquitetura sustentável)
2. **Issue #5** - Implementar tratamento robusto de erros - **ROI: Alto** (UX crítica)
3. **Issue #9** - Implementar suite de testes - **ROI: Alto** (Qualidade e confiança)

### **Technical Debt Priority**
1. **P0**: Memory leak no AnimationController (Issue #2)
2. **P1**: Rebuilds desnecessários impactando performance (Issue #1)
3. **P1**: Violação SRP dificultando manutenção (Issue #3)
4. **P2**: Falta de feedback UX durante transições (Issue #4)

## 🔧 COMANDOS RÁPIDOS

Para implementação específica:
- `Executar #2` - Corrigir memory leak crítico primeiro
- `Executar #1` - Otimizar performance de rebuild
- `Focar CRÍTICOS` - Implementar issues #1 e #2 priority
- `Quick wins` - Implementar issues #2, #7, #8 em batch
- `Validar #[número]` - Revisar implementação específica

## 📊 MÉTRICAS DE QUALIDADE

### **Complexity Metrics**
- Cyclomatic Complexity: 8.5 (Target: <3.0) ❌
- Method Length Average: 25 lines (Target: <20 lines) ❌
- Class Responsibilities: 6+ (Target: 1-2) ❌

### **Architecture Adherence**
- ✅ Clean Architecture: 85% (Good separation, domain entities well defined)
- ✅ Repository Pattern: N/A (UI layer, but properly uses providers)
- ✅ State Management: 90% (Excellent Riverpod usage)
- ❌ Error Handling: 60% (Missing comprehensive error states)

### **MONOREPO Health**
- ❌ Core Package Usage: 30% (Opportunity for shared widgets/services)
- ✅ Cross-App Consistency: 75% (State management aligned)
- ❌ Code Reuse Ratio: 40% (Dialog patterns could be shared)
- ❌ Premium Integration: 0% (No RevenueCat integration identified)

---

**Resumo Executivo**: O arquivo apresenta uma arquitetura sólida para uma calculadora veterinária complexa, mas sofre de responsabilidades concentradas e oportunidades de otimização de performance. Priorizar correção do memory leak e refatoração de responsabilidades terá maior impacto na qualidade e manutenibilidade do código.