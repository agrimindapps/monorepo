# PetiVeti Theme System

## 🎨 Sistema de Cores Unificado

O PetiVeti utiliza um sistema de cores baseado na identidade visual das páginas de login e promoção, garantindo consistência visual em todo o aplicativo.

### Cores Principais

```dart
// Roxo - Cor primária da marca
AppColors.primary         // #6A1B9A (Purple 800)
AppColors.primaryLight    // #9C4DCC (Purple 400) 
AppColors.primaryDark     // #4A148C (Purple 900)

// Azul - Cor secundária/accent
AppColors.secondary       // #03A9F4 (Light Blue 500)
AppColors.secondaryLight  // #40C4FF (Light Blue 400)
AppColors.secondaryDark   // #0288D1 (Light Blue 600)
```

### Gradientes

```dart
// Gradiente primário (headers, login, cards especiais)
AppColors.primaryGradient // [primary, primaryDark]

// Gradiente secundário (destaques suaves)
AppColors.secondaryGradient // [secondaryLight, secondary]
```

### Cores Semânticas

```dart
// Success (Verde médico/veterinário)
AppColors.success         // #4CAF50
AppColors.successLight    // #81C784
AppColors.successDark     // #388E3C

// Warning
AppColors.warning         // #FF9800
AppColors.warningLight    // #FFB74D
AppColors.warningDark     // #F57C00

// Error
AppColors.error           // #F44336
AppColors.errorLight      // #E57373
AppColors.errorDark       // #D32F2F

// Info
AppColors.info            // Same as secondary blue
```

### Cores por Feature

```dart
AppColors.petProfilesColor    // Purple (profiles)
AppColors.vaccinesColor       // Red 600 (vacinas)
AppColors.medicationsColor    // Green 700 (medicamentos)
AppColors.weightControlColor  // Orange 700 (peso)
AppColors.appointmentsColor   // Blue 600 (consultas)
AppColors.remindersColor      // Teal 700 (lembretes)
```

## 🛠️ Como Usar

### 1. Usar o Tema Automático (Recomendado)

```dart
// Os widgets padrão já usam as cores automaticamente
ElevatedButton(
  onPressed: () {},
  child: Text('Botão'), // Já usa AppColors.primary
)

Card(
  child: Text('Card'), // Já usa AppColors.surface
)
```

### 2. Usar Cores Específicas

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: AppColors.primaryGradient),
  ),
  child: Text(
    'Header',
    style: TextStyle(color: AppColors.textOnPrimary),
  ),
)
```

### 3. Ícones com Cores Temáticas

```dart
// Ícone principal (roxo)
Icon(Icons.pets, color: AppColors.primary)

// Ícone secundário (azul)
Icon(Icons.info, color: AppColors.secondary)

// Ícone por feature
Icon(Icons.vaccines, color: AppColors.vaccinesColor)
```

## 📱 Componentes com Tema Customizado

### PetFormDialog
- Header com gradiente roxo
- Botões com cores da marca
- Ícones de campo em azul

### FormSectionWidget
- Ícones de seção em roxo
- Títulos com cores padrão

### Bottom Navigation
- Selecionado: roxo
- Não selecionado: cinza médio

## 🌙 Tema Escuro

O sistema suporta tema escuro automaticamente:
- Roxo mais claro no modo escuro
- Superfícies escuras padronizadas
- Contraste otimizado

## 📏 Diretrizes de Uso

1. **Use o tema automático** sempre que possível
2. **Cores específicas** apenas quando necessário
3. **Gradientes** para headers e elementos especiais
4. **Cores por feature** para ícones específicos
5. **Consistência** em todo o app

## 🔄 Migração de Código Legado

Se você encontrar códigos com cores hardcoded, substitua por:

```dart
// ❌ Antes
color: Color(0xFF4CAF50)

// ✅ Depois  
color: AppColors.primary

// ❌ Antes
color: Colors.blue

// ✅ Depois
color: AppColors.secondary
```

## 🎯 Exemplos Práticos

### Dialog Header
```dart
decoration: BoxDecoration(
  gradient: LinearGradient(
    colors: AppColors.primaryGradient,
  ),
)
```

### Status Badge
```dart
Container(
  color: AppColors.success,
  child: Text(
    'Ativo',
    style: TextStyle(color: AppColors.textOnPrimary),
  ),
)
```

### Feature Card
```dart
Card(
  child: ListTile(
    leading: Icon(
      Icons.vaccines, 
      color: AppColors.vaccinesColor,
    ),
    title: Text('Vacinas'),
  ),
)
```