# ANÁLISE COMPLETA - CALCULADORAS VETERINÁRIAS
**Migração de GetX/MVC para Clean Architecture + SOLID**

---

## 📊 INVENTÁRIO COMPLETO (13 Calculadoras)

### **CATEGORIA: MEDICAÇÃO (5 calculadoras)**

#### 1. **Dosagem de Medicamentos**
- **Inputs**: Peso animal, medicamento selecionado, dosagem (mg/kg), concentração medicamento
- **Outputs**: Volume a administrar (ml), equivalente em mg
- **Lógica**: Cálculo (peso × dosagem) ÷ concentração
- **Complexidade**: MÉDIA
- **Base de Dados**: 10 medicamentos com faixas de dosagem
- **Validações**: Peso > 0, dosagem numérica, concentração > 0

#### 2. **Dosagem de Anestésicos** 
- **Inputs**: Espécie, anestésico, peso animal
- **Outputs**: Volume administrar, dosagem média, informações segurança
- **Lógica**: Dosagem baseada em espécie + faixas específicas por anestésico
- **Complexidade**: ALTA
- **Base de Dados**: Anestésicos por espécie, concentrações, descrições, advertências
- **Validações**: Espécie obrigatória, peso > 0, anestésico válido para espécie

#### 3. **Fluidoterapia**
- **Inputs**: Peso, percentual hidratação, período administração (horas)
- **Outputs**: Taxa de fluidoterapia, volume total
- **Lógica**: Cálculo baseado em déficit hídrico e manutenção
- **Complexidade**: MÉDIA
- **Validações**: Todos campos > 0

#### 4. **Diabetes e Insulina**
- **Inputs**: Espécie, peso, glicemia, tipo insulina, dose anterior (opcional)
- **Outputs**: Dosagem insulina, recomendações monitoramento
- **Lógica**: Fator base por espécie + ajustes por glicemia + dose anterior
- **Complexidade**: ALTA
- **Base de Dados**: Fatores insulina por espécie, durações insulina
- **Validações**: Glicemia 50-500, peso > 0, dose anterior se informado

#### 5. **Hidratação e Fluidoterapia Avançada**
- **Inputs**: Peso, percentual desidratação, perda corrente, temperatura, espécie, solução, via administração
- **Outputs**: Volume total, taxa infusão, distribuição horária, recomendações
- **Lógica**: Déficit + manutenção + perdas correntes + ajustes condição clínica
- **Complexidade**: ALTA
- **Base de Dados**: Fatores manutenção por espécie, correções por condição clínica
- **Validações**: Desidratação 0-15%, temperatura 35-45°C, peso > 0

---

### **CATEGORIA: NUTRIÇÃO (3 calculadoras)**

#### 6. **Dieta Caseira**
- **Inputs**: Espécie, peso, idade (anos/meses), estado fisiológico, nível atividade, tipo alimentação
- **Outputs**: Necessidade calórica, macronutrientes (g), quantidades alimentos específicos
- **Lógica**: RER = 70 × peso^0.75, ajustado por fatores multiplicadores
- **Complexidade**: ALTA
- **Base de Dados**: Fatores energéticos, proporções macronutrientes, composição alimentos
- **Validações**: Peso > 0, idade ≥ 0, seleções obrigatórias

#### 7. **Necessidades Calóricas**
- **Inputs**: Peso, espécie, estado fisiológico, nível atividade
- **Outputs**: Necessidade calórica diária, recomendações específicas
- **Lógica**: RER × fator base × fator atividade
- **Complexidade**: MÉDIA
- **Base de Dados**: Fatores base e atividade por espécie/estado
- **Validações**: Peso > 0, seleções obrigatórias

#### 8. **Peso Ideal e Condição Corporal**
- **Inputs**: Espécie, raça, sexo, esterilizado, idade, peso atual, escala ECC (1-9)
- **Outputs**: Peso ideal estimado, recomendações ajuste peso
- **Lógica**: Algoritmo complexo baseado em ECC + fatores raciais
- **Complexidade**: ALTA
- **Base de Dados**: Dados raciais, fatores correção por sexo/esterilização
- **Validações**: ECC 1-9, peso > 0, idade > 0

---

### **CATEGORIA: GESTAÇÃO (2 calculadoras)**

