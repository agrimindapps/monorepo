# 📝 Field Capacity Calculator - Example Usage

## 🎯 Real-World Example

### **Scenario: Soybean Planting Operation**

#### Input Parameters:
- **Operation Type**: Plantio (Planting)
- **Working Width**: 6.0 meters (6-row planter)
- **Working Speed**: 6.0 km/h
- **Field Efficiency**: 70% (default for planting)

#### Calculated Results:

**Theoretical Capacity**
```
Ct = (6.0 × 6.0) / 10 = 3.60 ha/h
```

**Effective Capacity**
```
Ce = 3.60 × (70 / 100) = 2.52 ha/h
```

**Hours per Hectare**
```
h/ha = 1 / 2.52 = 0.40 hours
```

**Daily Productivity**
```
8-hour day: 2.52 × 8 = 20.16 ha/day
10-hour day: 2.52 × 10 = 25.20 ha/day
```

### **Expected Display**

```
┌─────────────────────────────────────────┐
│ 📊 Resultado - Plantio                  │
├─────────────────────────────────────────┤
│                                         │
│   Capacidade Efetiva                    │
│        2.52 ha/h                        │
│   0.40 horas por hectare               │
│                                         │
├─────────────────────────────────────────┤
│ Capacidades Calculadas                  │
│ • Capacidade Teórica: 3.60 ha/h        │
│ • Capacidade Efetiva: 2.52 ha/h        │
│ • Eficiência de Campo: 70.0%           │
├─────────────────────────────────────────┤
│ Produtividade Diária                    │
│ ☀️ Jornada de 8 horas: 20.16 ha/dia   │
│ ⏰ Jornada de 10 horas: 25.20 ha/dia  │
├─────────────────────────────────────────┤
│ Parâmetros da Máquina                   │
│ • Largura de Trabalho: 6.00 m          │
│ • Velocidade: 6.00 km/h                │
├─────────────────────────────────────────┤
│ 💡 Dicas e Recomendações               │
│ • Mantenha velocidade constante        │
│ • Verifique nível de sementes          │
│ • Calibre semeadora antes de iniciar   │
│ • Planeje manobras e abastecimentos    │
└─────────────────────────────────────────┘
```

## 🔄 Different Operation Types

### **1. Preparo de Solo (Soil Preparation)**
```
Input: 4.0m width × 8.0 km/h
Efficiency: 75% (default)

Results:
- Theoretical: 3.20 ha/h
- Effective: 2.40 ha/h
- 8h day: 19.20 ha/day
```

### **2. Pulverização (Spraying)**
```
Input: 18.0m width × 12.0 km/h
Efficiency: 65% (default)

Results:
- Theoretical: 21.60 ha/h
- Effective: 14.04 ha/h
- 8h day: 112.32 ha/day
```

### **3. Colheita (Harvesting)**
```
Input: 7.5m width × 5.0 km/h
Efficiency: 70% (default)

Results:
- Theoretical: 3.75 ha/h
- Effective: 2.63 ha/h
- 8h day: 21.00 ha/day
```

## 🎨 UI Features Demo

### **Operation Type Selector**
```
┌──────────┬──────────┬──────────────┬──────────┐
│ ✓ Preparo│  Plantio │ Pulverização │ Colheita │
└──────────┴──────────┴──────────────┴──────────┘
```
- Green border when selected
- Check icon appears
- Bold text for selection

### **Custom Efficiency Toggle**
```
Eficiência de Campo           Usar padrão ⚪─────
                                         ───────⚫
┌────────────────────────────────────────────────┐
│ ℹ️  Eficiência padrão de 75% para operações   │
│     de preparo de solo                        │
└────────────────────────────────────────────────┘

                             OR

Eficiência de Campo           Usar padrão ⚫─────
                                         ───────⚪
┌─────────────────────────────┐
│ Eficiência Customizada  80 %│
└─────────────────────────────┘
```

### **Input Fields**
```
┌─────────────────────────────┐
│ Largura de Trabalho     6 m │
└─────────────────────────────┘

┌─────────────────────────────┐
│ Velocidade de Trabalho 6 km/h│
└─────────────────────────────┘
```
- Dark background
- Green focus border
- Clear validation messages

## 📱 Responsive Layout

### **Mobile (< 600px)**
- Stacked inputs vertically
- Full-width operation chips
- Compact result cards

### **Tablet/Desktop (> 600px)**
- Side-by-side inputs
- Inline operation chips
- Maximum content width: 800px

## 🚀 Performance

### **Calculation Speed**
- Instant (< 1ms) - Pure Dart calculations
- No network requests
- No database queries

### **State Management**
- Riverpod notifier updates UI automatically
- Form validation on every keystroke
- Result updates on button press

## 📊 Validation Examples

### **✅ Valid Inputs**
```dart
Width: 6.0m
Speed: 6.0 km/h
Efficiency: 70%
Operation: Plantio
→ ✓ Calculation successful
```

### **❌ Invalid Inputs**

**Width too large:**
```dart
Width: 60m
→ ✗ Erro: "Largura de trabalho não pode ser maior que 50 metros"
```

**Speed too high:**
```dart
Speed: 35 km/h
→ ✗ Erro: "Velocidade não pode ser maior que 30 km/h"
```

**Invalid efficiency:**
```dart
Efficiency: 150%
→ ✗ Erro: "Eficiência deve estar entre 0 e 100%"
```

## 🔗 Integration Path

To add this calculator to your app navigation:

```dart
// In agriculture_selection_page.dart
CalculatorCard(
  title: 'Capacidade de Campo',
  description: 'Calcule a capacidade operacional de máquinas',
  icon: Icons.agriculture,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const FieldCapacityCalculatorPage(),
    ),
  ),
),
```

---

**Ready to use!** 🎉
