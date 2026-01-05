# Padrão de Padding - App Petiveti

## 🎯 Regra Geral
**Todos os elementos de primeira camada devem ter 8px de distância das bordas do dispositivo**

## 📐 Padrões Estabelecidos

### 1. Headers (PetivetiPageHeader)
```dart
// ✅ JÁ TEM PADDING EMBUTIDO - NÃO precisa de wrapper
PetivetiPageHeader(
  icon: Icons.pets,
  title: 'Título',
  subtitle: 'Subtítulo',
)
// Padding interno: EdgeInsets.fromLTRB(8, 8, 8, 0)
```

### 2. Conteúdo após Header
```dart
// ✅ Use PetivetiContentPadding para seções
PetivetiContentPadding(
  child: YourContentWidget(),
)
// Padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)
```

### 3. Elementos Soltos (sem header)
```dart
// ✅ Use PetivetiPagePadding
PetivetiPagePadding(
  child: YourWidget(),
)
// Padding: EdgeInsets.all(8)
```

## 🔧 Widgets Disponíveis

### `PetivetiPagePadding`
Wrapper geral com padding customizável
```dart
PetivetiPagePadding(
  horizontal: 8.0,  // padrão
  vertical: 8.0,    // padrão
  top: 12.0,        // opcional
  bottom: 0.0,      // opcional
  child: child,
)
```

### `PetivetiContentPadding`
Para conteúdo de páginas (após header)
```dart
PetivetiContentPadding(
  vertical: 8.0,  // customizável
  child: child,
)
// Sempre usa horizontal: 8.0
```

## ❌ Anti-padrões (EVITAR)

```dart
// ❌ NÃO USE valores diferentes
Padding(padding: EdgeInsets.all(16))  // ERRADO - deve ser 8
Padding(padding: EdgeInsets.all(12))  // ERRADO - deve ser 8

// ❌ NÃO ENVOLVA Header com Padding extra
Padding(
  padding: EdgeInsets.all(8),
  child: PetivetiPageHeader(...),  // Header JÁ TEM padding
)

// ✅ CORRETO - Header sozinho
PetivetiPageHeader(...)
```

## 📋 Estrutura de Página Padrão

```dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header - SEM wrapper de padding
            PetivetiPageHeader(
              icon: Icons.pets,
              title: 'Título',
              subtitle: 'Subtítulo',
            ),
            
            // Seletor de Animal (se necessário)
            PetivetiPagePadding(
              top: 12.0,
              bottom: 0.0,
              child: EnhancedAnimalSelector(...),
            ),
            
            // Conteúdo principal
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {},
                child: ListView(
                  padding: EdgeInsets.all(8),  // ✅ Padding no ListView
                  children: [...],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔄 Migration Checklist

Para padronizar páginas existentes:

- [ ] Verificar se Header está sem wrapper extra de Padding
- [ ] Substituir `EdgeInsets.all(16)` por `EdgeInsets.all(8)`
- [ ] Substituir `EdgeInsets.symmetric(horizontal: 16)` por `...horizontal: 8`
- [ ] Usar `PetivetiContentPadding` para seções após header
- [ ] Garantir que ListViews/Grids usem `padding: EdgeInsets.all(8)`
- [ ] Testar em diferentes tamanhos de tela

## 📱 Páginas a Padronizar

- [ ] home_page.dart
- [ ] animals_page.dart  
- [ ] appointments_page.dart
- [ ] medications_page.dart
- [ ] vaccines_page.dart
- [ ] weight_page.dart
- [ ] expenses_page.dart
- [ ] settings_page.dart
- [ ] tools_page.dart
- [ ] calculators_page.dart