#### 9. **Gestação**
- **Inputs**: Espécie, data início gestação
- **Outputs**: Data prevista parto, período gestacional
- **Lógica**: Data início + dias gestação por espécie
- **Complexidade**: BAIXA
- **Base de Dados**: Períodos gestação por espécie
- **Validações**: Data válida, espécie selecionada

#### 10. **Gestação e Parto Avançada**
- **Inputs**: Espécie, raça, método cálculo (acasalamento/ultrassom), datas, tamanho fetos
- **Outputs**: Data parto, fases gestação detalhadas, fase atual
- **Lógica**: Cálculo por acasalamento OU estimativa por tamanho fetal via ultrassom
- **Complexidade**: ALTA
- **Base de Dados**: Ajustes por raça, estimativas idade fetal, fases gestação detalhadas
- **Validações**: Método-específicas, tamanho fetos > 0, datas coerentes

---

### **CATEGORIA: DIAGNÓSTICO (3 calculadoras)**

#### 11. **Idade Animal**
- **Inputs**: Espécie, idade animal (anos), porte (se cão)
- **Outputs**: Idade equivalente humana, fase da vida, dicas cuidados
- **Lógica**: Algoritmos diferentes por espécie/porte com progressão não-linear
- **Complexidade**: MÉDIA
- **Base de Dados**: Fatores conversão por porte canino, fases vida
- **Validações**: Idade > 0, porte obrigatório para cães

#### 12. **Condição Corporal**
- **Inputs**: Espécie, índice condição corporal (1-9)
- **Outputs**: Classificação, descrição detalhada, recomendações
- **Lógica**: Mapeamento direto índice → descrição + recomendação por faixa
- **Complexidade**: BAIXA
- **Base de Dados**: Descrições detalhadas por espécie/índice, classificações
- **Validações**: Índice 1-9, espécie obrigatória

#### 13. **Conversão de Unidades**
- **Inputs**: Valor numérico, unidade origem, unidade destino
- **Outputs**: Valor convertido
- **Lógica**: Fatores conversão entre unidades veterinárias
- **Complexidade**: BAIXA
- **Base de Dados**: Tabela fatores conversão
- **Validações**: Valor numérico, unidades diferentes

---

## 🎯 PADRÕES IDENTIFICADOS

### **PADRÕES ARQUITETURAIS ATUAIS:**
1. **Controller Pattern**: Todos usam controllers com ChangeNotifier/ValueNotifier
2. **Model Pattern**: Models como DTOs simples com dados + validação básica
3. **Form Validation**: GlobalKey<FormState> + validators customizados
4. **State Management**: Mix de ChangeNotifier, ValueNotifier e Obx (GetX)
5. **Navigation**: GetX navigation (Get.to(), Get.back())
6. **Loading States**: Simulação de delay + loading indicators
7. **Error Handling**: Try/catch com snackbars + debug prints

### **PADRÕES DE DADOS:**
1. **Static Data**: Maps com constantes (medicamentos, espécies, fatores)
2. **Dropdown Dependencies**: Cascatas espécie → raça → outros campos
3. **Range Calculations**: Faixas min/max com valores médios
4. **Compound Formulas**: RER, fatores multiplicadores, ajustes condicionais
5. **Text Controllers**: Gerenciamento manual de TextEditingController
6. **Date Handling**: DateTime pickers + formatação manual

### **PADRÕES UI:**
1. **Card-based Layout**: InfoCards, InputCards, ResultCards
2. **Responsive Design**: Column counts baseados em screen width
3. **Form Structure**: Scaffold + Form + validation
4. **Conditional Display**: ShowIf para cards opcionais
5. **Share Functionality**: Compartilhamento via share_plus
6. **Toggle States**: Info cards expansíveis

---

## 🏗️ ARQUITETURA STRATEGY PATTERN SUGERIDA

### **LAYER STRUCTURE:**
```
Domain/
├── Entities/           # CalculationInput, CalculationResult, ValidationError
├── Repositories/       # CalculatorRepository (interface)
└── UseCases/          # CalculateUseCase, ValidateInputUseCase

Data/
├── DataSources/       # LocalCalculatorDataSource (static data)
├── Models/            # CalculationInputModel, CalculationResultModel  
├── Repositories/      # CalculatorRepositoryImpl
└── Strategies/        # Concrete calculation strategies

Presentation/
├── Controllers/       # CalculatorController (Provider/Riverpod)
├── Pages/            # CalculatorPage (generic)
└── Widgets/          # InputFormWidget, ResultDisplayWidget
```

### **STRATEGY PATTERN IMPLEMENTATION:**
```dart
abstract class CalculationStrategy {
  CalculationResult calculate(CalculationInput input);
  ValidationResult validate(CalculationInput input);
  List<InputField> getRequiredFields();
  String get calculatorName;
}

// Concrete strategies
class MedicationDosageStrategy extends CalculationStrategy { ... }
class AnesthesiaDosageStrategy extends CalculationStrategy { ... }
class DietaryNeedsStrategy extends CalculationStrategy { ... }
// ... etc for all 13 calculators
```

### **SHARED COMPONENTS:**
1. **BaseCalculatorController**: Common state management
2. **ValidationMixin**: Reusable validators
3. **FormFieldBuilder**: Dynamic form generation
4. **ResultPresenter**: Consistent result display
5. **ShareService**: Result sharing functionality
6. **ErrorHandler**: Centralized error management

---

## 📋 CLASSIFICAÇÃO POR COMPLEXIDADE

### **🟢 BAIXA COMPLEXIDADE (3 calculadoras - 2-3 dias cada)**
1. **Gestação** - Cálculo simples data + offset
2. **Condição Corporal** - Lookup direto em mapas
3. **Conversão Unidades** - Fórmulas matemáticas básicas

**Características**: Poucos inputs, lógica linear, validações simples

### **🟡 MÉDIA COMPLEXIDADE (4 calculadoras - 3-5 dias cada)**
1. **Dosagem Medicamentos** - Fórmula + base dados medicamentos
2. **Fluidoterapia** - Cálculos múltiplos + validações específicas  
3. **Necessidades Calóricas** - RER + fatores multiplicadores
4. **Idade Animal** - Algoritmos por espécie + condicionais

**Características**: Múltiplos inputs, lógica condicional, base dados média

### **🔴 ALTA COMPLEXIDADE (6 calculadoras - 5-8 dias cada)**
1. **Dosagem Anestésicos** - Matriz complexa + segurança crítica
2. **Diabetes Insulina** - Múltiplos algoritmos + ajustes dinâmicos
3. **Hidratação Avançada** - Fórmulas compostas + muitos fatores
4. **Dieta Caseira** - Macronutrientes + quantidades específicas
5. **Peso Ideal** - Algoritmo complexo + dados raciais extensos
6. **Gestação Avançada** - Múltiplos métodos + estimativas ultrassom

**Características**: Muitos inputs, lógica complexa, bases dados extensas, múltiplos algoritmos

---

## 🚀 PLANO DE IMPLEMENTAÇÃO PRIORIZADO

### **FASE 1: INFRAESTRUTURA (1 semana)**
- [ ] Criar estrutura base Clean Architecture
- [ ] Implementar Strategy Pattern interfaces
- [ ] Desenvolver BaseCalculatorController
- [ ] Criar shared components (validation, form builders, etc.)
- [ ] Setup testes unitários base

### **FASE 2: CALCULADORAS SIMPLES (1 semana)**
- [ ] Gestação (0.5 dia)
- [ ] Condição Corporal (1 dia)  
- [ ] Conversão Unidades (0.5 dia)
- [ ] Testes + refinamentos (2 dias)

### **FASE 3: CALCULADORAS MÉDIAS (1.5 semanas)**
- [ ] Dosagem Medicamentos (3 dias)
- [ ] Fluidoterapia (3 dias)
- [ ] Necessidades Calóricas (3 dias)
- [ ] Idade Animal (2 dias)

### **FASE 4: CALCULADORAS COMPLEXAS - LOTE 1 (2 semanas)**
- [ ] Dosagem Anestésicos (5 dias)
- [ ] Diabetes Insulina (5 dias)
- [ ] Hidratação Avançada (4 dias)

### **FASE 5: CALCULADORAS COMPLEXAS - LOTE 2 (2 semanas)**
- [ ] Dieta Caseira (5 dias)
- [ ] Peso Ideal (4 dias)
- [ ] Gestação Avançada (5 dias)

### **FASE 6: INTEGRAÇÃO E POLIMENTO (1 semana)**
- [ ] Integração completa com navegação
- [ ] Testes end-to-end
- [ ] Performance optimization
- [ ] Documentation

---

## ⚡ ESTIMATIVAS TOTAIS

### **TEMPO DE DESENVOLVIMENTO:**
- **Infraestrutura**: 7 dias
- **Calculadoras Simples**: 7 dias  
- **Calculadoras Médias**: 11 dias
- **Calculadoras Complexas**: 28 dias
- **Integração**: 7 dias
- **TOTAL**: **60 dias úteis (12 semanas)**

### **ESFORÇO POR CATEGORIA:**
- **Setup/Infrastructure**: 15% (9 dias)
- **Simple Calculators**: 10% (6 dias)
- **Medium Calculators**: 18% (11 dias) 
- **Complex Calculators**: 47% (28 dias)
- **Integration/Polish**: 10% (6 dias)

### **RISK FACTORS:**
- **Data Migration**: Migração das constantes para estrutura adequada
- **Complex Logic**: Algoritmos de cálculo complexos (diabetes, dieta)
- **Validation**: Validações interdependentes e condicionais
- **UI Consistency**: Manter UX atual durante migração
- **Testing**: Cobertura adequada para cálculos críticos

---

## 🔧 DEPENDÊNCIAS E BLOCKERS

### **DEPENDÊNCIAS TÉCNICAS:**
1. **Core Package**: Services base (analytics, premium, etc.)
2. **Navigation**: Definir GoRouter vs GetX migration strategy
3. **State Management**: Provider vs Riverpod decision per app
4. **Testing Framework**: Unit tests + integration tests setup
5. **Data Sources**: Static data organization strategy

### **POTENTIAL BLOCKERS:**
1. **Medical Accuracy**: Validação de fórmulas veterinárias
2. **Regulatory Compliance**: Aspectos legais cálculos medicamentos
3. **Performance**: Cálculos complexos em devices baixo-end
4. **UX Consistency**: Manter interface familiar durante migração

---

## 📈 SUCCESS METRICS

### **QUALITY METRICS:**
- [ ] 100% coverage testes unitários cálculos críticos
- [ ] 0 regressões funcionalidade existente
- [ ] Performance equivalent or better
- [ ] Code complexity reduction (cyclomatic complexity)

### **ARCHITECTURE METRICS:**
- [ ] SOLID principles compliance
- [ ] Clean Architecture layers respected
- [ ] Strategy Pattern properly implemented
- [ ] Dependency injection throughout

### **USER METRICS:**
- [ ] Same or improved UX
- [ ] No calculation accuracy loss
- [ ] Maintained feature parity
- [ ] Improved error handling/feedback

---

## 🎯 ORDEM DE IMPLEMENTAÇÃO RECOMENDADA

**Por impacto vs complexidade:**

1. **Condição Corporal** (Alto uso, Baixa complexidade)
2. **Necessidades Calóricas** (Alto uso, Média complexidade) 
3. **Dosagem Medicamentos** (Crítico, Média complexidade)
4. **Gestação** (Comum, Baixa complexidade)
5. **Idade Animal** (Popular, Média complexidade)
6. **Conversão Unidades** (Utilitário, Baixa complexidade)
7. **Fluidoterapia** (Profissional, Média complexidade)
8. **Dosagem Anestésicos** (Crítico, Alta complexidade)
9. **Diabetes Insulina** (Especializado, Alta complexidade)
10. **Peso Ideal** (Complexo, Alta complexidade)
11. **Dieta Caseira** (Educacional, Alta complexidade)
12. **Gestação Avançada** (Especializado, Alta complexidade)  
13. **Hidratação Avançada** (Muito especializado, Alta complexidade)

---

**PRÓXIMOS PASSOS:**
1. **Validação técnica** das fórmulas com especialista veterinário
2. **Decisão arquitetural** sobre Provider vs Riverpod por app
3. **Setup do projeto** base com estrutura Clean Architecture
4. **Implementação piloto** com Condição Corporal
5. **Iteração e refinamento** do padrão estabelecido